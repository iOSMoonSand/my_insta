//
//  DataSource.m
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "Comment.h"
#import "DataSource.h"
#import "ImagePost.h"
#import "User.h"

@interface DataSource () {
    NSMutableArray *_imagePosts;
}

@property (nonatomic, strong) NSArray *imagePosts;
@property (nonatomic, assign) BOOL isRefreshing;

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
#pragma mark
#pragma mark: Initialization Override Methods
#pragma mark
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addRandomData];
    }
    return self;
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
        
        //access Instagram API to pull new data
        //if there is new data, place at index 0 of imagePosts
        //may need to go back in curriculum ans make array KVC (Ch 31)
        
        self.isRefreshing = NO;
        
    }
}
#pragma mark
#pragma mark: Random Data Creation Methods
#pragma mark
- (void) addRandomData {
    NSMutableArray *randomImagePosts = [NSMutableArray array];
    for (int i = 1; i <= 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            ImagePost *post = [[ImagePost alloc] init];
            post.user = [self createRandomUser];
            post.image = image;
            post.caption = [self createRandomSentence];
            NSUInteger commentCount = arc4random_uniform(10) + 2;
            NSMutableArray *randomComments = [NSMutableArray array];
            for (int i  = 0; i <= commentCount; i++) {
                Comment *randomComment = [self createRandomComment];
                [randomComments addObject: randomComment];
            }
            post.comments = randomComments;
            [randomImagePosts addObject: post];
        }
    }
    self.imagePosts = randomImagePosts;
}

- (User *)createRandomUser {
    User *user = [[User alloc] init];
    user.username = [self createRandomStringOfLength:arc4random_uniform(10) + 2];
    NSString *firstName = [self createRandomStringOfLength:arc4random_uniform(7) + 2];
    NSString *lastName = [self createRandomStringOfLength:arc4random_uniform(12) + 2];
    user.fullName = [NSString stringWithFormat: @"%@ %@", firstName, lastName];
    return user;
}

- (Comment *)createRandomComment {
    Comment *comment = [[Comment alloc] init];
    comment.author = [self createRandomUser];
    comment.text = [self createRandomSentence];
    return comment;
}

- (NSString *)createRandomSentence {
    NSUInteger wordCount = arc4random_uniform(20) + 2;
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    for (int i  = 0; i <= wordCount; i++) {
        NSString *randomWord = [self createRandomStringOfLength:arc4random_uniform(12) + 2];
        [randomSentence appendFormat:@"%@ ", randomWord];
    }
    return randomSentence;
}

- (NSString *) createRandomStringOfLength:(NSUInteger) len {
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return [NSString stringWithString:s];
}

@end










