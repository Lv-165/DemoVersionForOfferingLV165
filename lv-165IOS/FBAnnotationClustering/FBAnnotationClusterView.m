//
//  FBAnnotationClusterView.m
//  lv-165IOS
//
//  Created by Admin on 12/7/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "FBAnnotationClusterView.h"
#import "ClusterViewPieChart.h"
#import "HMMapAnnotation.h"

@import QuartzCore;

@interface FBAnnotationClusterView ()

@property(strong, nonatomic) ClusterViewPieChart *pieChartRight;
@property(strong, nonatomic) ClusterViewPieChart *pieChartLeft;

//@property(strong, nonatomic) UILabel *percentageLabel;
//@property(strong, nonatomic) UILabel *selectedSliceLabel;

//@property(strong, nonatomic) UISegmentedControl *indexOfSlices;

//@property(strong, nonatomic) UIButton *downArrow;
@property(assign, nonatomic) NSUInteger numOfSlices;
@property(nonatomic, strong) NSMutableArray *slices;

@property(nonatomic, strong) NSArray *sliceColors;

@end

@implementation FBAnnotationClusterView


- (void)divideAnnotationsByRating {
    _annotationsWithoutRating = [NSMutableArray new];
    _annotationsWithBadRating = [NSMutableArray new];
    _annotationsWithGoodRating = [NSMutableArray new];
    
    for (HMMapAnnotation *annotation in self.annotation.annotations) {

    switch (annotation.ratingForColor) {
    case senseLess:
      [_annotationsWithoutRating addObject:annotation];
      break;

    case badRating:
      [_annotationsWithBadRating addObject:annotation];
      break;

    case veryGoodRating:
      [_annotationsWithGoodRating addObject:annotation];
      break;
    }
  }
}


