//
//  HMCoreDataManager.m
//  lv-165IOS
//
//  Created by AG on 11/27/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMCoreDataManager.h"
#import "NSNumber+HMNumber.h"
#import "Place.h"
#import "Description.h"
#import "Comments.h"
#import "DescriptionInfo.h"
#import "Comments.h"
#import "User.h"
#import "Waiting.h"

@implementation HMCoreDataManager

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+ (HMCoreDataManager*) sharedManager {
    
    static HMCoreDataManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HMCoreDataManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Save Objects

- (void) saveCountriesToCoreDataWithNSArray:(NSArray*) countryArray {
    
    NSLog(@"saveContinentsToCoreDataWithNSArray");

    for (NSDictionary *dict in countryArray) {
        
        Countries *countries =
        [NSEntityDescription insertNewObjectForEntityForName:@"Countries"
                                      inManagedObjectContext:[self managedObjectContext]];
        
        countries.iso = [dict objectForKey:@"iso"];
        countries.name = [dict objectForKey:@"name"];
        NSInteger tempInteger = [[dict valueForKey:@"places"] doubleValue];
        countries.places = [NSNumber numberWithInteger:tempInteger];
    }
    
    [self saveContext];
}

- (void) savePlaceToCoreDataWithNSArray:(NSDictionary*) placeNSDictionary
                              contries:(Countries*)countries {
    
    //NSLog(@"savePlaceToCoreDataWithNSArray");
    
    Place* place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"                                                              inManagedObjectContext:[self managedObjectContext]];
        
    NSInteger tempInteger = [[placeNSDictionary valueForKey:@"id"] integerValue];
     place.id = [NSNumber numberWithInteger:tempInteger];
    
    NSInteger ratInteger = [[placeNSDictionary valueForKey:@"rating"] integerValue];
    place.rating = [NSNumber numberWithInteger:ratInteger];
    
    NSInteger comCountInteger = [[placeNSDictionary valueForKey:@"comments_count"] integerValue];
    place.comments_count = [NSNumber numberWithInteger:comCountInteger];
    
    NSInteger ratCountInteger = [[placeNSDictionary valueForKey:@"rating_count"] integerValue];
    place.rating_count = [NSNumber numberWithInteger:ratCountInteger];
    
    double lonDounble = [[placeNSDictionary valueForKey:@"lon"] doubleValue];
     place.lon = [NSNumber numberWithDouble:lonDounble];
    
    double latDounble = [[placeNSDictionary valueForKey:@"lat"] doubleValue];
    place.lat = [NSNumber numberWithDouble:latDounble];
    
    User* user =
    [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                  inManagedObjectContext:[self managedObjectContext]];
    
    NSDictionary *userDictionary = [placeNSDictionary objectForKey:@"user"];
    
    NSInteger userID = [[userDictionary valueForKey:@"id"] integerValue];
    user.id = [NSNumber numberWithInteger:userID];
    user.name = [userDictionary valueForKey:@"name"];
    place.user = user;
    
    Description *descriptionObj = [NSEntityDescription insertNewObjectForEntityForName:@"Description"
                                                                inManagedObjectContext:[self managedObjectContext]];
    NSDictionary *descriptionDictionary = [placeNSDictionary objectForKey:@"description"];
   
    NSString *langString =  [NSString stringWithFormat:@"%@", [descriptionDictionary allKeys]];
    NSString *empty = @"";
    NSString *finalString = [langString stringByReplacingOccurrencesOfString:@" " withString:empty];
    NSString *String1 = [finalString stringByReplacingOccurrencesOfString:@"\n" withString:empty];
    NSString *String2 = [String1 stringByReplacingOccurrencesOfString:@"(\"" withString:empty];
    NSString *String3 = [String2 stringByReplacingOccurrencesOfString:@"\"" withString:empty];
    NSString *String4 = [String3 stringByReplacingOccurrencesOfString:@")" withString:empty];
    descriptionObj.language = String4;
    NSDictionary *descriptionDict = [descriptionDictionary objectForKey:[NSString stringWithFormat:@"%@",descriptionObj.language]];
    
    if (![[descriptionDictionary allKeys]containsObject:String4]) {
        descriptionObj.descriptionString = @"No Description";
        descriptionObj.language = @"en_UK";
        descriptionObj.datetime = nil;
        descriptionObj.versions = @1;
        descriptionObj.fk_user = @"";
    } else {
        
        descriptionObj.descriptionString = [NSString stringWithFormat:@"%@",[descriptionDict objectForKey:@"description"]];

        NSLog(@"id %@",place.id);
        NSLog(@"language %@",descriptionObj.language);
        
        
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [df setTimeZone:[NSTimeZone systemTimeZone]];
        [df setFormatterBehavior:NSDateFormatterBehaviorDefault];
        NSDate *theDate = [df dateFromString:[NSString stringWithFormat:@"%@",[descriptionDict objectForKey:@"datetime"]]];
        //        NSLog(@"date: %@", theDate);
        descriptionObj.datetime = theDate;
        
        NSInteger versionCountInteger = [[descriptionDict valueForKey:@"versions"] integerValue];
        descriptionObj.versions = [NSNumber numberWithInteger:versionCountInteger];
        descriptionObj.fk_user = [NSString stringWithFormat:@"%@",[descriptionDict objectForKey:@"fk_user"]];
    }
    
    NSLog(@"descriptionString %@",descriptionObj.descriptionString);
    descriptionObj.place = place;
    [place setDescript:descriptionObj];// trouble
    
    if (comCountInteger) {
        
        NSArray *array = [placeNSDictionary objectForKey:@"comments"];
        for (NSDictionary *coment in array) {
            Comments *comment =
            [NSEntityDescription insertNewObjectForEntityForName:@"Comments"
                                                              inManagedObjectContext:[self managedObjectContext]];
            comment.comment = [coment valueForKey:@"comment"];
            NSInteger commentId = [[placeNSDictionary valueForKey:@"comments_count"] integerValue];
            comment.id = [NSNumber numberWithInteger:commentId];
            
            NSDictionary *userArray = [coment objectForKey:@"user"];
            User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                              inManagedObjectContext:[self managedObjectContext]];
            
            NSInteger userId = [[userArray valueForKey:@"id"] integerValue];
            user.id = [NSNumber numberWithInteger:userId];
            user.name = [userArray valueForKey:@"name"];
            
            comment.user = user;
            [place addCommentsObject:comment];
        }
    }
  
    Waiting *waiting = [NSEntityDescription insertNewObjectForEntityForName:@"Waiting"
                                                     inManagedObjectContext:[self managedObjectContext]];
    
    NSDictionary *waitingDictionary = [placeNSDictionary objectForKey:@"waiting_stats"];
    
    waiting.avg = [NSNumber numberFromValue:[waitingDictionary valueForKey:@"avg"]];
    waiting.avg_textual = [NSString stringWithFormat:@"%@",[waitingDictionary valueForKey:@"avg_textual"]];
    
    place.waiting = waiting;
    [countries addPlaceObject:place];

    [self saveContext];
}

