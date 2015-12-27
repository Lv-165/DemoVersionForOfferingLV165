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

@property(nonatomic) CGFloat startAngle;
@property(nonatomic) CGFloat endAngle;

@property(nonatomic) CGFloat startAngleAnimated;
@property(nonatomic) CGFloat endAngleAnimated;

@property(nonatomic, strong) UIColor *fillColor;
@property(nonatomic) CGFloat strokeWidth;
@property(nonatomic, strong) UIColor *strokeColor;

@end
