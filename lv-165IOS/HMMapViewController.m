//
//  ViewController.m
//  lv-165IOS
//
//  Created by AG on 11/23/15.
//  Copyright © 2015 AG. All rights reserved.
//

#import "Branch/BranchLinkProperties.h"
#import "Branch/BranchUniversalObject.h"
#import "Comments.h"
#import "Description.h"
#import "DescriptionInfo.h"
#import "FBAnnotationClustering/FBAnnotationClustering.h"
#import "HMAnnotationView.h"
#import "HMCommentsTableViewController.h"
#import "HMFiltersViewController.h"
#import "HMMapAnnotation.h"
#import "HMMapAnnotation.h"
#import "HMMapViewController.h"
#import "HMSearchViewController.h"
#import "HMSettingsViewController.h"
#import "HMWeatherManager.h"
#import "Place.h"
#import "SVGeocoder.h"
#import "UIView+MKAnnotationView.h"
#import "User.h"
#import "Waiting.h"
#import "Branch/BranchUniversalObject.h"
#import "Branch/BranchLinkProperties.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworking/AFHTTPSessionManager.h"
#import "HMGoogleDirectionsViewController.h"
#import "UILabel+HMdynamicSizeMe.h"
#import "HMImgurManager.h"
#import "HMWeatherViewController.h"
#import "DirectionBus.h"
#import "FBAnnotationClustering.h"

@interface HMMapViewController ()

@property(strong, nonatomic) CLLocationManager *locationManager;

//@property (strong, nonatomic) NSFetchedResultsController
//*fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@property(strong, nonatomic) NSArray *mapPointArray;

@property(assign, nonatomic) NSInteger ratingOfPoints;
@property(assign, nonatomic) BOOL pointHasComments;
@property(assign, nonatomic) BOOL pointHasDescription;

@property(strong, nonatomic) NSArray *placeArray;

@property(weak, nonatomic) MKAnnotationView *userLocationPin;
@property(weak, nonatomic) MKAnnotationView *aciveAnnotationView;
@property(assign, nonatomic) CLLocationCoordinate2D coordinateToPin;

@property(weak, nonatomic) MKAnnotationView *annotationView;
@property(strong, nonatomic) FBClusteringManager *clusteringManager;
@property(strong, nonatomic) NSMutableArray *clusteredAnnotations;
@property(strong, nonatomic) NSDictionary *weatherDict;

@property(strong, nonatomic) NSString *stringForGoogleDirectionsInstructions;

@end

static NSString *kSettingsComments = @"comments";
static NSString *kSettingsRating = @"rating";

static NSString *BaseURLForGoogleMDAPI =
    @"https://maps.googleapis.com/maps/api/directions/";

@implementation HMMapViewController

