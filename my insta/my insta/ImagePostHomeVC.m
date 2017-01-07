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
    [[DataSource shared] addObserver: self forKeyPath: @"imagePosts" options: 0 context: nil];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget: self action: @selector(didPullToRefresh:) forControlEvents: UIControlEventValueChanged];
    [self.tableView addSubview: refresh];
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

- (void)didPullToRefresh: (UIRefreshControl *)sender {
    [[DataSource shared] requestNewItemsWith:^(NSError *error) {
        [sender endRefreshing];
    }];
}
#pragma mark
#pragma mark - Key/Value Observer Methods
#pragma mark
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == [DataSource shared] && [keyPath isEqualToString: @"imagePosts"]) {
        NSKeyValueChange changeValue = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (changeValue == NSKeyValueChangeSetting) {
            //entire array of imagePosts has been replaced
            [self.tableView reloadData];
        } else if (changeValue == NSKeyValueChangeInsertion ||
                   changeValue == NSKeyValueChangeRemoval ||
                   changeValue == NSKeyValueChangeReplacement) {
            //incremental change: do not reload entire array
            //create an array of indexPaths that changed
            NSIndexSet *changedIndexesSet = change[NSKeyValueChangeIndexesKey];
            NSMutableArray *changedIndexesArray = [NSMutableArray array];
            [changedIndexesSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow: idx inSection: 0];
                [changedIndexesArray addObject: indexPath];
            }];
            [self.tableView beginUpdates];
            //specify what the changes are and update the array (animated)
            if (changeValue == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths: changedIndexesArray withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            if (changeValue == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths: changedIndexesArray withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            if (changeValue == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:changedIndexesArray withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView endUpdates];
        }
    }
}
#pragma mark
#pragma mark - Dealloc
#pragma mark
- (void)dealloc {
    [[DataSource shared] removeObserver: self forKeyPath: @"imagePosts"];
}
@end
