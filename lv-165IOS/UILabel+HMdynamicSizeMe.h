//
//  UILabel+HMdynamicSizeMe.h
//  lv-165IOS
//
//  Created by roman on 24.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (HMdynamicSizeMe)

-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text;
-(void)resizeHeightToFitForLabel:(UILabel *)label;
-(void)resizeHeightToFitForLabel:(UILabel *)label withText:(NSString *)text;

@end
