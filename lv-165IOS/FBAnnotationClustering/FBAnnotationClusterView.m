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
  double partOfAnnotationsWithoutRating;
  double partOfAnnotationsWithBadRating;
  double partOfAnnotationsWithGoodRating;
} PieChartSegments;

@interface FBAnnotationClusterView ()

@property(strong, nonatomic) NSMutableArray *segmentSizesArray;
@property(strong, nonatomic) NSMutableArray *segmentsArray;

@property(nonatomic) CGFloat partOfAnnotationsWithoutRating;
@property(nonatomic) CGFloat partOfAnnotationsWithGoodRating;
@property(nonatomic) CGFloat partOfAnnotationsWithBadRating;

@property(nonatomic) NSMutableArray *numberofAnnotationsByRating;

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

static CGFloat radianConversionFactor = M_PI / 180;

- (void)calculatePieChartSegmentSizes {

  // AnnotationsPresentByRating annotationsPresentByRating;
  _segmentsArray = [NSMutableArray new];
  _segmentSizesArray = [NSMutableArray new];

  NumberOfAnnotationsByRating numberOfAnnotationsByRating;
  PieChartSegments pieChartSegments;

  numberOfAnnotationsByRating.numOfAnnotationsWithBadRating = 0;
  numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating = 0;
  numberOfAnnotationsByRating.numOfAnnotationsWithoutRating = 0;

  pieChartSegments.partOfAnnotationsWithoutRating = 0;
  pieChartSegments.partOfAnnotationsWithGoodRating = 0;
  pieChartSegments.partOfAnnotationsWithBadRating = 0;

  //    _annotationsWithoutRating = [NSMutableArray new];
  //    _annotationsWithBadRating = [NSMutableArray new];
  //    _annotationsWithGoodRating = [NSMutableArray new];

  for (HMMapAnnotation *annotation in self.annotation.annotations) {
    switch (annotation.ratingForColor) {

    case senseLess:

      //  [_annotationsWithoutRating addObject:annotation];
      numberOfAnnotationsByRating.numOfAnnotationsWithoutRating++;
      break;
    case badRating:

      // [_annotationsWithBadRating addObject:annotation];
      numberOfAnnotationsByRating.numOfAnnotationsWithBadRating++;
      break;
    case veryGoodRating:

      // [_annotationsWithGoodRating addObject:annotation];
      numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating++;
      break;
    }
  }

  //  _numberofAnnotationsByRating = [[NSMutableArray
  //  alloc]initWithObjects:numberOfAnnotationsByRating.numOfAnnotationsWithBadRating,
  //    numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating,
  //                           numberOfAnnotationsByRating.numOfAnnotationsWithoutRating,
  //                           nil];

  NSUInteger total =
      numberOfAnnotationsByRating.numOfAnnotationsWithBadRating +
      numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating +
      numberOfAnnotationsByRating.numOfAnnotationsWithoutRating;

  pieChartSegments.partOfAnnotationsWithoutRating =
      (double)numberOfAnnotationsByRating.numOfAnnotationsWithoutRating / total;

  pieChartSegments.partOfAnnotationsWithGoodRating =
      (double)numberOfAnnotationsByRating.numOfAnnotationsWithGoodRating /
      total;

  pieChartSegments.partOfAnnotationsWithBadRating =
      (double)numberOfAnnotationsByRating.numOfAnnotationsWithBadRating / total;

  //   NSUInteger total =   _annotationsWithoutRating.count +
  //                       _annotationsWithBadRating.count +
  //                       _annotationsWithGoodRating.count;

  //  self.partOfAnnotationsWithoutRating = (CGFloat)
  //  _annotationsWithoutRating.count / total;
  //  self.partOfAnnotationsWithGoodRating = (CGFloat)
  //  _annotationsWithGoodRating.count / total;
  //  self.partOfAnnotationsWithBadRating =  (CGFloat)
  //  _annotationsWithBadRating.count / total;

  if (pieChartSegments.partOfAnnotationsWithoutRating) {
    NSNumber *rating = [NSNumber numberWithUnsignedInteger:senseLess];

    NSNumber *segmentSize = [NSNumber
        numberWithFloat:pieChartSegments.partOfAnnotationsWithoutRating];

    NSNumber *numOfAnnotationsWithoutRating =
        [NSNumber numberWithInt:numberOfAnnotationsByRating
                                    .numOfAnnotationsWithoutRating];

    NSDictionary *segmentOfAnnotationsWithoutRating = [[NSDictionary alloc]
        initWithObjectsAndKeys:rating, @"type", segmentSize, @"size",
                               numOfAnnotationsWithoutRating,
                               @"annotationsCount", @0, @"startAngle", @0,
                               @"endAngle", nil];

    [_segmentsArray addObject:segmentOfAnnotationsWithoutRating];
  }
  if (pieChartSegments.partOfAnnotationsWithGoodRating) {

    NSNumber *numOfAnnotationsWithGoodRating =
        [NSNumber numberWithInt:numberOfAnnotationsByRating
                                    .numOfAnnotationsWithGoodRating];
    NSNumber *rating = [NSNumber numberWithUnsignedInteger:veryGoodRating];

    NSNumber *segmentSize = [NSNumber
        numberWithFloat:pieChartSegments.partOfAnnotationsWithGoodRating];

    NSDictionary *segmentOfAnnotationsWithGoodRating = [[NSDictionary alloc]
        initWithObjectsAndKeys:rating, @"type", segmentSize, @"size",
                               numOfAnnotationsWithGoodRating,
                               @"annotationsCount", @0, @"startAngle", @0,
                               @"endAngle", nil];

    [_segmentsArray addObject:segmentOfAnnotationsWithGoodRating];
  }
  if (pieChartSegments.partOfAnnotationsWithBadRating) {
    NSNumber *numOfAnnotationsWithBadRating =
        [NSNumber numberWithInt:numberOfAnnotationsByRating
                                    .numOfAnnotationsWithBadRating];
    NSNumber *segmentSize = [NSNumber
        numberWithFloat:pieChartSegments.partOfAnnotationsWithBadRating];
    NSNumber *rating = [NSNumber numberWithUnsignedInteger:badRating];

    NSDictionary *segmentOfAnnotationsWithBadRating = [[NSDictionary alloc]
        initWithObjectsAndKeys:rating, @"type", segmentSize, @"size",
                               numOfAnnotationsWithBadRating,
                               @"annotationsCount", @0, @"startAngle", @0,
                               @"endAngle", nil];

    [_segmentsArray addObject:segmentOfAnnotationsWithBadRating];
  }

  // return [_segmentSizesArray copy];
}

