//
//  HMSettingsViewController.m
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 11/30/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMSettingsViewController.h"

@interface HMSettingsViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@end

@implementation HMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.segmentedControlForMapType.selectedSegmentIndex = [self.mapType intValue];
    
    // Initialize Data
    self.dataSource = [NSArray arrayWithObjects:@"EN",@"GB",@"FR",@"UA", nil];
    // Connect data
    self.languagePickerView.delegate = self;
    self.languagePickerView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segmented Control For Map Type

- (IBAction)segmentedControlForMapTypeValueChanged:(id)sender {
    self.mapType = [NSNumber numberWithLong:self.segmentedControlForMapType.selectedSegmentIndex];
    NSDictionary *dictionary = @{@"value" : self.mapType};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeMapTypeNotification"
                                                        object:self
                                                      userInfo:dictionary];
}

- (IBAction)actionDownloadsCountries:(id)sender {
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"downloadCountries"];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.dataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [self.dataSource objectAtIndex:row];
}

@end
