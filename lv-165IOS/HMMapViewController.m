//
//  ViewController.m
//  lv-165IOS
//
//  Created by AG on 11/23/15.
//  Copyright © 2015 AG. All rights reserved.
//

#import "HMMapViewController.h"
#import "HMSettingsViewController.h"
#import "HMFiltersViewController.h"
#import "HMSearchViewController.h"
#import <MapKit/MapKit.h>
#import "HMMapAnnotation.h"
#import "UIView+MKAnnotationView.h"
#import "Comments.h"
#import "Place.h"
#import "HMMapAnnotation.h"
#import "SVGeocoder.h"
#import "HMCommentsTableViewController.h"
#import "HMAnnotationView.h"
#import "FBAnnotationClustering/FBAnnotationClustering.h"
#import "ClusterOverlayView.h"

@interface HMMapViewController ()

@property(strong, nonatomic) CLLocationManager *locationManager;

@property(strong, nonatomic)
    NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(strong, nonatomic) NSMutableArray *mapPointArray;

@property(assign, nonatomic) NSInteger ratingOfPoints;
@property(assign, nonatomic) BOOL pointHasComments;

@property(strong, nonatomic) NSArray *placeArray;

@property(weak, nonatomic) MKAnnotationView *userLocationPin;

@property(strong, nonatomic) NSMutableArray *clusteredAnnotations;
@property(strong, nonatomic) FBClusteringManager *clusteringManager;
@property(strong, nonatomic) NSMutableArray *circleOverlayViews;

@end

static NSString *kSettingsComments = @"comments";
static NSString *kSettingsRating = @"rating";

@implementation HMMapViewController

static NSMutableArray *nameCountries;
static bool isMainRoute;

- (NSManagedObjectContext *)managedObjectContext {

  if (!_managedObjectContext) {
    _managedObjectContext =
        [[HMCoreDataManager sharedManager] managedObjectContext];
  }
  return _managedObjectContext;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.

  self.locationManager = [[CLLocationManager alloc] init];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(showPlace:)
                                               name:showPlaceNotificationCenter
                                             object:nil];
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  self.ratingOfPoints = [userDefaults integerForKey:kSettingsRating];
  self.pointHasComments = [userDefaults boolForKey:kSettingsComments];

  // Check for iOS 8. Without this guard the code will crash with "unknown
  // selector" on iOS 7.
  if ([self.locationManager
          respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    [self.locationManager requestWhenInUseAuthorization];
  }
  UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                           target:nil
                           action:nil];

  UIButton *yourCurrentLocation = [UIButton buttonWithType:UIButtonTypeCustom];
  [yourCurrentLocation setBackgroundImage:[UIImage imageNamed:@"compass"]
                                 forState:UIControlStateNormal];
  [yourCurrentLocation addTarget:self
                          action:@selector(showYourCurrentLocation:)
                forControlEvents:UIControlEventTouchUpInside];
  yourCurrentLocation.frame = CGRectMake(0, 0, 30, 30);
  yourCurrentLocation.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
  UIView *viewForShowCurrentLocation =
      [[UIView alloc] initWithFrame:CGRectMake(0, 30, 30, 30)];
  [viewForShowCurrentLocation addSubview:yourCurrentLocation];
  UIBarButtonItem *buttonForShowCurrentLocation =
      [[UIBarButtonItem alloc] initWithCustomView:viewForShowCurrentLocation];

  UIButton *moveToSettingsController =
      [UIButton buttonWithType:UIButtonTypeCustom];
  [moveToSettingsController setBackgroundImage:[UIImage imageNamed:@"tools"]
                                      forState:UIControlStateNormal];
  [moveToSettingsController addTarget:self
                               action:@selector(moveToToolsController:)
                     forControlEvents:UIControlEventTouchUpInside];
  moveToSettingsController.frame = CGRectMake(0, 0, 30, 30);
  moveToSettingsController.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
  UIView *viewForMoveToSettingsController =
      [[UIView alloc] initWithFrame:CGRectMake(0, 30, 30, 30)];
  [viewForMoveToSettingsController addSubview:moveToSettingsController];
  UIBarButtonItem *buttonForMoveToSettingsController = [[UIBarButtonItem alloc]
      initWithCustomView:viewForMoveToSettingsController];

  UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [searchButton setBackgroundImage:[UIImage imageNamed:@"Lupa"]
                          forState:UIControlStateNormal];
  [searchButton addTarget:self
                   action:@selector(buttonSearch:)
         forControlEvents:UIControlEventTouchUpInside];
  searchButton.frame = CGRectMake(0, 0, 30, 30);
  searchButton.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
  UIView *viewForSearchButton =
      [[UIView alloc] initWithFrame:CGRectMake(0, 30, 30, 30)];
  [viewForSearchButton addSubview:searchButton];
  UIBarButtonItem *buttonSearchButton =
      [[UIBarButtonItem alloc] initWithCustomView:viewForSearchButton];

  UIButton *moveToFilterController =
      [UIButton buttonWithType:UIButtonTypeCustom];
  [moveToFilterController setBackgroundImage:[UIImage imageNamed:@"filter"]
                                    forState:UIControlStateNormal];
  [moveToFilterController addTarget:self
                             action:@selector(moveToFilterController:)
                   forControlEvents:UIControlEventTouchUpInside];
  moveToFilterController.frame = CGRectMake(0, 0, 30, 30);
  moveToFilterController.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
  UIView *viewForMoveToFilterController =
      [[UIView alloc] initWithFrame:CGRectMake(0, 30, 30, 30)];
  [viewForMoveToFilterController addSubview:moveToFilterController];
  UIBarButtonItem *buttonForMoveToFilterController = [[UIBarButtonItem alloc]
      initWithCustomView:viewForMoveToFilterController];

  NSArray *buttons = @[
    buttonForShowCurrentLocation,
    flexibleItem,
    buttonSearchButton,
    flexibleItem,
    buttonForMoveToFilterController,
    flexibleItem,
    buttonForMoveToSettingsController
  ];

  [self.downToolBar setItems:buttons animated:NO];

  self.mapView.showsUserLocation = YES;

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(receiveChangeMapTypeNotification:)
             name:@"ChangeMapTypeNotification"
           object:nil];

  [self loadSettings];

  self.locationManager.delegate = self;

  [self startHeadingEvents];

  [self.locationManager startUpdatingHeading];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  self.ratingOfPoints = [userDefaults integerForKey:kSettingsRating];
  self.pointHasComments = [userDefaults boolForKey:kSettingsComments];
  // [self.mapView removeAnnotations:self.mapView.annotations];
  [self printPointWithContinent];

  NSLog(@" Points in map array %lu", (unsigned long)[self.mapPointArray count]);
  NSLog(@" point has comments %@", self.pointHasComments ? @"Yes" : @"No");

  [[self navigationController] setNavigationBarHidden:YES animated:YES];
  //}
  //
  //- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView
  //                       fullyRendered:(BOOL)fullyRendered {
  if (!self.clusteringManager) {

    [[NSOperationQueue new] addOperationWithBlock:^{
      double scale =
          _mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
      self.clusteringManager = [[FBClusteringManager alloc]
          initWithAnnotations:_clusteredAnnotations];
      NSArray *annotations = [self.clusteringManager
          clusteredAnnotationsWithinMapRect:_mapView.visibleMapRect
                              withZoomScale:scale];
      self.clusteringManager.scale = [[NSNumber alloc] initWithDouble:1.6];
      ;
      [self.clusteringManager displayAnnotations:annotations
                                       onMapView:_mapView];
    }];
  } else {
    [[NSOperationQueue new] addOperationWithBlock:^{
      double scale =
          _mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
      NSArray *annotations = [self.clusteringManager
          clusteredAnnotationsWithinMapRect:_mapView.visibleMapRect
                              withZoomScale:scale];
      [self.clusteringManager displayAnnotations:annotations
                                       onMapView:_mapView];
    }];
  }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  [[NSOperationQueue new] addOperationWithBlock:^{
    double scale =
        self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
    NSArray *annotations = [self.clusteringManager
        clusteredAnnotationsWithinMapRect:mapView.visibleMapRect
                            withZoomScale:scale];

    [self.clusteringManager displayAnnotations:annotations onMapView:mapView];
  }];
}

