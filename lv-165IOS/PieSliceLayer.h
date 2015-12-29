//
//  PieSliceLayer.h
//  lv-165IOS
//
//  Created by Admin on 12/25/15.
//  Copyright © 2015 SS. All rights reserved.
//
@import UIKit;
@import QuartzCore;

@interface PieSliceLayer : CALayer

@property(nonatomic, assign) CGFloat startAngle;
@property(nonatomic, assign) CGFloat endAngle;

@property(nonatomic, assign) CGFloat startAngleAnimated;
@property(nonatomic, assign) CGFloat endAngleAnimated;

@property(nonatomic, strong) NSNumber *segmentSize;

@property(nonatomic, strong) UIColor *fillColor;
@property(nonatomic) CGFloat strokeWidth;
@property(nonatomic, strong) UIColor *strokeColor;

@end
