//
//  HMCountriesViewController.m
//  lv-165IOS
//
//  Created by AG on 11/28/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMCountriesViewController.h"
#import "HMCoreDataManager.h"
#import "HMServerManager.h"
#import "HMDownloadCellTableViewCell.h"
#import "UIView+HMUItableViewCell.h"
#import "Countries.h"
#import "Place.h"
#import "HMMapViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "AFURLConnectionOperation.h"
#import "AFURLSessionManager.h"

@interface HMCountriesViewController ()

@property (strong, nonatomic)NSMutableArray *arrayOfContries;
@property (strong, nonatomic)NSMutableArray *arrayOfPlaces;
@property (strong, nonatomic)NSMutableArray *arrayOfDownloadedContinents;

@end

@implementation HMCountriesViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectModel = _managedObjectModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Countries", nil);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Countries"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    //NSLog(@"%@",fetchRequest);
    NSError* error;
    
    NSUInteger count = [[self managedObjectContext] countForFetchRequest:fetchRequest
                                                            error:&error];

    if (!count) {
        [self getContinentFromServer];
    }
    
    self.arrayOfContries = [[NSMutableArray alloc] init];
    self.arrayOfPlaces = [[NSMutableArray alloc] init];
    
#warning don't work, ASK!
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(blocButton)
//                                                 name:AFNetworkingOperationDidStartNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(anblocButton)
//                                                 name:AFNetworkingTaskDidResumeNotification
//                                               object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)getContinentFromServer {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[HMServerManager sharedManager]getCountriesWithonSuccess:^(NSArray *continents) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[HMCoreDataManager sharedManager] saveCountriesToCoreDataWithNSArray:continents];
                self.fetchedResultsController = nil;
                [self.tableView reloadData];
            });
            
        }
            onFailure:^(NSError *error, NSInteger statusCode) {
                NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
                
                [self showAlertWithTitle:@"Oops! No Internet"
                              andMessage:@"Check your connection"
                          andActionTitle:@"OK"];
                
            }];
    });

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Countries"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[nameDescriptor]];
    
    if ([self.searchString length]>0) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchString];
    } else
    {
        fetchRequest.predicate = [NSPredicate predicateWithValue:YES];
    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil]; //self.searchString.length>0?self.searchString:@"All"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)configureCell:(HMDownloadCellTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Countries *countries = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self.arrayOfContries addObject:countries];
    
    cell.continentLable.text = countries.name;
    cell.countLable.text = [NSString stringWithFormat:@"%@", countries.places];
    NSString* countriesIso = [countries.iso lowercaseString];

    [cell.continentsImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.geonames.org/flags/x/%@.gif",countriesIso]]
                         placeholderImage:[UIImage imageNamed:@"noFlag"]];
    
    //cell.downloadProgress.hidden = YES;
    
    if ([countries.place count] >= 1) {
        [cell.downloadSwitch setOn:YES];
    }
    else {
        [cell.downloadSwitch setOn:NO];
    }
}


#pragma mark Switcher

- (IBAction)actionDwnloadSwitch:(id)sender {
    
    HMDownloadCellTableViewCell* cell = [sender superCell];
    NSLog(@"name = %@, count = %@\n", cell.continentLable.text, cell.countLable.text);
    
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        for (Countries* countries in self.arrayOfContries ) {
            if ([cell.continentLable.text isEqualToString:countries.name]) {
                //getPlacesByContinentName
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[HMServerManager sharedManager] getPlacesByCountryWithISO:countries.iso onSuccess:^(NSDictionary *places)  {
                        //                NSLog(@"%@/n", places);
                        
                        [self.arrayOfPlaces removeAllObjects];
                        for (NSDictionary* dict in places) {
                            [self.arrayOfPlaces addObject:[dict objectForKey:@"id"]];
                        }
                        [self downloadPlaces:countries];
                        
                    } onFailure:^(NSError *error, NSInteger statusCode) {
                        
                        [self showAlertWithTitle:@"Oops! No Internet"
                                      andMessage:@"Check your connection"
                                  andActionTitle:@"OK"];
                        
                        ((UISwitch *)sender).on = NO;
                    }];
                    
                    
                });
            }
        }
    }
    else {
        for (Countries* countries in self.fetchedResultsController.fetchedObjects ) {
            if ([cell.continentLable.text isEqualToString:countries.name]) {
                
                for (Place *p in countries.place) {
                    [self.managedObjectContext deleteObject:p];
                }
                break;
            }
        }
        
        [[HMCoreDataManager sharedManager] saveContext];
    }
}

- (void) downloadPlaces:(Countries*)countries {
    
    //self.readyButton.enabled = NO;
    
    for (NSInteger i=0; i<self.arrayOfPlaces.count; i++) {
        
//        static NSInteger countPlace;
//        
//        if (i == 0) {
//            countPlace = 0;
//        }
        
        NSString *idPlaces = [NSString stringWithFormat:@"%@", [self.arrayOfPlaces objectAtIndex:i]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[HMServerManager sharedManager] getPlaceWithID:idPlaces onSuccess:^(NSDictionary *places) {
                //NSLog(@"\n\ni = %d\tPLACE%@\n",i++, places);
                
                [[HMCoreDataManager sharedManager] savePlaceToCoreDataWithNSArray:places contries:countries];
                
//                countPlace++;
//                if (countPlace == self.arrayOfPlaces.count) {
//                    self.readyButton.enabled = YES;
//                }
                
            } onFailure:^(NSError *error, NSInteger statusCode) {
                    NSLog(@"err");
            }];
        });
    }
}

#warning don't work, ASK!
//- (void) blocButton {
//    self.readyButton.enabled = NO;
//}
//
//- (void) anblocButton {
//    self.readyButton.enabled = YES;
//}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSLog(@"%@",searchBar);
    self.fetchedResultsController = nil;
    self.searchString = searchText;
}

#pragma mark - Alert View

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

@end
