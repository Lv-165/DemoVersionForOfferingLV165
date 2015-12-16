//
//  ClusterOverlayView.m
//  lv-165IOS
//
//  Created by Oleksandr Bretsko on 12/15/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "ClusterOverlayView.h"

@implementation ClusterOverlayView

//- (void)drawMapRect:(MKMapRect)mapRect
//          zoomScale:(MKZoomScale)zoomScale
//          inContext:(CGContextRef)ctx {
//  // get the rect in pixel coordinate and set to the imageView
//  CGRect rect = [self rectForCircle];
//
//  if (imageView) {
//    imageView.frame = rect;
//  }
//}

//- (CGRect)rectForCircle {
//
//  // the circle center
//  MKMapPoint mpoint = MKMapPointForCoordinate([[self overlay] coordinate]);

//  // geting the radius in map point
//  double radius = [(MKCircle *)[self overlay] radius];
//  double mapRadius = radius * MKMapPointsPerMeterAtLatitude(
//                                  [[self overlay] coordinate].latitude);
//
//  // calculate the rect in map coordinate
//  MKMapRect mrect = MKMapRectMake(mpoint.x - mapRadius, mpoint.y - mapRadius,
//                                  mapRadius * 2, mapRadius * 2);
//
//  // return the pixel coordinate circle
//  return [self rectForMapRect:mrect];
//}

// rectForCircle helped us to find the rect of the circle in pixel coordinate.
// We first get the location coordinate of the circle and convert it to
// MKMapPoint (map coordinate). Then we also convert the radius in meter to the map coordinate. With the two information, we can calculate the MKMapRect as we have the center and radius of the circle already. Finally, convert the MKMapRect to CGRect which will be in pixel coordinate, for us to manage the UIImageView later.


//- (void)removeExistingAnimation {
//
//  if (imageView) {
//    [imageView.layer removeAllAnimations];
//    [imageView removeFromSuperview];
//    imageView = nil;
//  }
//}


// This one is simple, simply remove any existing animation and nullified the imageView.

//#define MAX_RATIO 1.2 #define MIN_RATIO 0.8
//#define MAX_OPACITY 0.5 #define MIN_OPACITY 0.05
//#define ANIMATION_DURATION 0.8
// repeat forever #define ANIMATION_REPEAT 1e100f

//- (id)initWithCircle:(MKCircle *)circle {
//
//  self = [super initWithCircle:circle];
//
//  if (self) {
//    [self start];
//  }
//
//  return self;
//}

// TODO: add animation code to view or viewcontroller
//- (void)start {
//  // As the circle view is initiated, we want the animation being initiated immediately as well.removeExistAnimation- make sure there's no other UIImageView is animating in the every call for start Then, we create the UIImageView which contains the circle image and add  it to our view. The animation we want here, is the image will change in size along with opacity simultaneously.  Therefore, we initiate two CABasicAnimation  objects, which target to the opacity and transform.scale property of   the CALayer respectively. Then, the two animation objects set into a CAnimationGroup together and added to the CALayer of the UIImageView.
//    // We used some constant here, which the circle size will vary from 0.8 to
//    1.2
//     times of its radius. The opacity will be from 0.5 to 0.05. It means the large the circle, the more transparent it will be. As we need the Core Animation, remember to add the QuartzCore framework    to the project as well.

//    [self removeExistingAnimation];
//
//    CGRect rect = [self rectForCircle];
//
//    // create the image
//    UIImage *img = [UIImage imageNamed:@"redCircle.png"];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
//    imageView.frame = rect;
//    [self addSubview:imageView];
//
//    // opacity animation setup
//    CABasicAnimation *opacityAnimation;
//
//    opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    opacityAnimation.duration = ANIMATION_DURATION;
//    opacityAnimation.repeatCount = ANIMATION_REPEAT;
//    // theAnimation.autoreverses=YES;
//    opacityAnimation.fromValue = [NSNumber numberWithFloat:MAX_OPACITY];
//    opacityAnimation.toValue = [NSNumber numberWithFloat:MIN_OPACITY];
//
//    // resize animation setup
//    CABasicAnimation *transformAnimation;
//
//    transformAnimation =
//    [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//
//    transformAnimation.duration = ANIMATION_DURATION;
//    transformAnimation.repeatCount = ANIMATION_REPEAT;
//    // transformAnimation.autoreverses=YES;
//    transformAnimation.fromValue = [NSNumber numberWithFloat:MIN_RATIO];
//    transformAnimation.toValue = [NSNumber numberWithFloat:MAX_RATIO];
//
//    // group the two animation
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//
//    group.repeatCount = ANIMATION_REPEAT;
//    [group setAnimations:[NSArray arrayWithObjects:opacityAnimation,
//                          transformAnimation, nil]];
//    group.duration = ANIMATION_DURATION;
//
//    // apply the grouped animation
//    [imageView.layer addAnimation:group forKey:@"groupAnimation"];
//}

@end
