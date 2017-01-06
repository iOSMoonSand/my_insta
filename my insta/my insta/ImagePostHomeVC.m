//
//  ImagePostHomeVC.m
//  my insta
//
//  Created by Alexis Schreier on 01/05/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import "DataSource.h"
#import "ImagePostHomeVC.h"
#import "ImagePost.h"
#import "ImagePostCell.h"

@interface ImagePostHomeVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ImagePostHomeVC
#pragma mark
#pragma mark - UIViewController Methods
#pragma mark
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 480;
    
}
#pragma mark
#pragma mark - UITableViewDelegate, UITableViewDataSource Methods
#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataSource shared].imagePosts.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImagePostCell *cell = [tableView dequeueReusableCellWithIdentifier: @"ImagePostCell" forIndexPath:indexPath];
    cell.post = [DataSource shared].imagePosts[indexPath.row];
    [cell performWith: cell.post];
    return cell;
}
@end
