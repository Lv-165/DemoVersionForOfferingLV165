//
//  FBAnnotationClusterView.m
//  lv-165IOS
//
//  Created by Admin on 12/7/15.
//  Copyright © 2015 SS. All rights reserved.
//
@import QuartzCore;

#import "FBAnnotationClusterView.h"
#import "HMMapAnnotation.h"
#import "PieSliceLayer.h"
#import "math.h"

@import QuartzCore;
@import CoreText;

@interface FBAnnotationClusterView ()

@property(strong, nonatomic) CALayer *containerLayer;
@property(strong, nonatomic) NSMutableArray *segmentSizesArray;
@property(strong, nonatomic) NSMutableArray *segmentsArray;
@property(nonatomic, strong) NSArray *sliceColors;
- (void)updateSlices;

@end

@implementation FBAnnotationClusterView

- (id)initWithAnnotation:(FBAnnotationCluster *)annotation
       clusteringManager:(FBClusteringManager *)clusteringManager {

  _clusteringManager = clusteringManager;

  self = [super initWithAnnotation:annotation reuseIdentifier:nil];
  if (self != nil) {

    self.frame =
        CGRectMake(0, 0, _clusteringManager.clusterAnnotationViewRadius,
                   _clusteringManager.clusterAnnotationViewRadius);

    self.backgroundColor = [UIColor clearColor];

    if (annotation.animated) {

      [self updateSlices];
    } else {

      self.image = [self drawPieChartImageInRect:self.frame];
    }

    NSString *string = [[NSString alloc]
        initWithFormat:@"%ld", (long)self.annotation.annotations.count];

    CGPoint point =
        CGPointMake(self.bounds.origin.x + self.bounds.size.width / 1.5,
                    self.bounds.origin.y + self.bounds.size.height / 1.5);

    CATextLayer *textLayer =
        [self constructTextLayerAtPoint:point WithString:string];
    [self.layer addSublayer:textLayer];
  }
  return self;
}

- (void)updateSlices {

  _containerLayer.frame = self.bounds;

  int radius =
      MIN(_containerLayer.frame.size.height, _containerLayer.frame.size.width) /
      2;

  NSArray *coloursArray =
      [[NSArray alloc] initWithObjects:_clusteringManager.noneRatingColour,
                                       _clusteringManager.badRatingColour,
                                       _clusteringManager.normalRatingColour,
                                       _clusteringManager.goodRatingColour,
                                       _clusteringManager.veryGoodRatingColour,
                                       _clusteringManager.strokeColour, nil];

  [self calculatePieChartSegmentSizes];

  __block CGFloat previousSegmentAngle;
  __block CGFloat currentPointOnArcX;
  __block CGFloat currentPointOnArcY;

  [_segmentsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                               BOOL *stop) {

    NSMutableDictionary *segment = [obj mutableCopy];

    CGPoint center =
        CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    NSNumber *segmentType = segment[@"type"];

    NSNumber *segmentSize = segment[@"size"];

    NSNumber *numberOfAnnotations = segment[@"annotationsCount"];

    UIColor *color = coloursArray[segmentType.unsignedIntegerValue];

    CGFloat startAngle = 0.0;
    CGFloat endAngle = 0.0;

    if (idx == 0) {
      startAngle = 0;
    } else if (previousSegmentAngle) {

      startAngle = previousSegmentAngle;
    }

    if (idx == _segmentsArray.count - 1) {
      endAngle = 2 * M_PI;
      previousSegmentAngle = 0;
      currentPointOnArcX = 0;
      currentPointOnArcY = 0;

    } else {
      endAngle = 2 * M_PI * segmentSize.doubleValue;
      previousSegmentAngle = endAngle;
    }
    PieSliceLayer *slice = [PieSliceLayer layer];

    slice.frame = self.bounds;

    slice.startAngleAnimated = startAngle;
    slice.endAngleAnimated = endAngle;

    slice.segmentSize = segmentSize;
    slice.numberOfAnnotations = numberOfAnnotations;

    slice.fillColor = color;
    slice.strokeColor = [_clusteringManager strokeColour];
    slice.strokeWidth = 1;

    NSString *string = [[NSString alloc]
        initWithFormat:@"%ld", (long)numberOfAnnotations.integerValue];

    UIBezierPath *aPath = [UIBezierPath bezierPath];

    [aPath moveToPoint:center];

    [aPath addArcWithCenter:center
                     radius:radius
                 startAngle:startAngle
                   endAngle:endAngle
                  clockwise:YES];

    CGPoint currentPoint = [aPath currentPoint];

    CGPoint midPoint = CGPointMake(center.x + radius / 1.5 * cosf(startAngle),
                                   center.y + radius / 1.5 * sinf(startAngle));

    if (segmentSize.doubleValue > 0.6) {

      CATextLayer *textLayer =
          [self constructTextLayerAtPoint:midPoint WithString:string];

      [_containerLayer insertSublayer:textLayer atIndex:0];

    } else if (segmentSize.doubleValue > 0.4 && segmentSize.doubleValue < 0.6) {
      _textLayer = [self constructTextLayerAtPoint:midPoint WithString:string];
      [_containerLayer addSublayer:_textLayer];

    } else {
      // not putting text for very small area
    }

    currentPointOnArcX = currentPoint.x;
    currentPointOnArcY = currentPoint.y;

    [_clusteringManager.slicesArray addObject:slice];

    [_containerLayer addSublayer:slice];

  }];
}

