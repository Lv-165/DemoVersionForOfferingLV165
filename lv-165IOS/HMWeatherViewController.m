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
@property (nonatomic, strong) NSString *locationName;//humidity rename
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSString *icon;

@property (nonatomic, strong) UIScrollView *myScrollView;

@property (nonatomic, strong) NSMutableArray *weatherArray;
@property (nonatomic ,assign) NSInteger hours;
@property (nonatomic, copy) NSMutableArray *tempArrMinMax;


@end


static NSInteger kelvinMinus = 273;
static NSInteger sectionForHours;


@implementation HMWeatherViewController


#pragma ParseData

- (void)parseWeatherDictionary:(NSDictionary*)weather {

    _hours = 0;
    self.weatherArray = [self.weatherDict objectForKey:@"list"];

    for (NSDictionary *dict in self.weatherArray) {
    
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dict valueForKey:@"dt"]doubleValue]];

        BOOL today = [[NSCalendar currentCalendar] isDateInToday:date];
        if (today) {
            _hours = self.hours + 1;

        }
    }
    NSMutableArray *tempArraMinMax = [[NSMutableArray alloc]init];
    NSArray *weatherArr = [self.weatherArray subarrayWithRange:NSMakeRange(0, self.hours)];

    for (NSDictionary *dict in weatherArr) {
        int temperature = [[[dict  objectForKey:@"main"]objectForKey:@"temp"] integerValue];
        int diff = (int)(temperature - kelvinMinus);
        [tempArraMinMax addObject:[NSNumber numberWithInt:diff]];
        
    }
 
    self.tempHigh = [tempArraMinMax valueForKeyPath:@"@max.integerValue"];
    self.tempLow = [tempArraMinMax valueForKeyPath:@"@min.integerValue"];
    
    NSInteger temperature = [[[[self.weatherArray firstObject] objectForKey:@"main"]objectForKey:@"temp"] integerValue];
    int diff = (temperature - kelvinMinus);
    self.temperature = [NSNumber numberWithInt:diff];

    self.locationName = [NSString stringWithFormat:@"Humidity: %@%%",[[[self.weatherArray firstObject]objectForKey:@"main"]objectForKey:@"humidity"]];
    
    self.icon = [[[[self.weatherArray firstObject] objectForKey:@"weather"]firstObject] objectForKey:@"icon"];
    self.condition = [[[[self.weatherArray firstObject] objectForKey:@"weather"]firstObject] objectForKey:@"description"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self parseWeatherDictionary:self.weatherDict];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    sectionForHours = 0;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;

  //work good
    UIImage *background = [UIImage imageNamed:@"bg2"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    
    CGRect scrollViewRect = self.view.bounds;
    self.myScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.myScrollView.pagingEnabled = YES;
    [self.myScrollView addSubview:self.backgroundImageView];
    self.myScrollView.contentSize = self.backgroundImageView.bounds.size;
    self.myScrollView.delegate = self;
    [self.view addSubview:self.myScrollView];
    
    // 4 не видны черточки
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];//clearColor
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];

    CGRect headerFrame = [UIScreen mainScreen].bounds;
    
    CGFloat inset = 20;
    
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
  
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - (2 * hiloHeight),
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + (2 *hiloHeight)),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
   
   
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
  
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    
    if (self.temperature >0) {
       temperatureLabel.text = [NSString stringWithFormat:@"+%@%@",self.temperature ,@"°"];
    } else {
        temperatureLabel.text = [NSString stringWithFormat:@"%@%@",self.temperature ,@"°"];
    }
    
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:80];
    [temperatureLabel sizeToFit];
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    
    hiloLabel.text = [NSString stringWithFormat:@"max %@° /min %@°",[self.tempHigh stringValue],[self.tempLow stringValue]];
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:28];
    [header addSubview:hiloLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height/3, self.view.bounds.size.width/2, 40)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = self.locationName;
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:26];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    conditionsLabel.text = self.condition;
    [header addSubview:conditionsLabel];

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
//    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.hours+1;
    }
    NSInteger i = (NSInteger)((self.weatherArray.count - self.hours)/8);
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
    
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Today Forecast"];
        } else {
            
            NSArray *weatherArr = [self.weatherArray subarrayWithRange:NSMakeRange(0, self.hours+1)];

            [self configureHourlyCell:cell weather:[weatherArr objectAtIndex:indexPath.row]];
            
        }
    }
    else if (indexPath.section == 1) {
      
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        } else {
            
            NSMutableArray *tempArraMinMax = [[NSMutableArray alloc]init];
            NSMutableArray *weatherDays =[[NSMutableArray alloc]init];

            if(indexPath.row == 1) {
                
            weatherDays = [[self.weatherArray subarrayWithRange:NSMakeRange(0,self.hours)]mutableCopy];
            } else {
                
            weatherDays = [[self.weatherArray subarrayWithRange:NSMakeRange((self.hours + 8*(indexPath.row-1)),8)]mutableCopy];
            }
            
            for (NSDictionary *dict in weatherDays) {
                int temperature = [[[dict  objectForKey:@"main"]objectForKey:@"temp"] integerValue];
                int diff = (int)(temperature - kelvinMinus);
                [tempArraMinMax addObject:[NSNumber numberWithInt:diff]];
            }
            
            NSNumber *max = [tempArraMinMax valueForKeyPath:@"@max.integerValue"];
            NSNumber *min = [tempArraMinMax valueForKeyPath:@"@min.integerValue"];
            NSMutableArray *tempArr = [[NSMutableArray alloc]initWithObjects:max,min, nil];
            
             [self configureDailyCell:cell weather:[weatherDays firstObject] temperature:tempArr];
            }
    }
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}


- (void)configureHourlyCell:(UITableViewCell *)cell weather:(NSDictionary*)weather {
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[weather valueForKey:@"dt"]doubleValue]];
    NSString *time = [dateFormatter stringFromDate:date];
    NSInteger temp = [[[weather objectForKey:@"main"]objectForKey:@"temp"]integerValue]-kelvinMinus;

    if (temp >0){
        cell.textLabel.text = [NSString stringWithFormat:@"Time:%@ T: +%ld°",time,temp];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Time:%@ T: %ld°",time,temp];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[[weather objectForKey:@"weather"]firstObject] objectForKey:@"description"]];
    cell.imageView.image = [UIImage imageNamed:[self setImage:[[[weather objectForKey:@"weather"]firstObject] objectForKey:@"icon"]]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(NSDictionary *)weather  temperature:(NSArray*)temperatuteArr {
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    
  
    cell.textLabel.text = [NSString stringWithFormat:@"Max:%@°/ Min:%@°",[temperatuteArr objectAtIndex:0],[temperatuteArr objectAtIndex:1]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"EEEE"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[weather valueForKey:@"dt"]doubleValue]];
    NSString *dayInfo = [dateFormatter stringFromDate:date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",dayInfo],

    cell.imageView.image = [UIImage imageNamed:[self setImage:[[[weather objectForKey:@"weather"]firstObject] objectForKey:@"icon"]]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;

}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);

    self.blurredImageView.alpha = percent;
}

@end
