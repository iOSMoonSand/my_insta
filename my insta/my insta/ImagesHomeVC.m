//
//  ImagesHomeVC.m
//  my insta
//
//  Created by Alexis Schreier on 01/04/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "DataSource.h"
#import "ImagesHomeVC.h"
#import "ImagePost.h"

@interface ImagesHomeVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ImagesHomeVC
#pragma mark
#pragma mark - UIViewController Methods
#pragma mark
- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark
#pragma mark - UITableViewDelegate, UITableViewDataSource Methods
#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataSource shared].imagePosts.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"imageCell" forIndexPath: indexPath];
    static NSInteger imageViewTag = 1234;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag: imageViewTag];
    if (!imageView) {
        //cell.contentView has not return an image with the imageTag so it's a new cell
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.frame = cell.contentView.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.tag = imageViewTag;
        [cell.contentView addSubview: imageView];
    }
    ImagePost *post = [DataSource shared].imagePosts[indexPath.row];
    imageView.image = post.image;
    return cell;
}
@end