static NSMutableArray *nameCountries;
static bool isMainRoute;
static bool isRoad;

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib

  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(showPlace:)
                                               name:showPlaceNotificationCenter
                                             object:nil];
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  self.ratingOfPoints = [userDefaults integerForKey:kSettingsRating];
  self.pointHasComments = [userDefaults boolForKey:kSettingsComments];
  self.pointHasDescription = [userDefaults boolForKey:kSettingsComments];

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

  NSArray *buttonsForDownToolBar = @[
    [self createColorButton:@"compass"
                   selector:@selector(showYourCurrentLocation:)],
    flexibleItem,
    [self createColorButton:@"Lupa" selector:@selector(buttonSearch:)],
    flexibleItem,
    [self createColorButton:@"filter"
                   selector:@selector(moveToFilterController:)],
    flexibleItem,
    [self createColorButton:@"tools"
                   selector:@selector(moveToToolsController:)]
  ];

  NSArray *buttonsForUpToolBar = @[
    [self createColorButton:@"sharing30_30"
                   selector:@selector(sharingForSocialNetworking:)],
    flexibleItem,
    [self createColorButton:@"favptite30_30"
                   selector:@selector(addToFavourite:)],
    flexibleItem,
    [self createColorButton:@"info30_30" selector:@selector(infoMethod:)],
    flexibleItem,
    [self createColorButton:@"road30_30"
                   selector:@selector(showRoudFromThisPlaceToMyLocation:)],
    flexibleItem,
    [self createColorButton:@"direction_compass"
                   selector:@selector(showDirectionToThisAnnotation:)],
    flexibleItem,
    [self createColorButton:@"weather"
                   selector:@selector(weatherShow:)]
  ];

  [self.downToolBar setItems:buttonsForDownToolBar animated:YES];

  [self.upToolBar setItems:buttonsForUpToolBar animated:YES];

  self.constraitToShowUpToolBar.constant = 0.0f;
  self.mapView.showsUserLocation = YES;

  [self loadSettings];

  self.locationManager.delegate = self;

  [self startHeadingEvents];

  [self.locationManager startUpdatingHeading];
  [self.locationManager startUpdatingLocation];

  self.mapView.showsScale = YES;

  [self.viewForPinOfInfo setUserInteractionEnabled:YES];

  UISwipeGestureRecognizer *swipeUp =
      [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSwipe:)];
  UISwipeGestureRecognizer *swipeDown =
      [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSwipe:)];

  // Setting the swipe direction.
  [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
  [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];

  // Adding the swipe gesture on image view
  [self.viewForPinOfInfo addGestureRecognizer:swipeUp];
  [self.viewForPinOfInfo addGestureRecognizer:swipeDown];
    
    NSDictionary *params = [[Branch getInstance] getLatestReferringParams];
    NSNumber *placeId = [params objectForKey:@"place_id"];
    if (placeId) {
        [self showPlaceAnnotation:placeId];
    }
}

- (void)showPlaceAnnotation:(NSNumber *)placeId {
    self.placeArray =
    [[HMCoreDataManager sharedManager] getPlaceWithStringId:[NSString stringWithFormat:@"%@", placeId]];
    
    Place *place = [self.placeArray firstObject];
    User *user = place.user;
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(place.lat.doubleValue, place.lon.doubleValue);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = {coord, span};
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coord];
    
    [self.mapView setRegion:region];
    [self.mapView addAnnotation:annotation];
    
    self.downToolBar.hidden = YES;
    
    Description *desc = place.descript;
    
    self.descriptionTextView.text = desc.descriptionString;
    self.autorDescriptionLable.text = user.name;
    Waiting *waiting = place.waiting;
    self.waitingTimeLable.text = [NSString
                                  stringWithFormat:NSLocalizedString(@"Average waiting time: %@", nil), waiting.avg_textual];
    [self.descriptionTextView resizeHeightToFitForLabel:self.descriptionTextView];
    
    self.constraitToShowUpToolBar.constant = self.waitingTimeLable.frame.size.height +
    self.descriptionTextView.frame.size.height + 60.f;
    
    [self.viewToAnimate setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:1.f
                     animations:^{
                         [self.viewToAnimate layoutIfNeeded];
                     }];
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  self.ratingOfPoints = [userDefaults integerForKey:kSettingsRating];
  self.pointHasComments = [userDefaults boolForKey:kSettingsComments];
  self.pointHasDescription = [userDefaults boolForKey:kSettingsComments];
  [self.mapView removeAnnotations:self.mapView.annotations];
  [self printPointWithContinent];

  NSLog(@" Points in map array %lu", (unsigned long)[self.mapPointArray count]);
  NSLog(@" point has comments %@", self.pointHasComments ? @"Yes" : @"No");

  [[self navigationController] setNavigationBarHidden:YES animated:YES];

  [self loadSettings];

  if (!self.clusteringManager) {

    [[NSOperationQueue new] addOperationWithBlock:^{
      double scale =
          _mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
      self.clusteringManager = [[FBClusteringManager alloc]
          initWithAnnotations:_clusteredAnnotations];

      self.clusteringManager.scale = [[NSNumber alloc] initWithDouble:1.6];

      NSArray *annotations = [self.clusteringManager
          clusteredAnnotationsWithinMapRect:_mapView.visibleMapRect
                              withZoomScale:scale];
      [self.clusteringManager displayAnnotations:annotations
                                       onMapView:_mapView];
    }];
  } else {

    [self reloadClusteringAnimated:NO];
  }
}

