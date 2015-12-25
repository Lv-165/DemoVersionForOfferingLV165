//
//  HMWeatherTableViewController.h
//  lv-165IOS
//
//  Created by AG on 12/24/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMWeatherTableViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *weatherDict;
@property (strong, nonatomic) NSArray *daysWeather;

@end
