//
//  UIView.m
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/2/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
#import "MapKit/MKAnnotationView.h"

@implementation UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView {
    
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView*)self;
    }
    if (!self.superview) {
        return nil;
    }
    return [self.superview superAnnotationView];
}

@end
