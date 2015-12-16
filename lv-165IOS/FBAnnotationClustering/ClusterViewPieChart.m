
#import "ClusterViewPieChart.h"
#import <QuartzCore/QuartzCore.h>

@interface SliceLayer : CAShapeLayer

@property(nonatomic) CGFloat progress;

@property(nonatomic, assign) CGFloat value;
@property(nonatomic, assign) CGFloat percentage;
@property(nonatomic, assign) double startAngle;
@property(nonatomic, assign) double endAngle;
@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, strong) NSString *text;

- (void)createArcAnimationForKey:(NSString *)key
                       fromValue:(NSNumber *)from
                         toValue:(NSNumber *)to
                        Delegate:(id)delegate;
@end

@implementation SliceLayer

//@dynamic progress;

- (void)drawInContext:(CGContextRef)ctx {
    
  CGPoint center =
      CGPointMake((self.bounds.size.width / 2) + self.centerOffset,
                  (self.bounds.size.height / 2) - self.centerOffset);
  CGFloat radius = MIN(center.x, center.y) - 25;
  radius *= self.pieScale;
  int clockwise = self.startAngle > self.endAngle;

  /* Clipping should be done first so the next path(s) are not creating the
   * clipping mask */
  CGContextMoveToPoint(ctx, center.x, center.y);
  CGContextAddArc(ctx, center.x, center.y, radius * 0.5, self.startAngle,
                  self.endAngle, !clockwise);
  // CGContextClipPath(ctx);
  CGContextClip(ctx);

  /* Now, start drawing your graph and filling things in... */
  CGContextBeginPath(ctx);
  CGContextMoveToPoint(ctx, center.x, center.y);

  CGPoint p1 = CGPointMake(center.x + radius * cosf(self.startAngle),
                           center.y + radius * sinf(self.startAngle));

  CGContextAddLineToPoint(ctx, p1.x, p1.y);
  CGContextAddArc(ctx, center.x, center.y, radius, self.startAngle,
                  self.endAngle, clockwise);
  CGContextClosePath(ctx);

  CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
  CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
  CGContextSetLineWidth(ctx, self.strokeWidth);

  self.pathRef = CGContextCopyPath(ctx);
  CGContextDrawPath(ctx, kCGPathFillStroke);

  // LABELS
  UIGraphicsPushContext(ctx);
  CGContextSetFillColorWithColor(ctx, self.labelColor.CGColor);

  CGFloat distance = [self angleDistance:(self.startAngle * 180 / M_PI)
                                  angle2:(self.endAngle * 180 / M_PI)];
  CGFloat arcDistanceAngle = distance * M_PI / 180;
  CGFloat arcCenterAngle = self.startAngle + arcDistanceAngle / 2;

  CGPoint labelPoint = CGPointMake(center.x + radius * cosf(arcCenterAngle),
                                   center.y + radius * sinf(arcCenterAngle));

  /*
   Basic drawing of lines to labels.. Disabled for now..
   CGContextBeginPath(ctx);
   CGContextMoveToPoint(ctx, labelPoint.x, labelPoint.y);
   */

  if (labelPoint.x <= center.x)
    labelPoint.x -= 50;
  else
    labelPoint.x += 5;

  if (labelPoint.y <= center.y)
    labelPoint.y -= 25;

  /*
   Basic drawing of lines to labels.. Disabled for now..
   CGContextAddLineToPoint(ctx, labelPoint.x, labelPoint.y);
   CGContextClosePath(ctx);

   CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
   CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
   CGContextSetLineWidth(ctx, self.strokeWidth);
   CGContextDrawPath(ctx, kCGPathFillStroke);
   */

  [self.labelString drawAtPoint:labelPoint
                       forWidth:50.0f
                       withFont:[UIFont systemFontOfSize:18]
                  lineBreakMode:NSLineBreakByClipping];
  UIGraphicsPopContext();
}

