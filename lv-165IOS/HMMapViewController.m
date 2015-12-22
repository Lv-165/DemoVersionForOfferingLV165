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
#import "User.h"
#import "DescriptionInfo.h"
#import "Description.h"
#import "Waiting.h"
#import "Branch/BranchUniversalObject.h"
#import "Branch/BranchLinkProperties.h"

@interface HMMapViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;

//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@property (strong, nonatomic) NSArray* mapPointArray;

@property (assign, nonatomic) NSInteger ratingOfPoints;
@property (assign, nonatomic) BOOL pointHasComments;
@property (assign, nonatomic) BOOL pointHasDescription;

@property (strong, nonatomic) NSArray *placeArray;

@property (weak, nonatomic) MKAnnotationView *userLocationPin;

@property (weak , nonatomic) MKAnnotationView* annotationView;

@end

static NSString* kSettingsComments = @"comments";
static NSString* kSettingsRating = @"rating";

@implementation HMMapViewController

static NSMutableArray* nameCountries;
static bool isMainRoute;

//- (NSManagedObjectContext*) managedObjectContext {
//    
//    if (!_managedObjectContext) {
//        _managedObjectContext = [[HMCoreDataManager sharedManager] managedObjectContext];
//    }
//    return _managedObjectContext;
//}

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
    self.pointHasDescription = [userDefaults boolForKey:kSettingsComments];
    
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
                                     [self createColorButton:@"filter" selector:@selector(sharingForSocialNetworking:)],
                                     flexibleItem,
                                     [self createColorButton:@"favptite30_30" selector:@selector(addToFavourite:)],
                                     flexibleItem,
                                     [self createColorButton:@"info30_3-0" selector:@selector(infoMethod:)],
                                     flexibleItem,
                                     [self createColorButton:@"road30_30" selector:@selector(showRoudFromThisPlaceToMyLocation:)]
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
    
    
    [self.viewForPinOfInfo setUserInteractionEnabled:YES];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    // Adding the swipe gesture on image view
    [self.viewForPinOfInfo addGestureRecognizer:swipeUp];
    [self.viewForPinOfInfo addGestureRecognizer:swipeDown];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.ratingOfPoints = [userDefaults integerForKey:kSettingsRating];
    self.pointHasComments = [userDefaults boolForKey:kSettingsComments];
    self.pointHasDescription = [userDefaults boolForKey:kSettingsComments];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self printPointWithContinent];
    
    NSLog(@" Points in map array %lu",(unsigned long)[self.mapPointArray count]);
    NSLog(@" point has comments %@",self.pointHasComments ? @"Yes" : @"No");
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [self loadSettings];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"Up Swipe");
        
        NSString *stringId = [NSString stringWithFormat:@"%ld",
                              (long)((HMMapAnnotation *)self.annotationView.annotation).idPlace];
        
        self.placeArray = [[HMCoreDataManager sharedManager] getPlaceWithStringId:stringId];
        
        [self performSegueWithIdentifier:@"Comments" sender:self];
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"Down Swipe");
        NSArray *arr = self.mapView.selectedAnnotations;
        [self.mapView deselectAnnotation:[arr firstObject] animated:YES];
    }
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
    
    if (self.mapView.userLocation.location) {
        MKMapRect zoomRect = MKMapRectNull;
        CLLocationCoordinate2D location  = self.mapView.userLocation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        static double delta = 40000;
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        zoomRect = MKMapRectUnion(zoomRect, rect);
        zoomRect = [self.mapView mapRectThatFits:zoomRect];
        
        [self.mapView setVisibleMapRect:zoomRect
                            edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                               animated:YES];
    } else {
        
        [self showAlertWithTitle:@"No User Location"
                      andMessage:@"You didn't allow to get your current location"
                  andActionTitle:@"OK"];
    }
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

#pragma mark - Tool Bar for Pin

