
#import <UIKit/UIKit.h>

@class ClusterViewPieChart;

@protocol ClusterViewPieChartDataSource <NSObject>
@required
- (NSUInteger)numberOfSlicesInPieChart:(ClusterViewPieChart *)pieChart;
- (CGFloat)pieChart:(ClusterViewPieChart *)pieChart
    valueForSliceAtIndex:(NSUInteger)index;
@optional
- (UIColor *)pieChart:(ClusterViewPieChart *)pieChart
 colorForSliceAtIndex:(NSUInteger)index;
- (NSString *)pieChart:(ClusterViewPieChart *)pieChart
   textForSliceAtIndex:(NSUInteger)index;
@end

@protocol ClusterViewPieChartDelegate <NSObject>
@optional
- (void)pieChart:(ClusterViewPieChart *)pieChart
    willSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(ClusterViewPieChart *)pieChart
    didSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(ClusterViewPieChart *)pieChart
    willDeselectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(ClusterViewPieChart *)pieChart
    didDeselectSliceAtIndex:(NSUInteger)index;
@end

@interface ClusterViewPieChart : UIView
@property(nonatomic, weak) id<ClusterViewPieChartDataSource> dataSource;
@property(nonatomic, weak) id<ClusterViewPieChartDelegate> delegate;
@property(nonatomic, assign) CGFloat startPieAngle;
@property(nonatomic, assign) CGFloat animationSpeed;
@property(nonatomic, assign) CGPoint pieCenter;
@property(nonatomic, assign) CGFloat pieRadius;
@property(nonatomic, assign) BOOL showLabel;
@property(nonatomic, strong) UIFont *labelFont;
@property(nonatomic, strong) UIColor *labelColor;
@property(nonatomic, strong) UIColor *labelShadowColor;
@property(nonatomic, assign) CGFloat labelRadius;
@property(nonatomic, assign) CGFloat selectedSliceStroke;
@property(nonatomic, assign) CGFloat selectedSliceOffsetRadius;
@property(nonatomic, assign) BOOL showPercentage;

+ (UIImage *)constructPieChartImage;
+ (UIView *)constructPieChartView;

- (id)initWithFrame:(CGRect)frame Center:(CGPoint)center Radius:(CGFloat)radius;
- (void)reloadData;
- (void)setPieBackgroundColor:(UIColor *)color;

- (void)setSliceSelectedAtIndex:(NSInteger)index;
- (void)setSliceDeselectedAtIndex:(NSInteger)index;

- (void)createArcAnimationForKey:(NSString *)key
                       fromValue:(NSNumber *)from
                         toValue:(NSNumber *)to
                        Delegate:(id)delegate;

@end

