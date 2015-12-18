//
//  HMCoreDataManager.h
//  lv-165IOS
//
//  Created by AG on 11/27/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "HMServerManager.h"
#import "Countries.h"
//#import "HMCoreDataObjects.h"

@interface HMCoreDataManager : NSManagedObject 

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) printCountryA;
- (void) deleteAllObjects;

+ (HMCoreDataManager*) sharedManager;

- (void) saveCountriesToCoreDataWithNSArray:(NSArray*) countryArray;
- (void) savePlaceToCoreDataWithNSArray:(NSDictionary*) placeNSDictionary
                               contries:(Countries*)countries;
- (void) saveCountriesToCoreDataWithCountries:(Countries*) countriess;

#pragma mark - Get Objects

- (NSArray *) getPlaceWithStringId:(NSString *) stringId;
- (NSArray *) getPlaceWithStartRating:(NSString *)startRating endRating:(NSString *)endRating;
- (NSArray *) getPlaceWithCommentsStartRating:(NSString *)startRating endRating:(NSString *)endRating;

@end
