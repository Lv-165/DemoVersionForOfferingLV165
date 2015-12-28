//
//  PieSliceLayer.m
//  lv-165IOS
//
//  Created by Admin on 12/25/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "FBClusteringManager.h"
#import "PieSliceLayer.h"

@implementation PieSliceLayer

@dynamic startAngle, endAngle;

- (id<CAAction>)actionForKey:(NSString *)event {

  if ([event isEqualToString:@"startAngle"] ||
      [event isEqualToString:@"endAngle"]) {

    //          CABasicAnimation *startAngleAnimation =
    //          [CABasicAnimation animationWithKeyPath:@"startAngle"];
    //         // startAngleAnimation.fromValue= @(self.startAngle);
    //          startAngleAnimation.toValue = @(self.startAngle);
    //          startAngleAnimation.fillMode = kCAFillModeForwards;
    //          startAngleAnimation.removedOnCompletion = NO;
    //          startAngleAnimation.duration = 10.0;
    //
    CABasicAnimation *endAngleAnimation =
        [CABasicAnimation animationWithKeyPath:@"endAngle"];
    //  endAngleAnimation.fromValue = @(self.startAngle);
    endAngleAnimation.toValue = @(self.endAngle);

    endAngleAnimation.fillMode = kCAFillModeForwards;
    endAngleAnimation.removedOnCompletion = NO;
    endAngleAnimation.duration = 5.0;

    //          CAAnimationGroup * animationGroup = [CAAnimationGroup new];
    //          animationGroup.animations =
    //          @[startAngleAnimation,endAngleAnimation];

    return endAngleAnimation;

    //[self addAnimation:animationGroup forKey:@"startAngle"];

    //    CABasicAnimation *animation = [CABasicAnimation
    //    animationWithKeyPath:event];
    //
    //    animation.duration = [CATransaction animationDuration];
    //    animation.timingFunction = [CATransaction animationTimingFunction];
    //    return animation;

    // return [self makeAnimationForKey:event];
  }

  return [super actionForKey:event];
}

