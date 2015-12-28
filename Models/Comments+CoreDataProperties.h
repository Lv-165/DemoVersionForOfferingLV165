//
//  Comments+CoreDataProperties.h
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/28/15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comments.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comments (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *comment;
@property (nullable, nonatomic, retain) NSDate *datetime;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) Place *place;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