#pragma mark - buttons on Tool Bar

- (void)showYourCurrentLocation:(UIBarButtonItem *)sender {
  MKMapRect zoomRect = MKMapRectNull;
  CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
  MKMapPoint center = MKMapPointForCoordinate(location);
  static double delta = 40000;
  MKMapRect rect =
      MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
  zoomRect = MKMapRectUnion(zoomRect, rect);
  zoomRect = [self.mapView mapRectThatFits:zoomRect];

  [self.mapView setVisibleMapRect:zoomRect
                      edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                         animated:YES];
}

- (void)moveToToolsController:(UIBarButtonItem *)sender {

  [self performSegueWithIdentifier:@"showSettingsViewController" sender:sender];
}

- (void)moveToFilterController:(UIBarButtonItem *)sender {

  [self performSegueWithIdentifier:@"showFilterViewController" sender:sender];
}

- (void)buttonSearch:(UIBarButtonItem *)sender {

  [self performSegueWithIdentifier:@"showSearchViewController" sender:sender];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

  if ([segue.identifier isEqualToString:@"showSettingsViewController"]) {

    // sending smth to destinationViewController

  } else if ([[segue identifier] isEqualToString:@"Comments"]) {
    Place *place = [self.placeArray objectAtIndex:0];
    HMCommentsTableViewController *createViewController =
        segue.destinationViewController;
    createViewController.create = place;
  }
}

#pragma mark - Notifications

- (void)receiveChangeMapTypeNotification:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"ChangeMapTypeNotification"]) {

    [self loadSettings];
  }
}

