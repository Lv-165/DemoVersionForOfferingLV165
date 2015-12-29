//
//  Description+CoreDataProperties.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/28/15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Description.h"

NS_ASSUME_NONNULL_BEGIN

@interface Description (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *datetime;
@property (nullable, nonatomic, retain) NSString *descriptionString;
@property (nullable, nonatomic, retain) NSString *fk_user;
@property (nullable, nonatomic, retain) NSString *language;
@property (nullable, nonatomic, retain) NSNumber *versions;
@property (nullable, nonatomic, retain) DescriptionInfo *descriptInfo;
@property (nullable, nonatomic, retain) Place *place;

@end

NS_ASSUME_NONNULL_END
