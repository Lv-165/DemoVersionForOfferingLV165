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

@interface HMMapViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@property (strong, nonatomic) NSMutableArray* mapPointArray;

@property (assign, nonatomic) NSInteger ratingOfPoints;
@property (assign, nonatomic) BOOL pointHasComments;

@property (strong, nonatomic) NSArray *placeArray;

@property (weak, nonatomic) MKAnnotationView *userLocationPin;

@end

static NSString* kSettingsComments = @"comments";
static NSString* kSettingsRating = @"rating";

@implementation HMMapViewController

static NSMutableArray* nameCountries;
static bool isMainRoute;

- (NSManagedObjectContext*) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[HMCoreDataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPlace:)
                                                 name:showPlaceNotificationCenter object:nil];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.ratingOfPoints = [userDefaults integerForKey:kSettingsRating];
    self.pointHasComments = [userDefaults boolForKey:kSettingsComments];
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    UIBarButtonItem *flexibleItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *buttonsForDownToolBar = @[
                         [self createColorButton:@"compass"
                                        selector:@selector(showYourCurrentLocation:)],
                         flexibleItem,
                         [self createColorButton:@"Lupa"
                                        selector:@selector(buttonSearch:)],
                         flexibleItem,
                         [self createColorButton:@"filter"
                                        selector:@selector(moveToFilterController:)],
                         flexibleItem,
                         [self createColorButton:@"tools"
                                        selector:@selector(moveToToolsController:)]
                         ];
    
    NSArray *buttonsForUpToolBar = @[
                                     [self createColorButton:@"compass" selector:@selector(showYourCurrentLocation:)]//To check do correct
                                     ];
    
    [self.downToolBar setItems:buttonsForDownToolBar animated:YES];
    
    [self.upToolBar setItems:buttonsForUpToolBar animated:YES];
    
    self.constraitToShowUpToolBar.constant = 0.0f;
    self.mapView.showsUserLocation = YES;
    
    [self loadSettings];
    
    self.locationManager.delegate = self;
    
    [self startHeadingEvents];
    
    [self.locationManager startUpdatingHeading];
    
    self.mapView.showsScale = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.ratingOfPoints = [userDefaults integerForKey:kSettingsRating];
    self.pointHasComments = [userDefaults boolForKey:kSettingsComments];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self printPointWithContinent];
    
    NSLog(@" Points in map array %lu",(unsigned long)[self.mapPointArray count]);
    NSLog(@" point has comments %@",self.pointHasComments ? @"Yes" : @"No");
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [self loadSettings];
}

#pragma mark - for creating buttons

- (UIBarButtonItem *)createColorButton:(NSString *)nameButton
                            selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:nameButton]
                      forState:UIControlStateNormal];
    
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 30, 30);
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    UIView *viewForButton = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 30, 30)];
    [viewForButton addSubview:button];
    UIBarButtonItem *buttonForviewForButton = [[UIBarButtonItem alloc] initWithCustomView:viewForButton];
    
    return buttonForviewForButton;
}

#pragma mark - buttons on Tool Bar

- (void)showYourCurrentLocation:(UIBarButtonItem *)sender {
    MKMapRect zoomRect = MKMapRectNull;
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    MKMapPoint center = MKMapPointForCoordinate(location);
    static double delta = 40000;
    MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
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
        Place  *place = [self.placeArray objectAtIndex:0];
        HMCommentsTableViewController *createViewController = segue.destinationViewController;
        createViewController.create = place;
    }
}

