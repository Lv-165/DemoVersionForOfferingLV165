//
//  FBAnnotationClusterView.m
//  lv-165IOS
//
//  Created by Admin on 12/7/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "FBAnnotationClusterView.h"
#import "HMMapAnnotation.h"

@import QuartzCore;
@import CoreText;

typedef NS_OPTIONS(NSInteger, AnnotationsPresentByRating) {
  PresentWithoutRating = 1 << 0,
  PresentWithBadRating = 1 << 1,
  PresentWithGoodRating = 1 << 2
};

typedef struct {
  unsigned int numOfAnnotationsWithoutRating;
  unsigned int numOfAnnotationsWithBadRating;
  unsigned int numOfAnnotationsWithGoodRating;
} NumberOfAnnotationsByRating;

typedef struct {
    unsigned int partOfAnnotationsWithoutRating;
    unsigned int partOfAnnotationsWithBadRating;
    unsigned int partOfAnnotationsWithGoodRating;
} PieChartSegments;

@interface FBAnnotationClusterView ()

@property(strong, nonatomic) UIColor *goodRatingColour;
@property(strong, nonatomic) UIColor *badRatingColour;
@property(strong, nonatomic) UIColor *noneRatingColour;
@property(strong, nonatomic) NSMutableArray *segmentSizesArray;


//@property(strong, nonatomic) ClusterViewPieChart *pieChartRight;
//@property(strong, nonatomic) ClusterViewPieChart *pieChartLeft;

//@property(strong, nonatomic) UILabel *percentageLabel;
//@property(strong, nonatomic) UILabel *selectedSliceLabel;

//@property(strong, nonatomic) UISegmentedControl *indexOfSlices;

//@property(strong, nonatomic) UIButton *downArrow;
@property(assign, nonatomic) NSUInteger numOfSlices;
@property(nonatomic, strong) NSMutableArray *slices;

@property(nonatomic, strong) NSArray *sliceColors;

//@property(nonatomic) CGFloat partWithoutRating;
//@property(nonatomic) CGFloat partWithBadRating;
//@property(nonatomic) CGFloat partWithGoodRating;

@end

@implementation FBAnnotationClusterView

AnnotationsPresentByRating annotationsPresentByRating;
NumberOfAnnotationsByRating numberOfAnnotationsByRating;
PieChartSegments pieChartSegments;

static CGFloat radianConversionFactor = M_PI / 180;

- (void)calculatePieChartSegmentSizes {

    _numberOfPieChartSegments = 0;

   // _segmentSizesArray = [NSMutableArray alloc]initWithCapacity:3];

    numberOfAnnotationsByRating.numOfAnnotationsWithBadRating = 0;
    numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating = 0;
    numberOfAnnotationsByRating.numOfAnnotationsWithoutRating = 0;

    //  _annotationsWithoutRating = [NSMutableArray new];
    //  _annotationsWithBadRating = [NSMutableArray new];
    //  _annotationsWithGoodRating = [NSMutableArray new];

    for (HMMapAnnotation *annotation in self.annotation.annotations) {
        switch (annotation.ratingForColor) {
            case senseLess:
                //[_annotationsWithoutRating addObject:annotation];
                numberOfAnnotationsByRating.numOfAnnotationsWithoutRating++;
                break;
            case badRating:
                // [_annotationsWithBadRating addObject:annotation];
                numberOfAnnotationsByRating.numOfAnnotationsWithBadRating++;
                break;
            case veryGoodRating:
                //[_annotationsWithGoodRating addObject:annotation];
                
                numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating++;
                break;
        }
    }

  NSUInteger total =
      numberOfAnnotationsByRating.numOfAnnotationsWithBadRating +
      numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating +
      numberOfAnnotationsByRating.numOfAnnotationsWithoutRating;
  // NSUInteger total =   _annotationsWithoutRating.count +
  //                     _annotationsWithBadRating.count +
  //                     _annotationsWithGoodRating.count;

  pieChartSegments.partOfAnnotationsWithoutRating = numberOfAnnotationsByRating.numOfAnnotationsWithoutRating / total;
  pieChartSegments.partOfAnnotationsWithGoodRating = numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating / total;
  pieChartSegments.partOfAnnotationsWithBadRating = numberOfAnnotationsByRating.numOfAnnotationsWithBadRating / total;

  if (pieChartSegments.partOfAnnotationsWithoutRating ) {
    [_segmentSizesArray addObject:[NSNumber numberWithFloat:pieChartSegments.partOfAnnotationsWithoutRating ]];
  }
  if (pieChartSegments.partOfAnnotationsWithBadRating) {
    [_segmentSizesArray addObject:[NSNumber numberWithFloat:pieChartSegments.partOfAnnotationsWithBadRating]];
  }
  if (pieChartSegments.partOfAnnotationsWithGoodRating) {
    [_segmentSizesArray
        addObject:[NSNumber numberWithFloat:pieChartSegments.partOfAnnotationsWithGoodRating]];
  }
    //return [_segmentSizesArray copy];
}