- (id)initWithLayer:(id)layer {

  // clusteringManager:(FBClusteringManager *)clusteringManager {
  //
  //    _clusteringManager = clusteringManager;

  if (self = [super initWithLayer:layer]) {
    if ([layer isKindOfClass:[PieSliceLayer class]]) {
      PieSliceLayer *other = (PieSliceLayer *)layer;
      self.startAngle = other.startAngle;
      self.endAngle = other.endAngle;
      self.fillColor = other.fillColor;

      self.strokeColor = other.strokeColor;
      self.strokeWidth = other.strokeWidth;
    }
  }

  return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {

  if ([key isEqualToString:@"startAngle"] ||
      [key isEqualToString:@"endAngle"]) {

    return YES;
  }

  return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {

  //[[NSOperationQueue new] addOperationWithBlock:^{

  CGPoint center =
      CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
  CGFloat radius = MIN(center.x, center.y);

  CGContextBeginPath(ctx);
  CGContextMoveToPoint(ctx, center.x, center.y);

  CGPoint p1 = CGPointMake(center.x + radius * cosf(self.startAngle),
                           center.y + radius * sinf(self.startAngle));
  CGContextAddLineToPoint(ctx, p1.x, p1.y);

  int clockwise = self.startAngle < self.endAngle;
  CGContextAddArc(ctx, center.x, center.y, radius, self.startAngle,
                  self.endAngle, clockwise);

  CGContextClosePath(ctx);

  // Color it
  CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
  CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
  CGContextSetLineWidth(ctx, self.strokeWidth);

  CGContextDrawPath(ctx, kCGPathFillStroke);

    
//    for (CALayer *layer in [self sublayers]) {
//
//        if ([[layer name] isEqualToString:@"textLayer"]) {
//            [layer removeFromSuperlayer];
//            [[self modelLayer]insertSublayer:layer atIndex:[self.sublayers count]];
//        }
//    }

  //  UIGraphicsPushContext(ctx);
  //
  //  //    CGPoint center = CGPointMake(self.bounds.origin.x +
  //  //    self.bounds.size.width/2, self.bounds.origin.y +
  //  //    self.bounds.size.height/2);
  //  //  CGFloat radius =  MIN(self.bounds.size.height, self.bounds.size.width)
  //  /
  //  //  2;
  //
  //  UIBezierPath *aPath = [UIBezierPath bezierPath];
  //  [aPath moveToPoint:center];
  //
  //  [aPath addArcWithCenter:center
  //                   radius:radius
  //               startAngle:self.startAngle
  //                 endAngle:self.endAngle
  //                clockwise:NO];
  //
  //  [aPath setLineWidth:3];
  //  [aPath closePath];
  //
  //  [self.fillColor setFill];
  //  [self.strokeColor setStroke];
  //
  //  //[color setFill];
  //
  //  //[[_clusteringManager strokeColour] setStroke];
  //
  //  [aPath stroke];
  //  [aPath fill];
  //
  //  UIGraphicsPopContext();

  //
  //    _midPoint = CGPointMake(center.x + radius / 2 * cosf(self.startAngle),
  //                                   center.y + radius / 2 *
  //                                   sinf(self.startAngle));

  //         [aPath setLineWidth:3];
  //         // WAS previousSegmentAngle = endAngle;
  //
  //         [aPath closePath];
  //         // set the stoke color
  //
  //         [color setFill];
  //         [[_clusteringManager strokeColour] setStroke];
  //
  //         // draw the path
  //         [aPath stroke];
  //         [aPath fill];

  // CGPoint midPoint;

  //}];
}

- (void)processSegmentsArray {

  //    UIBezierPath *aPath = [UIBezierPath bezierPath];
  //    [aPath moveToPoint:CGPointMake(center.x, center.y)];
  //
  //    [aPath addArcWithCenter:CGPointMake(center.x, center.y)
  //                     radius:radius
  //                 startAngle:startAngle
  //                   endAngle:endAngle
  //                  clockwise:YES];
}

- (void)drawString:(NSString *)string atPoint:(CGPoint)point {

  // MARK: BLOCK TO DRAW TEXT
  // CGRect textRect = CGRectMake(xPosition, yPosition, canvasWidth,
  // canvasHeight);
  //
  // NSDictionary *attrDict = [NSDictionary
  // dictionaryWithObjectsAndKeys:labelFont,
  //    NSFontAttributeName,
  //    paragraphStyle,
  //    NSParagraphStyleAttributeName,
  //    nil];

  // assume your maximumSize contains {255, MAXFLOAT}
  // CGRect lblRect = [text boundingRectWithSize:(CGSize){225,
  // MAXFLOAT}
  //              options:NSStringDrawingUsesLineFragmentOrigin
  //           attributes:attrDict
  //              context:nil];
  // CGSize labelHeighSize = lblRect.size;

  // NSString *string = [[NSString alloc] initWithFormat:@"%f",
  // num.doubleValue];

  // UIFont *font = [UIFont systemFontOfSize:10];
  //
  ////  use standard size to prevent error accrual
  //
  // CGSize sampleSize = [string sizeWithAttributes:[NSDictionary
  // dictionaryWithObjectsAndKeys:sampleFont, NSFontAttributeName,
  // nil]];
  // CGFloat scale = MIN((sampleSize.width-10) / sampleSize.width,
  //(sampleSize.height-10) / sampleSize.height);
  //
  // text.font = [UIFont fontWithDescriptor:font.fontDescriptor
  // size:scale
  //* sampleFont.pointSize];
  //
  // CGFloat fontSize = 30;

  //  NSMutableParagraphStyle *textStyle =
  //      NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
  //  textStyle.alignment = NSTextAlignmentCenter;
  //
  //  NSDictionary *textFontAttributes = @{
  //    NSFontAttributeName :
  //        [UIFont fontWithName:@"Helvetica"
  //                        size:_clusteringManager.labelFontSize],
  //    NSParagraphStyleAttributeName : textStyle
  //  };
  //  [string drawAtPoint:point withAttributes:textFontAttributes];


    NSArray * array = [self sublayers];

  for (CALayer *layer in array) {

    if ([[layer name] isEqualToString:@"textLayer"]) {

      [layer removeFromSuperlayer];

      [self insertSublayer:layer atIndex:[self.sublayers count]];
        
    }
  }
}

//- (CALayer *)myLayer {
//
//    for (CALayer *layer in [superLayerOfMyLayer sublayers]) {
//
//        if ([[layer name] isEqualToString:LabelLayerName]) {
//            return layer;
//        }
//    }
//
//    return nil;
//}

@end
