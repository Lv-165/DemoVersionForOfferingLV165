//
//  HMFiltersViewController.m
//  lv-165IOS
//
//  Created by User on 08.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMFiltersViewController.h"

@interface HMFiltersViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@end


static NSString* kSettingsComments = @"comments";
static NSString* kSettingsRating   = @"rating";
static NSString* kSettingsClastering = @"clastering";


@implementation HMFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *remontImage = [UIImage imageNamed:@"cluster"];
    self.commentImage = [[UIImageView alloc] initWithImage:remontImage];
    [self.view addSubview:self.commentImage];
    [self loadSettings];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.dataSource = [NSArray arrayWithObjects:NSLocalizedString(@"High", nil), NSLocalizedString(@"Middle", nil), NSLocalizedString(@"Low", nil), nil];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerView selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsClastering]inComponent:0 animated:NO];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.pickerView = nil;
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    return [self.dataSource objectAtIndex:row];
}


#pragma mark - Save and Load

- (void) saveSettings {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setBool:self.commentsSwitch.isOn forKey:kSettingsComments];
    [userDefaults setInteger:self.ratingControl.selectedSegmentIndex forKey:kSettingsRating];
    [userDefaults setInteger:[self.pickerView selectedRowInComponent:0] forKey:kSettingsClastering];
    
    [userDefaults synchronize];
}

- (void) loadSettings {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.commentsSwitch.on = [userDefaults boolForKey:kSettingsComments];
    self.ratingControl.selectedSegmentIndex = [userDefaults integerForKey:kSettingsRating];
    [self.pickerView selectRow:[userDefaults integerForKey:kSettingsClastering]inComponent:0 animated:NO];
   
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger selectedRow = [thePickerView selectedRowInComponent:0];
    [[NSUserDefaults standardUserDefaults] setInteger:selectedRow forKey:kSettingsClastering];
}


#pragma mark - Actions


- (IBAction)actionValueChanged:(id)sender {
    [self saveSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewDidDisappear:(BOOL)animated {
    [self saveSettings];
    animated =  YES;
}



@end