//- (void)calculateNumOfAnnotationsByRating {
//    _numberOfPieChartSegments = 0;
//
//  numberOfAnnotationsByRating.numOfAnnotationsWithBadRating = 0;
//  numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating = 0;
//  numberOfAnnotationsByRating.numOfAnnotationsWithoutRating = 0;
//
//  //  _annotationsWithoutRating = [NSMutableArray new];
//  //  _annotationsWithBadRating = [NSMutableArray new];
//  //  _annotationsWithGoodRating = [NSMutableArray new];
//
//  for (HMMapAnnotation *annotation in self.annotation.annotations) {
//    switch (annotation.ratingForColor) {
//    case senseLess:
//      //[_annotationsWithoutRating addObject:annotation];
//      numberOfAnnotationsByRating.numOfAnnotationsWithoutRating++;
//      break;
//    case badRating:
//      // [_annotationsWithBadRating addObject:annotation];
//      numberOfAnnotationsByRating.numOfAnnotationsWithBadRating++;
//      break;
//    case veryGoodRating:
//      //[_annotationsWithGoodRating addObject:annotation];
//
//      numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating++;
//      break;
//    }
//  }
//
////    if (numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating) {
////        _numberOfPieChartSegments++;
////    }
////    if (numberOfAnnotationsByRating.numOfAnnotationsWithoutRating) {
////        _numberOfPieChartSegments++;
////    }
////    if (numberOfAnnotationsByRating.numOfAnnotationsWithBadRating) {
////        _numberOfPieChartSegments++;
////    }
//
//}


//- (NSUInteger)countAnnotationsByRating   {
//    _numberOfPieChartSegments = 0;
//    [self calculateNumOfAnnotationsByRating];
//    if (_numOfAnnotationsWithoutRating) {
//        _numberOfPieChartSegments++;
//    }
//    if (_numOfAnnotationsWithGoodRating) {
//        _numberOfPieChartSegments++;
//    }
//    if (_numOfAnnotationsWithBadRating) {
//        _numberOfPieChartSegments++;
//    }
//    return _numberOfPieChartSegments;
//}



//- (void)returnNonZero {
//  _numOfAnnotationsWithoutRating;
//  _numOfAnnotationsWithBadRating;
//  _numOfAnnotationsWithGoodRating;
//
//  annotationsPresentByRating =
//      PresentWithBadRating | PresentWithoutRating | PresentWithGoodRating;
//
//  if (annotationsPresentByRating & PresentWithBadRating) {
//
//  }
//}


//- (void)countAnnotationsByRating {
//  //    [self enumerateAnnotationsForRating];
//  //    _numOfAnnotationsWithoutRating = _annotationsWithoutRating.count;
//  //    _numOfAnnotationsWithBadRating = _annotationsWithBadRating.count;
//  //    _numOfAnnotationsWithGoodRating = _annotationsWithGoodRating.count;
//
//  _numOfAnnotationsWithoutRating = 0;
//  _numOfAnnotationsWithBadRating = 0;
//  _numOfAnnotationsWithGoodRating = 0;
//
//  for (HMMapAnnotation *annotation in self.annotation.annotations) {
//    switch (annotation.ratingForColor) {
//    case senseLess:
//      _numOfAnnotationsWithoutRating++;
//      break;
//
//    case badRating:
//      _numOfAnnotationsWithBadRating++;
//      break;
//
//    case veryGoodRating:
//      _numOfAnnotationsWithGoodRating++;
//      break;
//    }
//
//    //    for  (HMMapAnnotation * annotation in clusterAnnotation.annotations){
//    //        NSNumber * num = self.slices [annotation.ratingForColor];
//    //        NSUInteger count = num.integerValue;
//    //        count++;
//    //    }
//  }
//}
//
//- (NSUInteger)countPieChartSegments {
//  _numberOfPieChartSegments = 0;
//  [self countAnnotationsByRating];
//  if (_numOfAnnotationsWithoutRating) {
//    _numberOfPieChartSegments++;
//  }
//  if (_numOfAnnotationsWithGoodRating) {
//    _numberOfPieChartSegments++;
//  }
//  if (_numOfAnnotationsWithBadRating) {
//    _numberOfPieChartSegments++;
//  }
//  return _numberOfPieChartSegments;
//}


- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  if (self != nil) {
    FBAnnotationCluster *clusterAnnotation = (FBAnnotationCluster *)annotation;
    self.frame = CGRectMake(0, 0, 70, 70);
    self.backgroundColor = [UIColor clearColor];
    // self.opaque = YES;
    //[self setNeedsDisplay];
    // ClusterViewPieChart *pieChartView = [ClusterViewPieChart alloc];

    // self.image = [ClusterViewPieChart constructPieChartImage];

    // self.annotationLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35,
    // 35)];

    //    self.annotationLabel.layer.borderWidth = 3;
    //    self.annotationLabel.layer.cornerRadius = 17.5;
    //    self.annotationLabel.font = [UIFont systemFontOfSize:14.0];
    //    self.annotationLabel.backgroundColor = [UIColor whiteColor];
    //
    //    self.annotationLabel.text = [NSString
    //        stringWithFormat:@"%lu",
    //                         (unsigned
    //                         long)clusterAnnotation.annotations.count];
    //    self.annotationLabel.textAlignment = NSTextAlignmentCenter;
    //
    //    self.annotationLabel.layer.borderColor =
    //        [[UIColor colorWithRed:0.4379 green:0.6192 blue:0.7767 alpha:1.0]
    //            CGColor];
    //    self.annotationLabel.backgroundColor = [UIColor clearColor];
    //      self.annotationLabel.clipsToBounds = YES;
    //    self.annotationLabel.layer.masksToBounds  =YES;
    //
    //    self.canShowCallout = NO;
    //    self.draggable = NO;
    //    self.annotationLabel.userInteractionEnabled = YES;
    //    [self addSubview:self.annotationLabel];
  }

  return self;
}

//// Draw inner pie
// CGFloat innerRadius = CGRectGetMidX(circleRect) * 0.45;
//
// CGContextSetFillColorWithColor(context, innerPieColor);
// CGContextMoveToPoint(context, center.x, center.y);
// CGContextAddArc(context, center.x, center.y, innerRadius, startAngle,
//                endAngle, 0);
// CGContextClosePath(context);
// CGContextFillPath(context);

