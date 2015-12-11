//
//  HMCommentsTableViewController.m
//  lv-165IOS
//
//  Created by Yurii Huber on 10.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMCommentsTableViewController.h"
#import "HMDynamicTableViewCell.h"
#import "Place.h"
#import "Description.h"
#import "Comments.h"
#import "DescriptionInfo.h"
#import "Countries.h"
#import "Comments.h"
#import "User.h"
#import <MapKit/MapKit.h>

@interface HMCommentsTableViewController ()

@property(strong, nonatomic)DescriptionInfo *descriptionInfo;

@end

static NSString* const CellIdentifier = @"DynamicTableViewCell";

@implementation HMCommentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *array = self.create.descript.allObjects;

    Description *description = [array objectAtIndex:0];
    
    self.commentsArray = self.create.comments.allObjects;
    self.descriptionInfo = description.descriptInfo;

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

# pragma mark - Cell Setup

- (void)setUpCell:(HMDynamicTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        cell.label.text = self.descriptionInfo.descriptionString;
    }
    else  if (indexPath.section >= 1){
        Comments *comments = [self.commentsArray objectAtIndex:(indexPath.section-1)];
        cell.label.text = comments.comment;
    }
}

# pragma mark - UITableViewControllerDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.descriptionInfo.descriptionString) {
        return [self.commentsArray count] + 1;
    }
    else {
        return [self.commentsArray count];
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.create.user.name == nil) {
            return @"Anonym";
        } else {
            return self.create.user.name;
        }
    }
    else if (section >= 1){
        Comments *comments = [self.commentsArray objectAtIndex:(section-1)];
        if (comments.user.name == nil) {
            return @"Anonym";
        } else {
            return comments.user.name;
        }
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HMDynamicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self setUpCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static HMDynamicTableViewCell *cell = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    });
    
    [self setUpCell:cell atIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:cell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end
