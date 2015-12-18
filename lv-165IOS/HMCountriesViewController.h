//
//  HMCountriesViewController.h
//  lv-165IOS
//
//  Created by AG on 11/28/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMCoreDataViewController.h"

@interface HMCountriesViewController : HMCoreDataViewController

- (IBAction)actionDwnloadSwitch:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *readyButton;

@end
