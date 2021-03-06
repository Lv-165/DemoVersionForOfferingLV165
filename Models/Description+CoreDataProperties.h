//
//  Description+CoreDataProperties.h
//  lv-165IOS
//
//  Created by Admin on 04.12.15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Description.h"

NS_ASSUME_NONNULL_BEGIN

@interface Description (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *language;
@property (nullable, nonatomic, retain) DescriptionInfo *descriptInfo;
@property (nullable, nonatomic, retain) Place *place;

@end

NS_ASSUME_NONNULL_END