- (void) deleteAllObjects {
    
    NSArray* allObjects = [self allObjects];
    
    for (id object in allObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    [self.managedObjectContext save:nil];
}

#pragma mark - Get Objects

- (NSArray *) getPlaceWithStringId:(NSString *) stringId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", stringId];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = predicate;
    
    return [[self managedObjectContext] executeFetchRequest:request
                                                      error:nil];
}

- (NSArray *) getPlaceWithStartRating:(NSString *)startRating endRating:(NSString *)endRating {
    
    NSPredicate* ratingPredicate = [NSPredicate predicateWithFormat:@"%@ => rating  AND rating >= %@",startRating, endRating];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    
    [fetchRequest setPredicate:ratingPredicate];
    
    return [[self managedObjectContext] executeFetchRequest:fetchRequest
                                               error:nil];
}

- (NSArray *) getPlaceWithCommentsStartRating:(NSString *)startRating endRating:(NSString *)endRating {
    
    NSPredicate* ratingPredicate = [NSPredicate predicateWithFormat:@"%@ => rating  AND rating >= %@",startRating, endRating];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    
//    NSPredicate* commentsCountPredicate = [NSPredicate predicateWithFormat:@"comments_count > %@",@0];
     NSPredicate* commentsCountPredicate = [NSPredicate predicateWithFormat:@"comments_count > %@ OR SUBQUERY(descript,$description,$description.descriptionString.length > %@).@count != 0",@0,@0];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:ratingPredicate, commentsCountPredicate, nil]];
    
    [fetchRequest setPredicate:compoundPredicate];
    
    return [[self managedObjectContext] executeFetchRequest:fetchRequest
                                                      error:nil];
}

#pragma mark - Print Objects

- (void) printCountryA{
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"Country"
                inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@", @"A"];
    [request setPredicate:predicate];
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    NSLog(@"Print Country Entities %@",resultArray);
}

- (NSArray*) allObjects {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"HMCoreDataObjects"
                inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.lv_165IOS" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"lv_165IOS" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"lv_165IOS.sqlite"];
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