- (CATextLayer *)constructTextLayerAtPoint:(CGPoint)point
                                WithString:(NSString *)string {
  CATextLayer *textLayer = [CATextLayer layer];
  [textLayer setFontSize:12];

  [textLayer setForegroundColor:[[UIColor blackColor] CGColor]];

  [textLayer setBounds:self.frame];
  [textLayer setPosition:point];
  [textLayer setString:string];
  [textLayer setName:@"textLayer"];
  return textLayer;
}

- (void)doInitialSetup {
  _containerLayer = [CALayer layer];
  [self.layer addSublayer:_containerLayer];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self doInitialSetup];
  }

  return self;
}

// TODO:check why I need this
- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self doInitialSetup];
  }

  return self;
}

- (void)calculatePieChartSegmentSizes {

  _segmentsArray = [NSMutableArray new];

  NSUInteger numOfAnnotationsWithoutRating = 0;
  NSUInteger numOfAnnotationsWithBadRating = 0;
  NSUInteger numOfAnnotationsWithNormalRating = 0;
  NSUInteger numOfAnnotationsWithGoodRating = 0;
  NSUInteger numOfAnnotationsWithVeryGoodRating = 0;

  for (HMMapAnnotation *annotation in self.annotation.annotations) {

    switch (annotation.ratingForColor) {

    case noRating:
      numOfAnnotationsWithoutRating++;
      break;

    case badRating:
      numOfAnnotationsWithBadRating++;
      break;

    case normalRating:
      numOfAnnotationsWithNormalRating++;
      break;

    case goodRating:
      numOfAnnotationsWithGoodRating++;
      break;

    case veryGoodRating:
      numOfAnnotationsWithVeryGoodRating++;
      break;
    }
  }

  NSUInteger total =
      numOfAnnotationsWithoutRating + numOfAnnotationsWithBadRating +
      numOfAnnotationsWithNormalRating + numOfAnnotationsWithGoodRating +
      numOfAnnotationsWithVeryGoodRating;

  NSNumber *nsNumberOfAnnotationsWithoutRating =
      [NSNumber numberWithUnsignedInteger:numOfAnnotationsWithoutRating];

  NSNumber *nsNumberOfAnnotationsWithBadRating =
      [NSNumber numberWithUnsignedInteger:numOfAnnotationsWithBadRating];

  NSNumber *nsNumberOfAnnotationsWithNormalRating =
      [NSNumber numberWithUnsignedInteger:numOfAnnotationsWithNormalRating];

  NSNumber *nsNumberOfAnnotationsWithGoodRating =
      [NSNumber numberWithUnsignedInteger:numOfAnnotationsWithGoodRating];

  NSNumber *nsNumberOfAnnotationsWithVeryGoodRating =
      [NSNumber numberWithUnsignedInteger:numOfAnnotationsWithVeryGoodRating];

  NSArray *numOfAnnotationsByRating = [[NSArray alloc]
      initWithObjects:nsNumberOfAnnotationsWithoutRating,
                      nsNumberOfAnnotationsWithBadRating,
                      nsNumberOfAnnotationsWithNormalRating,
                      nsNumberOfAnnotationsWithGoodRating,
                      nsNumberOfAnnotationsWithVeryGoodRating, nil];

  [numOfAnnotationsByRating
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        NSNumber *numberOfAnnotationsInSegment = (NSNumber *)obj;

        NSNumber *rating = [NSNumber numberWithUnsignedInteger:idx];

        double segmentSizeDouble =
            (double)numberOfAnnotationsInSegment.integerValue / total;

        NSNumber *segmentSize = [NSNumber numberWithFloat:segmentSizeDouble];

        NSDictionary *segmentProperties = [[NSDictionary alloc]
            initWithObjectsAndKeys:rating, @"type", segmentSize, @"size",
                                   numberOfAnnotationsInSegment,
                                   @"annotationsCount", @0, @"startAngle", @0,
                                   @"endAngle", nil];

        [_segmentsArray addObject:segmentProperties];
      }];
}

