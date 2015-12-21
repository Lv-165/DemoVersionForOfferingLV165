//
//  HMFiltersViewController.h
//  lv-165IOS
//
//  Created by User on 08.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMFiltersViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *commentsSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ratingControl;
@property (weak, nonatomic) IBOutlet UIImageView *commentImage;


@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSString *commentsLanguage;


- (IBAction)actionValueChanged:(id)sender;
- (void) saveSettings;


@end
