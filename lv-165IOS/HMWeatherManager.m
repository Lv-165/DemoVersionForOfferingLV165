//
//  HMWeatherManager.m
//  lv-165IOS
//
//  Created by AG on 12/24/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMWeatherManager.h"

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "HMMapViewController.h"
#import "Place+CoreDataProperties.h"

#import "HMWeatherManager.h"
#import "AFNetworking.h"

static NSString const *appCode = @"&appid=7ac6f2fd306b7f23df52b396c5d83ba5";
static NSString const *baseURLString = @"http://api.openweathermap.org/data/2.5/forecast?";


@interface HMWeatherManager ()

@property(strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

@end

@implementation HMWeatherManager

+ (HMWeatherManager*) sharedManager {
    
    static HMWeatherManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HMWeatherManager alloc] init];
    });
    
    return manager;
}

- (BOOL) isServerReachable {
    return self.reachability.isReachable;
}

- (void) checkServerConnection {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Status server - %i",[[HMWeatherManager sharedManager] isServerReachable]);
        [self checkServerConnection];
    });
}

- (id)init {
    self = [super init];
    if (self) {
        self.reachability = [Reachability reachabilityWithHostName:@"http://openweathermap.org"];
        [self.reachability startNotifier];
        [self checkServerConnection];
        
        self.reachability.unreachableBlock = ^void (Reachability* reachability) {
            
        };
        
        NSURL* url = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/forecast?"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}

- (void) getWeatherByCoordinate:(Place*)place
                      onSuccess:(void(^)(NSDictionary* places))success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSString *weatherCoord = [NSString stringWithFormat:@"%@lat=%.3f&lon=%.3f%@",baseURLString,[place.lat floatValue],[place.lon floatValue],appCode];
    
    [self.requestOperationManager
     GET:weatherCoord
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
     }];
}


@end