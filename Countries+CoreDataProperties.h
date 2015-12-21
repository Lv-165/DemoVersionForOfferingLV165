//
//  Countries+CoreDataProperties.h
//  lv-165IOS
//
//  Created by User on 20.12.15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Countries.h"

NS_ASSUME_NONNULL_BEGIN

@interface Countries (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *iso;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *places;
@property (nullable, nonatomic, retain) NSSet<Place *> *place;

@end

@interface Countries (CoreDataGeneratedAccessors)

- (void)addPlaceObject:(Place *)value;
- (void)removePlaceObject:(Place *)value;
- (void)addPlace:(NSSet<Place *> *)values;
- (void)removePlace:(NSSet<Place *> *)values;

@end

NS_ASSUME_NONNULL_END
