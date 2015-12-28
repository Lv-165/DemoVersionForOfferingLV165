//
//  DirectionBus+CoreDataProperties.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/28/15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DirectionBus.h"

NS_ASSUME_NONNULL_BEGIN

@interface DirectionBus (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *directionString;
@property (nullable, nonatomic, retain) Place *place;

@end

NS_ASSUME_NONNULL_END
