//
//  Place.h
//  lv-165IOS
//
//  Created by Yurii Huber on 21.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comments, Countries, Description, Location, User, Waiting;

NS_ASSUME_NONNULL_BEGIN

@interface Place : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Place+CoreDataProperties.h"
