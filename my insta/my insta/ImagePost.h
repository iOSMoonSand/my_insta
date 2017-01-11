//
//  ImagePost.h
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ImageDownloadState) {
    NeedsImage = 0,
    DownloadInProgress = 1,
    NonRecoverableError = 2,
    HasImage = 3
};

@class User;

@interface ImagePost : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, assign) ImageDownloadState downloadState;

- (instancetype)initWith: (NSDictionary *)postDict;

@end