#pragma mark - Deallocation

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Annotation View

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <HMAnnotationView>)annotation {
    
    static NSString* identifier = @"Annotation";
    MKPinAnnotationView* pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        NSString *identifier = @"UserAnnotation";
        
        MKAnnotationView *pin = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!pin) {
        
            pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
        pin.canShowCallout = YES;
        pin.image = [UIImage imageNamed:@"UserArrow"];
    } else {
        pin.annotation = annotation;
    }
    
    self.userLocationPin = pin;
    return pin;
}
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    switch (((HMMapAnnotation *)annotation).ratingForColor) {
            
        case badRating:
        {
            pin.pinTintColor = [UIColor redColor];
            break;
        }
        case senseLess:
        {
            pin.pinTintColor = [UIColor whiteColor];
            break;
        }
        case veryGoodRating:
        {
            pin.pinTintColor = [UIColor greenColor];
            break;
        }
    }
    pin.animatesDrop = NO;
    pin.canShowCallout = YES;
    
    UIButton* descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [descriptionButton addTarget:self
                          action:@selector(actionDescription:)
                forControlEvents:UIControlEventTouchUpInside];
    pin.rightCalloutAccessoryView = descriptionButton;
    
    UIButton* directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [directionButton addTarget:self
                        action:@selector(actionDirection:)
              forControlEvents:UIControlEventTouchUpInside];
    pin.leftCalloutAccessoryView = directionButton;
    
    return pin;
}

#pragma mark - MKMapViewDelegate -

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        
        if (!isMainRoute) {
            renderer.lineWidth = 2.5f;
            renderer.strokeColor = [UIColor colorWithRed:0.f green:0.1f blue:1.f alpha:0.9f];
            return renderer;
        } else {
            renderer.lineWidth = 1.5f;
            renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.6f];
            return renderer;
        }
    }
    else if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonView.lineWidth = 2.f;
        polygonView.strokeColor = [UIColor magentaColor];
        
        return polygonView;
    }
    return nil;
}

#pragma mark - Alert -

- (UIAlertController *)createAlertControllerWithTitle:(NSString *)title
                                              message:(NSString *)message {
    
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:title
                                   message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
        return alert;
}