// + (BOOL)needsDisplayForKey:(NSString *)key {
//  // This is the core of what does animation for us. It
//  // tells CoreAnimation that it needs to redisplay on
//  // each new value of progress, including tweened ones.
//  return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
//}

//- (id)actionForKey:(NSString *)aKey {
//  // This is the other crucial half to tweening.
//  // The animation we return is compatible with that
//  // used by UIView, but it also enables implicit
//  // filling-up-the-pie animations.
//  if ([aKey isEqualToString:@"progress"]) {
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:aKey];
//    animation.fromValue = [self.presentationLayer valueForKey:aKey];
//    return animation;
//  }
//  return [super actionForKey:aKey];
//}

- (void)drawInContext:(CGContextRef)context {
  // This is the gold; the drawing of the pie itself.
  // In this code, it draws in a "HUD"-y style, using
  // the same color to fill as the border.
  CGRect circleRect = CGRectInset(self.bounds, 1, 1);

  CGColorRef borderColor = [[UIColor whiteColor] CGColor];
  CGColorRef backgroundColor =
      [[UIColor colorWithWhite:1.0 alpha:0.15] CGColor];

  CGContextSetFillColorWithColor(context, backgroundColor);
  CGContextSetStrokeColorWithColor(context, borderColor);
  CGContextSetLineWidth(context, 2.0f);

  CGContextFillEllipseInRect(context, circleRect);
  CGContextStrokeEllipseInRect(context, circleRect);

  CGFloat radius = MIN(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));
  CGPoint center = CGPointMake(radius, CGRectGetMidY(circleRect));
  CGFloat startAngle = -M_PI / 2;
  CGFloat endAngle = self.progress * 2 * M_PI + startAngle;
  CGContextSetFillColorWithColor(context, borderColor);
  CGContextMoveToPoint(context, center.x, center.y);
  CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
  CGContextClosePath(context);
  CGContextFillPath(context);

  [super drawInContext:context];
}

//    - (void)drawInContext:(CGContextRef)context {
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
//}

//    - (void)drawInContext:(CGContextRef)context {
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

- (void)drawInContext:(CGContextRef)context {
  CGRect circleRect = CGRectInset(self.bounds, 1, 1);

  UIColor *__autoreleasing borderColor = [UIColor whiteColor];
  UIColor *__autoreleasing backgroundColor =
      [UIColor colorWithWhite:0 alpha:0.75];

  CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
  CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
  CGContextSetLineWidth(context, 2.0f);

  CGContextFillEllipseInRect(context, circleRect);
  CGContextStrokeEllipseInRect(context, circleRect);

  CGFloat radius = MIN(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));
  CGPoint center = CGPointMake(radius, CGRectGetMidY(circleRect));
  CGFloat startAngle = -M_PI / 2;
  // need progress here
  NSUInteger progress = 50;
  CGFloat endAngle = progress * 2 * M_PI + startAngle;
  CGContextSetFillColorWithColor(context, borderColor.CGColor);
  CGContextMoveToPoint(context, center.x, center.y);
  CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
  CGContextClosePath(context);
  CGContextFillPath(context);

  [super drawInContext:context];
}

+ (void)drawCircle:(CGRect)rect {
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
  if ([key isEqualToString:@"startAngle"] ||
      [key isEqualToString:@"endAngle"]) {
    return YES;
  } else {
    return [super needsDisplayForKey:key];
  }
}

- (id)initWithLayer:(id)layer {
  if (self = [super initWithLayer:layer]) {
    if ([layer isKindOfClass:[SliceLayer class]]) {
      self.startAngle = [(SliceLayer *)layer startAngle];
      self.endAngle = [(SliceLayer *)layer endAngle];
    }
  }
  return self;
}

