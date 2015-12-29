//
//  FBClusterManager.h
//  AnnotationClustering
//
//  Created by Filip Bec on 05/01/14.
//  Copyright (c) 2014 Infinum Ltd. All rights reserved.
//

@import Foundation;
@import QuartzCore;
#import "FBAnnotationCluster.h"
#import "FBQuadTreeNode.h"

@class FBClusteringManager;

@protocol FBClusteringManagerDelegate <NSObject>
@optional

- (CGFloat)cellSizeFactorForCoordinator:(FBClusteringManager *)coordinator;

@end

@interface FBClusteringManager : NSObject

@property(nonatomic, strong) NSNumber *scale;
@property(nonatomic, assign) id<FBClusteringManagerDelegate> delegate;

@property(strong, nonatomic) UIColor *noneRatingColour;
@property(strong, nonatomic) UIColor *badRatingColour;
@property(strong, nonatomic) UIColor *normalRatingColour;
@property(strong, nonatomic) UIColor *goodRatingColour;
@property(strong, nonatomic) UIColor *veryGoodRatingColour;

//@property(assign, nonatomic) CGPoint currentPointOnArc;
//@property(assign, nonatomic) CGFloat currentPointOnArcX;
//@property(assign, nonatomic) CGFloat currentPointOnArcY;

@property(assign, nonatomic) NSUInteger clusterAnnotationViewRadius;
@property(assign, nonatomic) NSUInteger clusteringFactor;
@property(assign, nonatomic) NSUInteger labelFontSize;
@property(strong, nonatomic) UIColor *strokeColour;

@property(copy, atomic) NSArray *currentlyClusteredAnnotations;
@property(assign, atomic) NSUInteger numOfClusteredAnnotations;
@property(assign, atomic) NSUInteger numOfInitializedAnnotationViews;

@property(strong, nonatomic) NSMutableArray *slicesArray;

- (void)firePieChartAnimation;

- (id)initWithAnnotations:(NSArray *)annotations;

- (void)setAnnotations:(NSArray *)annotations;

- (void)addAnnotations:(NSArray *)annotations;

- (void)removeAnnotations:(NSArray *)annotations;

- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect
                                 withZoomScale:(double)zoomScale;

- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect
                                 withZoomScale:(double)zoomScale
                                    withFilter:
                                        (BOOL (^)(id<MKAnnotation>))filter;

- (NSArray *)allAnnotations;

- (void)displayAnnotations:(NSArray *)annotations
                 onMapView:(MKMapView *)mapView;

@end