- (void)reloadClusteringAnimated:(BOOL)animated {
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    double scale =
        _mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
    NSArray *annotations = [self.clusteringManager
        clusteredAnnotationsWithinMapRect:_mapView.visibleMapRect
                            withZoomScale:scale];
    if (animated) {
      for (HMMapAnnotation *annotation in annotations) {
        if ([annotation isMemberOfClass:[FBAnnotationCluster class]]) {
          FBAnnotationCluster *clusterAnnotation =
              (FBAnnotationCluster *)annotation;
          clusterAnnotation.animated = YES;
        }
      }
    }
      
    [self.clusteringManager displayAnnotations:annotations onMapView:_mapView];
  }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  [self reloadClusteringAnimated:animated];
}

- (void)mapView:(MKMapView *)mapView
    didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
  [self.clusteringManager firePieChartAnimation];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {

  if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
    NSLog(@"Up Swipe");

      NSString *stringId = [NSString stringWithFormat:@"%ld",
                            (long)((HMMapAnnotation *)self.annotationView.annotation).idPlace];

    self.placeArray =
        [[HMCoreDataManager sharedManager] getPlaceWithStringId:stringId];

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

  [button addTarget:self
                action:selector
      forControlEvents:UIControlEventTouchUpInside];
  button.frame = CGRectMake(0, 0, 30, 30);
  button.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
  UIView *viewForButton =
      [[UIView alloc] initWithFrame:CGRectMake(0, 30, 30, 30)];
  [viewForButton addSubview:button];
  UIBarButtonItem *buttonForviewForButton =
      [[UIBarButtonItem alloc] initWithCustomView:viewForButton];

  return buttonForviewForButton;
}

#pragma mark - buttons on Tool Bar

- (void)showYourCurrentLocation:(UIBarButtonItem *)sender {

  if (self.mapView.userLocation.location) {
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
- (void)weatherShow:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"weather" sender:sender];
}

#pragma mark - Tool Bar for Pin

- (void)sharingForSocialNetworking:(UIBarButtonItem *)sender {

  BranchUniversalObject *branchUniversalObject =
      [[BranchUniversalObject alloc] initWithCanonicalIdentifier:@"10000"];
  [branchUniversalObject registerView];

  Place *place = [self.placeArray firstObject];
  User *user = place.user;

  self.autorDescriptionLable.text = user.name;

  branchUniversalObject.title =
      [NSString stringWithFormat:@"Author: %@", place.user.name];
  branchUniversalObject.contentDescription = [NSString
      stringWithFormat:@"Lat: %@, Lon: %@\r\n Description: %@", place.lat,
                       place.lon, place.descript.descriptionString];
  [branchUniversalObject
      addMetadataKey:@"place_id"
               value:[NSString stringWithFormat:@"%@", place.id]];

  UIGraphicsBeginImageContext(self.mapView.bounds.size);
  [self.mapView drawViewHierarchyInRect:self.mapView.bounds
                     afterScreenUpdates:YES];
  UIImage *locationImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  NSData *data = UIImagePNGRepresentation(locationImage);

  NSString *clientId = @"ba6022d743eb49c";

  NSString *title = @"Screen for sharing";
  NSString *description =
      [NSString stringWithFormat:@"Lat: %@, Lon: %@", place.lat, place.lon];

  [HMImgurManager uploadPhoto:data
      title:title
      description:description
      imgurClientId:clientId
      completionBlock:^(NSString *result) {
        branchUniversalObject.imageUrl = result;

        BranchLinkProperties *linkProperties = [BranchLinkProperties new];

        linkProperties.feature = @"sharing";
        linkProperties.channel = @"default";
        [linkProperties
            addControlParam:@"$desktop_url"
                  withValue:[NSString
                                stringWithFormat:@"http://hitchwiki.org/maps/"
                                                 @"?zoom=15&lat=%@&lon=%@",
                                                 place.lat, place.lon]];
        [linkProperties addControlParam:@"$ios_url"
                              withValue:@"hitchwiki.iosmobile://"];

        [branchUniversalObject
            getShortUrlWithLinkProperties:linkProperties
                              andCallback:^(NSString *url, NSError *error) {
                                if (!error) {
                                  NSLog(@"Success getting url: %@", url);
                                }
                              }];

        [branchUniversalObject
            showShareSheetWithLinkProperties:linkProperties
                                andShareText:nil
                          fromViewController:self
                                 andCallback:^{
                                   NSLog(@"Finished presenting");
                                 }];
      }
      failureBlock:^(NSURLResponse *response, NSError *error,
                     NSInteger status) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Upload Failed"
                             message:[NSString stringWithFormat:
                                                   @"%@ (Status code %ld)",
                                                   [error localizedDescription],
                                                   (long)status]
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action){
                                   }];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

      }];
}

