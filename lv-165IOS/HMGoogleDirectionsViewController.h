//
//  HMGoogleDirectionsViewController.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/23/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMGoogleDirectionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textViewForGoogleDirections;

@property (strong, nonatomic) NSString *textForLabel;

@end
