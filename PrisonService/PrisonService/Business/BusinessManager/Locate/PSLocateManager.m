//
//  PSLocateManager.m
//  PrisonService
//
//  Created by calvin on 2018/5/9.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSLocateManager.h"
#import <CoreLocation/CoreLocation.h>

#define Locate_Province_Cache_key @"Locate_Province_Cache_key"

@interface PSLocateManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation PSLocateManager
+ (PSLocateManager *)sharedInstance {
    static PSLocateManager *manager = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (!manager) {
            manager = [[self alloc] init];
        }
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        _province = [[NSUserDefaults standardUserDefaults] objectForKey:Locate_Province_Cache_key];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 100.0f;
        _locationManager.delegate = self;
    }
    return self;
}

- (void)reverseGeocodeLocation:(CLLocation *)location {
    
    _lat=[[NSNumber numberWithDouble:location.coordinate.latitude] stringValue] ;
    _lng=[[NSNumber numberWithDouble:location.coordinate.longitude] stringValue] ;
    double lat =  [_lat doubleValue];
    double lng =  [_lng doubleValue];
    _lat = [NSString stringWithFormat:@"%.6lf",lat];
    _lng = [NSString stringWithFormat:@"%.6lf",lng];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *place in placemarks) {
            if (place.administrativeArea.length > 0) {
                _province = place.administrativeArea;
                _city=place.locality;
                [[NSUserDefaults standardUserDefaults] setObject:place.administrativeArea forKey:Locate_Province_Cache_key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //获取到地址重新刷新广告
                if (_province.length>0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationRefreshAdvertisement object:nil];
                }
            }
        }
    }];
}

- (void)startUpdatingLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status != kCLAuthorizationStatusDenied) {
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation {
    [_locationManager stopUpdatingLocation];
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0) {
        [self reverseGeocodeLocation:locations[0]];
        [self stopUpdatingLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}
#pragma mark - PSLaunchTask
- (void)launchTaskWithCompletion:(LaunchTaskCompletion)completion {
    [self startUpdatingLocation];
    if (completion) {
        completion(YES);
    }
}

@end
