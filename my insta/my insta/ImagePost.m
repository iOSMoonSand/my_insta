//
//  ImagePost.m
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "Comment.h"
#import "ImagePost.h"
#import "User.h"

@implementation ImagePost
#pragma mark
#pragma mark: Init Override
#pragma mark
- (instancetype)initWith:(NSDictionary *)postDict {
    self = [super init];
    if (self) {
        self.idNumber = postDict[@"id"];
        self.user = [[User alloc] initWith: postDict[@"user"]];
        NSString *stdResImgUrlString = postDict[@"images"][@"standard_resolution"][@"url"];
        NSURL *stdResImageURL = [NSURL URLWithString: stdResImgUrlString];
        if (stdResImageURL) {
            self.imageURL = stdResImageURL;
        }
        NSDictionary *captionDict = postDict[@"caption"];
        if ([captionDict isKindOfClass: [NSDictionary class]]) {
            self.caption = captionDict[@"text"];
        } else {
            self.caption = @"";
        }
        NSMutableArray *commentsArray = [NSMutableArray array];
        for (NSDictionary *commentDict in postDict[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWith: commentDict];
            [commentsArray addObject: comment];
        }
        self.comments = commentsArray;
    }
    return self;
}
#pragma mark
#pragma mark: NSCoding Methods
#pragma mark
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.user = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user))];
        self.imageURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageURL))];
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.user forKey:NSStringFromSelector(@selector(user))];
    [aCoder encodeObject:self.imageURL forKey:NSStringFromSelector(@selector(imageURL))];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.caption forKey:NSStringFromSelector(@selector(caption))];
    [aCoder encodeObject:self.comments forKey:NSStringFromSelector(@selector(comments))];
}
@end
