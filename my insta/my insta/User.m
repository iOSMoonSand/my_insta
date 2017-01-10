//
//  User.m
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "User.h"

@implementation User
#pragma mark
#pragma mark: Init Override
#pragma mark
- (instancetype)initWith:(NSDictionary *)userDict {
    self = [super init];
    if (self) {
        self.idNumber = userDict[@"id"];
        self.username = userDict[@"username"];
        self.fullName = userDict[@"full_name"];
        NSString *urlString = userDict[@"profile_picture"];
        NSURL *profilePicURL = [NSURL URLWithString: urlString];
        if (profilePicURL) {
            self.profilePictureURL = profilePicURL;
        }
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
        self.username = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(username))];
        self.fullName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fullName))];
        self.profilePicture = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profilePicture))];
        self.profilePictureURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profilePictureURL))];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.username forKey:NSStringFromSelector(@selector(username))];
    [aCoder encodeObject:self.fullName forKey:NSStringFromSelector(@selector(fullName))];
    [aCoder encodeObject:self.profilePicture forKey:NSStringFromSelector(@selector(profilePicture))];
    [aCoder encodeObject:self.profilePictureURL forKey:NSStringFromSelector(@selector(profilePictureURL))];
}

@end