- (void)actionWithTitle:(NSString *)title
             alertTitle:(NSString *)alertTitle
           alertMessage:(NSString *)alertMessage {
    
    UIAlertController * alert = [self createAlertControllerWithTitle:alertTitle
                                                             message:alertMessage];
    UIAlertAction* alertAction = [UIAlertAction
                                  actionWithTitle:title
                                  style:UIAlertActionStyleCancel
                                  handler:^(UIAlertAction * action) {
                                  }];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) createRouteForAnotationCoordinate:(CLLocationCoordinate2D)endCoordinate
                           startCoordinate:(CLLocationCoordinate2D)startCoordinate {
    MKDirections* directions;
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:startCoordinate
                                                        addressDictionary:nil];
    MKMapItem* startDestination = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    request.source = startDestination;
    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:endCoordinate
                                                      addressDictionary:nil];
    MKMapItem *endDestination = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    
    request.destination = endDestination;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.requestsAlternateRoutes = isMainRoute;
    BOOL temp = isMainRoute;
    directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
    if (error) {
        NSLog(@"%@", error);
        } else if ([response.routes count] == 0) {
            NSLog(@"routes = 0");
        } else {
            NSMutableArray *array  = [NSMutableArray array];
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

- (void) actionDescription:(UIButton*) sender {
    MKAnnotationView* annotationView = [sender superAnnotationView];
    NSString *str = [NSString stringWithFormat:@"%ld",
                     (long)((HMMapAnnotation *)annotationView.annotation).idPlace];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", str];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = predicate;
    self.placeArray = [[self managedObjectContext] executeFetchRequest:request
                                                                 error:nil];
    [self performSegueWithIdentifier:@"Comments" sender:self];
}

- (void) actionDirection:(UIButton*) sender {
    [self removeRoutes];
    MKAnnotationView* annotationView = [sender superAnnotationView];
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

- (void) actionRemoveRoute:(UIButton*) sender {
    MKAnnotationView* annotationView = [sender superAnnotationView];
    UIButton* directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [directionButton addTarget:self action:@selector(actionDirection:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.leftCalloutAccessoryView = directionButton;
    
    [self removeRoutes];
}

- (void)printPointWithContinent {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    
    NSInteger minForPoint = 0;
    NSInteger maxForPoint = 5;
    
    switch (self.ratingOfPoints) {
        case 0:
        {
            minForPoint = 0;
            maxForPoint = 5;
            break;
        }
        case 1:
        {
            minForPoint = 1;
            maxForPoint = 3;
            break;
        }
        case 2:
        {
            minForPoint = 4;
            maxForPoint = 5;
            break;
        }
        default:
            break;
    }
    
    NSPredicate* ratingPredicate = [NSPredicate predicateWithFormat:@"%@ => rating  AND rating >= %@",[NSString stringWithFormat:@" %ld",(long)maxForPoint],[NSString stringWithFormat:@" %ld",(long)minForPoint]];
    
    if(!self.pointHasComments) {
        [fetchRequest setPredicate:ratingPredicate];
    } else {
        NSPredicate* commentsCountPredicate = [NSPredicate predicateWithFormat:@"comments_count > %@",@0];
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:ratingPredicate, commentsCountPredicate, nil]];
        
        [fetchRequest setPredicate:compoundPredicate];
    }
    self.mapPointArray = [[managedObjectContext executeFetchRequest:fetchRequest
                                                              error:nil] mutableCopy];
    NSLog(@"MAP annotation array count %lu",(unsigned long)self.mapPointArray.count);
    
    for (Place* place in self.mapPointArray) {
        HMMapAnnotation *annotation = [[HMMapAnnotation alloc] init];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [place.lat doubleValue];
        coordinate.longitude = [place.lon doubleValue];
        if ([place.rating intValue] == 0) {
            annotation.ratingForColor = senseLess;
        } else if (([place.rating intValue] >=4) && ([place.rating intValue] <= 5)) {
            annotation.ratingForColor = badRating;
        } else if (([place.rating intValue] >=1) && ([place.rating intValue] <= 3)) {
            annotation.ratingForColor = veryGoodRating;
        }
        annotation.coordinate = coordinate;
        annotation.title = [NSString stringWithFormat:@"Rating = %@", place.rating];
        annotation.subtitle = [NSString stringWithFormat:@"%.5g, %.5g",
                               annotation.coordinate.latitude,
                               annotation.coordinate.longitude];
        annotation.idPlace = [place.id integerValue];
        
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - methods for Notification

- (void)showPlace:(NSNotification *)notification {
    [self.navigationController popViewControllerAnimated:YES];
    SVPlacemark *object =
    [notification.userInfo objectForKey:showPlaceNotificationCenterInfoKey];
    CLLocationCoordinate2D point = object.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(point, 800, 800);
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(10_9, 4_0) {
    MKMapRect zoomRect = MKMapRectNull;

    CLLocationCoordinate2D location = view.annotation.coordinate;
    MKMapPoint center = MKMapPointForCoordinate(location);
    
    static double delta = 1000000;
    
    MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
    zoomRect = MKMapRectUnion(zoomRect, rect);
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    
    [self.mapView setVisibleMapRect:zoomRect
                        edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                           animated:YES];
    self.downToolBar.hidden = YES;
    self.constraitToShowUpToolBar.constant = 210.f;
    [self.viewToAnimate setNeedsUpdateConstraints];
    [UIView animateWithDuration:1.f animations:^{
        [self.viewToAnimate layoutIfNeeded];
    }];
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(10_9, 4_0) {
    self.downToolBar.hidden = NO;
    self.constraitToShowUpToolBar.constant = 0.f;
    [self.viewToAnimate setNeedsUpdateConstraints];
    [UIView animateWithDuration:1.f animations:^{
        [self.viewToAnimate layoutIfNeeded];
    }];
}



- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    self.userLocationPin.transform = CGAffineTransformMakeRotation((manager.heading.trueHeading * M_PI) / 180.f);
    
}

@end