//// Draw the White Line
// CGFloat lineRadius = CGRectGetMidX(circleRect) * 0.72;
// CGFloat arrowWidth = 0.35;
//
// CGContextSetStrokeColorWithColor(context, arrowColor);
// CGContextSetFillColorWithColor(context, arrowColor);
//
// CGMutablePathRef path = CGPathCreateMutable();
// CGContextSetLineWidth(context, 16);
// CGFloat lineEndAngle = ((endAngle - startAngle) >= arrowWidth)
//? endAngle - arrowWidth
//: endAngle;
// CGPathAddArc(path, NULL, center.x, center.y, lineRadius, startAngle,
//             lineEndAngle, 0);
// CGContextAddPath(context, path);
// CGContextStrokePath(context);

- (void)drawText:(CGFloat)xPosition
       yPosition:(CGFloat)yPosition
     canvasWidth:(CGFloat)canvasWidth
    canvasHeight:(CGFloat)canvasHeight {
  // Draw Text
  CGRect textRect = CGRectMake(xPosition, yPosition, canvasWidth, canvasHeight);
  NSMutableParagraphStyle *textStyle =
      NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
  textStyle.alignment = NSTextAlignmentLeft;

  NSDictionary *textFontAttributes = @{
    NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:12],
    NSForegroundColorAttributeName : UIColor.redColor,
    NSParagraphStyleAttributeName : textStyle
  };

  [@"Hello, World!" drawInRect:textRect withAttributes:textFontAttributes];
}

- (void)addText {
  //    NSString *text = [[NSString alloc]initWithFormat:@"%lu",(unsigned
  //    long)_numOfAnnotationsWithBadRating];
  //    NSAttributedString* attString = [[NSAttributedString alloc]
  //                                     initWithString:text] ;
  //    CTFramesetterRef framesetter =
  //    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
  //    CTFrameRef frame =
  //    CTFramesetterCreateFrame(framesetter,
  //                             CFRangeMake(0, [attString length]), path,
  //                             NULL);
  //
  //    CTFrameDraw(frame, context);
}

- (void)drawRect:(CGRect)rect {

  _goodRatingColour =
      [UIColor colorWithRed:0.257 green:0.667 blue:0.244 alpha:1.000];
  _badRatingColour =
      [UIColor colorWithRed:0.871 green:0.000 blue:0.126 alpha:1.000];
  _noneRatingColour =
      [UIColor colorWithRed:0.620 green:0.625 blue:0.612 alpha:1.000];

    NSArray *coloursArray = [[NSArray alloc]initWithObjects:_noneRatingColour,_badRatingColour, _goodRatingColour, nil];

  CGRect circleRect = CGRectInset(self.bounds, 1, 1);
  CGPoint center =
      CGPointMake(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));

  //  UIBezierPath *circularPath = [UIBezierPath
  //  bezierPathWithRoundedRect:self.bounds
  //                               cornerRadius:self.bounds.size.height / 2.0];
  //    [circularPath addClip];

  // CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2,
  // rect.origin.y + rect.size.height / 2);

  CGFloat radius = rect.size.width / 2;

  //    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);

  CGContextRef context = UIGraphicsGetCurrentContext();

  // CGContextAddEllipseInRect(context, CGRectInset(rect, 2.0, 2.0));

  CGMutablePathRef arc = CGPathCreateMutable();
  CGPathMoveToPoint(arc, NULL, center.x, center.y);

  // CGContextMoveToPoint(context, center.x, center.y);
  CGFloat startAngle = 0;
  CGFloat endAngle = 360 * radianConversionFactor;

    //NSUInteger numOfPieChartSegments = [self countPieChartSegments];

  [self calculatePieChartSegmentSizes];

  CGFloat currentAngle;

//    if (pieChartSegments.partOfAnnotationsWithoutRating ) {
//        _noneRatingColour;
//        CGFloat angle = 360 * pieChartSegments.partOfAnnotationsWithoutRating;
//        currentAngle;
//    }
//
//    if (pieChartSegments.partOfAnnotationsWithBadRating) {
//        _badRatingColour;
//currentAngle;
//    }
//    
//    if (pieChartSegments.partOfAnnotationsWithGoodRating) {
//        _goodRatingColour;
//        currentAngle;
//    }


   // for (NSNumber * segmentSize in pieChartSegmentSizes){
    for (unsigned int i = 0; i < _segmentSizesArray.count; i++){
     if (i == 0){
         startAngle = 0;
     } else {
         startAngle = currentAngle;
     }


     if (i == _segmentSizesArray.count){
        endAngle = 360;
     }else {

    NSNumber * num = _segmentSizesArray[i];
         
      CGFloat endAngle = 360 * num.doubleValue;
     }
     currentAngle = endAngle;

    UIColor * color = coloursArray[i];

     CGContextSetFillColorWithColor(
                                    context, color
                                    .CGColor);
     CGContextSetStrokeColorWithColor(
                                      context, [UIColor colorWithRed:0.163 green:0.743 blue:0.751 alpha:1.000]
                                      .CGColor);

        //CGFloat angle = 180 * radianConversionFactor;


        // drawing segment 1

        // CGPathRef donutSegment = CGPathCreateCopyByStrokingPath(  arc, NULL,
        // lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
        // CGContextAddPath(context, donutSegment);



        CGPathAddArc(arc, NULL, center.x, center.y, rect.size.width / 2, startAngle,
                     endAngle, YES);
        CGPathCloseSubpath(arc);
        CGContextAddPath(context, arc);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGContextFillPath(context);
        //      CGContextAddArc(context, center.x, center.y, radius,
        //      startAngle,angle1, 0);
        //      CGContextClosePath(context);
        //      CGContextFillPath(context);

        // drawing segment 2

        //    donutSegment = CGPathCreateCopyByStrokingPath(       arc, NULL,
        //    lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
        //    CGContextAddPath(context, donutSegment);


}
  //  NSLog(@"numOfPieChartSegments: %lu",(unsigned long)numOfPieChartSegments);

  // [self drawText:0 yPosition:0 canvasWidth:200 canvasHeight:150];
