//
//  UILabel+HMdynamicSizeMe.m
//  lv-165IOS
//
//  Created by roman on 24.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "UILabel+HMdynamicSizeMe.h"

@implementation UILabel (HMdynamicSizeMe)

-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text
{
    CGSize maximumLabelSize     = CGSizeMake(290, FLT_MAX);
    
    CGSize expectedLabelSize    = [text sizeWithFont:label.font
                                   constrainedToSize:maximumLabelSize
                                       lineBreakMode:label.lineBreakMode];
    
    return expectedLabelSize.height;
}

-(void)resizeHeightToFitForLabel:(UILabel *)label
{
    CGRect newFrame         = label.frame;
    newFrame.size.height    = [self heightForLabel:label withText:label.text];
    label.frame             = newFrame;
}

-(void)resizeHeightToFitForLabel:(UILabel *)label withText:(NSString *)text
{
    label.text              = text;
    [self resizeHeightToFitForLabel:label];
}

@end
