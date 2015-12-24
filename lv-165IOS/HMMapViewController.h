//
//  ViewController.h
//  lv-165IOS
//
//  Created by AG on 11/23/15.
//  Copyright © 2015 AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HMCoreDataManager.h"
#import "HMServerManager.h"

extern NSString* const addToMyFavourite;
extern NSString* const addToMyFavouriteInfoKey;

@interface HMMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewToAnimate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraitToShowUpToolBar;
@property (weak, nonatomic) IBOutlet UIToolbar *upToolBar;

@property (weak, nonatomic) IBOutlet UIToolbar *downToolBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//viewForPinOfInfo
@property (weak, nonatomic) IBOutlet UIView *viewForPinOfInfo;
@property (weak, nonatomic) IBOutlet UILabel *waitingTimeLable;
@property (weak, nonatomic) IBOutlet UILabel *autorDescriptionLable;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;


@end