#pragma mark - Deallocation

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Annotation View

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<HMAnnotationView>)annotation {

  static NSString *annotationIDNormal = @"Annotation";
  MKPinAnnotationView *pin = (MKPinAnnotationView *)
      [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIDNormal];

  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    self.userLocationPin = pin;
    return nil;
  } else if ([annotation isKindOfClass:[FBAnnotationCluster class]]) {
    FBAnnotationCluster *clusterAnnotation = annotation;

    FBAnnotationClusterView *clusterAnnotationView =
        [[FBAnnotationClusterView alloc] initWithAnnotation:clusterAnnotation
                                            reuseIdentifier:nil];
      clusterAnnotationView.userInteractionEnabled = YES;
      return clusterAnnotationView;
  } else {

    if (!pin) {

      // pin = [[MKAnnotationView alloc] initWithAnnotation:annotation
      // reuseIdentifier:annotationIDNormal];

      pin.canShowCallout = YES;
      pin.image = [UIImage imageNamed:@"UserArrow"];
    } else {
      pin.annotation = annotation;
    }

    switch (((HMMapAnnotation *)annotation).ratingForColor) {

    case badRating: {
      pin.pinTintColor = [UIColor redColor];
      break;
    }
    case senseLess: {
      pin.pinTintColor = [UIColor whiteColor];
      break;
    }
    case veryGoodRating: {
      pin.pinTintColor = [UIColor greenColor];
      break;
    }
    }
    pin.animatesDrop = NO;
    pin.canShowCallout = YES;

    UIButton *descriptionButton =
        [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [descriptionButton addTarget:self
                          action:@selector(actionDescription:)
                forControlEvents:UIControlEventTouchUpInside];
    pin.rightCalloutAccessoryView = descriptionButton;

    UIButton *directionButton =
        [UIButton buttonWithType:UIButtonTypeContactAdd];
    [directionButton addTarget:self
                        action:@selector(actionDirection:)
              forControlEvents:UIControlEventTouchUpInside];
    pin.leftCalloutAccessoryView = directionButton;

    return pin;
  }
}

