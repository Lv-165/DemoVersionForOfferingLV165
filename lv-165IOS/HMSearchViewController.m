//
//  HMSearchViewController.m
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 11/30/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMSearchViewController.h"
#import "SVGeocoder.h"
#import "UICellForInfo.h"

NSString* const showPlaceNotificationCenter = @"showPlaceNotificationCenter";
NSString* const showPlaceNotificationCenterInfoKey = @"showPlaceNotificationCenterInfoKey";

@interface HMSearchViewController ()

@property (strong, nonatomic) NSMutableArray *arrayForPlacesMarks;
@property (strong, nonatomic) NSMutableArray *arrayOfFavouritePlaces;
@property (strong, nonatomic) NSMutableArray *arrayOfHistoryPlaces;

@property (assign, nonatomic)BOOL isAtSearchBar;

@end

@implementation HMSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayOfHistoryPlaces = [NSMutableArray array];
    self.arrayOfFavouritePlaces = [NSMutableArray array];
    self.arrayForPlacesMarks = [NSMutableArray array];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    // Do any additional setup after loading the view.
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.tableView.backgroundView = nil;
    self.isAtSearchBar = YES;
    self.arrayForPlacesMarks = [NSMutableArray array];
    [SVGeocoder geocode:searchBar.text
             completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
                 if ([placemarks count]) {
                     for (SVPlacemark *object in placemarks) {
                         NSString *stringOfPlace = [self creatingAObjectOfMassive:object];
                         
                         NSNumber *latitude = [[NSNumber alloc] initWithDouble:object.location.coordinate.latitude];
                         NSNumber *longitude = [[NSNumber alloc] initWithDouble:object.location.coordinate.longitude];
                         
                         NSDictionary *coordinate = @{
                                                      @"latitude":latitude,
                                                      @"longitude":longitude
                                                      };
                         NSDictionary *place = @{
                                                 @"StringOfPlace":stringOfPlace,
                                                 @"Coordinate":coordinate,
                                                 };
                         
                         [self.arrayForPlacesMarks addObject:place];
                 }
                 }else {
                     self.tableView.backgroundView = nil;
                     [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]]];
                 }
                 
                 [self.tableView reloadData];
             }];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if ([self.arrayForPlacesMarks count]) {
        self.arrayForPlacesMarks = nil;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch (selectedScope) {
        case 0:
        {
            self.arrayOfHistoryPlaces = [userDefaults objectForKey:@"PlaceByHistory"];
            self.arrayForPlacesMarks = [[NSMutableArray alloc] initWithArray:self.arrayOfHistoryPlaces];
            break;
        }
        case 1:
        {
            self.arrayOfFavouritePlaces = [userDefaults objectForKey:@"PlaceByFavourite"];
            self.arrayForPlacesMarks = [[NSMutableArray alloc] initWithArray:self.arrayOfFavouritePlaces];
            break;
        }
    }
    self.isAtSearchBar = NO;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayForPlacesMarks count];
}

- (UICellForInfo *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    
    UICellForInfo *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"UITableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.infoLabel.text = (NSString *)[self.arrayForPlacesMarks[indexPath.row] objectForKey:@"StringOfPlace"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isAtSearchBar) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.arrayOfHistoryPlaces];
        [tempArray addObject:self.arrayForPlacesMarks[indexPath.row]];//gyghg

    if ([tempArray count] >= 20) {
        for (NSInteger i = 0; i < ([self.arrayOfHistoryPlaces count] - 20); i ++) {
            [tempArray removeObjectAtIndex:i];
        }
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"PlaceByHistory"];
    [userDefaults setObject:tempArray forKey:@"PlaceByHistory"];
    }
    
    NSDictionary *dictionary =
    [NSDictionary dictionaryWithObject:[self.arrayForPlacesMarks[indexPath.row]
                          objectForKey:@"Coordinate"]
                                forKey:showPlaceNotificationCenterInfoKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:showPlaceNotificationCenter
                                                        object:nil
                                                      userInfo:dictionary];
}

#pragma mark - for creating elememt of arrayOfFavourite and arrayOfHistory

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
            [str appendFormat:@", %@",dataOfLocality];
            count ++;
        }
    }
    [str deleteCharactersInRange:NSMakeRange(0, 1)];
    return str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

