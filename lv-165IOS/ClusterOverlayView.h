//
//  ClusterOverlayView.h
//  lv-165IOS
//
//  Created by Oleksandr Bretsko on 12/15/15.
//  Copyright © 2015 SS. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ClusterOverlayView : MKCircleRenderer

// drawMapRect:zoomScale:inContext: method.

// if your class contains  content that may not be ready for drawing right away, you should also override the canDrawMapRect:zoomScale: method and use it to report when your class is ready and able to draw.

// TODO: implement rating display here - pie chart

// The map view may tile large overlays and distribute the rendering of each  tile to separate threads. Therefore, the implementation of your  drawMapRect:zoomScale:inContext: method must be safe to run from background threads and from multiple threads simultaneously.

@end