- (id)initWithAnnotation:(FBAnnotationCluster *)annotation
       clusteringManager:(FBClusteringManager *)clusteringManager {

  _clusteringManager = clusteringManager;

  //- (id)initWithAnnotation:(id<MKAnnotation>)annotation
  //         reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithAnnotation:annotation reuseIdentifier:nil];
  if (self != nil) {

    // FBAnnotationCluster *clusterAnnotation = (FBAnnotationCluster
    // *)annotation;

    self.frame = CGRectMake(0, 0, 40, 40);
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

- (void)drawRect:(CGRect)rect {

  NSArray *coloursArray = [[NSArray alloc]
      initWithObjects:_clusteringManager.noneRatingColour,
                      _clusteringManager.badRatingColour,
                      _clusteringManager.goodRatingColour, nil];

  CGRect circleRect = CGRectInset(self.bounds, 1, 1);
  CGPoint center =
      CGPointMake(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));

  //  UIBezierPath *circularPath = [UIBezierPath
  //  bezierPathWithRoundedRect:self.bounds
  //                               cornerRadius:self.bounds.size.height / 2.0];
  //    [circularPath addClip];

  // CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2,
  // rect.origin.y + rect.size.height / 2);

  // CGFloat radius = rect.size.width / 2;

  //    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);

  // CGContextAddEllipseInRect(context, CGRectInset(rect, 2.0, 2.0));

  // CGContextMoveToPoint(context, center.x, center.y);

  // NSUInteger numOfPieChartSegments = [self countPieChartSegments];

  [self calculatePieChartSegmentSizes];

  //    if (pieChartSegments.partOfAnnotationsWithoutRating ) {
  //        _noneRatingColour;
  //        CGFloat angle = 360 *
  //        pieChartSegments.partOfAnnotationsWithoutRating;
  //        currentAngle;
  //    }
  //
  //    if (pieChartSegments.partOfAnnotationsWithBadRating) {
  //        _badRatingColour;
  // currentAngle;
  //    }
  //
  //    if (pieChartSegments.partOfAnnotationsWithGoodRating) {
  //        _goodRatingColour;
  //        currentAngle;
  //    }

  // MARK: segment struct

  //    segment.colour =
  //    segment.size (nsnumber) =
  //    segment.annotationsCount

  // struct segment = .type , .size , .annotationsCount , .colour
  // .type is ns_enum, colour = array[.type] or dictionary

  // segment size - no order, if array index, need to bypass nil by checking
  // if(!array[i] == nil )
  // segment color - array index

  [_segmentsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                               BOOL *stop) {

    NSMutableDictionary *segment = [obj mutableCopy];
    // _segmentsArray[idx];

    NSNumber *segmentType = segment[@"type"];
    NSNumber *segmentSize = segment[@"size"];
    NSNumber *numberOfAnnotations = segment[@"annotationsCount"];

    CGFloat startAngle = 0;
    CGFloat endAngle = 360 * radianConversionFactor;

    //  otherwise put outside with __block CGFloat currentAngle = 0;

    // start angle
    if (idx == 0) {
      startAngle = 0;
      // [segment setObject:[NSNumber numberWithFloat:startAngle]
      // forKey:@"startAngle"];
      // *stop = YES;    // Stop enumerating
      // return;
    } else {
      NSNumber *previousSegment = _segmentsArray[idx - 1];
      startAngle = previousSegment.doubleValue;

      //   [segment setObject:[NSNumber numberWithFloat:startAngle]
      //   forKey:@"startAngle"];
      // startAngle = currentAngle;
    }

    // end angle
    if (idx == _segmentsArray.count - 1) {
      endAngle = 360 * radianConversionFactor;
      //  [segment setObject:[NSNumber numberWithFloat:endAngle]
      //  forKey:@"startAngle"];
    } else {

      endAngle = 360 * radianConversionFactor * segmentSize.doubleValue;
      //  [segment setObject:[NSNumber numberWithFloat:endAngle]
      //  forKey:@"startAngle"];
    }

    //  for (unsigned int i = 0; i < _segmentSizesArray.count; i++) {
    //
    //    NSNumber *num;
    //    // start angle
    //    if (i == 0) {
    //      startAngle = 0;
    //    } else {
    //      startAngle = currentAngle;
    //    }
    //
    //    // end angle
    //    if (i == _segmentSizesArray.count - 1) {
    //      endAngle = 360 * radianConversionFactor;
    //    } else {
    //
    //      num = _segmentSizesArray[i];
    //
    //      endAngle = 360 * radianConversionFactor * num.doubleValue;
    //    }

    // currentAngle = endAngle;

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGMutablePathRef arc = CGPathCreateMutable();
    CGPathMoveToPoint(arc, NULL, center.x, center.y);

    // RatingForPin rating = (RatingForPin)segment[@"type"];

    UIColor *color = coloursArray[segmentType.unsignedIntegerValue];

    CGContextSetFillColorWithColor(context, color.CGColor);

    CGContextSetStrokeColorWithColor(
        context, [UIColor colorWithRed:1 green:1 blue:1 alpha:1.000].CGColor);

    // CGPathRef donutSegment = CGPathCreateCopyByStrokingPath(  arc, NULL,
    // lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
    // CGContextAddPath(context, donutSegment);

    CGPathAddArc(arc, NULL, center.x, center.y, rect.size.width / 2, startAngle,
                 endAngle, YES);

    CGPathCloseSubpath(arc);


    // pieSegmentCenter

    // MARK: !!!!get segment bpunding box
    CGRect pieSegmentRect = CGPathGetPathBoundingBox(arc);

    //      CGPoint pieSegmentCenter =
    //      CGPointMake(CGRectGetMidX(pieSegmentRect),
    //      CGRectGetMidY(pieSegmentRect));

    // NSLog(@"pieSegmentCenter
    // x:%f,y:%f",pieSegmentCenter.x,pieSegmentCenter.y);

    // NSLog(@"%@",pieSegmentRect);

    CGContextAddPath(context, arc);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextFillPath(context);

    //      CGContextAddArc(context, center.x, center.y, radius,
    //      startAngle,angle1, 0);
    //      CGContextClosePath(context);
    //      CGContextFillPath(context);

    //    donutSegment = CGPathCreateCopyByStrokingPath(       arc, NULL,
    //    lineWidth, kCGLineCapButt, kCGLineJoinMiter, 10);
    //    CGContextAddPath(context, donutSegment);

    // CGRect textRect = CGRectMake(xPosition, yPosition, canvasWidth,
    // canvasHeight);

    //      NSDictionary *attrDict = [NSDictionary
    //      dictionaryWithObjectsAndKeys:labelFont,
    //                                NSFontAttributeName,
    //                                paragraphStyle,
    //                                NSParagraphStyleAttributeName,
    //                                nil];
    //
    //
    //      //assume your maximumSize contains {255, MAXFLOAT}
    //      CGRect lblRect = [text boundingRectWithSize:(CGSize){225, MAXFLOAT}
    //                                          options:NSStringDrawingUsesLineFragmentOrigin
    //                                       attributes:attrDict
    //                                          context:nil];
    //      CGSize labelHeighSize = lblRect.size;

    //  NSString *string = [[NSString alloc] initWithFormat:@"%f",
    //  num.doubleValue];

    NSString *string = [[NSString alloc]
        initWithFormat:@"%ld", (long)numberOfAnnotations.integerValue];

    NSMutableParagraphStyle *textStyle =
        NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;

    UIFont *font = [UIFont systemFontOfSize:10];

    // use standard size to prevent error accrual

    //      CGSize sampleSize = [string sizeWithAttributes:[NSDictionary
    //      dictionaryWithObjectsAndKeys:sampleFont, NSFontAttributeName, nil]];
    //      CGFloat scale = MIN((sampleSize.width-10) / sampleSize.width,
    //      (sampleSize.height-10) / sampleSize.height);
    //
    //    text.font = [UIFont fontWithDescriptor:font.fontDescriptor size:scale
    //    * sampleFont.pointSize];

    // CGFloat fontSize = 30;
    //      NSDictionary *textFontAttributes = @{
    //                                           NSFontAttributeName : [UIFont
    //                                           fontWithName:@"Helvetica"
    //                                           size:fontSize],
    //                                           //
    //                                           NSForegroundColorAttributeName
    //                                           : UIColor.redColor,
    //                                           NSParagraphStyleAttributeName :
    //                                           textStyle
    //                                           };

    //      while (fontSize > 0.0)
    //      {
    //          CGSize size = [string boundingRectWithSize:pieSegmentRect.size
    //          options:nil attributes:textFontAttributes context:nil];
    //
    //        //[UIFont fontWithName:@"Verdana" size:fontSize]
    //
    ////         pieSegmentRect
    //
    //          if (size.height <= pieSegmentRect.size.height) break;
    //
    //          fontSize -= 1.0;
    //      }

    [string drawInRect:pieSegmentRect withAttributes:nil];

    //
    //      if (_ctframe != NULL) CFRelease(_ctframe);
    //
    //      if (_framesetter != NULL) CFRelease(_framesetter);
    //
    //      //Creates an immutable framesetter object from an attributed string.
    //      //Use here the attributed string with which to construct the
    //      framesetter object.
    //      CTFramesetterRef * framesetter =
    //      CTFramesetterCreateWithAttributedString((__bridge
    //                                                                                CFAttributedStringRef)self.attributedString);
    //
    //
    //      //Creates a mutable graphics path.
    //      CGMutablePathRef mainPath = CGPathCreateMutable();
    //
    //      if (!_path) {
    //          CGPathAddRect(mainPath, NULL, CGRectMake(0, 0,
    //          self.bounds.size.width, self.bounds.size.height));
    //      } else {
    //          CGPathAddPath(mainPath, NULL, _path);
    //      }
    //
    //      //This call creates a frame full of glyphs in the shape of the path
    //      //provided by the path parameter. The framesetter continues to fill
    //      //the frame until it either runs out of text or it finds that text
    //      //no longer fits.
    //      CTFrameRef drawFrame = CTFramesetterCreateFrame(_framesetter,
    //      CFRangeMake(0, 0),
    //                                                      mainPath, NULL);
    //
    //      CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    //      CGContextTranslateCTM(context, 0, self.bounds.size.height);
    //      CGContextScaleCTM(context, 1.0, -1.0);
    //      // draw text
    //      CTFrameDraw(drawFrame, context);
    //
    //      //clean up
    //      if (drawFrame) CFRelease(drawFrame);
    //      CGPathRelease(mainPath);


      //MARK:UIGraphicsBeginImageContextWithOptions
//try opaque context
//    UIGraphicsBeginImageContextWithOptions(<#CGSize size#>, yes, <#CGFloat scale#>)

//   CGContextRef context = UIGraphicsGetCurrentContext();

//      UIGraphicsEndImageContext();
//      UIGraphicsPopContext();


//      // First fill the background with white.
//      CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
//      CGContextFillRect(context,pageRect);
//      CGContextSaveGState(context);
//
//
//      // Flip the context so that the PDF page is rendered right side up
//      CGContextTranslateCTM(context, 0.0, pageRect.size.height);
//      CGContextScaleCTM(context, 1.0, -1.0);

//Coordinate space transformations

// Scale the context so that the PDF page is rendered at the

// correct size for the zoom level.

// Scale the current graphics state's transformation matrix (the CTM)

// CGContextScaleCTM(context, pdfScale,pdfScale);

//      CGContextDrawPDFPage(context, page);

//      CGContextRestoreGState(context);

//      UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();

//      UIGraphicsEndImageContext();


  }];
}

