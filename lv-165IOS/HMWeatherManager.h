//
//  HMWeatherManager.h
//  lv-165IOS
//
//  Created by AG on 12/24/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "HMMapViewController.h"

@interface  HMWeatherManager : NSObject

@property (strong, nonatomic) Reachability* reachability;
@property (assign, nonatomic,readwrite) BOOL isServerReachable;


+ (HMWeatherManager*) sharedManager;
- (void) getWeatherByCoordinate:(Place*)place
                      onSuccess:(void(^)(NSDictionary* places))success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
