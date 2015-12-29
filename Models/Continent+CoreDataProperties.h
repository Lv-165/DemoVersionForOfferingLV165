//
//  Continent+CoreDataProperties.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/28/15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Continent.h"

NS_ASSUME_NONNULL_BEGIN

@interface Continent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) Location *location;

@end

NS_ASSUME_NONNULL_END
