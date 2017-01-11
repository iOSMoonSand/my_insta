//
//  DataSource.m
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import <AFNetworking.h>
#import <UICKeyChainStore.h>

#import "Comment.h"
#import "DataSource.h"
#import "ImagePost.h"
#import "InstgrmLoginVC.h"
#import "User.h"

@interface DataSource () {
    NSMutableArray *_imagePosts;
}

@property (nonatomic, strong) NSArray *imagePosts;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) AFHTTPRequestOperationManager *instgrmOperationMgr;

@end

@implementation DataSource
#pragma mark
#pragma mark: Class Methods
#pragma mark
+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

+ (NSString *)instgrmClientID {
    return @"d82058321dcf406da8b36db211d2f442";
}
#pragma mark
#pragma mark: Initialization Override Methods
#pragma mark
- (instancetype)init {
    self = [super init];
    if (self) {
        [self createOperationMgr];
        self.accessToken = [UICKeyChainStore stringForKey: @"access token"];
//        self.accessToken = nil;
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathFor:NSStringFromSelector(@selector(imagePosts))];
                NSArray *storedImagePosts = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedImagePosts.count > 0) {
                        NSMutableArray *mutableImagePosts = [storedImagePosts mutableCopy];
                        [self willChangeValueForKey:@"imagePosts"];
                        self.imagePosts = mutableImagePosts;
                        [self didChangeValueForKey:@"imagePosts"];
                    } else {
                        [self retrieveJsonDataWith: nil completion: nil];
                    }
                });
            });
        }
    }
    return self;
}
#pragma mark
#pragma mark: Notification Registration
#pragma mark
- (void)registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName: InstgrmLoginVCDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        [UICKeyChainStore setString: self.accessToken forKey: @"access token"];
        [self retrieveJsonDataWith: nil completion: nil];
    }];
}
#pragma mark
#pragma mark: Networking Methods
#pragma mark
- (void)createOperationMgr {
    NSURL *baseURL = [NSURL URLWithString: @"https://api.instagram.com/v1/"];
    self.instgrmOperationMgr = [[AFHTTPRequestOperationManager alloc] initWithBaseURL: baseURL];
    AFJSONResponseSerializer *jsonRespSerializer = [AFJSONResponseSerializer serializer];
    AFImageResponseSerializer *imgRespSerializer = [AFImageResponseSerializer serializer];
    imgRespSerializer.imageScale = 1.0;
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers: @[jsonRespSerializer, imgRespSerializer]];
    self.instgrmOperationMgr.responseSerializer = serializer;
}

- (void)retrieveJsonDataWith:(NSDictionary *)parameters completion: (NewItemsCompletion)completion {
    if (self.accessToken) {
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        [mutableParameters addEntriesFromDictionary: parameters];
        [self.instgrmOperationMgr GET:@"users/self/media/recent"
                           parameters:mutableParameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                      [self parseFeedDictionary: responseObject fromRequestWith: parameters];
                                  }
                                  if (completion) {
                                      completion(nil);
                                  }
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  if (completion) {
                                      completion(error);
                                  }
                              }];
    }
}

- (void)parseFeedDictionary: (NSDictionary *)feedDict fromRequestWith: (NSDictionary *)parameters {
    NSArray *postsArray = feedDict[@"data"];
    NSMutableArray *tmpPostsArray = [NSMutableArray array];
    for (NSDictionary *postDict in postsArray) {
        ImagePost *post = [[ImagePost alloc] initWith: postDict];
        if (post) {
            [tmpPostsArray addObject: post];
        }
    }
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"imagePosts"];
    if (parameters[@"min_id"]) {
        NSRange rangeOfIndexes = NSMakeRange(0, tmpPostsArray.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
#pragma mark: TODO check if data is being updated
        [mutableArrayWithKVO replaceObjectsAtIndexes: indexSetOfNewObjects withObjects: tmpPostsArray];
        //        [mutableArrayWithKVO insertObjects: tmpPostsArray atIndexes:indexSetOfNewObjects];
    } else {
        [self willChangeValueForKey: @"imagePosts"];
        self.imagePosts = tmpPostsArray;
        [self didChangeValueForKey: @"imagePosts"];
    }
    [self saveImages];
}

