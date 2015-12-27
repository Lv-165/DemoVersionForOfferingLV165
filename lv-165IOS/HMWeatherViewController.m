//
//  HMWeatherViewController.m
//  lv-165IOS
//
//  Created by User on 26.12.15.
//  Copyright © 2015 SS. All rights reserved.
//

#import "HMWeatherViewController.h"

@interface HMWeatherViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;



@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
//@property (nonatomic, strong) NSDate *sunrise;
//@property (nonatomic, strong) NSDate *sunset;
//@property (nonatomic, strong) NSString *conditionDescription;
//@property (nonatomic, strong) NSString *condition;
//@property (nonatomic, strong) NSNumber *windBearing;
//@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;




// 3
- (NSString *)imageName;


@end
static double kelvinMinus = 273.15;
IBOutlet UILabel *temperatureLabel;

@implementation HMWeatherViewController



#pragma ParseData

- (void)parseWeatherDictionary:(NSDictionary*)weather {
    //convert date
    self.date = [NSDate dateWithTimeIntervalSince1970:[[self.weatherDict valueForKey:@"dt"]doubleValue]];
    self.humidity = [[self.weatherDict objectForKey:@"main"]objectForKey:@"humidity"];
    
    double tempHightFar =[[[self.weatherDict objectForKey:@"main"]valueForKey:@"temp_max"]doubleValue];
    self.tempHigh = [NSNumber numberWithDouble:(tempHightFar - kelvinMinus)];
    
    double tempLowFar =[[[self.weatherDict objectForKey:@"main"]valueForKey:@"temp_min"]doubleValue];
    self.tempLow = [NSNumber numberWithDouble:(tempLowFar - kelvinMinus)];
    
    double temperature = [[[self.weatherDict objectForKey:@"main"]objectForKey:@"temp"] doubleValue];
    self.temperature = [NSNumber numberWithDouble:(temperature - kelvinMinus)];

    self.locationName = [NSString stringWithFormat:@"%@",[self.weatherDict objectForKey:@"name"]];
    self.icon = [[[self.weatherDict objectForKey:@"weather"]firstObject] objectForKey:@"icon"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self parseWeatherDictionary:self.weatherDict];
    
    // 1
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"%f",self.screenHeight);
    
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    // 2
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 3
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    // 4 не видны черточки
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];//clearColor
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
//    self.tableView.separatorEffect = [UIVibrancyEffect blurEffect];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    // 1
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    // 2
    CGFloat inset = 20;
    // 3
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    // 4
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    // 5
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
   
    // 1
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 2
    // bottom left fix size
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    if (self.temperature >0) {
       temperatureLabel.text = [NSString stringWithFormat:@"+%@%@",self.temperature ,@"0°"];
    } else {
        temperatureLabel.text = [NSString stringWithFormat:@"%@%@",self.temperature ,@"0°"];
    }
    
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:80];
     [temperatureLabel sizeToFit];
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 40)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = self.locationName;
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:conditionsLabel];
    
    // 3
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    iconView.image = [UIImage imageNamed:[self setImage:self.icon]];
    [header addSubview:iconView];
}
-(NSString*)setImage:(NSString*)code {
    
    NSDictionary *iconCodes = @{
                  @"01d" : @"weather-clear",
                  @"02d" : @"weather-few",
                  @"03d" : @"weather-few",
                  @"04d" : @"weather-broken",
                  @"09d" : @"weather-shower",
                  @"10d" : @"weather-rain",
                  @"11d" : @"weather-tstorm",
                  @"13d" : @"weather-snow",
                  @"50d" : @"weather-mist",
                  @"01n" : @"weather-moon",
                  @"02n" : @"weather-few-night",
                  @"03n" : @"weather-few-night",
                  @"04n" : @"weather-broken",
                  @"09n" : @"weather-shower",
                  @"10n" : @"weather-rain-night",
                  @"11n" : @"weather-tstorm",
                  @"13n" : @"weather-snow",
                  @"50n" : @"weather-mist",
                  };
    return [iconCodes objectForKey:code];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}


// 1
#pragma mark - UITableViewDataSource

// 2
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // TODO: Return count of forecast
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // 3
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//change???
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];// no changes
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    // TODO: Setup the cell
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Determine cell height based on screen
    return 44;
}

+ (NSDictionary *)imageMap {
    // 1
    static NSDictionary *_imageMap = nil;
    if (!_imageMap) {
        // 2
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}
//+ (NSDictionary *)JSONKeyPathsByPropertyKey {
//    return @{
//             @"date": @"dt",
//             @"locationName": @"name",
//             @"humidity": @"main.humidity",
//             @"temperature": @"main.temp",
//             @"tempHigh": @"main.temp_max",
//             @"tempLow": @"main.temp_min",
//             @"sunrise": @"sys.sunrise",
//             @"sunset": @"sys.sunset",
//             @"conditionDescription": @"weather.description",
//             @"condition": @"weather.main",
//             @"icon": @"weather.icon",
//             @"windBearing": @"wind.deg",
//             @"windSpeed": @"wind.speed"
//             };
//}


@end