//
//
//  switch (numOfPieChartSegments) {
//  case 0:
//  case 1: {
//
//    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
//    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
//
//    CGPathAddArc(arc, NULL, center.x, center.y, radius, startAngle, endAngle,
//                 YES);
//    CGPathCloseSubpath(arc);
//    CGContextAddPath(context, arc);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGContextFillPath(context);
//    //    CGContextAddArc(context, center.x, center.y, radius,
//    //    startAngle,endAngle, YES);
//    //      CGContextClosePath(context);
//    //      CGContextFillPath(context);
//
//    // CGFloat lineWidth = 5; // any radius you want
//
//    //   CGPathRef donutSegment = CGPathCreateCopyByStrokingPath(   arc, NULL,
//    //   lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//    //   CGContextAddPath(context, donutSegment);
//
//    break;
//  }
//  case 2: {
//    CGFloat angle1 = 180 * radianConversionFactor;
//
//
//      360/1
//      360/2
//    // drawing segment 1
//
//    // CGPathRef donutSegment = CGPathCreateCopyByStrokingPath(  arc, NULL,
//    // lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//    // CGContextAddPath(context, donutSegment);
//
//    CGContextSetFillColorWithColor(
//        context, [UIColor colorWithRed:0.257 green:0.667 blue:0.244 alpha:1.000]
//                     .CGColor);
//    CGContextSetStrokeColorWithColor(
//        context, [UIColor colorWithRed:0.163 green:0.743 blue:0.751 alpha:1.000]
//                     .CGColor);
//
//    CGPathAddArc(arc, NULL, center.x, center.y, rect.size.width / 2, startAngle,
//                 angle1, YES);
//    CGPathCloseSubpath(arc);
//    CGContextAddPath(context, arc);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGContextFillPath(context);
//    //      CGContextAddArc(context, center.x, center.y, radius,
//    //      startAngle,angle1, 0);
//    //      CGContextClosePath(context);
//    //      CGContextFillPath(context);
//
//    // drawing segment 2
//
//    //    donutSegment = CGPathCreateCopyByStrokingPath(       arc, NULL,
//    //    lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//    //    CGContextAddPath(context, donutSegment);
//    CGContextSetFillColorWithColor(
//        context, [UIColor colorWithRed:0.808 green:0.286 blue:0.212 alpha:1.000]
//                     .CGColor);
//    CGContextSetStrokeColorWithColor(
//        context, [UIColor colorWithRed:0.422 green:0.345 blue:0.568 alpha:1.000]
//                     .CGColor);
//
//    arc = CGPathCreateMutable();
//    CGPathMoveToPoint(arc, NULL, center.x, center.y);
//
//    CGPathAddArc(arc, NULL, center.x, center.y, radius, angle1, endAngle, YES);
//    CGPathCloseSubpath(arc);
//    CGContextAddPath(context, arc);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGContextFillPath(context);
//
//    //      CGContextAddArc(context, center.x, center.y, radius,
//    //      angle1,endAngle, 0);
//    //      CGContextClosePath(context);
//    //      CGContextFillPath(context);
//
//    break;
//  }
//  case 3: {
//    CGFloat angle1 = 120 * radianConversionFactor;
//    CGFloat angle2 = 240 * radianConversionFactor;
//
//    // drawing segment 1
//
//    //    CGPathRef donutSegment = CGPathCreateCopyByStrokingPath(       arc,
//    //    NULL, lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//    //    CGContextAddPath(context, donutSegment);
//
//    CGContextSetFillColorWithColor(
//        context, [UIColor colorWithRed:0.257 green:0.667 blue:0.244 alpha:1.000]
//                     .CGColor);
//    CGContextSetStrokeColorWithColor(
//        context, [UIColor colorWithRed:0.163 green:0.743 blue:0.751 alpha:1.000]
//                     .CGColor);
//
//    CGPathAddArc(arc, NULL, center.x, center.y, rect.size.width / 2, startAngle,
//                 angle1, YES);
//    CGPathCloseSubpath(arc);
//    CGContextAddPath(context, arc);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGContextFillPath(context);
//
//    //      CGContextMoveToPoint(context, center.x, center.y);
//    //      CGContextAddLineToPoint(context, <#CGFloat x#>, <#CGFloat y#>);
//    //      CGContextAddArc(context, center.x, center.y, radius,
//    //      startAngle,angle1, 0);
//    //      CGContextAddLineToPoint(context, center.x, center.y);
//    //      CGContextClosePath(context);
//    //      CGContextFillPath(context);
//
//    // drawing segment 2
//
//    //    donutSegment = CGPathCreateCopyByStrokingPath(       arc, NULL,
//    //    lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//    //    CGContextAddPath(context, donutSegment);
//
//    CGContextSetFillColorWithColor(
//        context, [UIColor colorWithRed:0.808 green:0.286 blue:0.212 alpha:1.000]
//                     .CGColor);
//    CGContextSetStrokeColorWithColor(
//        context, [UIColor colorWithRed:0.422 green:0.345 blue:0.568 alpha:1.000]
//                     .CGColor);
//
//    //      CGContextAddArc(context, center.x, center.y, radius, angle1,angle2,
//    //      0);
//    //      CGContextClosePath(context);
//    //      CGContextFillPath(context);
//    arc = CGPathCreateMutable();
//    CGPathMoveToPoint(arc, NULL, center.x, center.y);
//    CGPathAddArc(arc, NULL, center.x, center.y, radius, angle1, angle2, YES);
//    CGPathCloseSubpath(arc);
//    CGContextAddPath(context, arc);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGContextFillPath(context);
//    ;
//
//    // drawing segment 3
//
//    //    donutSegment = CGPathCreateCopyByStrokingPath(       arc, NULL,
//    //    lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//    //    CGContextAddPath(context, donutSegment);
//
//    CGContextSetFillColorWithColor(
//        context, [UIColor colorWithRed:1.000 green:0.996 blue:0.960 alpha:1.000]
//                     .CGColor);
//    CGContextSetStrokeColorWithColor(
//        context, [UIColor colorWithRed:0.351 green:0.860 blue:0.825 alpha:1.000]
//                     .CGColor);
//    //      CGContextAddArc(context, center.x, center.y, radius,
//    //      angle2,endAngle, 0);
//    //      CGContextClosePath(context);
//    //      CGContextFillPath(context);
//    arc = CGPathCreateMutable();
//    CGPathMoveToPoint(arc, NULL, center.x, center.y);
//    CGPathAddArc(arc, NULL, center.x, center.y, radius, angle2, endAngle, NO);
//    CGPathCloseSubpath(arc);
//    CGContextAddPath(context, arc);
//    CGContextDrawPath(context, kCGPathFillStroke);
//    CGContextFillPath(context);
//    break;
//  }
//  //  case 4: {
//  //    CGFloat angle1 = 90 * radianConversionFactor;
//  //    CGFloat angle2 = 180 * radianConversionFactor;
//  //    CGFloat angle3 = 270 * radianConversionFactor;
//  //
//  //    // drawing segment 1
//  //
//  //    //    CGPathRef donutSegment = CGPathCreateCopyByStrokingPath(
//  //    //        arc, NULL, lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//  //    //    CGContextAddPath(c, donutSegment);
//  //
//  //    CGContextSetFillColorWithColor(
//  //        context, [UIColor colorWithRed:0.257 green:0.667 blue:0.244
//  //        alpha:1.000]
//  //                     .CGColor);
//  //    CGContextSetStrokeColorWithColor(
//  //        context, [UIColor colorWithRed:0.163 green:0.743 blue:0.751
//  //        alpha:1.000]
//  //                     .CGColor);
//  //    //      CGContextAddArc(context, center.x, center.y, radius,
//  //    //      startAngle,angle1, 0);
//  //    //      CGContextClosePath(context);
//  //    //      CGContextFillPath(context);
//  //
//  //    CGPathAddArc(arc, NULL, center.x, center.y, rect.size.width / 2,
//  //    startAngle,
//  //                 angle1, YES);
//  //    CGPathCloseSubpath(arc);
//  //    CGContextAddPath(context, arc);
//  //    CGContextDrawPath(context, kCGPathFillStroke);
//  //    CGContextFillPath(context);
//  //
//  //    // drawing segment 2
//  //
//  //    //    donutSegment = CGPathCreateCopyByStrokingPath(      arc, NULL,
//  //    //    lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//  //    //    CGContextAddPath(context, donutSegment);
//  //
//  //    CGContextSetFillColorWithColor(
//  //        context, [UIColor colorWithRed:0.808 green:0.286 blue:0.212
//  //        alpha:1.000]
//  //                     .CGColor);
//  //    CGContextSetStrokeColorWithColor(
//  //        context, [UIColor colorWithRed:0.422 green:0.345 blue:0.568
//  //        alpha:1.000]
//  //                     .CGColor);
//  //    //      CGContextAddArc(context, center.x, center.y, radius,
//  //    angle1,angle2,
//  //    //      0);
//  //    //      CGContextClosePath(context);
//  //    //      CGContextFillPath(context);
//  //      arc = CGPathCreateMutable();
//  //      CGPathMoveToPoint(arc, NULL, center.x, center.y);
//  //    CGPathAddArc(arc, NULL, center.x, center.y, radius, angle1, angle2,
//  //    YES);
//  //    CGPathCloseSubpath(arc);
//  //    CGContextAddPath(context, arc);
//  //    CGContextDrawPath(context, kCGPathFillStroke);
//  //    CGContextFillPath(context);
//  //
//  //    // drawing segment 3
//  //
//  //    //    donutSegment = CGPathCreateCopyByStrokingPath(
//  //    //        arc, NULL, lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//  //    //    CGContextAddPath(context, donutSegment);
//  //
//  //    CGContextSetFillColorWithColor(
//  //        context, [UIColor colorWithRed:1.000 green:0.041 blue:0.000
//  //        alpha:1.000]
//  //                     .CGColor);
//  //    CGContextSetStrokeColorWithColor(
//  //        context, [UIColor colorWithRed:0.860 green:0.159 blue:0.848
//  //        alpha:1.000]
//  //                     .CGColor);
//  //    //      CGContextAddArc(context, center.x, center.y, radius,
//  //    angle2,angle3,
//  //    //      0);
//  //    //      CGContextClosePath(context);
//  //    //      CGContextFillPath(context);
//  //      arc = CGPathCreateMutable();
//  //      CGPathMoveToPoint(arc, NULL, center.x, center.y);
//  //    CGPathAddArc(arc, NULL, center.x, center.y, radius, angle2, angle3,
//  //    YES);
//  //
//  //    CGPathCloseSubpath(arc);
//  //    CGContextAddPath(context, arc);
//  //    CGContextDrawPath(context, kCGPathFillStroke);
//  //    CGContextFillPath(context);
//  //
//  //    // drawing segment 4
//  //
//  //    //    donutSegment = CGPathCreateCopyByStrokingPath(
//  //    //        arc, NULL, lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
//  //    //    CGContextAddPath(context, donutSegment);
//  //
//  //    CGContextSetFillColorWithColor(
//  //        context, [UIColor colorWithRed:0.289 green:0.808 blue:0.318
//  //        alpha:1.000]
//  //                     .CGColor);
//  //    CGContextSetStrokeColorWithColor(
//  //        context, [UIColor colorWithRed:0.860 green:0.145 blue:0.269
//  //        alpha:1.000]
//  //                     .CGColor);
//  //    //      CGContextAddArc(context, center.x, center.y, radius,
//  //    //      angle3,endAngle, 0);
//  //    //      CGContextClosePath(context);
//  //    //      CGContextFillPath(context);
//  //      arc = CGPathCreateMutable();
//  //      CGPathMoveToPoint(arc, NULL, center.x, center.y);
//  //    CGPathAddArc(arc, NULL, center.x, center.y, radius, angle3, endAngle,
//  //    YES);
//  //    CGPathCloseSubpath(arc);
//  //    CGContextAddPath(context, arc);
//  //    CGContextDrawPath(context, kCGPathFillStroke);
//  //    CGContextFillPath(context);
//  //    ;
//  //    break;
//  //  }
//  default:
//    break;
//  }
}