- (void) downloadImageFor:(ImagePost *)post {
    if (post.imageURL && !post.image) {
        post.downloadState = DownloadInProgress;
        [self.instgrmOperationMgr GET:post.imageURL.absoluteString
                           parameters:nil
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if ([responseObject isKindOfClass:[UIImage class]]) {
                                      post.image = responseObject;
                                      post.downloadState = HasImage;
                                      NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"imagePosts"];
                                      NSUInteger index = [mutableArrayWithKVO indexOfObject:post];
                                      [mutableArrayWithKVO replaceObjectAtIndex:index withObject:post];
                                      [self saveImages];
                                  } else {
                                      post.downloadState = NonRecoverableError;
                                  }
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  NSLog(@"Error downloading image: %@", error);
                                  post.downloadState = NonRecoverableError;
                                  if ([error.domain isEqualToString: NSURLErrorDomain]) {
                                      if (error.code == NSURLErrorTimedOut ||
                                          error.code == NSURLErrorCancelled ||
                                          error.code == NSURLErrorCannotConnectToHost ||
                                          error.code == NSURLErrorNetworkConnectionLost ||
                                          error.code == NSURLErrorNotConnectedToInternet ||
                                          error.code == kCFURLErrorInternationalRoamingOff ||
                                          error.code == kCFURLErrorCallIsActive ||
                                          error.code == kCFURLErrorDataNotAllowed ||
                                          error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                          post.downloadState = NeedsImage;
                                      }
                                  }
                              }];
    }
}
#pragma mark
#pragma mark: Persistence to Disk Methods
#pragma mark
- (NSString *)pathFor: (NSString *)fileName {
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [pathsArray firstObject];
    NSString *filePath = [docsDir stringByAppendingPathComponent: fileName];
    return filePath;
}

- (void)saveImages {
    if (self.imagePosts.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger postsToSaveCount = MIN(self.imagePosts.count, 50);
            NSArray *postsToSave = [self.imagePosts subarrayWithRange: NSMakeRange(0, postsToSaveCount)];
            NSString *fullPath = [self pathFor: NSStringFromSelector(@selector(imagePosts))];
            NSData *postData = [NSKeyedArchiver archivedDataWithRootObject: postsToSave];
            NSError *dataError;
            BOOL wroteSuccessfully = [postData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
    }
}
#pragma mark
#pragma mark: Key/Value Observing Methods
#pragma mark
- (NSUInteger)countOfImagePosts {
    return self.imagePosts.count;
}

- (id)objectInImagePostsAtIndex:(NSUInteger)index {
    return [self.imagePosts objectAtIndex: index];
}

- (NSArray *)imagePostsAtIndexes:(NSIndexSet *)indexes {
    return [self.imagePosts objectsAtIndexes: indexes];
}

- (void)insertObject:(ImagePost *)object inImagePostsAtIndex:(NSUInteger)index {
    [_imagePosts insertObject: object atIndex: index];
}

- (void)removeObjectFromImagePostsAtIndex:(NSUInteger)index {
    [_imagePosts removeObjectAtIndex: index];
}

- (void)replaceObjectInImagePostsAtIndex:(NSUInteger)index withObject:(id)object {
    [_imagePosts replaceObjectAtIndex: index withObject: object];
}
#pragma mark
#pragma mark: Pull to Refresh Methods
#pragma mark
- (void)requestNewItemsWith:(NewItemsCompletion)completion {
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        NSString *minID = [[self.imagePosts firstObject] idNumber];
        NSDictionary *parameters;
        if (minID) {
            parameters = @{@"min_id": minID};
        }
        [self retrieveJsonDataWith: parameters completion:^(NSError *error) {
            self.isRefreshing = NO;
            if (completion) {
                completion(error);
            }
        }];
    }
}

@end