//- (void)createArcAnimationForKey:(NSString *)key
//                       fromValue:(NSNumber *)from
//                         toValue:(NSNumber *)to
//                        Delegate:(id)delegate {
//  CABasicAnimation *arcAnimation = [CABasicAnimation
//  animationWithKeyPath:key];
//  NSNumber *currentAngle = [[self presentationLayer] valueForKey:key];
//  if (!currentAngle)
//    currentAngle = from;
//  [arcAnimation setFromValue:currentAngle];
//  [arcAnimation setToValue:to];
//  [arcAnimation setDelegate:delegate];
//  [arcAnimation
//      setTimingFunction:[CAMediaTimingFunction
//                            functionWithName:kCAMediaTimingFunctionDefault]];
//  [self addAnimation:arcAnimation forKey:key];
//  [self setValue:to forKey:key];
//}

//- (NSString *)description {
//  return [NSString
//      stringWithFormat:@"value:%f, percentage:%0.0f, start:%f, end:%f",
//      _value,
//                       _percentage, _startAngle / M_PI * 180,
//                       _endAngle / M_PI * 180];
//}

@end

@interface ClusterViewPieChart (Private)
- (void)updateTimerFired:(NSTimer *)timer;
- (SliceLayer *)createSliceLayer;
- (CGSize)sizeThatFitsString:(NSString *)string;
- (void)updateLabelForLayer:(SliceLayer *)pieLayer value:(CGFloat)value;
- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection
                                         to:(NSUInteger)newSelection;
@end

@implementation ClusterViewPieChart {
  NSInteger _selectedSliceIndex;
  // pie view, contains all slices
  UIView *_pieView;

  // animation control
  NSTimer *_animationTimer;
  NSMutableArray *_animations;
}

static NSUInteger kDefaultSliceZOrder = 100;

