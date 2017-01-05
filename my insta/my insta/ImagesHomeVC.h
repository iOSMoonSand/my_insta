//
//  ImagesHomeVC.h
//  my insta
//
//  Created by Alexis Schreier on 01/04/17.
//  Copyright © 2017 MoonSandApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagesHomeVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
