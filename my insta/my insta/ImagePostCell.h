//
//  ImagePostCell.h
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImagePost;

@interface ImagePostCell : UITableViewCell

@property (nonatomic, strong) ImagePost *post;

- (void) performWith: (ImagePost *)item;

@end