// just clipping for now
// - (void)drawRect:(CGRect)rect {
//  UIBezierPath *circularPath =
//      [UIBezierPath bezierPathWithRoundedRect:self.bounds
//                                 cornerRadius:self.bounds.size.height / 2.0];
//  [circularPath addClip];

//  // clip subsequent drawing to the inside of the path
//  [self.image drawInRect:self.bounds];
//}

//- (void)drawRect:(CGRect)rect {
//
//        CGRect circleRect = CGRectInset(self.bounds, 1, 1);
//        CGFloat startAngle = -M_PI / 2;
//        NSUInteger  progress = 50;
//        CGFloat endAngle = progress * 2 * M_PI + startAngle;
//
//        CGColorRef outerPieColor = [[UIColor colorWithRed:137.0 / 255.0
//                                                    green:12.0 / 255.0
//                                                     blue:88.0 / 255.0
//                                                    alpha:1.0] CGColor];
//        CGColorRef innerPieColor = [[UIColor colorWithRed:235.0 / 255.0
//                                                    green:214.0 / 255.0
//                                                     blue:227.0 / 255.0
//                                                    alpha:1.0] CGColor];
//        CGColorRef arrowColor = [[UIColor whiteColor] CGColor];
//
//        // Draw outer pie
//        CGFloat outerRadius = CGRectGetMidX(circleRect);
//        CGPoint center =
//        CGPointMake(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));
//
//        CGContextSetFillColorWithColor(context, outerPieColor);
//        CGContextMoveToPoint(context, center.x, center.y);
//        CGContextAddArc(context, center.x, center.y, outerRadius, startAngle,
//                        endAngle, 0);
//        CGContextClosePath(context);
//        CGContextFillPath(context);
//
//        // Draw inner pie
//        CGFloat innerRadius = CGRectGetMidX(circleRect) * 0.45;
//
//        CGContextSetFillColorWithColor(context, innerPieColor);
//        CGContextMoveToPoint(context, center.x, center.y);
//        CGContextAddArc(context, center.x, center.y, innerRadius, startAngle,
//                        endAngle, 0);
//        CGContextClosePath(context);
//        CGContextFillPath(context);
//
//        // Draw the White Line
//        CGFloat lineRadius = CGRectGetMidX(circleRect) * 0.72;
//        CGFloat arrowWidth = 0.35;
//
//        CGContextSetStrokeColorWithColor(context, arrowColor);
//        CGContextSetFillColorWithColor(context, arrowColor);
//
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGContextSetLineWidth(context, 16);
//        CGFloat lineEndAngle = ((endAngle - startAngle) >= arrowWidth)
//        ? endAngle - arrowWidth
//        : endAngle;
//        CGPathAddArc(path, NULL, center.x, center.y, lineRadius, startAngle,
//                     lineEndAngle, 0);
//        CGContextAddPath(context, path);
//        CGContextStrokePath(context);
//
//        // Draw the Triangle pointer
//        CGFloat arrowStartAngle = lineEndAngle - 0.01;
//        CGFloat arrowOuterRadius = CGRectGetMidX(circleRect) * 0.90;
//        CGFloat arrowInnerRadius = CGRectGetMidX(circleRect) * 0.54;
//
//        CGFloat arrowX = center.x + (arrowOuterRadius *
//        cosf(arrowStartAngle));
//        CGFloat arrowY = center.y + (arrowOuterRadius *
//        sinf(arrowStartAngle));
//
//        CGContextMoveToPoint(context, arrowX, arrowY); // top corner
//
//        arrowX = center.x + (arrowInnerRadius * cosf(arrowStartAngle));
//        arrowY = center.y + (arrowInnerRadius * sinf(arrowStartAngle));
//
//        CGContextAddLineToPoint(context, arrowX, arrowY); // bottom corner
//
//        arrowX = center.x + (lineRadius * cosf(endAngle));
//        arrowY = center.y + (lineRadius * sinf(endAngle));
//
//        CGContextAddLineToPoint(context, arrowX, arrowY); // point
//        CGContextClosePath(context);
//        CGContextFillPath(context);
//
//         [super drawInContext:context];
//    }

