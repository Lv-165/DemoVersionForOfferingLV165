//
//  HMSettingsViewController.m
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 11/30/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMSettingsViewController.h"

@interface HMSettingsViewController ()

@end

@implementation HMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self loadSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segmented Control For Map Type

- (IBAction)segmentedControlForMapTypeValueChanged:(id)sender {
    
    [self saveSettings];
}

- (IBAction)actionDownloadsCountries:(id)sender {
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"downloadCountries"];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Map Type Saving

- (void)saveSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:self.segmentedControlForMapType.selectedSegmentIndex forKey:@"kMapType"];
    
    [userDefaults synchronize];
}

- (void)loadSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.segmentedControlForMapType.selectedSegmentIndex = [userDefaults integerForKey:@"kMapType"];
}

@end
