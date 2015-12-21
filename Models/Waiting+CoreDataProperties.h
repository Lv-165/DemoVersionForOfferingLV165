//
//  Waiting+CoreDataProperties.h
//  lv-165IOS
//
//  Created by Yurii Huber on 21.12.15.
//  Copyright © 2015 SS. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Waiting.h"

NS_ASSUME_NONNULL_BEGIN

@interface Waiting (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *avg;
@property (nullable, nonatomic, retain) NSString *avg_textual;
@property (nullable, nonatomic, retain) NSNumber *count;
@property (nullable, nonatomic, retain) Place *place;

@end

NS_ASSUME_NONNULL_END
