//
//  HMGoogleDirectionsViewController.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/23/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Place;

@interface HMGoogleDirectionsViewController : UIViewController

@property (strong, nonatomic) Place *place;

@property (weak, nonatomic) IBOutlet UITextView *textViewForGoogleDirections;

@property (strong, nonatomic) NSString *textForLabel;

- (IBAction)actionSave:(id)sender;

@end
