//
//  ImagesHomeVC.m
//  my insta
//
//  Created by Alexis Schreier on 01/04/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "ImagesHomeVC.h"

@interface ImagesHomeVC ()
#pragma mark
#pragma mark - Properties
#pragma mark
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *images;
@end

@implementation ImagesHomeVC
#pragma mark
#pragma mark - UIViewController Methods
#pragma mark
- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = [NSMutableArray array];
    for (int i = 1; i <= 10; i++) {
        NSString *imageName = [NSString stringWithFormat: @"%d.jpg", i];
        UIImage *image = [UIImage imageNamed: imageName];
        if (image) {
            [self.images addObject: image];
        }
    }
}
#pragma mark
#pragma mark - UITableViewDelegate, UITableViewDataSource Methods
#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
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
    UIImage *image = self.images[indexPath.row];
    imageView.image = image;
    return cell;
}
@end










