//
//  HMGoogleDirectionsViewController.m
//  lv-165IOS
//
//  Created by Ihor Zabrotsky on 12/23/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMGoogleDirectionsViewController.h"
#import "HMCoreDataManager.h"

@interface HMGoogleDirectionsViewController ()

@end

@implementation HMGoogleDirectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.textViewForGoogleDirections.text = self.textForLabel;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionSave:(id)sender {

    if (![self.textForLabel isEqualToString:@""]) {
        
        [self showAlertWithTitle:@"Direction saved"
                      andMessage:nil
                  andActionTitle:@"OK"];
        
        [[HMCoreDataManager sharedManager] saveDirectionToCoreDataWithPlace:self.place
                                                            directionString:self.textForLabel];
    } else {
        
        [self showAlertWithTitle:@"Direction wasn't saved"
                      andMessage:@"You can't save empty direction"
                  andActionTitle:@"OK"];
    }
    
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
