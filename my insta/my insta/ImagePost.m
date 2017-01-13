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
            self.downloadState = NeedsImage;
        } else {
            self.downloadState = NonRecoverableError;
        }
        NSDictionary *captionDict = postDict[@"caption"];
        if ([captionDict isKindOfClass: [NSDictionary class]]) {
            self.caption = captionDict[@"text"];
        } else {
            self.caption = @"";
        }

        NSDictionary *commentsCountDict = postDict[@"comments"];
        if ([commentsCountDict isKindOfClass: [NSDictionary class]]) {
            self.commentsCount = [commentsCountDict[@"count"] description];
        } else {
            self.commentsCount = @"no comments... yet";
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"E, MMM, d, yyyy hh:mm a"];
        NSTimeInterval timeInterval = [postDict[@"created_time"] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate: timeInterval];
        NSString *formattedDateString = [formatter stringFromDate:date];
        self.dateCreated = formattedDateString;
        if ([postDict[@"filter"] isKindOfClass: [NSDictionary class]]) {
            self.filter = postDict[@"filter"];
        } else {
            self.likesCount = @"No Filter used.";
        }
        NSDictionary *likesCountDict = postDict[@"likes"];
        if ([likesCountDict isKindOfClass: [NSDictionary class]]) {
            self.likesCount = [likesCountDict[@"count"] description];
        } else {
            self.likesCount = @"no likes... yet";
        }
        if ([postDict[@"link"] isKindOfClass: [NSString class]]) {
            self.link = postDict[@"link"];
        } else {
            self.link = @"Error retrieving link";
        }
        if ([postDict[@"location"] isKindOfClass: [NSString class]]) {
            self.location = postDict[@"location"];
        } else {
            self.location = @"No location specified.";
        }
        NSSet *tags = [NSSet setWithObject: postDict[@"tags"]];
        NSArray *strings = [tags allObjects];
        NSString *string1 = [[[strings valueForKey:@"description"] componentsJoinedByString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *string2 = [string1 stringByReplacingOccurrencesOfString:@"(" withString:@""];
        NSString *string3 = [string2 stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSString *string4 = [string3 stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        if (string4.length == 0) {
            self.tags = @"No tags were added.";
        } else {
            self.tags = string4;
        }
        //save for addition of comments array
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
        if (self.image) {
            self.downloadState = HasImage;
        } else if (self.imageURL) {
            self.downloadState = NeedsImage;
        } else {
            self.downloadState = NonRecoverableError;
        }
        self.caption = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(caption))];
        self.comments = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(comments))];
        self.commentsCount = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(commentsCount))];
        self.dateCreated = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(dateCreated))];
        self.filter = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filter))];
        self.likesCount = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(likesCount))];
        self.link = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(link))];
        self.location = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(location))];
        self.tags = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(tags))];
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
    [aCoder encodeObject:self.commentsCount forKey:NSStringFromSelector(@selector(commentsCount))];
    [aCoder encodeObject:self.dateCreated forKey:NSStringFromSelector(@selector(dateCreated))];
    [aCoder encodeObject:self.filter forKey:NSStringFromSelector(@selector(filter))];
    [aCoder encodeObject:self.likesCount forKey:NSStringFromSelector(@selector(likesCount))];
    [aCoder encodeObject:self.link forKey:NSStringFromSelector(@selector(link))];
    [aCoder encodeObject:self.location forKey:NSStringFromSelector(@selector(location))];
    [aCoder encodeObject:self.tags forKey:NSStringFromSelector(@selector(tags))];
}
@end