//- (void)drawRect:(CGRect)rect {
//    CGRect circleRect = CGRectInset(self.bounds, 1, 1);
//
//    UIColor * __autoreleasing borderColor = [UIColor whiteColor];
//    UIColor * __autoreleasing backgroundColor = [UIColor colorWithWhite:0
//    alpha: 0.75];
//
//    CGContextSetFillColorWithColor(context, backgroundColor.CGColor );
//    CGContextSetStrokeColorWithColor(context, borderColor.CGColor );
//    CGContextSetLineWidth(context, 2.0f);
//
//    CGContextFillEllipseInRect(context, circleRect);
//    CGContextStrokeEllipseInRect(context, circleRect);
//
//    CGFloat radius = MIN(CGRectGetMidX(circleRect),
//    CGRectGetMidY(circleRect));
//    CGPoint center = CGPointMake(radius, CGRectGetMidY(circleRect));
//    CGFloat startAngle = -M_PI / 2;
//    //need progress here
//    NSUInteger progress = 50;
//    CGFloat endAngle = progress * 2 * M_PI + startAngle;
//    CGContextSetFillColorWithColor(context, borderColor.CGColor );
//    CGContextMoveToPoint(context, center.x, center.y);
//    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle,
//    0);
//    CGContextClosePath(context);
//    CGContextFillPath(context);
//
//}

