//
//  HMSettingsViewController.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 11/30/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMSettingsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlForMapType;
@property (strong, nonatomic) NSArray *dataSource;

- (IBAction)segmentedControlForMapTypeValueChanged:(id)sender;
- (IBAction)actionDownloadsCountries:(id)sender;

@end