- (void)appendBezierArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle fillColor:(UIColor*)color toBezierPath:(UIBezierPath*)path{

   // attach to UIBezierPath *path = [UIBezierPath bezierPath];
    UIBezierPath *slicePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius
  startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path moveToPoint:center];
    [path appendPath:slicePath];
    [path addLineToPoint:center];
    [color setFill];
    [[UIColor whiteColor]setStroke];
    [path stroke];
    [path fill];
}

- (CGPoint)findArcEndPointInView:(UIView *) view withRadius:(CGFloat)radius angle:(CGFloat)angle{

CGFloat shortest_side = MIN(view.bounds.size.width, view.bounds.size.height);
CGFloat x = roundf(cosf(angle)* radius+shortest_side/2) ;
CGFloat y = roundf(sinf(angle)* radius+shortest_side/2);
CGPoint point = CGPointMake (x, y);
    return point;
}


////try UIBezierPath methods with controlPoints
//- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;
//- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;



//MARK:Animation
//-(void)drawCircleInView:(UIView *)view {
//
//CAShapeLayer *layer = [CAShapeLayer layer];
//layer.strokeStart = 0;
//layer.strokeEnd = 0;
//layer.delegate = view;
//
//NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
//layer.strokeColor = [UIColor redColor].CGColor;
//layer.fillColor = [UIColor clearColor].CGColor;
//UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(60, 100, 200, 200)];
//layer.path = path.CGPath;
////ViewController
////self.layer = layer;
////[self.view.layer addSublayer:view.layer];
//}
//- (void)update {
////ViewController
//    if (self.layer.strokeEnd >= 1.0) {
//        if (self.layer.strokeStart <= 1.0) {
//            self.layer.strokeStart += 0.05;
//        }else{
//
//            self.layer.strokeEnd = 0;
//            self.layer.strokeStart = 0;
//        }
//    }else {
//        self.layer.strokeEnd += 0.05;
//
//    }
//}