// - (void)drawRect:(CGRect)rect {
// can add sublayer to view's layer instead of subclassed layer
//    CALayer *parentLayer = [CALayer layer];
//    [self.view.layer addSubLayer:parentLayer];
//
//    [parentLayer addSublayer: myShapeLayer];
//    [parentLayer addSublayer: myLayerOverShapeLayer];
//
//  UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
//  CGContextRef ctx = UIGraphicsGetCurrentContext();
//  // Create the clipping path and add it
//  UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:imageRect];
//  [path addClip];
//
////    need image here
//    UIImage * image;
//  [image drawInRect:imageRect];
//
//  CGContextSetStrokeColorWithColor(ctx, [[UIColor greenColor] CGColor]);
//  [path setLineWidth:50.0f];
//  [path stroke];
//
//  UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//
//  self.image = roundedImage;
// }

// - (void)drawRect:(CGRect)rect {
//  {

// self.contentsScale = [UIScreen mainScreen].scale;

//        CGContextRef currenctContext = ctx;
//        CGContextSetStrokeColorWithColor(currenctContext, [UIColor
//        blackColor].CGColor);
//
//        CGContextSetLineWidth(currenctContext, _lineWidth);
//        CGContextSetLineJoin(currenctContext,kCGLineJoinRound);
//
//        CGContextMoveToPoint(currenctContext,x1, y1);
//        CGContextAddLineToPoint(currenctContext,x2, y2);
//        CGContextStrokePath(currenctContext);
// }

// clipping image
//+ (UIImage *)maskedImage {
//  CGRect rect = CGRectZero;
//  rect.size = self.image.size;
//
//  UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
//
//  UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
//  [clipPath appendPath:self.paths[1]];
//  clipPath.usesEvenOddFillRule = YES;
//
//  CGContextSaveGState(UIGraphicsGetCurrentContext());
//  {
//    [clipPath addClip];
//    [[UIColor orangeColor] setFill];
//    [self.paths[0] fill];
//  }
//  CGContextRestoreGState(UIGraphicsGetCurrentContext());
//
//  UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//
//
//  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
//  {
//    CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
//    [self.originalImage drawAtPoint:CGPointZero];
//  }
//  UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//
//  return maskedImage;
//}

//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef currenctContext = UIGraphicsGetCurrentContext();
//    [[UIColor blackColor] set];
//
//    CGContextSetLineWidth(currenctContext, _lineWidth);
//    CGContextSetLineJoin(currenctContext,kCGLineJoinRound);
//
//    CGContextMoveToPoint(currenctContext,x1, y1);
//    CGContextAddLineToPoint(currenctContext,x2, y2);
//    CGContextStrokePath(currenctContext);
//}

#pragma mark - PIECHART SUBVIEW

- (void)didAddSubview:(UIView *)subview {
}

- (void)addSubview:(UIView *)view {
////}
////
////#pragma mark - PIECHART DEMO
////
////- (void)viewDidLoad {
//self.slices = [NSMutableArray arrayWithCapacity:10];
//
//for (int i = 0; i < 5; i++) {
//NSNumber *one = [NSNumber numberWithInt:rand() % 60 + 20];
//[_slices addObject:one];
//}
//
//[self.pieChartLeft setDataSource:self];
//[self.pieChartLeft setStartPieAngle:M_PI_2];
//[self.pieChartLeft setAnimationSpeed:1.0];
//[self.pieChartLeft
//setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
//[self.pieChartLeft setLabelRadius:160];
//[self.pieChartLeft setShowPercentage:YES];
//[self.pieChartLeft
//setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
//[self.pieChartLeft setPieCenter:CGPointMake(240, 240)];
//[self.pieChartLeft setUserInteractionEnabled:NO];
//[self.pieChartLeft setLabelShadowColor:[UIColor blackColor]];
//
//[self.pieChartRight setDelegate:self];
//[self.pieChartRight setDataSource:self];
//[self.pieChartRight setPieCenter:CGPointMake(240, 240)];
////[self.pieChartRight setShowPercentage:NO];
//[self.pieChartRight setLabelColor:[UIColor blackColor]];
//
////[self.percentageLabel.layer setCornerRadius:90];
//
//self.sliceColors = [NSArray arrayWithObjects:[UIColor colorWithRed:246 / 255.0
//                       green:155 / 255.0
//                        blue:0 / 255.0
//                       alpha:1],
//       [UIColor colorWithRed:129 / 255.0
//                       green:195 / 255.0
//                        blue:29 / 255.0
//                       alpha:1],
//       [UIColor colorWithRed:62 / 255.0
//                       green:173 / 255.0
//                        blue:219 / 255.0
//                       alpha:1],
//       [UIColor colorWithRed:229 / 255.0
//                       green:66 / 255.0
//                        blue:115 / 255.0
//                       alpha:1],
//       [UIColor colorWithRed:148 / 255.0
//                       green:141 / 255.0
//                        blue:139 / 255.0
//                       alpha:1],
//       nil];
//
//// rotate up arrow
//// self.downArrow.transform = CGAffineTransformMakeRotation(M_PI);
}

