//
//  HMMapAnnotation.m
//  lv-165IOS
//
//  Created by Yurii Huber on 03.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMMapAnnotation.h"

@implementation HMMapAnnotation

- (id)initWithLocation:(CLLocationCoordinate2D) coord {
    
    self = [super init];
    if (self) {
        self.coordinate = coord;
    }
    return self;
}

@end
