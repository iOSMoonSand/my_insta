//
//  Comment.m
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment
#pragma mark
#pragma mark: Init Override
#pragma mark
- (instancetype)initWith:(NSDictionary *)commentDict {
    self = [super init];
    if (self) {
        self.idNumber = commentDict[@"id"];
        self.text = commentDict[@"text"];
        self.author = [[User alloc] initWith: commentDict[@"from"]];
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
        self.text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
        self.author = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(author))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];
    [aCoder encodeObject:self.author forKey:NSStringFromSelector(@selector(author))];
}

@end