- (void)addToFavourite:(UIBarButtonItem *)sender {
    CLLocationCoordinate2D coordinate = self.annotationView.annotation.coordinate;
    [SVGeocoder reverseGeocode:coordinate completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            if ([placemarks count] > 0) {
                SVPlacemark* placeMark = [placemarks firstObject];
                NSString *stringOfPlace = [self creatingAObjectOfMassive:placeMark];
                
                NSNumber *latitude = [[NSNumber alloc] initWithDouble:placeMark.location.coordinate.latitude];
                NSNumber *longitude = [[NSNumber alloc] initWithDouble:placeMark.location.coordinate.longitude];
                
                NSDictionary *coordinate = @{
                  @"latitude" : latitude,
                  @"longitude" : longitude
                };
                NSDictionary *place = @{
                  @"StringOfPlace" : stringOfPlace,
                  @"Coordinate" : coordinate,
                };
                NSUserDefaults *userDefaults =
                    [NSUserDefaults standardUserDefaults];
                NSArray *tempArrayOne =
                    [userDefaults objectForKey:@"PlaceByFavourite"];
                NSInteger i = 0;
                for (NSDictionary *placeInDict in tempArrayOne) {
                  if ([[placeInDict objectForKey:@"StringOfPlace"]
                          isEqualToString:stringOfPlace]) {
                    i++;
                  }
                }
                if (i == 0) {
                NSMutableArray *tempArrayTwo = [[NSMutableArray alloc] initWithArray:tempArrayOne];
                    if ([tempArrayTwo count] > 10) {
                        for (NSInteger i = 0; i < ([tempArrayTwo count] - 10); i ++) {
                            [tempArrayTwo removeObjectAtIndex:i];
                        }
                    }
                [tempArrayTwo addObject:place];
                [userDefaults removeObjectForKey:@"PlaceByFavourite"];
                [userDefaults setObject:tempArrayTwo forKey:@"PlaceByFavourite"];
            }
            } else {
                NSLog(@"No Placemarks Found");
              }
            }
          }];
}

- (void)infoMethod:(UIBarButtonItem *)sender {
  [self performSegueWithIdentifier:@"Comments" sender:self];
}

