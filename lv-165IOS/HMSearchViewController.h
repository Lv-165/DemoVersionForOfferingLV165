//
//  HMSearchViewController.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 11/30/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const showPlaceNotificationCenter;
extern NSString* const showPlaceNotificationCenterInfoKey;

typedef enum : NSUInteger {
    placesFromSearchBar = 0,
    placeFromFavourite,
    placeFromHistory
} dataPlaceFrom;

@interface HMSearchViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic)dataPlaceFrom idicator;

@end
