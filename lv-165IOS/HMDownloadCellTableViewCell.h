//
//  HMDownloadCellTableViewCell.h
//  lv-165IOS
//
//  Created by Yurii Huber on 01.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMDownloadCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *continentsImage;
@property (weak, nonatomic) IBOutlet UILabel *continentLable;
@property (weak, nonatomic) IBOutlet UILabel *countLable;
@property (weak, nonatomic) IBOutlet UISwitch *downloadSwitch;

@end