- (void)showRoudFromThisPlaceToMyLocation:(UIBarButtonItem *)sender {

  if ([self.mapView.overlays count]) {
    [self.mapView removeOverlays:self.mapView.overlays];
    isRoad = NO;
    return;
  }

  if (self.mapView.userLocation.location) {

    if (!self.aciveAnnotationView) {
      return;
    }
    isRoad = YES;

    self.coordinateToPin = self.aciveAnnotationView.annotation.coordinate;
    CLLocationCoordinate2D coordinate =
        self.aciveAnnotationView.annotation.coordinate;

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

- (void)showDirectionToThisAnnotation:(UIBarButtonItem *)sender {

  NSString *string = [NSString
      stringWithFormat:@"%@json?origin=%f,%f&destination=%f,%f&mode=transit&"
                       @"alternatives=true&key=AIzaSyCi2xvtI8XRpu3ee6I35-"
                       @"HVenilkXXokEI",
                       BaseURLForGoogleMDAPI,
                       self.mapView.userLocation.location.coordinate.latitude,
                       self.mapView.userLocation.location.coordinate.longitude,
                       self.annotationView.annotation.coordinate.latitude,
                       self.annotationView.annotation.coordinate.longitude];

  NSURL *url = [NSURL URLWithString:string];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];

  AFHTTPRequestOperation *operation =
      [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];

  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                             id responseObject) {

    NSArray *routes = [((NSDictionary *)responseObject)objectForKey:@"routes"];

    for (id objectInRoutes in routes) {

      NSArray *legs = [(NSDictionary *)objectInRoutes objectForKey:@"legs"];

      for (id objectInLegs in legs) {

        NSArray *steps = [(NSDictionary *)objectInLegs objectForKey:@"steps"];

        for (id objectInSteps in steps) {
            
            if ([objectInSteps objectForKey:@"html_instructions"] && ![[[objectInSteps objectForKey:@"html_instructions"] description] isEqualToString:@""]) {

            self.stringForGoogleDirectionsInstructions = [NSString
                stringWithFormat:@"%@%@\n",
                                 self.stringForGoogleDirectionsInstructions,
                                 [objectInSteps
                                     objectForKey:@"html_instructions"]];
          }

          if ([objectInSteps objectForKey:@"transit_details"]) {

            NSDictionary *inTransitDetails =
                [objectInSteps objectForKey:@"transit_details"];

            NSDictionary *inLines = [inTransitDetails objectForKey:@"line"];

            if ([inLines objectForKey:@"url"] && ![[[inLines objectForKey:@"url"] description] isEqualToString:@""]) {

              self.stringForGoogleDirectionsInstructions = [NSString
                  stringWithFormat:@"%@%@\n",
                                   self.stringForGoogleDirectionsInstructions,
                                   [inLines objectForKey:@"url"]];
                    }
                }
            }
          }
        }

        NSString *stringId = [NSString stringWithFormat:@"%ld",
                              (long)((HMMapAnnotation *)self.annotationView.annotation).idPlace];
        
        self.placeArray =
        [[HMCoreDataManager sharedManager] getPlaceWithStringId:stringId];
        
        [self performSegueWithIdentifier:@"showGoogleDirectionsViewController"
                                  sender:sender];
        self.stringForGoogleDirectionsInstructions = @"";
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", error.description);
        
        NSString *stringId = [NSString stringWithFormat:@"%ld",
                              (long)((HMMapAnnotation *)self.annotationView.annotation).idPlace];
        
        NSArray *tempArray = [[HMCoreDataManager sharedManager]
                              getPlaceWithStringId:stringId];
        
        Place *place = [tempArray firstObject];
        
        DirectionBus *directionBus = place.directionBus;
        
        if (directionBus.directionString) {
            self.stringForGoogleDirectionsInstructions = directionBus.directionString;
        }
        else {
            NSLog(@"no directionBus.directionString");
        }
        
        [self performSegueWithIdentifier:@"showGoogleDirectionsViewController"
                                  sender:sender];
        
        self.stringForGoogleDirectionsInstructions = @"";

        NSLog(@"%@", error.description);

  }];

  [operation start];
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
        Place  *place = [self.placeArray firstObject];
        HMCommentsTableViewController *createViewController = segue.destinationViewController;
        createViewController.create = place;
    } else if ([segue.identifier isEqualToString:@"showGoogleDirectionsViewController"]) {
        
        Place *place = [self.placeArray firstObject];
        HMGoogleDirectionsViewController *destViewController = segue.destinationViewController;
        
        destViewController.place = place;
        destViewController.textForLabel = self.stringForGoogleDirectionsInstructions;
        
    } else if ([[segue identifier] isEqualToString:@"weather"]) {
        
        if (!self.weatherDict) {
            
            [self showAlertWithTitle:@"Oops! No Internet"
                          andMessage:@"Check your connection"
                      andActionTitle:@"OK"];
            
        } if ([[segue identifier] isEqualToString:@"showGoogleDirectionsViewControllerCoreData"]) {
           
            HMGoogleDirectionsViewController *destViewController = segue.destinationViewController;
            
            Place *place = [self.placeArray firstObject];
            
            DirectionBus *directionBus = place.directionBus;
            
            if (directionBus.directionString) {
                destViewController.textForLabel = directionBus.directionString;
            }
            else {
                NSLog(@"no directionBus.directionString");
            }
            
        } else {
            NSDictionary *weather = self.weatherDict;
            HMWeatherViewController *weatherViewController = segue.destinationViewController;
            weatherViewController.weatherDict = weather;
        }
    }
}