//// fill with yellow
//rectShape.fillColor = UIColor.yellowColor().CGColor
//
//// 1
//// begin with a circle with a 50 points radius
//let startShape = UIBezierPath(roundedRect: bounds, cornerRadius: 50).CGPath
//// animation end with a large circle with 500 points radius
//let endShape = UIBezierPath(roundedRect: CGRect(x: -450, y: -450, width: 1000, height: 1000), cornerRadius: 500).CGPath
//
//// set initial shape
//rectShape.path = startShape
//
//// 2
//// animate the `path`
//let animation = CABasicAnimation(keyPath: "path")
//animation.toValue = endShape
//animation.duration = 1 // duration is 1 sec
//// 3
//animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
//animation.fillMode = kCAFillModeBoth // keep to value after finishing
//animation.removedOnCompletion = false // don't remove after finishing
//// 4
//rectShape.addAnimation(animation, forKey: animation.keyPath)


//-(CGFloat)scaleToAspectFit:(CGSize)source into:(CGSize)into
// padding:(float)padding
//{
//    return MIN((into.width-padding) / source.width, (into.height-padding) /
//    source.height);
//}

- (UIFont *)fontSizedForAreaSize:(CGSize)size
                      withString:(NSString *)string
                       usingFont:(UIFont *)font;
{
  UIFont *sampleFont = [UIFont
      fontWithDescriptor:font.fontDescriptor
                    size:12.]; // use standard size to prevent error accrual
  CGSize sampleSize = [string
      sizeWithAttributes:
          [NSDictionary dictionaryWithObjectsAndKeys:sampleFont,
                                                     NSFontAttributeName, nil]];
  CGFloat scale = MIN((sampleSize.width - 10) / sampleSize.width,
                      (sampleSize.height - 10) / sampleSize.height);

  return [UIFont fontWithDescriptor:font.fontDescriptor
                               size:scale * sampleFont.pointSize];
}