#pragma mark - MKMapViewDelegate -

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {

  if ([overlay isKindOfClass:[MKPolyline class]]) {

    MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];

    if (!isMainRoute) {
      renderer.lineWidth = 2.5f;
      renderer.strokeColor =
          [UIColor colorWithRed:0.f green:0.1f blue:1.f alpha:0.9f];
      return renderer;
    } else {
      renderer.lineWidth = 1.5f;
      renderer.strokeColor =
          [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.6f];
      return renderer;
    }
  } else if ([overlay isKindOfClass:[MKPolygon class]]) {
    MKPolygonRenderer *polygonView =
        [[MKPolygonRenderer alloc] initWithOverlay:overlay];
    polygonView.lineWidth = 2.f;
    polygonView.strokeColor = [UIColor magentaColor];

    return polygonView;
  } else if ([overlay isKindOfClass:[MKCircle class]]) {

    MKCircle *circleOverlay = (MKCircle *)overlay;
    MKCircleRenderer *circleRenderer =
        [[MKCircleRenderer alloc] initWithCircle:overlay];

    // the circle center
    MKMapPoint overlayMapPoint =
        MKMapPointForCoordinate(circleOverlay.coordinate);

    double mapRadius =
        circleOverlay.radius *
        MKMapPointsPerMeterAtLatitude(circleOverlay.coordinate.latitude);

    // calculate the rect in map coordinate
    MKMapRect mrect = MKMapRectMake(overlayMapPoint.x - mapRadius,
                                    overlayMapPoint.y - mapRadius,
                                    mapRadius * 2, mapRadius * 2);

    // return the pixel coordinate circle
    CGRect rect = [circleRenderer rectForMapRect:mrect];
    CGPoint overlayPoint = [circleRenderer pointForMapPoint:overlayMapPoint];
    // Alternative: CGPoint point = [mapView convertCoordinate:
    // annotation.coordinate toPointToView:overlayView];

    //      circleRenderer.pointForMapPoint:
    //      circleRenderer.mapPointForPoint:
    //      circleRenderer.rectForMapRect:
    //      circleRenderer.mapRectForRect:

    // painting the pie chart - only one piece currently!
    CGMutablePathRef arc = CGPathCreateMutable();

    // if number of ratings = 2 - divide by 360/2, else if 3 - 360/3
    CGFloat startAngle;
    CGFloat endAngle;

    CGPathMoveToPoint(arc, NULL, overlayPoint.x, overlayPoint.y);

    CGPathAddArc(arc, NULL, overlayPoint.x, overlayPoint.y,
                 circleOverlay.radius, startAngle, endAngle, YES);

    //    Step 2: Stroke that arc
    //    Create the final donut segment shape by stroking the arc. This // function may look like magic to you but that is how it feels to find a //    hidden treasure in Core Graphics. It will stroke the path with a //    specific stroke width. "Line cap" and "line join" control how the // start and end  of the shape looks and how the joins between path // components look (there    is only one component in this shape).

    CGFloat lineWidth = 10.0; // any radius you want
    CGPathRef donutSegment =
        CGPathCreateCopyByStrokingPath(arc, NULL, lineWidth, kCGLineCapButt,
                                       kCGLineJoinMiter, // the default
                                       10); // 10 is default miter limit

    //    Step 3: There is no step 3 (well, there is fill + stroke) // Fill this shape just like you did with the pie shapes. (lightGray and // black was used in Image 2 (above)).

    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextAddPath(c, donutSegment);
    CGContextSetFillColorWithColor(c, [UIColor lightGrayColor].CGColor);
    CGContextSetStrokeColorWithColor(c, [UIColor blackColor].CGColor);
    CGContextDrawPath(c, kCGPathFillStroke);

     [_circleOverlayViews addObject:circleRenderer];
      
      // TODO: implement rating display (pie chart) here or in subclassed
    // MKCircleRenderer


      //    UITapGestureRecognizer *tapRecogniser =
//        [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                action:@selector(handleTap:)];
//    tapRecogniser.numberOfTapsRequired = 1;
//    tapRecogniser.numberOfTouchesRequired = 1;
//
//    tapRecogniser.delegate = self;

    // need to keep array of overlay views for gesture reognizer, to find the view(renderer) when tapped
      
    // TODO: initialize the array
    // implement clearing the array when regionDidChange and in other updates

    //[_mapView addGestureRecognizer:tapRecogniser];

    // probably not here[circleRenderer addGestureRecognizer:tapRecogniser];

  // MKOverlayPathRenderer *pathRenderer =   [[MKOverlayPathRenderer alloc] initWithOverlay:overlay];

    // if (overlay.RatingForPin == ) {

    // modify path - for animation or for drawing
    // CGPathRef path = pathRenderer.path;

    // pathRenderer.fillColor = [UIColor redColor];
    // pathRenderer.strokeColor = [UIColor blackColor];
    // pathRenderer.lineWidth =
    // pathRenderer.lineDashPattern =
    // pathRenderer.lineDashPhase
    //            pathRenderer.lineJoin =
    // pathRenderer.lineCap =
    // }

    //        You can use this class as-is or subclass to define additional   drawing behaviors. If you subclass, you should override the createPath method and use that method to build the appropriate path object. To change the path, invalidate it and recreate the path using whatever new data your subclass has obtained. The miter limit helps you avoid spikes in paths that use the kCGLineJoinMiter join style. If the ratio of  the miter length—that is, the diagonal length of the miter join—to the line thickness exceeds the miter limit, the joint is converted to a bevel join. The default miter limit is 10, which results in the  conversion of miters whose angle at the joint is less   than 11 degrees
     // lineDashPhase
    // Property
    // The offset (in points) at which to start drawing the  dash pattern. Use this property to start drawing a dashed line partway through a segment or gap. For example, a phase value of 6 for the patter 5-2-3-2 would cause drawing to begin in the middle of the first gap. The default value of this property is 0.


    // lineDashPattern Property
    // An array of numbers specifying the dash pattern to
    // use for the path.

    // @property(copy) NSArray <NSNumber *>
    // *lineDashPattern
    // Discussion
    // The array contains one or more NSNumber objects that indicate the lengths (measured in points) of the line segments and gaps in the pattern. The values in the array alternate,  starting with the first line segment length,  followed by the first gap length, followed by the second line segment length, and so on. // This property is set to nil by default, which indicates no line dash pattern.
    // Creating and Managing the Path // path
    // The path representing the overlay’s shape.
    // OBJECTIVE-C
    // @property CGPathRef path
    // Discussion
    // Getting the value of this property causes the path to be created (using the createPath method) if it does not already exist. You can assign a path object to this property explicitly. When assigning a new path object to this property, the overlay renderer stores a strong reference to the path you provide.
      
      // - createPath
    // Creates the path for the overlay.
    // The default implementation of this method does nothing. Subclasses should override it and use it to create the CGPathRef data type to be used for drawing. After creating the path, your  implementation should assign it to the path property.
     // - invalidatePath
    // Updates the path associated with the overlay renderer.
      // OBJECTIVE-C
    //                                        - (void)invalidatePath
    // Discussion
    // Call this method when a change in the path information would require you to recreate the overlay’s  path. This method sets the path property to nil and tells the overlay renderer to redisplay its contents.
//      Drawing the Path
//  applyStrokePropertiesToContext:atZoomScale:
    // Applies the receiver’s current stroke-related drawing properties to the specified graphics context.

    // applyStrokePropertiesToContext(_ // context: CGContext,
    // atZoomScale zoomScale: MKZoomScale)
    // OBJECTIVE-C
    // -
    // (void)applyStrokePropertiesToContext:(CGContextRef)context
    //                                        atZoomScale:(MKZoomScale)zoomScale
    // Parameters
    // context
    // The graphics context used to draw the view’s contents.
    
      // zoomScale
    // The current zoom scale used for drawing.
    // Discussion
    // This is a convenience method for applying all of the drawing properties used when     // stroking a path. This method applies the stroke color, line width, line join, line cap, miter limit, line dash phase, and line dash attributes to the specified graphics context. This method applies the scale factor in the zoomScale parameter to the line width and line dash pattern automatically so that lines scale appropriately.
    //
    // This method does not save the current graphics state  before applying the new attributes. If you want to preserve the existing state, you must save it yourself and restore it later when you finish // drawing.
// applyFillPropertiesToContext:atZoomScale:
    // Applies the receiver’s current fill-related drawing properties to the specified graphics context.
      
//  (void)applyFillPropertiesToContext:(CGContextRef)context
    // atZoomScale:(MKZoomScale)zoomScale     // Parameters     // context     // The graphics context used to draw the view’s contents.
    // zoomScale // The current zoom scale     // used for drawing.
    // Discussion This is a convenience method for applying all of the drawing properties used when filling a path. This method applies the current fill color to  the specified graphicscontext.
   
  //  applyStrokePropertiesToContext:atZoomScale:

    // fillPath:inContext:
    // Fills the area
    // enclosed
    // the specified path.  Declaration

 // (void)fillPath:(CGPathRef)path
    // inContext:(CGContextRef)context
    // Parameters path The path to fill. context The graphics context in which to draw the path.Discussion You must set the current fill color before calling this method. Typically you do this by calling the applyFillPropertiesToContext:atZoomScale: method prior to drawing. If the fillColor   property is  currently nil,  this method  does nothing.
 
  }
  return nil;
}