#pragma mark - Deallocation

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Annotation View

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<HMAnnotationView>)annotation {

  static NSString *identifier = @"Annotation";
  MKPinAnnotationView *pin = (MKPinAnnotationView *)
      [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
  if ([annotation isKindOfClass:[MKUserLocation class]]) {

    NSString *identifier = @"UserAnnotation";

    MKAnnotationView *pin = (MKAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!pin) {

      pin = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                         reuseIdentifier:identifier];

      pin.canShowCallout = YES;
      pin.image = [UIImage imageNamed:@"UserArrow"];
    } else {
      pin.annotation = annotation;
    }

    self.userLocationPin = pin;
    return pin;
  } else if ([annotation isMemberOfClass:[FBAnnotationCluster class]]) {
    FBAnnotationCluster *clusterAnnotation = annotation;
    if (clusterAnnotation.animated) {
      FBAnnotationClusterView *clusterAnnotationView =
          [[FBAnnotationClusterView alloc]
              initWithAnnotation:clusterAnnotation
               clusteringManager:_clusteringManager];
      return clusterAnnotationView;
    } else {

      FBAnnotationClusterView *clusterAnnotationView =
          [[FBAnnotationClusterView alloc]
              initWithAnnotation:clusterAnnotation
               clusteringManager:_clusteringManager];
      return clusterAnnotationView;
    }
  } else {
    if (!pin) {
      pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                            reuseIdentifier:identifier];
    }

    switch (((HMMapAnnotation *)annotation).ratingForColor) {

    case noRating: {
      pin.pinTintColor = [UIColor darkGrayColor];
      break;
    }
    case badRating: {
      pin.pinTintColor = [UIColor redColor];
      break;
    }
    case normalRating: {
      pin.pinTintColor = [UIColor colorWithRed:(252 / 255.0)
                                         green:(190 / 255.0)
                                          blue:(78 / 255.0)
                                         alpha:1];
      break;
    }
    case goodRating: {
      pin.pinTintColor = [UIColor colorWithRed:(200 / 255.0)
                                         green:(233 / 255.0)
                                          blue:(100 / 255.0)
                                         alpha:1];
      break;
    }
    case veryGoodRating: {
      pin.pinTintColor = [UIColor colorWithRed:(140 / 255.0)
                                         green:(180 / 255.0)
                                          blue:(110 / 255.0)
                                         alpha:1];
      break;
    }
    }
    pin.animatesDrop = NO;

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
  }
  return nil;
}

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

//          [self showAlertWithTitle:@"No direction"
//                        andMessage:@"There is no connection between your "
//                        @"position and this point"
//                    andActionTitle:@"OK"];

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