// -(UIImage *)drawClusterImage{
// UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
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

- (void)drawtext {
  //
  //    if (_ctframe != NULL) CFRelease(_ctframe);
  //
  //    if (_framesetter != NULL) CFRelease(_framesetter);
  //
  //    //Creates an immutable framesetter object from an attributed string.
  //    //Use here the attributed string with which to construct the framesetter
  //    object.
  //    CTFramesetterRef * framesetter =
  //    CTFramesetterCreateWithAttributedString((__bridge
  //                                                            CFAttributedStringRef)self.attributedString);
  //
  //
  //    //Creates a mutable graphics path.
  //    CGMutablePathRef mainPath = CGPathCreateMutable();
  //
  //    if (!_path) {
  //        CGPathAddRect(mainPath, NULL, CGRectMake(0, 0,
  //        self.bounds.size.width, self.bounds.size.height));
  //    } else {
  //        CGPathAddPath(mainPath, NULL, _path);
  //    }
  //
  //    //This call creates a frame full of glyphs in the shape of the path
  //    //provided by the path parameter. The framesetter continues to fill
  //    //the frame until it either runs out of text or it finds that text
  //    //no longer fits.
  //    CTFrameRef drawFrame = CTFramesetterCreateFrame(_framesetter,
  //    CFRangeMake(0, 0),
  //                                                    mainPath, NULL);
  //
  //    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
  //    CGContextTranslateCTM(context, 0, self.bounds.size.height);
  //    CGContextScaleCTM(context, 1.0, -1.0);
  //    // draw text
  //    CTFrameDraw(drawFrame, context);
  //
  //    //clean up
  //    if (drawFrame) CFRelease(drawFrame);
  //    CGPathRelease(mainPath);
}

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