//- (void)addAnimatedOverlayToAnnotation:(id<MKAnnotation>)annotation {
//  // get a frame around the annotation
//  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
//      annotation.coordinate, OVERLAYMETERS, OVERLAYMETERS);
//  CGRect rect = [_mapView convertRegion:region toRectToView:_mapView];
//  // set up the animated overlay
//  if (!animatedOverlay) {
//    animatedOverlay = [[AnimatedOverlay alloc] initWithFrame:rect];
//  } else {
//    [animatedOverlay setFrame:rect];
//  }
//  // add to the map and start the animation
//  [_mapView addSubview:animatedOverlay];
//  if ([annotation.title isEqual:@"1"]) {
//    [animatedOverlay startAnimatingWithColor:[UIColor redColor]
//    andFrame:rect];
//  } else if ([annotation.title isEqual:@"2"]) {
//    [animatedOverlay startAnimatingWithColor:[UIColor purpleColor]
//                                    andFrame:rect];
//  } else { // == @"3"
//    [animatedOverlay startAnimatingWithColor:[UIColor greenColor]
//                                    andFrame:rect];
//  }
//}
//
//- (void)removeAnimatedOverlay {
//  if (animatedOverlay) {
//    [animatedOverlay stopAnimating];
//    [animatedOverlay removeFromSuperview];
//  }
//}

//-(void) startAnimatingWithColor:(UIColor *)color andFrame:(CGRect)frame{
//
//    //TODO: animate  FBAnnotationClusterView.image.frame or
//    FBAnnotationClusterView.frame
//
//    //get the image
//    UIImage * image = [UIImage imageNamed:@"circle.png"];
//
//    UIColor *colorForAnimation = color;
//
//    //image color change
//
//    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextClipToMask(context, rect, self.image.CGImage);
//    CGContextSetFillColorWithColor(context, [colorForAnimation CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
//                                                scale:1.0 orientation:
//                                                UIImageOrientationDownMirrored];
//    self.image = flippedImage;
//
//
//    //opacity animation setup
//    CABasicAnimation *opacityAnimation;
//
//    opacityAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
//    opacityAnimation.duration = ANIMATION_DURATION;
//    opacityAnimation.repeatCount = ANIMATION_REPEAT;
//    //theAnimation.autoreverses=YES;
//    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.85];
//    opacityAnimation.toValue = [NSNumber numberWithFloat:0.15];
//
//    //resize animation setup
//    CABasicAnimation *transformAnimation;
//
//    transformAnimation = [CABasicAnimation
//    animationWithKeyPath:@"transform.scale"];
//
//    transformAnimation.duration = ANIMATION_DURATION;
//    transformAnimation.repeatCount = ANIMATION_REPEAT;
//    //transformAnimation.autoreverses=YES;
//    transformAnimation.fromValue = [NSNumber numberWithFloat:MIN_RATIO];
//    transformAnimation.toValue = [NSNumber numberWithFloat:MAX_RATIO];
//
//
//    //group the two animation
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//
//    group.repeatCount = ANIMATION_REPEAT;
//    [group setAnimations:[NSArray arrayWithObjects:opacityAnimation,
//    transformAnimation, nil]];
//    group.duration = ANIMATION_DURATION;
//
//    //apply the grouped animaton
//    [self.layer addAnimation:group forKey:@"groupAnimation"];
//}
//
//-(void)stopAnimating{
//    [self.layer removeAllAnimations];
//    [self removeFromSuperview];
//}

/** Returns the distance of |pt| to |poly| in meters
 *
 * from http://paulbourke.net/geometry/pointlineplane/DistancePoint.java
 *
 */
- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(MKPolyline *)poly {
  double distance = MAXFLOAT;
  for (int n = 0; n < poly.pointCount - 1; n++) {

    MKMapPoint ptA = poly.points[n];
    MKMapPoint ptB = poly.points[n + 1];

    double xDelta = ptB.x - ptA.x;
    double yDelta = ptB.y - ptA.y;

    if (xDelta == 0.0 && yDelta == 0.0) {

      // Points must not be equal
      continue;
    }

    double u = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) /
               (xDelta * xDelta + yDelta * yDelta);
    MKMapPoint ptClosest;
    if (u < 0.0) {

      ptClosest = ptA;
    } else if (u > 1.0) {

      ptClosest = ptB;
    } else {

      ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
    }

    distance = MIN(distance, MKMetersBetweenMapPoints(ptClosest, pt));
  }

  return distance;
}

