//
//  HMServerManager.m
//  lv-165IOS
//
//  Created by roman on 27.11.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMServerManager.h"
#import "AFNetworking.h"
#import "HMCoreDataManager.h"
#import "AFURLConnectionOperation.h"

@interface HMServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

@end


@implementation HMServerManager

+ (HMServerManager*) sharedManager {
    
    static HMServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HMServerManager alloc] init];
    });
    
    return manager;
}
- (BOOL) isServerReachable {
    return self.reachability.isReachable;
}

- (void) checkServerConnection {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Status server - %i",[[HMServerManager sharedManager] isServerReachable]);
        [self checkServerConnection];
    });
}

- (id)init {
    self = [super init];
    if (self) {
        self.reachability = [Reachability reachabilityWithHostName:@"http://hitchwiki.org/"];
        [self.reachability startNotifier];
        [self checkServerConnection];
        
        self.reachability.unreachableBlock = ^void (Reachability* reachability) {
            
        };
        NSURL* url = [NSURL URLWithString:@"http://hitchwiki.org/maps/api/"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}

- (void) getCountriesWithonSuccess:(void(^)(NSArray* countries)) success
                         onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    [self.requestOperationManager
     GET:@"?countries"
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         success(responseObject.allValues);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
    
}

- (void) getContinentsWithonSuccess:(void (^)(NSArray *))success
                          onFailure:(void (^)(NSError *, NSInteger))failure {
    
    [self.requestOperationManager
     GET:@"?continents"
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"Countries get GOOD");// вызов записи в кор дату
         success(responseObject.allValues);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

- (void) getPlacesByCountryWithISO:(NSString *)iso
                         onSuccess:(void(^)(NSDictionary* places)) success
                         onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    
    NSString* countriesForGet = [NSString stringWithFormat:@"?country=%@",iso];
    
    [self.requestOperationManager
     GET:countriesForGet
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

- (void)getPlaceWithID:(NSString *)placeID
             onSuccess:(void(^)(NSDictionary* cities)) success
             onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSString* IDplace = [NSString stringWithFormat:@"?place=%@",placeID];
    
    [self.requestOperationManager
     GET:IDplace
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

- (void)getPlaceyByName:(NSString *)cityName
              onSuccess:(void(^)(NSArray* cities)) success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSString* city = [NSString stringWithFormat:@"?city=%@",cityName];
    
    [self.requestOperationManager
     GET:city
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

- (void)getPlacesByContinentName:(NSString *)continentName
                       onSuccess:(void (^)(NSDictionary *))success
                       onFailure:(void (^)(NSError *, NSInteger))failure {
    NSString* continent = [NSString stringWithFormat:@"?continent=%@",continentName];
    
    [self.requestOperationManager
     GET:continent
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         failure(error, error.code);
         
     }];
}

- (NSManagedObjectContext* )managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[HMCoreDataManager sharedManager]managedObjectContext];
    }
    return _managedObjectContext;
    
}

@end