- (void)printPointWithContinent {

  NSInteger minForPoint = 0;
  NSInteger maxForPoint = 5;

  switch (self.ratingOfPoints) {
  case 0: {
    minForPoint = 0;
    maxForPoint = 5;
    break;
  }
  case 1: {
    minForPoint = 4;
    maxForPoint = 5;
    break;
  }
  case 2: {
    minForPoint = 1;
    maxForPoint = 3;
    break;
  }
  default:
    break;
  }

  NSString *startRating =
      [NSString stringWithFormat:@" %ld", (long)maxForPoint];
  NSString *endRating = [NSString stringWithFormat:@" %ld", (long)minForPoint];

  if (!self.pointHasComments || !self.pointHasDescription) {

    self.mapPointArray =
        [[HMCoreDataManager sharedManager] getPlaceWithStartRating:startRating
                                                         endRating:endRating];
  } else {

    self.mapPointArray = [[HMCoreDataManager sharedManager]
        getPlaceWithCommentsStartRating:startRating
                              endRating:endRating];
  }

  NSLog(@"MAP annotation array count %lu",
        (unsigned long)self.mapPointArray.count);
  _clusteredAnnotations = [NSMutableArray new];
  for (Place *place in self.mapPointArray) {
    HMMapAnnotation *annotation = [[HMMapAnnotation alloc] init];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [place.lat doubleValue];
    coordinate.longitude = [place.lon doubleValue];

    if ([place.rating intValue] == 0) {
      annotation.ratingForColor = noRating;
    } else if ([place.rating intValue] == 5) {
      annotation.ratingForColor = badRating;
    } else if ([place.rating intValue] == 4) {
      annotation.ratingForColor = normalRating;
    } else if ([place.rating intValue] == 3) {
      annotation.ratingForColor = goodRating;
    } else if (([place.rating intValue] >= 1) &&
               ([place.rating intValue] <= 2)) {
      annotation.ratingForColor = veryGoodRating;
    }
    annotation.coordinate = coordinate;
    annotation.title = [NSString stringWithFormat:@"Rating = %@", place.rating];

    annotation.subtitle = [NSString
        stringWithFormat:@"%.5g, %.5g", annotation.coordinate.latitude,
                         annotation.coordinate.longitude];
    annotation.idPlace = [place.id integerValue];
    [_clusteredAnnotations addObject:annotation];
    //[self.mapView addAnnotation:annotation];
  }
}

#pragma mark - methods for Notification

- (void)showPlace:(NSNotification *)notification {
  [self.navigationController popViewControllerAnimated:YES];
  NSDictionary *object =
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

  if ([CLLocationManager headingAvailable]) {
    self.locationManager.headingFilter = 5;
    [self.locationManager startUpdatingHeading];
  }
}

- (void)mapView:(MKMapView *)mapView
    didSelectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(10_9, 4_0) {

  self.aciveAnnotationView = view;

  if (![view isMemberOfClass:[FBAnnotationClusterView class]]) {

    self.annotationView = view;

    self.downToolBar.hidden = YES;
    NSString *stringId = [NSString
        stringWithFormat:@"%ld",
                         (long)((HMMapAnnotation *)view.annotation).idPlace];

    self.placeArray =
        [[HMCoreDataManager sharedManager] getPlaceWithStringId:stringId];

    Place *place = [self.placeArray firstObject];
    User *user = place.user;
      

    self.weatherDict = [[NSDictionary alloc] init];
      [[HMWeatherManager sharedManager] getWeatherByCoordinate:place onSuccess:^(NSDictionary *weather) {
          
          self.weatherDict = weather;
      } onFailure:^(NSError *error, NSInteger statusCode) {
          
          NSLog(@"%@%ld",error,(long)statusCode);
      }];

    self.autorDescriptionLable.text = user.name;

    Description *desc = place.descript;

    self.descriptionTextView.text = desc.descriptionString;
    Waiting *waiting = place.waiting;
    self.waitingTimeLable.text = [NSString
        stringWithFormat:NSLocalizedString(@"Average waiting time: %@", nil), waiting.avg_textual];
    [self.descriptionTextView
        resizeHeightToFitForLabel:self.descriptionTextView];

    self.constraitToShowUpToolBar.constant =
        self.waitingTimeLable.frame.size.height +
        self.descriptionTextView.frame.size.height + 60.f;

    [self.viewToAnimate setNeedsUpdateConstraints];

    [UIView animateWithDuration:1.f
                     animations:^{
                       [self.viewToAnimate layoutIfNeeded];
                     }];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

  if ([touches count] == 1) {
    UITouch *touch = [touches anyObject];
    if (touch.view.subviews && [touch tapCount] == 1) {

      FBAnnotationClusterView *selectedAnnotationView;

      if ([touch.view isMemberOfClass:[FBAnnotationClusterView class]]) {
        selectedAnnotationView = (FBAnnotationClusterView *)touch.view;
        [self showClusterAnimated:selectedAnnotationView];
      }
    }
  }
}

- (void)showClusterAnimated:(FBAnnotationClusterView *)annotationView {
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{

    NSArray *array = annotationView.annotation.annotations;

    MKMapRect zoomRect = MKMapRectNull;
    for (id<MKAnnotation> annotation in array) {
      MKMapPoint annotationPoint =
          MKMapPointForCoordinate(annotation.coordinate);
      MKMapRect pointRect =
          MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
      zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }

    for (HMMapAnnotation *annotation in array) {
      if ([annotation isMemberOfClass:[FBAnnotationCluster class]]) {

        FBAnnotationCluster *clusterAnnotation =
            (FBAnnotationCluster *)annotation;
        clusterAnnotation.animated = YES;
      }
    }
      
    [_mapView setVisibleMapRect:zoomRect animated:YES];
    [_mapView removeAnnotation:annotationView.annotation];
      
  }];
}