/** Converts |px| to meters at location |pt| */
- (double)metersFromPixel:(NSUInteger)px atPoint:(CGPoint)pt {
  CGPoint ptB = CGPointMake(pt.x + px, pt.y);

  CLLocationCoordinate2D coordA =
      [_mapView convertPoint:pt toCoordinateFromView:_mapView];
  CLLocationCoordinate2D coordB =
      [_mapView convertPoint:ptB toCoordinateFromView:_mapView];

  return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA),
                                  MKMapPointForCoordinate(coordB));
}

#define MAX_DISTANCE_PX 22.0f
- (void)handleTap:(UITapGestureRecognizer *)tap {
  if ((tap.state & UIGestureRecognizerStateRecognized) ==
      UIGestureRecognizerStateRecognized) {

    // Get map coordinate from touch point
    CGPoint touchPt = [tap locationInView:_mapView];
    CLLocationCoordinate2D coord =
        [_mapView convertPoint:touchPt toCoordinateFromView:_mapView];

    double maxMeters = [self metersFromPixel:MAX_DISTANCE_PX atPoint:touchPt];

    float nearestDistance = MAXFLOAT;
    MKPolyline *nearestPoly = nil;

    // for every overlay ...
    for (id<MKOverlay> overlay in _mapView.overlays) {

      // .. if MKPolyline ...
      if ([overlay isKindOfClass:[MKPolyline class]]) {

        // ... get the distance ...
        float distance = [self distanceOfPoint:MKMapPointForCoordinate(coord)
                                        toPoly:overlay];

        // ... and find the nearest one
        if (distance < nearestDistance) {

          nearestDistance = distance;
          nearestPoly = overlay;
        }
      }
    }

    if (nearestDistance <= maxMeters) {

      NSLog(@"Touched poly: %@\n"
             "    distance: %f",
            nearestPoly, nearestDistance);
    }
  }
}

- (void)didTap:(UITapGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    // convert the touch point to a CLLocationCoordinate & geocode
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];

    // MKPolylineView *touchedPolyLineView = [self
    // circleOverlayTapped:touchPoint];

    //        if (touchedPolyLineView) {
    //
    //        }
  }
}

//- (MKPolylineView *)circleOverlayTapped:(CGPoint)point {
//  // Check if the overlay got tapped
//  for (MKCircleRenderer *circleOverlayView in _circleOverlayViews) {
//    // Get view frame rect in the mapView's coordinate system
//    CGRect viewFrameInMapView =
//        [circleOverlayView.superview convertRect:circleOverlayView.frame
//                                          toView:_mapView];
//
//    // Check if the touch is within the view bounds
//    if (CGRectContainsPoint(viewFrameInMapView, point)) {
//      return circleOverlayView;
//    }
//  }
//  return nil;
//}

#pragma mark - Alert -

- (UIAlertController *)createAlertControllerWithTitle:(NSString *)title
                                              message:(NSString *)message {

  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:title
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  return alert;
}

- (void)actionWithTitle:(NSString *)title
             alertTitle:(NSString *)alertTitle
           alertMessage:(NSString *)alertMessage {

  UIAlertController *alert =
      [self createAlertControllerWithTitle:alertTitle message:alertMessage];
  UIAlertAction *alertAction =
      [UIAlertAction actionWithTitle:title
                               style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action){
                             }];
  [alert addAction:alertAction];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)createRouteForAnotationCoordinate:(CLLocationCoordinate2D)endCoordinate
                          startCoordinate:
                              (CLLocationCoordinate2D)startCoordinate {
  MKDirections *directions;

  MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
  MKPlacemark *startPlacemark =
      [[MKPlacemark alloc] initWithCoordinate:startCoordinate
                            addressDictionary:nil];
  MKMapItem *startDestination =
      [[MKMapItem alloc] initWithPlacemark:startPlacemark];
  request.source = startDestination;
  MKPlacemark *endPlacemark =
      [[MKPlacemark alloc] initWithCoordinate:endCoordinate
                            addressDictionary:nil];
  MKMapItem *endDestination =
      [[MKMapItem alloc] initWithPlacemark:endPlacemark];

  request.destination = endDestination;
  request.transportType = MKDirectionsTransportTypeAutomobile;
  request.requestsAlternateRoutes = isMainRoute;
  BOOL temp = isMainRoute;
  directions = [[MKDirections alloc] initWithRequest:request];
  [directions
      calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response,
                                                 NSError *error) {
        if (error) {
          NSLog(@"%@", error);
        } else if ([response.routes count] == 0) {
          NSLog(@"routes = 0");
        } else {
          NSMutableArray *array = [NSMutableArray array];
          for (MKRoute *route in response.routes) {
            [array addObject:route.polyline];
          }
          isMainRoute = temp;

          [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
        }
      }];
}

- (void)removeRoutes {
  [self.mapView removeOverlays:self.mapView.overlays];
}

#pragma mark Action to pin button

