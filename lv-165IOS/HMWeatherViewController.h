//
//  HMWeatherViewController.h
//  lv-165IOS
//
//  Created by User on 26.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+LBBlurredImage.h"

@interface HMWeatherViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSDictionary *weatherDict;
@property (strong, nonatomic) NSArray *daysWeather;

@end
