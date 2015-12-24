//
//  HMDownloadCellTableViewCell.m
//  lv-165IOS
//
//  Created by Yurii Huber on 01.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMDownloadCellTableViewCell.h"

@implementation HMDownloadCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)downloadSwitchOn {
    self.downloadSwitch.enabled = YES;
}

- (void)downloadSwitchOff {
    self.downloadSwitch.enabled = NO;
}

@end
