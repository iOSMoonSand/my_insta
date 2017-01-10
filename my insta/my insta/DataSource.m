//
//  DataSource.m
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

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
        self.accessToken = [UICKeyChainStore stringForKey: @"access token"];
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
                        for (ImagePost *post in self.imagePosts) {
                            [self downloadImageFor: post];
                        }
                    } else {
                        [self retrieveJsonDataWith: nil];
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
        [self retrieveJsonDataWith: nil];
    }];
}
#pragma mark
#pragma mark: JSON Serialization
#pragma mark
- (void)retrieveJsonDataWith: (NSDictionary *)parameters {
    if (self.accessToken) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableString *urlString = [NSMutableString stringWithFormat: @"https://api.instagram.com/v1/users/self/media/recent?access_token=%@", self.accessToken];
            for (NSString *parameterKey in parameters) {
                [urlString appendFormat: @"&%@=%@", parameterKey, parameters[parameterKey]];
            }
            NSURL *url = [NSURL URLWithString: urlString];
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL: url];
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &webError];
                if (responseData) {
                    NSError *jsonError;
                    NSDictionary *feedDict = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: &jsonError];
                    if (feedDict) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self parseFeedDictionary: feedDict fromRequestWith: parameters];
                        });
                    }
                }
            }
        });
    }
}

- (void)parseFeedDictionary: (NSDictionary *)feedDict fromRequestWith: (NSDictionary *)parameters {
    NSArray *postsArray = feedDict[@"data"];
    NSMutableArray *tmpPostsArray = [NSMutableArray array];
    for (NSDictionary *postDict in postsArray) {
        ImagePost *post = [[ImagePost alloc] initWith: postDict];
        if (post) {
            [tmpPostsArray addObject: post];
            [self downloadImageFor: post];
        }
    }
    [self willChangeValueForKey: @"imagePosts"];
    self.imagePosts = tmpPostsArray;
    [self didChangeValueForKey: @"imagePosts"];
    
    [self saveImages];
}

- (void) downloadImageFor:(ImagePost *)post {
    if (post.imageURL && !post.image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:post.imageURL];
            NSURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image) {
                    post.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"imagePosts"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:post];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:post];
                        [self saveImages];
                    });
                }
            } else {
                NSLog(@"Error downloading image: %@", error);
            }
        });
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
        #pragma mark TODO: refactor with Instagram API methods
        //
        //add images from Insta
        //
        self.isRefreshing = NO;
        #pragma mark TODO: refactor error handling
        //not calling an error because using dummy data for now
        if (completion) {
            completion(nil);
        }
    }
}

@end