static CGPathRef CGPathCreateArc(CGPoint center, CGFloat radius,
                                 CGFloat startAngle, CGFloat endAngle) {
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, center.x, center.y);

  CGPathAddArc(path, NULL, center.x, center.y, radius, startAngle, endAngle, 0);
  CGPathCloseSubpath(path);

  return path;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {

    self.backgroundColor = [UIColor clearColor];
    _pieView = [[UIView alloc] initWithFrame:frame];

    [_pieView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_pieView];

    _selectedSliceIndex = -1;
    _animations = [[NSMutableArray alloc] init];

    _animationSpeed = 0.5;
    _startPieAngle = M_PI_2 * 3;
    _selectedSliceStroke = 3.0;

    self.pieRadius = MIN(frame.size.width / 2, frame.size.height / 2) - 10;
    self.pieCenter = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    self.labelFont =
        [UIFont boldSystemFontOfSize:MAX((int)self.pieRadius / 10, 5)];
    _labelColor = [UIColor whiteColor];
    _labelRadius = _pieRadius / 2;
    _selectedSliceOffsetRadius = MAX(10, _pieRadius / 10);

    _showLabel = YES;
    _showPercentage = YES;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
             Center:(CGPoint)center
             Radius:(CGFloat)radius {
  self = [self initWithFrame:frame];
  if (self) {
    self.pieCenter = center;
    self.pieRadius = radius;
  }
  return self;
}

//- (id)initWithCoder:(NSCoder *)aDecoder {
//  self = [super initWithCoder:aDecoder];
//  if (self) {
//    _pieView = [[UIView alloc] initWithFrame:self.bounds];
//    [_pieView setBackgroundColor:[UIColor clearColor]];
//    [self insertSubview:_pieView atIndex:0];
//
//    _selectedSliceIndex = -1;
//    _animations = [[NSMutableArray alloc] init];
//
//    _animationSpeed = 0.5;
//    _startPieAngle = M_PI_2 * 3;
//    _selectedSliceStroke = 3.0;
//
//    CGRect bounds = [[self layer] bounds];
//    self.pieRadius = MIN(bounds.size.width / 2, bounds.size.height / 2) - 10;
//    self.pieCenter = CGPointMake(bounds.size.width / 2, bounds.size.height /
//    2);
//    self.labelFont =
//        [UIFont boldSystemFontOfSize:MAX((int)self.pieRadius / 10, 5)];
//    _labelColor = [UIColor whiteColor];
//    _labelRadius = _pieRadius / 2;
//    _selectedSliceOffsetRadius = MAX(10, _pieRadius / 10);
//
//    _showLabel = YES;
//    _showPercentage = YES;
//  }
//  return self;
//}

- (void)setPieCenter:(CGPoint)pieCenter {
  [_pieView setCenter:pieCenter];
  _pieCenter = CGPointMake(_pieView.frame.size.width / 2,
                           _pieView.frame.size.height / 2);
}

- (void)setPieRadius:(CGFloat)pieRadius {
  _pieRadius = pieRadius;
  CGPoint origin = _pieView.frame.origin;
  CGRect frame = CGRectMake(origin.x + _pieCenter.x - pieRadius,
                            origin.y + _pieCenter.y - pieRadius, pieRadius * 2,
                            pieRadius * 2);
  _pieCenter = CGPointMake(frame.size.width / 2, frame.size.height / 2);
  [_pieView setFrame:frame];
  [_pieView.layer setCornerRadius:_pieRadius];
}

- (void)setPieBackgroundColor:(UIColor *)color {
  [_pieView setBackgroundColor:color];
}

#pragma mark - Factories

+ (UIImage *)constructPieChartImage {
  CGContextRef currentContext = UIGraphicsGetCurrentContext();
  /* Set the width for the line */
  CGContextSetLineWidth(currentContext, 5.0f);
  /* Start the line at this point */
  CGContextMoveToPoint(currentContext, 50.0f, 10.0f);
  /* And end it at this point */
  CGContextAddLineToPoint(currentContext, 100.0f, 200.0f);
  /* Use the context's current color to draw the line */
  CGContextStrokePath(currentContext);

  UIImage *image = [UIImage new];
  return image;
}

+ (UIView *)constructPieChartView {

  // TODO: for IPad add animated view with pie chart, and clickable pie segments

  UIView *view = [UIView new];
  return view;
}

#pragma mark - Pie Layer Creation Method

- (SliceLayer *)createSliceLayer {
  SliceLayer *pieLayer = [SliceLayer layer];
  [pieLayer setZPosition:0];
  [pieLayer setStrokeColor:NULL];
  CATextLayer *textLayer = [CATextLayer layer];
  textLayer.contentsScale = [[UIScreen mainScreen] scale];
  CGFontRef font = nil;

  font = CGFontCreateCopyWithVariations((__bridge CGFontRef)(self.labelFont),
                                        (__bridge CFDictionaryRef)(@{}));

  if (font) {
    [textLayer setFont:font];
    CFRelease(font);
  }

  [textLayer setFontSize:self.labelFont.pointSize];
  [textLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
  [textLayer setAlignmentMode:kCAAlignmentCenter];
  [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
  [textLayer setForegroundColor:self.labelColor.CGColor];

  if (self.labelShadowColor) {
    [textLayer setShadowColor:self.labelShadowColor.CGColor];
    [textLayer setShadowOffset:CGSizeZero];
    [textLayer setShadowOpacity:1.0f];
    [textLayer setShadowRadius:2.0f];
  }

  CGSize size = [@"0" sizeWithFont:self.labelFont];
  [CATransaction setDisableActions:YES];
  [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
  [textLayer setPosition:CGPointMake(_pieCenter.x + (_labelRadius * cos(0)),
                                     _pieCenter.y + (_labelRadius * sin(0)))];
  [CATransaction setDisableActions:NO];
  [pieLayer addSublayer:textLayer];
  return pieLayer;
}

- (void)updateLabelForLayer:(SliceLayer *)pieLayer value:(CGFloat)value {
  CATextLayer *textLayer = [[pieLayer sublayers] objectAtIndex:0];
  [textLayer setHidden:!_showLabel];
  if (!_showLabel)
    return;
  NSString *label;
  if (_showPercentage)
    label = [NSString stringWithFormat:@"%0.0f", pieLayer.percentage * 100];
  else
    label = (pieLayer.text) ? pieLayer.text
                            : [NSString stringWithFormat:@"%0.0f", value];

  CGSize size = [label sizeWithFont:self.labelFont];

  [CATransaction setDisableActions:YES];
  if (M_PI * 2 * _labelRadius * pieLayer.percentage <
          MAX(size.width, size.height) ||
      value <= 0) {
    [textLayer setString:@""];
  } else {
    [textLayer setString:label];
    [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
  }
  [CATransaction setDisableActions:NO];
}

#pragma mark - Pie Reload Data With Animation

//- (void)reloadData {
//  if (_dataSource) {
//    CALayer *parentLayer = [_pieView layer];
//    NSArray *slicelayers = [parentLayer sublayers];
//
//    _selectedSliceIndex = -1;
//    [slicelayers
//        enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//          SliceLayer *layer = (SliceLayer *)obj;
//          if (layer.isSelected)
//            [self setSliceDeselectedAtIndex:idx];
//        }];
//
//    double startToAngle = 0.0;
//    double endToAngle = startToAngle;
//
//    NSUInteger sliceCount = [_dataSource numberOfSlicesInPieChart:self];
//
//    double sum = 0.0;
//    double values[sliceCount];
//    for (int index = 0; index < sliceCount; index++) {
//      values[index] = [_dataSource pieChart:self valueForSliceAtIndex:index];
//      sum += values[index];
//    }
//
//    double angles[sliceCount];
//    for (int index = 0; index < sliceCount; index++) {
//      double div;
//      if (sum == 0)
//        div = 0;
//      else
//        div = values[index] / sum;
//      angles[index] = M_PI * 2 * div;
//    }
//
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:_animationSpeed];
//
//    [_pieView setUserInteractionEnabled:NO];
//
//    __block NSMutableArray *layersToRemove = nil;
//
//    BOOL isOnStart = ([slicelayers count] == 0 && sliceCount);
//    NSInteger diff = sliceCount - [slicelayers count];
//    layersToRemove = [NSMutableArray arrayWithArray:slicelayers];
//
//    BOOL isOnEnd = ([slicelayers count] && (sliceCount == 0 || sum <= 0));
//    if (isOnEnd) {
//      for (SliceLayer *layer in _pieView.layer.sublayers) {
//        [self updateLabelForLayer:layer value:0];
//        [layer
//            createArcAnimationForKey:@"startAngle"
//                           fromValue:[NSNumber
//                           numberWithDouble:_startPieAngle]
//                             toValue:[NSNumber
//                             numberWithDouble:_startPieAngle]
//                            Delegate:self];
//        [layer
//            createArcAnimationForKey:@"endAngle"
//                           fromValue:[NSNumber
//                           numberWithDouble:_startPieAngle]
//                             toValue:[NSNumber
//                             numberWithDouble:_startPieAngle]
//                            Delegate:self];
//      }
//      [CATransaction commit];
//      return;
//    }
//
//    for (int index = 0; index < sliceCount; index++) {
//      SliceLayer *layer;
//      double angle = angles[index];
//      endToAngle += angle;
//      double startFromAngle = _startPieAngle + startToAngle;
//      double endFromAngle = _startPieAngle + endToAngle;
//
//      if (index >= [slicelayers count]) {
//        layer = [self createSliceLayer];
//        if (isOnStart)
//          startFromAngle = endFromAngle = _startPieAngle;
//        [parentLayer addSublayer:layer];
//        diff--;
//      } else {
//        SliceLayer *onelayer = [slicelayers objectAtIndex:index];
//        if (diff == 0 || onelayer.value == (CGFloat)values[index]) {
//          layer = onelayer;
//          [layersToRemove removeObject:layer];
//        } else if (diff > 0) {
//          layer = [self createSliceLayer];
//          [parentLayer insertSublayer:layer atIndex:index];
//          diff--;
//        } else if (diff < 0) {
//          while (diff < 0) {
//            [onelayer removeFromSuperlayer];
//            [parentLayer addSublayer:onelayer];
//            diff++;
//            onelayer = [slicelayers objectAtIndex:index];
//            if (onelayer.value == (CGFloat)values[index] || diff == 0) {
//              layer = onelayer;
//              [layersToRemove removeObject:layer];
//              break;
//            }
//          }
//        }
//      }
//
//      layer.value = values[index];
//      layer.percentage = (sum) ? layer.value / sum : 0;
//      UIColor *color = nil;
//      if ([_dataSource
//              respondsToSelector:@selector(pieChart:colorForSliceAtIndex:)]) {
//        color = [_dataSource pieChart:self colorForSliceAtIndex:index];
//      }
//
//      if (!color) {
//        color = [UIColor colorWithHue:((index / 8) % 20) / 20.0 + 0.02
//                           saturation:(index % 8 + 3) / 10.0
//                           brightness:91 / 100.0
//                                alpha:1];
//      }
//
//      [layer setFillColor:color.CGColor];
//      if ([_dataSource
//              respondsToSelector:@selector(pieChart:textForSliceAtIndex:)]) {
//        layer.text = [_dataSource pieChart:self textForSliceAtIndex:index];
//      }
//
//      [self updateLabelForLayer:layer value:values[index]];
//      [layer createArcAnimationForKey:@"startAngle"
//                            fromValue:[NSNumber
//                            numberWithDouble:startFromAngle]
//                              toValue:[NSNumber numberWithDouble:startToAngle
//                              +
//                                                                 _startPieAngle]
//                             Delegate:self];
//      [layer createArcAnimationForKey:@"endAngle"
//                            fromValue:[NSNumber numberWithDouble:endFromAngle]
//                              toValue:[NSNumber numberWithDouble:endToAngle +
//                                                                 _startPieAngle]
//                             Delegate:self];
//      startToAngle = endToAngle;
//    }
//    [CATransaction setDisableActions:YES];
//    for (SliceLayer *layer in layersToRemove) {
//      [layer setFillColor:[self backgroundColor].CGColor];
//      [layer setDelegate:nil];
//      [layer setZPosition:0];
//      CATextLayer *textLayer = [[layer sublayers] objectAtIndex:0];
//      [textLayer setHidden:YES];
//    }
//
//    [layersToRemove
//        enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//          [obj removeFromSuperlayer];
//        }];
//
//    [layersToRemove removeAllObjects];
//
//    for (SliceLayer *layer in _pieView.layer.sublayers) {
//      [layer setZPosition:kDefaultSliceZOrder];
//    }
//
//    [_pieView setUserInteractionEnabled:YES];
//
//    [CATransaction setDisableActions:NO];
//    [CATransaction commit];
//  }
//}

#pragma mark - Animation Delegate + Run Loop Timer

//- (void)updateTimerFired:(NSTimer *)timer;
//{
//  CALayer *parentLayer = [_pieView layer];
//  NSArray *pieLayers = [parentLayer sublayers];
//
//  [pieLayers enumerateObjectsUsingBlock:^(CAShapeLayer *obj, NSUInteger idx,
//                                          BOOL *stop) {
//
//    NSNumber *presentationLayerStartAngle =
//        [[obj presentationLayer] valueForKey:@"startAngle"];
//    CGFloat interpolatedStartAngle = [presentationLayerStartAngle
//    doubleValue];
//
//    NSNumber *presentationLayerEndAngle =
//        [[obj presentationLayer] valueForKey:@"endAngle"];
//    CGFloat interpolatedEndAngle = [presentationLayerEndAngle doubleValue];
//
//    CGPathRef path = CGPathCreateArc(
//        _pieCenter, _pieRadius, interpolatedStartAngle, interpolatedEndAngle);
//    [obj setPath:path];
//    CFRelease(path);
//
//    {
//      CALayer *labelLayer = [[obj sublayers] objectAtIndex:0];
//      CGFloat interpolatedMidAngle =
//          (interpolatedEndAngle + interpolatedStartAngle) / 2;
//      [CATransaction setDisableActions:YES];
//      [labelLayer
//          setPosition:CGPointMake(_pieCenter.x + (_labelRadius *
//                                                  cos(interpolatedMidAngle)),
//                                  _pieCenter.y + (_labelRadius *
//                                                  sin(interpolatedMidAngle)))];
//      [CATransaction setDisableActions:NO];
//    }
//  }];
//}
//
//- (void)animationDidStart:(CAAnimation *)anim {
//  if (_animationTimer == nil) {
//    static float timeInterval = 1.0 / 60.0;
//    // Run the animation timer on the main thread.
//    // We want to allow the user to interact with the UI while this timer is
//    // running.
//    // If we run it on this thread, the timer will be halted while the user is
//    // touching the screen (that's why the chart was disappearing in our
//    // collection view).
//    _animationTimer =
//        [NSTimer timerWithTimeInterval:timeInterval
//                                target:self
//                              selector:@selector(updateTimerFired:)
//                              userInfo:nil
//                               repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:_animationTimer
//                              forMode:NSRunLoopCommonModes];
//  }
//
//  [_animations addObject:anim];
//}
//
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)animationCompleted
//{
//  [_animations removeObject:anim];
//
//  if ([_animations count] == 0) {
//    [_animationTimer invalidate];
//    _animationTimer = nil;
//  }
//}

#pragma mark - Touch Handing (Selection Notification)

//- (NSInteger)getCurrentSelectedOnTouch:(CGPoint)point {
//  __block NSUInteger selectedIndex = -1;
//
//  CGAffineTransform transform = CGAffineTransformIdentity;
//
//  CALayer *parentLayer = [_pieView layer];
//  NSArray *pieLayers = [parentLayer sublayers];
//
//  [pieLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
//  {
//    SliceLayer *pieLayer = (SliceLayer *)obj;
//    CGPathRef path = [pieLayer path];
//
//    if (CGPathContainsPoint(path, &transform, point, 0)) {
//      [pieLayer setLineWidth:_selectedSliceStroke];
//      [pieLayer setStrokeColor:[UIColor whiteColor].CGColor];
//      [pieLayer setLineJoin:kCALineJoinBevel];
//      [pieLayer setZPosition:MAXFLOAT];
//      selectedIndex = idx;
//    } else {
//      [pieLayer setZPosition:kDefaultSliceZOrder];
//      [pieLayer setLineWidth:0.0];
//    }
//  }];
//  return selectedIndex;
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//  [self touchesMoved:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//  UITouch *touch = [touches anyObject];
//  CGPoint point = [touch locationInView:_pieView];
//  [self getCurrentSelectedOnTouch:point];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//  UITouch *touch = [touches anyObject];
//  CGPoint point = [touch locationInView:_pieView];
//  NSInteger selectedIndex = [self getCurrentSelectedOnTouch:point];
//  [self notifyDelegateOfSelectionChangeFrom:_selectedSliceIndex
//                                         to:selectedIndex];
//  [self touchesCancelled:touches withEvent:event];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//  CALayer *parentLayer = [_pieView layer];
//  NSArray *pieLayers = [parentLayer sublayers];
//
//  for (SliceLayer *pieLayer in pieLayers) {
//    [pieLayer setZPosition:kDefaultSliceZOrder];
//    [pieLayer setLineWidth:0.0];
//  }
//}

#pragma mark - Selection Notification

//- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection
//                                         to:(NSUInteger)newSelection {
//  if (previousSelection != newSelection) {
//    if (previousSelection != -1) {
//      NSUInteger tempPre = previousSelection;
//      if ([_delegate
//              respondsToSelector:@selector(pieChart:willDeselectSliceAtIndex:)])
//        [_delegate pieChart:self willDeselectSliceAtIndex:tempPre];
//      [self setSliceDeselectedAtIndex:tempPre];
//      previousSelection = newSelection;
//      if ([_delegate
//              respondsToSelector:@selector(pieChart:didDeselectSliceAtIndex:)])
//        [_delegate pieChart:self didDeselectSliceAtIndex:tempPre];
//    }
//
//    if (newSelection != -1) {
//      if ([_delegate
//              respondsToSelector:@selector(pieChart:willSelectSliceAtIndex:)])
//        [_delegate pieChart:self willSelectSliceAtIndex:newSelection];
//      [self setSliceSelectedAtIndex:newSelection];
//      _selectedSliceIndex = newSelection;
//      if ([_delegate
//              respondsToSelector:@selector(pieChart:didSelectSliceAtIndex:)])
//        [_delegate pieChart:self didSelectSliceAtIndex:newSelection];
//    }
//  } else if (newSelection != -1) {
//    SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:newSelection];
//    if (_selectedSliceOffsetRadius > 0 && layer) {
//      if (layer.isSelected) {
//        if ([_delegate respondsToSelector:@selector(pieChart:
//                                              willDeselectSliceAtIndex:)])
//          [_delegate pieChart:self willDeselectSliceAtIndex:newSelection];
//        [self setSliceDeselectedAtIndex:newSelection];
//        if (newSelection != -1 &&
//            [_delegate respondsToSelector:@selector(pieChart:
//                                              didDeselectSliceAtIndex:)])
//          [_delegate pieChart:self didDeselectSliceAtIndex:newSelection];
//        previousSelection = _selectedSliceIndex = -1;
//      } else {
//        if ([_delegate
//                respondsToSelector:@selector(pieChart:willSelectSliceAtIndex:)])
//          [_delegate pieChart:self willSelectSliceAtIndex:newSelection];
//        [self setSliceSelectedAtIndex:newSelection];
//        previousSelection = _selectedSliceIndex = newSelection;
//        if (newSelection != -1 &&
//            [_delegate
//                respondsToSelector:@selector(pieChart:didSelectSliceAtIndex:)])
//          [_delegate pieChart:self didSelectSliceAtIndex:newSelection];
//      }
//    }
//  }
//}

#pragma mark - Selection Programmatically Without Notification

//- (void)setSliceSelectedAtIndex:(NSInteger)index {
//  if (_selectedSliceOffsetRadius <= 0)
//    return;
//  SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:index];
//  if (layer && !layer.isSelected) {
//    CGPoint currPos = layer.position;
//    double middleAngle = (layer.startAngle + layer.endAngle) / 2.0;
//    CGPoint newPos =
//        CGPointMake(currPos.x + _selectedSliceOffsetRadius * cos(middleAngle),
//                    currPos.y + _selectedSliceOffsetRadius *
//                    sin(middleAngle));
//    layer.position = newPos;
//    layer.isSelected = YES;
//  }
//}
//
//- (void)setSliceDeselectedAtIndex:(NSInteger)index {
//  if (_selectedSliceOffsetRadius <= 0)
//    return;
//  SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:index];
//  if (layer && layer.isSelected) {
//    layer.position = CGPointMake(0, 0);
//    layer.isSelected = NO;
//  }
//}

//- (void)setShowPercentage:(BOOL)showPercentage {
//  _showPercentage = showPercentage;
//  for (SliceLayer *layer in _pieView.layer.sublayers) {
//    CATextLayer *textLayer = [[layer sublayers] objectAtIndex:0];
//    [textLayer setHidden:!_showLabel];
//    if (!_showLabel)
//      return;
//    NSString *label;
//    if (_showPercentage)
//      label = [NSString stringWithFormat:@"%0.0f", layer.percentage * 100];
//    else
//      label = (layer.text) ? layer.text
//                           : [NSString stringWithFormat:@"%0.0f",
//                           layer.value];
//    CGSize size = [label sizeWithFont:self.labelFont];
//
//    if (M_PI * 2 * _labelRadius * layer.percentage <
//        MAX(size.width, size.height)) {
//      [textLayer setString:@""];
//    } else {
//      [textLayer setString:label];
//      [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
//    }
//  }
//}

@end