- (void)mapView:(MKMapView *)mapView
    didDeselectAnnotationView:(MKAnnotationView *)view {

  if (![view isMemberOfClass:[FBAnnotationClusterView class]]) {
    self.downToolBar.hidden = NO;
    [self.viewToAnimate setNeedsUpdateConstraints];

    [UIView animateWithDuration:1.f
                     animations:^{
                       [self.viewToAnimate layoutIfNeeded];
                     }];
  }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {

  if (isRoad) {

    if (!CLLocationCoordinate2DIsValid(self.coordinateToPin)) {
      return;
    }

    CLLocationCoordinate2D coordinate = self.coordinateToPin;

    isMainRoute = YES;
    [self createRouteForAnotationCoordinate:newLocation.coordinate
                            startCoordinate:coordinate];
    isMainRoute = NO;
    [self createRouteForAnotationCoordinate:newLocation.coordinate
                            startCoordinate:coordinate];
  }
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading {

  self.userLocationPin.transform = CGAffineTransformMakeRotation(
      (manager.heading.trueHeading * M_PI) / 180.f);
}

#pragma mark - Alert

- (void)showAlertWithTitle:(NSString *)title
                andMessage:(NSString *)message
            andActionTitle:(NSString *)actionTitle {

  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:title
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *defaultAction =
      [UIAlertAction actionWithTitle:actionTitle
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action){
                             }];

  [alert addAction:defaultAction];
  [self presentViewController:alert animated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

  return UIInterfaceOrientationMaskAll;
}

- (NSString *)creatingAObjectOfMassive:(SVPlacemark *)placeMark {
  NSMutableArray *levelOfLocality = [NSMutableArray array];
  if (placeMark.formattedAddress) {
    [levelOfLocality addObject:placeMark.formattedAddress];
  }
  if (placeMark.administrativeArea) {
    [levelOfLocality addObject:placeMark.administrativeArea];
  }
  if (placeMark.subAdministrativeArea) {
    [levelOfLocality addObject:placeMark.subAdministrativeArea];
  }
  if (placeMark.thoroughfare) {
    [levelOfLocality addObject:placeMark.thoroughfare];
  }
  NSInteger count = 0;
  NSMutableString *str = [NSMutableString stringWithFormat:@""];
  for (id dataOfLocality in levelOfLocality) {
    if (count >= 3) {
      break;
    }
    if (dataOfLocality) {
      [str appendFormat:@", %@", dataOfLocality];
      count++;
    }
  }
  [str deleteCharactersInRange:NSMakeRange(0, 1)];
  return str;
}

@end