//- (void)viewDidUnload {
//  [self setPieChartLeft:nil];
//  [self setPieChartRight:nil];
//  [self setPercentageLabel:nil];
//  [self setSelectedSliceLabel:nil];
//  [self setIndexOfSlices:nil];
//  [self setNumOfSlices:nil];
//  [self setDownArrow:nil];
//  [super viewDidUnload];
//}

//- (void)viewWillAppear:(BOOL)animated {
//  [super viewWillAppear:animated];
//}

//- (void)viewDidAppear:(BOOL)animated {
//  [super viewDidAppear:animated];
//  [self.pieChartLeft reloadData];
//  [self.pieChartRight reloadData];
//}

//- (void)viewWillDisappear:(BOOL)animated {
//  [super viewWillDisappear:animated];
//}

//- (void)viewDidDisappear:(BOOL)animated {
//  [super viewDidDisappear:animated];
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:
//    (UIInterfaceOrientation)interfaceOrientation {
//  // Return YES for supported orientations
//  return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//}

//- (IBAction)SliceNumChanged:(id)sender {
//  UIButton *btn = (UIButton *)sender;
//  NSInteger num = self.numOfSlices.text.intValue;
//  if (btn.tag == 100 && num > -10)
//    num = num - ((num == 1) ? 2 : 1);
//  if (btn.tag == 101 && num < 10)
//    num = num + ((num == -1) ? 2 : 1);
//
//  self.numOfSlices.text = [NSString stringWithFormat:@"%d", num];
//}

//- (IBAction)clearSlices {
//  [_slices removeAllObjects];
//  [self.pieChartLeft reloadData];
//  [self.pieChartRight reloadData];
//}

//- (IBAction)addSliceBtnClicked:(id)sender {
//  NSInteger num = [self.numOfSlices.text intValue];
//  if (num > 0) {
//    for (int n = 0; n < abs(num); n++) {
//      NSNumber *one = [NSNumber numberWithInt:rand() % 60 + 20];
//      NSInteger index = 0;
//      if (self.slices.count > 0) {
//        switch (self.indexOfSlices.selectedSegmentIndex) {
//        case 1:
//          index = rand() % self.slices.count;
//          break;
//        case 2:
//          index = self.slices.count - 1;
//          break;
//        }
//      }
//      [_slices insertObject:one atIndex:index];
//    }
//  } else if (num < 0) {
//    if (self.slices.count <= 0)
//      return;
//    for (int n = 0; n < abs(num); n++) {
//      NSInteger index = 0;
//      if (self.slices.count > 0) {
//        switch (self.indexOfSlices.selectedSegmentIndex) {
//        case 1:
//          index = rand() % self.slices.count;
//          break;
//        case 2:
//          index = self.slices.count - 1;
//          break;
//        }
//        [_slices removeObjectAtIndex:index];
//      }
//    }
//  }
//  [self.pieChartLeft reloadData];
//  [self.pieChartRight reloadData];
//}

//- (IBAction)updateSlices {
//  for (int i = 0; i < _slices.count; i++) {
//    [_slices replaceObjectAtIndex:i
//                       withObject:[NSNumber numberWithInt:rand() % 60 + 20]];
//  }
//  [self.pieChartLeft reloadData];
//  [self.pieChartRight reloadData];
//}
//
//- (IBAction)showSlicePercentage:(id)sender {
//  UISwitch *perSwitch = (UISwitch *)sender;
//  [self.pieChartRight setShowPercentage:perSwitch.isOn];
//}

#pragma mark - ClusterViewPieChartPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(ClusterViewPieChart *)pieChart {
  NSUInteger numOfSlices = 0;
  if (_numOfAnnotationsWithoutRating) {
    numOfSlices++;
  }
  if (_numOfAnnotationsWithGoodRating) {
    numOfSlices++;
  }
  if (_numOfAnnotationsWithBadRating) {
    numOfSlices++;
  }
  return numOfSlices;
  // return self.slices.count;
}

- (CGFloat)pieChart:(ClusterViewPieChart *)pieChart
    valueForSliceAtIndex:(NSUInteger)index {
  return [[self.slices objectAtIndex:index] intValue];
}

//- (UIColor *)pieChart:(ClusterViewPieChart *)pieChart
// colorForSliceAtIndex:(NSUInteger)index {
//  if (pieChart == self.pieChartRight)
//    return nil;
//  return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
//}

//#pragma mark - ClusterViewPieChartPieChart Delegate
//- (void)pieChart:(ClusterViewPieChartPieChart *)pieChart
//    willSelectSliceAtIndex:(NSUInteger)index {
//  NSLog(@"will select slice at index %d", index);
//}

//- (void)pieChart:(ClusterViewPieChartPieChart *)pieChart
//    willDeselectSliceAtIndex:(NSUInteger)index {
//  NSLog(@"will deselect slice at index %d", index);
//}

//- (void)pieChart:(ClusterViewPieChartPieChart *)pieChart
//    didDeselectSliceAtIndex:(NSUInteger)index {
//  NSLog(@"did deselect slice at index %d", index);
//}

//- (void)pieChart:(ClusterViewPieChartPieChart *)pieChart
//    didSelectSliceAtIndex:(NSUInteger)index {
//  NSLog(@"did select slice at index %d", index);
//  self.selectedSliceLabel.text =
//      [NSString stringWithFormat:@"$%@", [self.slices objectAtIndex:index]];
//}

@end
