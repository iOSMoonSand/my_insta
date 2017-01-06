//
//  DataSource.h
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NewItemsCompletion)(NSError *error);

@interface DataSource : NSObject

@property (nonatomic, strong, readonly) NSArray *imagePosts;

+ (instancetype)shared;
- (void)requestNewItemsWith: (NewItemsCompletion)completion;

@end