- (void)actionDescription:(UIButton *)sender {
  MKAnnotationView *annotationView = [sender superAnnotationView];
  NSString *str =
      [NSString stringWithFormat:@"%ld", (long)((HMMapAnnotation *)
                                                    annotationView.annotation)
                                             .idPlace];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", str];
  NSFetchRequest *request =
      [NSFetchRequest fetchRequestWithEntityName:@"Place"];
  request.predicate = predicate;
  self.placeArray =
      [[self managedObjectContext] executeFetchRequest:request error:nil];
  [self performSegueWithIdentifier:@"Comments" sender:self];
}

- (void)actionDirection:(UIButton *)sender {
  [self removeRoutes];
  MKAnnotationView *annotationView = [sender superAnnotationView];
  if (!annotationView) {
    return;
  }
  CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;

  isMainRoute = YES;
  [self createRouteForAnotationCoordinate:self.mapView.userLocation.coordinate
                          startCoordinate:coordinate];
  isMainRoute = NO;
  [self createRouteForAnotationCoordinate:self.mapView.userLocation.coordinate
                          startCoordinate:coordinate];
}

- (void)actionRemoveRoute:(UIButton *)sender {
  MKAnnotationView *annotationView = [sender superAnnotationView];
  UIButton *directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
  [directionButton addTarget:self
                      action:@selector(actionDirection:)
            forControlEvents:UIControlEventTouchUpInside];
  annotationView.leftCalloutAccessoryView = directionButton;

  [self removeRoutes];
}

- (void)printPointWithContinent {
  NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
  NSFetchRequest *fetchRequest =
      [[NSFetchRequest alloc] initWithEntityName:@"Place"];

  NSInteger minForPoint = 0;
  NSInteger maxForPoint = 5;

  switch (self.ratingOfPoints) {
  case 0: {
    minForPoint = 0;
    maxForPoint = 5;
    break;
  }
  case 1: {
    minForPoint = 1;
    maxForPoint = 3;
    break;
  }
  case 2: {
    minForPoint = 4;
    maxForPoint = 5;
    break;
  }
  default:
    break;
  }

  NSPredicate *ratingPredicate =
      [NSPredicate predicateWithFormat:
                       @"%@ => rating  AND rating >= %@",
                       [NSString stringWithFormat:@" %ld", (long)maxForPoint],
                       [NSString stringWithFormat:@" %ld", (long)minForPoint]];

  if (!self.pointHasComments) {
    [fetchRequest setPredicate:ratingPredicate];
  } else {
    NSPredicate *commentsCountPredicate =
        [NSPredicate predicateWithFormat:@"comments_count > %@", @0];
    NSPredicate *compoundPredicate = [NSCompoundPredicate
        andPredicateWithSubpredicates:
            [NSArray
                arrayWithObjects:ratingPredicate, commentsCountPredicate, nil]];

    [fetchRequest setPredicate:compoundPredicate];
  }
  self.mapPointArray =
      [[managedObjectContext executeFetchRequest:fetchRequest
                                           error:nil] mutableCopy];

  NSLog(@"MAP annotation array count %lu",
        (unsigned long)self.mapPointArray.count);

  _clusteredAnnotations = [NSMutableArray new];

  for (Place *place in self.mapPointArray) {
    HMMapAnnotation *annotation = [[HMMapAnnotation alloc] init];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [place.lat doubleValue];
    coordinate.longitude = [place.lon doubleValue];
    if ([place.rating intValue] == 0) {
      annotation.ratingForColor = senseLess;
    } else if (([place.rating intValue] >= 4) &&
               ([place.rating intValue] <= 5)) {
      annotation.ratingForColor = badRating;
    } else if (([place.rating intValue] >= 1) &&
               ([place.rating intValue] <= 3)) {
      annotation.ratingForColor = veryGoodRating;
    }
    annotation.coordinate = coordinate;
    annotation.title = [NSString stringWithFormat:@"Rating = %@", place.rating];
    annotation.subtitle = [NSString
        stringWithFormat:@"%.5g, %.5g", annotation.coordinate.latitude,
                         annotation.coordinate.longitude];
    annotation.idPlace = [place.id integerValue];

    //[self.mapView addAnnotation:annotation];
    [_clusteredAnnotations addObject:annotation];
  }
}

#pragma mark - methods for Notification

