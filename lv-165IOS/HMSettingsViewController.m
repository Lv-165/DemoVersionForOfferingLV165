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
    
    [self loadSettings];
    
    // Initialize Data
    self.dataSource = [NSArray arrayWithObjects:@"English", @"Ukrainian", @"Russian", @"German", @"French", nil];
    // Connect data
    self.languagePickerView.delegate = self;
    self.languagePickerView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveSettings {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:self.segmentedControlForMapType.selectedSegmentIndex forKey:@"kMapType"];
    
    [userDefaults synchronize];
}

- (void) loadSettings {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.segmentedControlForMapType.selectedSegmentIndex = [userDefaults integerForKey:@"kMapType"];
    
}

#pragma mark - Segmented Control For Map Type

- (IBAction)segmentedControlForMapTypeValueChanged:(id)sender {
    
    [self saveSettings];
    
    NSDictionary *dictionary = @{@"value" : [NSNumber numberWithLong:self.segmentedControlForMapType.selectedSegmentIndex]};
    
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
