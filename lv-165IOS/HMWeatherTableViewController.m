//
//  HMWeatherTableViewController.m
//  lv-165IOS
//
//  Created by AG on 12/24/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMWeatherTableViewController.h"
#import "HMWeatherTableViewCell.h"

@interface HMWeatherTableViewController ()



@end

@implementation HMWeatherTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.commentsArray = self.create.comments.allObjects;
//    self.descriptionInfo = self.create.descript;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

}
- (void)setUpCell:(HMWeatherTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        cell.label.text = self.weatherDict;
//    } else  if (indexPath.section == 1){
//        Comments *comments = [self.commentsArray objectAtIndex:(indexPath.section-1)];
//        
//        NSString *str = @"Comment:";
//        
//        cell.label.text = [NSString stringWithFormat:@"%@ %@",str,comments.comment];
//    }else  if (indexPath.section > 1){
//        Comments *comments = [self.commentsArray objectAtIndex:(indexPath.section-1)];
//        cell.label.text = comments.comment;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 7;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