- (void)countAnnotationsByRating:
    (FBAnnotationCluster *)clusterAnnotation {

//    [self enumerateAnnotationsForRating];
//    _numOfAnnotationsWithoutRating = _annotationsWithoutRating.count;
//    _numOfAnnotationsWithBadRating = _annotationsWithBadRating.count;
//    _numOfAnnotationsWithGoodRating = _annotationsWithGoodRating.count;
    
  _numOfAnnotationsWithoutRating = 0;
  _numOfAnnotationsWithBadRating = 0;
  _numOfAnnotationsWithGoodRating = 0;

  for (HMMapAnnotation *annotation in clusterAnnotation.annotations) {

    switch (annotation.ratingForColor) {
    case senseLess:
      _numOfAnnotationsWithoutRating++;
      break;

    case badRating:
      _numOfAnnotationsWithBadRating++;
      break;

    case veryGoodRating:
      _numOfAnnotationsWithGoodRating++;
      break;
    }

    //    for  (HMMapAnnotation * annotation in clusterAnnotation.annotations){
    //        NSNumber * num = self.slices [annotation.ratingForColor];
    //        NSUInteger count = num.integerValue;
    //        count++;
    //    }
  }
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  if (self != nil) {

    FBAnnotationCluster *clusterAnnotation = (FBAnnotationCluster *)annotation;
    
    //ClusterViewPieChart *pieChartView = [ClusterViewPieChart alloc];

      
    self.image = [ClusterViewPieChart constructPieChartImage];

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


//MARK: UIGraphicsBeginImageContext

//+ (void)drawCircle:(CGRect)rect {
//
//  UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
//  CGContextRef ctx = UIGraphicsGetCurrentContext();
//  // Create the clipping path and add it
//  UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:imageRect];
//  [path addClip];
//  [image drawInRect:imageRect];
//
//  CGContextSetStrokeColorWithColor(ctx, [[UIColor greenColor] CGColor]);
//  [path setLineWidth:50.0f];
//  [path stroke];
//
//  UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//
//  self.imageView.image = roundedImage;
//}



// clipping image

//+ (UIImage *)maskedImage {
//  CGRect rect = CGRectZero;
//  rect.size = self.originalImage.size;
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



+ (UIImage *)drawInContext:(CGContextRef)context {

  CGRect circleRect = CGRectInset(self.bounds, 1, 1);
  CGFloat startAngle = -M_PI / 2;
  CGFloat endAngle = self.progress * 2 * M_PI + startAngle;

  CGColorRef outerPieColor = [[UIColor colorWithRed:137.0 / 255.0
                                              green:12.0 / 255.0
                                               blue:88.0 / 255.0
                                              alpha:1.0] CGColor];
  CGColorRef innerPieColor = [[UIColor colorWithRed:235.0 / 255.0
                                              green:214.0 / 255.0
                                               blue:227.0 / 255.0
                                              alpha:1.0] CGColor];
  CGColorRef arrowColor = [[UIColor whiteColor] CGColor];

  // Draw outer pie
  CGFloat outerRadius = CGRectGetMidX(circleRect);
  CGPoint center =
      CGPointMake(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));

  CGContextSetFillColorWithColor(context, outerPieColor);
  CGContextMoveToPoint(context, center.x, center.y);
  CGContextAddArc(context, center.x, center.y, outerRadius, startAngle,
                  endAngle, 0);
  CGContextClosePath(context);
  CGContextFillPath(context);

  // Draw inner pie
  CGFloat innerRadius = CGRectGetMidX(circleRect) * 0.45;

  CGContextSetFillColorWithColor(context, innerPieColor);
  CGContextMoveToPoint(context, center.x, center.y);
  CGContextAddArc(context, center.x, center.y, innerRadius, startAngle,
                  endAngle, 0);
  CGContextClosePath(context);
  CGContextFillPath(context);

  // Draw the White Line
  CGFloat lineRadius = CGRectGetMidX(circleRect) * 0.72;
  CGFloat arrowWidth = 0.35;

  CGContextSetStrokeColorWithColor(context, arrowColor);
  CGContextSetFillColorWithColor(context, arrowColor);

  CGMutablePathRef path = CGPathCreateMutable();
  CGContextSetLineWidth(context, 16);
  CGFloat lineEndAngle = ((endAngle - startAngle) >= arrowWidth)
                             ? endAngle - arrowWidth
                             : endAngle;
  CGPathAddArc(path, NULL, center.x, center.y, lineRadius, startAngle,
               lineEndAngle, 0);
  CGContextAddPath(context, path);
  CGContextStrokePath(context);

  // Draw the Triangle pointer
  CGFloat arrowStartAngle = lineEndAngle - 0.01;
  CGFloat arrowOuterRadius = CGRectGetMidX(circleRect) * 0.90;
  CGFloat arrowInnerRadius = CGRectGetMidX(circleRect) * 0.54;

  CGFloat arrowX = center.x + (arrowOuterRadius * cosf(arrowStartAngle));
  CGFloat arrowY = center.y + (arrowOuterRadius * sinf(arrowStartAngle));

  CGContextMoveToPoint(context, arrowX, arrowY); // top corner

  arrowX = center.x + (arrowInnerRadius * cosf(arrowStartAngle));
  arrowY = center.y + (arrowInnerRadius * sinf(arrowStartAngle));

  CGContextAddLineToPoint(context, arrowX, arrowY); // bottom corner

  arrowX = center.x + (lineRadius * cosf(endAngle));
  arrowY = center.y + (lineRadius * sinf(endAngle));

  CGContextAddLineToPoint(context, arrowX, arrowY); // point
  CGContextClosePath(context);
  CGContextFillPath(context);

  [super drawInContext:context];
}

//- (void)drawRect:(CGRect)rect
//{
//    UIBezierPath *circularPath = [UIBezierPath
//    bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.height
//    / 2.0];
//    [circularPath addClip];
//    //clip subsequent drawing to the inside of the path
//    [self.image drawInRect:self.bounds];
//}




#pragma mark - PIECHART SUBVIEW

-(void)didAddSubview:(UIView *)subview{
    
}

-(void)addSubview:(UIView *)view{
    
//}
//
//#pragma mark - PIECHART DEMO
//
//- (void)viewDidLoad {
  self.slices = [NSMutableArray arrayWithCapacity:10];

  for (int i = 0; i < 5; i++) {
    NSNumber *one = [NSNumber numberWithInt:rand() % 60 + 20];
    [_slices addObject:one];
  }

  [self.pieChartLeft setDataSource:self];
  [self.pieChartLeft setStartPieAngle:M_PI_2];
  [self.pieChartLeft setAnimationSpeed:1.0];
  [self.pieChartLeft
      setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
  [self.pieChartLeft setLabelRadius:160];
  [self.pieChartLeft setShowPercentage:YES];
  [self.pieChartLeft
      setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
  [self.pieChartLeft setPieCenter:CGPointMake(240, 240)];
  [self.pieChartLeft setUserInteractionEnabled:NO];
  [self.pieChartLeft setLabelShadowColor:[UIColor blackColor]];

  [self.pieChartRight setDelegate:self];
  [self.pieChartRight setDataSource:self];
  [self.pieChartRight setPieCenter:CGPointMake(240, 240)];
  //[self.pieChartRight setShowPercentage:NO];
  [self.pieChartRight setLabelColor:[UIColor blackColor]];

  [self.percentageLabel.layer setCornerRadius:90];

  self.sliceColors = [NSArray arrayWithObjects:[UIColor colorWithRed:246 / 255.0
                                                               green:155 / 255.0
                                                                blue:0 / 255.0
                                                               alpha:1],
                                               [UIColor colorWithRed:129 / 255.0
                                                               green:195 / 255.0
                                                                blue:29 / 255.0
                                                               alpha:1],
                                               [UIColor colorWithRed:62 / 255.0
                                                               green:173 / 255.0
                                                                blue:219 / 255.0
                                                               alpha:1],
                                               [UIColor colorWithRed:229 / 255.0
                                                               green:66 / 255.0
                                                                blue:115 / 255.0
                                                               alpha:1],
                                               [UIColor colorWithRed:148 / 255.0
                                                               green:141 / 255.0
                                                                blue:139 / 255.0
                                                               alpha:1],
                                               nil];

  // rotate up arrow
  self.downArrow.transform = CGAffineTransformMakeRotation(M_PI);
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
//
//- (void)viewWillAppear:(BOOL)animated {
//  [super viewWillAppear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//  [super viewDidAppear:animated];
//  [self.pieChartLeft reloadData];
//  [self.pieChartRight reloadData];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//  [super viewWillDisappear:animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//  [super viewDidDisappear:animated];
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:
//    (UIInterfaceOrientation)interfaceOrientation {
//  // Return YES for supported orientations
//  return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//}


- (IBAction)SliceNumChanged:(id)sender {
  UIButton *btn = (UIButton *)sender;
  NSInteger num = self.numOfSlices.text.intValue;
  if (btn.tag == 100 && num > -10)
    num = num - ((num == 1) ? 2 : 1);
  if (btn.tag == 101 && num < 10)
    num = num + ((num == -1) ? 2 : 1);

  self.numOfSlices.text = [NSString stringWithFormat:@"%d", num];
}

- (IBAction)clearSlices {
  [_slices removeAllObjects];
  [self.pieChartLeft reloadData];
  [self.pieChartRight reloadData];
}

- (IBAction)addSliceBtnClicked:(id)sender {
  NSInteger num = [self.numOfSlices.text intValue];
  if (num > 0) {
    for (int n = 0; n < abs(num); n++) {
      NSNumber *one = [NSNumber numberWithInt:rand() % 60 + 20];
      NSInteger index = 0;
      if (self.slices.count > 0) {
        switch (self.indexOfSlices.selectedSegmentIndex) {
        case 1:
          index = rand() % self.slices.count;
          break;
        case 2:
          index = self.slices.count - 1;
          break;
        }
      }
      [_slices insertObject:one atIndex:index];
    }
  } else if (num < 0) {
    if (self.slices.count <= 0)
      return;
    for (int n = 0; n < abs(num); n++) {
      NSInteger index = 0;
      if (self.slices.count > 0) {
        switch (self.indexOfSlices.selectedSegmentIndex) {
        case 1:
          index = rand() % self.slices.count;
          break;
        case 2:
          index = self.slices.count - 1;
          break;
        }
        [_slices removeObjectAtIndex:index];
      }
    }
  }
  [self.pieChartLeft reloadData];
  [self.pieChartRight reloadData];
}

- (IBAction)updateSlices {
  for (int i = 0; i < _slices.count; i++) {
    [_slices replaceObjectAtIndex:i
                       withObject:[NSNumber numberWithInt:rand() % 60 + 20]];
  }
  [self.pieChartLeft reloadData];
  [self.pieChartRight reloadData];
}

- (IBAction)showSlicePercentage:(id)sender {
  UISwitch *perSwitch = (UISwitch *)sender;
  [self.pieChartRight setShowPercentage:perSwitch.isOn];
}

#pragma mark - ClusterViewPieChartPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(ClusterViewPieChartPieChart *)pieChart {
  NSUInteger numOfSlices = 0;
  if (_numOfAnnotationsWithoutRating) {
    numOfSlices++
  }
  if (_numOfAnnotationsWithGoodRating) {
    numOfSlices++
  }
  if (_numOfAnnotationsWithBadRating) {
    numOfSlices++
  }
  return numOfSlices;
  // return self.slices.count;
}

- (CGFloat)pieChart:(ClusterViewPieChartPieChart *)pieChart
    valueForSliceAtIndex:(NSUInteger)index {
  return [[self.slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(ClusterViewPieChartPieChart *)pieChart
 colorForSliceAtIndex:(NSUInteger)index {
  if (pieChart == self.pieChartRight)
    return nil;
  return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

#pragma mark - ClusterViewPieChartPieChart Delegate
- (void)pieChart:(ClusterViewPieChartPieChart *)pieChart
    willSelectSliceAtIndex:(NSUInteger)index {
  NSLog(@"will select slice at index %d", index);
}
- (void)pieChart:(ClusterViewPieChartPieChart *)pieChart
    willDeselectSliceAtIndex:(NSUInteger)index {
  NSLog(@"will deselect slice at index %d", index);
}
- (void)pieChart:(ClusterViewPieChartPieChart *)pieChart
    didDeselectSliceAtIndex:(NSUInteger)index {
  NSLog(@"did deselect slice at index %d", index);
}
- (void)pieChart:(ClusterViewPieChartPieChart *)pieChart
    didSelectSliceAtIndex:(NSUInteger)index {
  NSLog(@"did select slice at index %d", index);
  self.selectedSliceLabel.text =
      [NSString stringWithFormat:@"$%@", [self.slices objectAtIndex:index]];
}

@end