- (void)showPlace:(NSNotification *)notification {
  [self.navigationController popViewControllerAnimated:YES];
  SVPlacemark *object =
      [notification.userInfo objectForKey:showPlaceNotificationCenterInfoKey];
  CLLocationCoordinate2D point = object.coordinate;
  MKCoordinateRegion region =
      MKCoordinateRegionMakeWithDistance(point, 800, 800);
  [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

#pragma mark - Map Type Saving

- (void)saveSettings {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

  [userDefaults setInteger:self.mapView.mapType forKey:@"kMapType"];

  [userDefaults synchronize];
}

- (void)loadSettings {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

  self.mapView.mapType = [userDefaults integerForKey:@"kMapType"];
}

#pragma mark - Heading Update

- (void)startHeadingEvents {

  if (!self.locationManager) {
    CLLocationManager *theManager = [[CLLocationManager alloc] init];
    self.locationManager = theManager;
    self.locationManager.delegate = self;
  }

  self.locationManager.distanceFilter = 1000;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
  [self.locationManager startUpdatingLocation];

  if ([CLLocationManager headingAvailable]) {
    self.locationManager.headingFilter = 5;
    [self.locationManager startUpdatingHeading];
  }
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading {

  self.userLocationPin.transform = CGAffineTransformMakeRotation(
      (manager.heading.trueHeading * M_PI) / 180.f);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

  if ([touches count] == 1) {
    UITouch *touch = [touches anyObject];
    if (touch.view.subviews && [touch tapCount] == 1) {

      CGPoint point = [touch locationInView:touch.view];

      FBAnnotationClusterView *selectedAnnotationView;
        
      NSMutableArray *annotationsArray;
     // for (id View in touch.view.subviews) {

        if ([touch.view isMemberOfClass:[FBAnnotationClusterView class]]) {

         // FBAnnotationClusterView *annotationView =   (FBAnnotationClusterView *)View;

          // TODO: test it
        //  CGRect frame = [touch.view convertRect:touch.view.frame toView:self.view];

          // WAS          CGRect frame =
          //              [annotationView
          //              convertRect:annotationView.annotationLabel.frame
          //                                   toView:self.view];

        //  if (CGRectContainsPoint(frame, point)) {


            // annotationsArray = [annotationView.annotation.annotations copy];

            // annotationsArray = [NSMutableArray new];
            //            for (HMMapAnnotation *annotation in
            //            annotationView.annotation
            //                     .annotations) {
            //              [annotationsArray addObject:annotation];
            //            }
            selectedAnnotationView = (FBAnnotationClusterView *)touch.view;
           // break;
         // }
     //   }
      }

      NSArray *array = [selectedAnnotationView.annotation.annotations copy];
      [self.mapView showAnnotations:array animated:YES];

      [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width /
                       self.mapView.visibleMapRect.size.width;

        NSArray *annotations = [self.clusteringManager
            clusteredAnnotationsWithinMapRect:self.mapView.visibleMapRect
                                withZoomScale:scale];

        [self.clusteringManager displayAnnotations:annotations
                                         onMapView:self.mapView];
      }];
    }
  }
}

// MARK: Solution with subclassed MKCircleView
- (void)addGesturerecognizersForOverlays {
  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleMapTap:)];
  tap.cancelsTouchesInView = NO;
  tap.numberOfTapsRequired = 1;

  UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
  tap2.cancelsTouchesInView = NO;
  tap2.numberOfTapsRequired = 2;

  [self.mapView addGestureRecognizer:tap2];
  [self.mapView addGestureRecognizer:tap];
  [tap requireGestureRecognizerToFail:tap2];
  // Ignore single tap if the user actually double taps
}

//- (void)mapTapped:(UITapGestureRecognizer *)recognizer {
//  MKMapView *mapView = (MKMapView *)recognizer.view;
//  id<MKOverlay> tappedOverlay = nil;
//  for (id<MKOverlay> overlay in mapView.overlays) {
//
//    MKOverlayView *view = [mapView viewForOverlay:overlay];
//    if (view) {
//      // Get view frame rect in the mapView's coordinate system
//      CGRect viewFrameInMapView =
//          [view.superview convertRect:view.frame toView:mapView];
//      // Get touch point in the mapView's coordinate system
//      CGPoint point = [recognizer locationInView:mapView];
//      // Check if the touch is within the view bounds
//      if (CGRectContainsPoint(viewFrameInMapView, point)) {
//        tappedOverlay = overlay;
//        break;
//      }
//    }
//  }
//  NSLog(@"Tapped view: %@", [mapView viewForOverlay:tappedOverlay]);
//}

- (void)handleMapTap:(UIGestureRecognizer *)tap {
  CGPoint tapPoint = [tap locationInView:self.mapView];

  CLLocationCoordinate2D tapCoord =
      [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
  MKMapPoint mapPoint = MKMapPointForCoordinate(tapCoord);
  CGPoint mapPointAsCGP = CGPointMake(mapPoint.x, mapPoint.y);

  for (id<MKOverlay> overlay in self.mapView.overlays) {
    if ([overlay isKindOfClass:[ClusterOverlayView class]]) {

      // update cluster view according to rating

      // initialize colours for cluster
      UIColor *color = [UIColor redColor];

      //      overlay.fillColor = color;
      //      overlay.strokeColor = color;
      //      overlay.lineWidth = 2;

      // MKPolygon *polygon = (MKPolygon*) overlay;

      //            CGMutablePathRef mpr = CGPathCreateMutable();
      //
      //            MKMapPoint *polygonPoints = polygon.points;
      //
      //            for (int p=0; p < polygon.pointCount; p++){
      //                MKMapPoint mp = polygonPoints[p];
      //                if (p == 0)
      //                    CGPathMoveToPoint(mpr, NULL, mp.x, mp.y);
      //                else
      //                    CGPathAddLineToPoint(mpr, NULL, mp.x, mp.y);
      //            }
      //
      //            if(CGPathContainsPoint(mpr , NULL, mapPointAsCGP, FALSE)){
      //                // ... found it!
      //            }
      //
      //            CGPathRelease(mpr);
    }
  }
}

@end