#pragma mark - calculating number Of Annotations ByRating

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
//    //    for  (HMMapAnnotation * annotation in
//    clusterAnnotation.annotations){
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

#pragma mark - PIECHART SUBVIEW

- (void)didAddSubview:(UIView *)subview {
}

- (void)addSubview:(UIView *)view {
  ////}
  ////
  ////#pragma mark - PIECHART DEMO
  ////
  ////- (void)viewDidLoad {
  // self.slices = [NSMutableArray arrayWithCapacity:10];
  //
  // for (int i = 0; i < 5; i++) {
  // NSNumber *one = [NSNumber numberWithInt:rand() % 60 + 20];
  //[_slices addObject:one];
  //}
  //
  //[self.pieChartLeft setDataSource:self];
  //[self.pieChartLeft setStartPieAngle:M_PI_2];
  //[self.pieChartLeft setAnimationSpeed:1.0];
  //[self.pieChartLeft
  // setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
  //[self.pieChartLeft setLabelRadius:160];
  //[self.pieChartLeft setShowPercentage:YES];
  //[self.pieChartLeft
  // setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
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
  // self.sliceColors = [NSArray arrayWithObjects:[UIColor colorWithRed:246 /
  // 255.0
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

//- (NSUInteger)numberOfSlicesInPieChart:(ClusterViewPieChart *)pieChart {
//  NSUInteger numOfSlices = 0;
//  if (_numOfAnnotationsWithoutRating) {
//    numOfSlices++;
//  }
//  if (_numOfAnnotationsWithGoodRating) {
//    numOfSlices++;
//  }
//  if (_numOfAnnotationsWithBadRating) {
//    numOfSlices++;
//  }
//  return numOfSlices;
//  // return self.slices.count;
//}

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
