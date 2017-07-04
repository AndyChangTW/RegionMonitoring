//
//  ViewController.m
//  GeoTargetingTest
//
//  Created by Andy on 2017/7/3.
//  Copyright © 2017年 ACStudio. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

@interface ViewController ()<CLLocationManagerDelegate>{
    CLLocationManager *lm;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    if (!lm) {
        lm = [[CLLocationManager alloc] init];
    }
    [lm setDelegate:self];
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    [lm startUpdatingLocation];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [lm requestAlwaysAuthorization];
        [self writeLog:@"Request For Authorization"];
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways){
        [self writeLog:@"kCLAuthorizationStatusAuthorizedAlways Checked"];
    }
    [self setupMonitoringRegion];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"You Did Open My Area Monitoring App";
    content.body = @"Let's Test.";
    content.sound = [UNNotificationSound defaultSound];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"DidOpenApp" content:content trigger:nil];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
       
        if (error) {
            [self writeLog:[NSString stringWithFormat:@"NotificationCenter add notification request did Fail with error: %@",error.description]];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupMonitoringRegion{
    [self writeLog:@"Setup region for monitoring"];
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        NSString *title = @"八德路金山南路路口";
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(25.043833, 121.530459);
        CGFloat radius = 100.0;
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radius identifier:title];
        [lm startMonitoringForRegion:region];
        [lm requestStateForRegion:region];
        [self writeLog:[NSString stringWithFormat:@"CLLocationManager start monitoring region: %@",region.identifier]];
    }else{
        [self writeLog:@"CLLocationManager Fail to monitor region"];
    }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"You Did Enter My Monitoring Area";
    content.body = [NSString stringWithFormat:@"CLLocationManager did enter region: %@",region.identifier];
    content.sound = [UNNotificationSound defaultSound];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"DidEnterRegion" content:content trigger:nil];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        [self writeLog:[NSString stringWithFormat:@"CLLocationManager did enter region: %@",region.identifier]];
        if (error) {
            [self writeLog:[NSString stringWithFormat:@"NotificationCenter add notification request did Fail with error: %@",error.description]];
        }
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"You Did Exit My Monitoring Area";
    content.body = [NSString stringWithFormat:@"CLLocationManager did exit region: %@",region.identifier];
    content.sound = [UNNotificationSound defaultSound];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"DidExitRegion" content:content trigger:nil];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        [self writeLog:[NSString stringWithFormat:@"CLLocationManager did exit region: %@",region.identifier]];
        if (error) {
            [self writeLog:[NSString stringWithFormat:@"NotificationCenter add notification request did Fail with error: %@",error.description]];
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSString *stateString = @"Unknown";
    switch (state) {
        case CLRegionStateInside:
            stateString = @"Inside";
            break;
        case CLRegionStateOutside:
            stateString = @"Outside";
        default:
            break;
    }
    [self writeLog:[NSString stringWithFormat:@"CLLocationManager did determine state:%@ for region: %@",stateString,region.identifier]];
}


-(void)writeLog:(NSString *)writeline{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Log.txt"];
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSString *firstLine = [NSString stringWithFormat:@"%@\n",writeline];
    if (fileExist) {
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [fh seekToEndOfFile];
        [fh writeData:[firstLine dataUsingEncoding:NSUTF8StringEncoding]];
        [fh closeFile];
    }else{
        [firstLine writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}


@end
