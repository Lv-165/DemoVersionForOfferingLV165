//
//  Place+CoreDataProperties.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/28/15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface Place (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *comments_count;
@property (nullable, nonatomic, retain) NSDate *datetime;
@property (nullable, nonatomic, retain) NSNumber *elevation;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *lat;
@property (nullable, nonatomic, retain) NSNumber *lon;
@property (nullable, nonatomic, retain) NSNumber *rating;
@property (nullable, nonatomic, retain) NSNumber *rating_count;
@property (nullable, nonatomic, retain) NSSet<Comments *> *comments;
@property (nullable, nonatomic, retain) Countries *countries;
@property (nullable, nonatomic, retain) Description *descript;
@property (nullable, nonatomic, retain) Location *location;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, retain) Waiting *waiting;
@property (nullable, nonatomic, retain) DirectionBus *directionBus;

@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comments *)value;
- (void)removeCommentsObject:(Comments *)value;
- (void)addComments:(NSSet<Comments *> *)values;
- (void)removeComments:(NSSet<Comments *> *)values;

@end

NS_ASSUME_NONNULL_END
