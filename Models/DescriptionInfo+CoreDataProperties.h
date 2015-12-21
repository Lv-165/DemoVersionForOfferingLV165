//
//  DescriptionInfo+CoreDataProperties.h
//  lv-165IOS
//
//  Created by Yurii Huber on 21.12.15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DescriptionInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface DescriptionInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *datetime;
@property (nullable, nonatomic, retain) NSString *descriptionString;
@property (nullable, nonatomic, retain) NSNumber *fk_user;
@property (nullable, nonatomic, retain) NSNumber *versions;
@property (nullable, nonatomic, retain) Description *descript;

@end

NS_ASSUME_NONNULL_END
