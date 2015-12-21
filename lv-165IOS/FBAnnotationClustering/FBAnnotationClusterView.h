//
//  FBAnnotationClusterView.h
//  lv-165IOS
//
//  Created by Admin on 12/7/15.
//  Copyright © 2015 SS. All rights reserved.
//

@import MapKit;
@import Foundation;
//@class FBClusteringManager;

#import "ClusterViewPieChart.h"
#import "FBAnnotationCluster.h"
#import "FBClusteringManager.h"

@interface FBAnnotationClusterView
    : MKAnnotationView <ClusterViewPieChartDelegate,
                        ClusterViewPieChartDataSource>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-synthesis"
@property(nonatomic) FBAnnotationCluster *annotation;
#pragma clang diagnostic pop

@property(nonatomic, strong)FBClusteringManager * clusteringManager;


//@property(nonatomic, strong) NSMutableArray *annotationsWithoutRating;
//@property(nonatomic, strong) NSMutableArray *annotationsWithGoodRating;
//@property(nonatomic, strong) NSMutableArray *annotationsWithBadRating;
//
//@property(nonatomic) NSUInteger numOfAnnotationsWithoutRating;
//@property(nonatomic) NSUInteger numOfAnnotationsWithGoodRating;
//@property(nonatomic) NSUInteger numOfAnnotationsWithBadRating;
//
//@property(nonatomic) NSUInteger numberOfPieChartSegments;

- (void)countAnnotationsByRating;
- (void)groupAnnotationsByRating;

//@property(nonatomic) UILabel *annotationLabel;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
       clusteringManager:(FBClusteringManager* ) clusteringManager;


@end