- (void)sharingForSocialNetworking:(UIBarButtonItem *)sender {

    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc]
                                                    initWithCanonicalIdentifier:@"1000"];
    [branchUniversalObject registerView];
    
    Place *place = [self.placeArray firstObject];
  
    branchUniversalObject.title = place.descript.descriptionString;
    branchUniversalObject.contentDescription = [NSString stringWithFormat:@"Lat: %@, Lon: %@", place.lat, place.lon];
    UIGraphicsBeginImageContext(self.mapView.frame.size);
    [self.mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *locationImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImagePNGRepresentation(locationImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *imageName = [NSString stringWithFormat:@"locationImage"];
    NSString *stringPath = [documentsDirectory stringByAppendingPathComponent:@"locationImage.png"];
    [data writeToFile:stringPath atomically:YES];
//    NSURL *dataURL = [[NSBundle mainBundle] URLForResource: @"locationImage" withExtension:@"png"];
    
    branchUniversalObject.imageUrl = stringPath;
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    
    linkProperties.feature = @"sharing";
    linkProperties.channel = @"default";
    [linkProperties addControlParam:@"$desktop_url" withValue:@"http://hitchwiki.org/"];
    [linkProperties addControlParam:@"$ios_url" withValue:@"hitchwiki.iosmobile://"];
    
    [branchUniversalObject getShortUrlWithLinkProperties:linkProperties
                                             andCallback:^(NSString *url, NSError *error) {
        if (!error) {
            NSLog(@"Success getting url: %@", url);
        }
    }];
        
    [branchUniversalObject showShareSheetWithLinkProperties:linkProperties
                                               andShareText:nil
                                         fromViewController:self
                                                andCallback:^{
                                                    NSLog(@"Finished presenting");
                                                }];
}

- (void)addToFavourite:(UIBarButtonItem *)sender {}
- (void)infoMethod:(UIBarButtonItem *)sender {}
- (void)showRoudFromThisPlaceToMyLocation:(UIBarButtonItem *)sender {}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showSettingsViewController"]) {
        
        // sending smth to destinationViewController
        
    } else if ([[segue identifier] isEqualToString:@"Comments"]) {
        Place  *place = [self.placeArray firstObject];
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
            
        case noRating:
        {
            pin.pinTintColor = [UIColor darkGrayColor];
            break;
        }
        case badRating:
        {
             pin.pinTintColor = [UIColor redColor];
            break;
        }
        case normalRating:
        {
            pin.pinTintColor = [UIColor colorWithRed:(252/255.0) green:(190/255.0) blue:(78/255.0) alpha:1];
            break;
        }
        case goodRating:
        {
            pin.pinTintColor = [UIColor colorWithRed:(200/255.0) green:(233/255.0) blue:(100/255.0) alpha:1];
            break;
        }
        case veryGoodRating:
        {
            pin.pinTintColor = [UIColor colorWithRed:(140/255.0) green:(180/255.0) blue:(110/255.0) alpha:1];
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
    MKMapItem *startDestination = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
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
        
        [self showAlertWithTitle:@"No direction"
                      andMessage:@"There is no connection between your position and this point"
                  andActionTitle:@"OK"];
        
        }
    else if ([response.routes count] == 0) {
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
//    MKAnnotationView* annotationView = [sender superAnnotationView];
//    NSString *stringId = [NSString stringWithFormat:@"%ld",
//                     (long)((HMMapAnnotation *)annotationView.annotation).idPlace];
//    
//    self.placeArray = [[HMCoreDataManager sharedManager] getPlaceWithStringId:stringId];
    
    [self performSegueWithIdentifier:@"Comments" sender:self];
}

- (void) actionDirection:(UIButton*) sender {
    
    if (self.mapView.userLocation.location) {
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
    } else {
        
        [self showAlertWithTitle:@"No User Location"
                      andMessage:@"You didn't allow to get your current location"
                  andActionTitle:@"OK"];
    }
}

- (void) actionRemoveRoute:(UIButton*) sender {
    MKAnnotationView* annotationView = [sender superAnnotationView];
    UIButton* directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [directionButton addTarget:self action:@selector(actionDirection:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.leftCalloutAccessoryView = directionButton;
    
    [self removeRoutes];
}

- (void)printPointWithContinent {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    
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
            minForPoint = 4;
            maxForPoint = 5;
            break;
        }
        case 2:
        {
            minForPoint = 1;
            maxForPoint = 3;
            break;
        }
        default:
            break;
    }
    
    NSString *startRating = [NSString stringWithFormat:@" %ld",(long)maxForPoint];
    NSString *endRating = [NSString stringWithFormat:@" %ld",(long)minForPoint];
    
    if(!self.pointHasComments ||!self.pointHasDescription) {
        
        self.mapPointArray  = [[HMCoreDataManager sharedManager] getPlaceWithStartRating:startRating
                                                                               endRating:endRating];
    } else {
  
        self.mapPointArray = [[HMCoreDataManager sharedManager] getPlaceWithCommentsStartRating:startRating
                                                                                      endRating:endRating];
    }
    
    NSLog(@"MAP annotation array count %lu",(unsigned long)self.mapPointArray.count);
    
    for (Place* place in self.mapPointArray) {
        HMMapAnnotation *annotation = [[HMMapAnnotation alloc] init];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [place.lat doubleValue];
        coordinate.longitude = [place.lon doubleValue];
        
        if ([place.rating intValue] == 0) {
            annotation.ratingForColor = noRating;
        }else if ([place.rating intValue] == 5) {
            annotation.ratingForColor = badRating;
        }else if ([place.rating intValue] == 4) {
            annotation.ratingForColor = normalRating;
        }else if ([place.rating intValue] == 3) {
            annotation.ratingForColor = goodRating;
        }else if (([place.rating intValue] >=1) && ([place.rating intValue] <= 2)) {
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

#pragma mark - methods for Notification//latitude":latitude, @"longitude

- (void)showPlace:(NSNotification *)notification {
    [self.navigationController popViewControllerAnimated:YES];
    NSDictionary  *object =
    [notification.userInfo objectForKey:showPlaceNotificationCenterInfoKey];
    CLLocationCoordinate2D point;
    
    point.latitude = [[object valueForKey:@"latitude"] doubleValue];
    point.longitude = [[object valueForKey:@"longitude"] doubleValue];
    
    MKCoordinateRegion region = self.mapView.region;
    region.center = point;
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

    self.annotationView = view;
    
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
    
    NSString *stringId = [NSString stringWithFormat:@"%ld",
                          (long)((HMMapAnnotation *)view.annotation).idPlace];
    
    self.placeArray = [[HMCoreDataManager sharedManager] getPlaceWithStringId:stringId];
    
    Place *place = [self.placeArray firstObject];
    User *user = place.user;
 
    self.autorDescriptionLable.text = user.name;

    Description *desc = place.descript;
    
    self.descriptionLable.text = desc.descriptionString;
    [self.descriptionLable sizeToFit];
    
    Waiting *waiting = place.waiting;
    self.waitingTimeLable.text = [NSString stringWithFormat:@"Average waiting time: %@", waiting.avg_textual];
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

#pragma mark - Alert

- (void)showAlertWithTitle:(NSString *)title
                andMessage:(NSString *)message
            andActionTitle:(NSString *)actionTitle {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:actionTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
    
}

@end