- (UIImage *)grabImage {

  UIGraphicsBeginImageContext([self bounds].size);

  [[self layer] renderInContext:UIGraphicsGetCurrentContext()];

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  return image;
}

- (UIImage *)drawPieChartImageInRect:(CGRect)rect {

  UIGraphicsBeginImageContext(rect.size);

  NSArray *coloursArray =
      [[NSArray alloc] initWithObjects:_clusteringManager.noneRatingColour,
                                       _clusteringManager.badRatingColour,
                                       _clusteringManager.normalRatingColour,
                                       _clusteringManager.goodRatingColour,
                                       _clusteringManager.veryGoodRatingColour,
                                       _clusteringManager.strokeColour, nil];

  CGRect circleRect = CGRectInset(self.bounds, 1, 1);

  CGPoint center =
      CGPointMake(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));

  [self calculatePieChartSegmentSizes];

  __block CGFloat previousSegmentAngle;
  __block CGFloat currentPointOnArcX;
  __block CGFloat currentPointOnArcY;

  [_segmentsArray
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        UIBezierPath *aPath = [UIBezierPath bezierPath];
        NSMutableDictionary *segment = [obj mutableCopy];

        NSNumber *segmentType = segment[@"type"];

        UIColor *color = coloursArray[segmentType.unsignedIntegerValue];

        NSNumber *segmentSize = segment[@"size"];
        double segmentSizeDouble = segmentSize.doubleValue;

        CGFloat startAngle = 0;
        CGFloat endAngle = 0;

        if (idx == 0) {
          startAngle = 0;
        } else if (previousSegmentAngle) {

          startAngle = previousSegmentAngle;
        }

        if (idx == _segmentsArray.count - 1) {
          endAngle = 2 * M_PI;
          previousSegmentAngle = 0;
          currentPointOnArcX = 0;
          currentPointOnArcY = 0;
        } else {

          endAngle = 2 * M_PI * segmentSizeDouble;
          previousSegmentAngle = endAngle;
        }

        [aPath moveToPoint:CGPointMake(center.x, center.y)];

        [aPath addArcWithCenter:center
                         radius:rect.size.width / 2
                     startAngle:startAngle
                       endAngle:endAngle
                      clockwise:YES];

        [aPath setLineWidth:3];
        [aPath closePath];
        [color setFill];
        [[_clusteringManager strokeColour] setStroke];
        [aPath stroke];
        [aPath fill];
      }];

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  return image;
}

@end
