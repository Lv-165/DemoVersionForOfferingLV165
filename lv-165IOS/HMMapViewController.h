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

@interface HMMapViewController
    : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,
                        UIGestureRecognizerDelegate>

@property(weak, nonatomic) IBOutlet UIToolbar *downToolBar;
@property(weak, nonatomic) IBOutlet MKMapView *mapView;

@end
