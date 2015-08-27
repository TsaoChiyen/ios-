//
//  LocationManager.m
//  ReSearch
//
//  Created by NigasMone on 14-8-5..
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#define SetDefaultLocation [self setLocation:30.679943 lng:104.067923]

#import "LocationManager.h"
#import "BMapKit.h"
#import "Globals.h"

static LocationManager * sharedLocationManager = nil;

@interface LocationManager () <CLLocationManagerDelegate, BMKGeoCodeSearchDelegate> {
    CLLocationManager * locationManager;
    CLLocation* oldLocation;
}
@property (nonatomic, strong) CLGeocoder * geocoder;
@property (nonatomic, strong) BMKGeoCodeSearch * bmkgeocoder;
@end

@implementation LocationManager
@synthesize coordinate, located, geocodeGot, locationText, alwaysUpdateLocation;
@synthesize geocoder;
@synthesize block;
@synthesize offsetdistance;

+ (LocationManager*)sharedManager {
    if (sharedLocationManager == nil) {
        sharedLocationManager = [[LocationManager alloc] init];
    }
    return sharedLocationManager;
}

+ (void)setDealloc {
    [sharedLocationManager setBlock:nil];
    [sharedLocationManager stopUpdatingLocation];
    sharedLocationManager = nil;
}

- (id)init {
    if (self = [super init]) {
        self.locService = [[BMKLocationService alloc]init];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.distanceFilter = 10.0f;
        located = NO;
        offsetdistance = 0.f;
    }
    return self;
}

- (CLLocationManager *)locationManager {
    return locationManager;
}

- (void)dealloc {
    [_locService stopUserLocationService];
    locationManager.delegate = nil;
    self.locService.delegate = nil;
    self.locService = nil;
    self.locationText = nil;
    self.geocoder = nil;
}

#pragma mark - Public
- (void)startUpdatingLocation {
    if (self.locationServicesEnabled) {
        if (Sys_Version >= 8.0) {
            [locationManager requestAlwaysAuthorization];
        } else {
            [locationManager startUpdatingLocation];
        }
        alwaysUpdateLocation = YES;
    } else {
        //        if (coordinate.latitude == 0 && coordinate.longitude == 0) {
        //            SetDefaultLocation;
        //        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LocationDisabledNotification object:nil];
    }
}

- (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

- (void)stopUpdatingLocation {
    alwaysUpdateLocation = NO;
    [locationManager stopUpdatingLocation];
    [geocoder cancelGeocode];
}

- (void)showAlertMessage:(NSString*)msg {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:String(@"好的") otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - CLLocationManagerDelegate - ios8 获取定位授权
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (kCLAuthorizationStatusDenied == status||kCLAuthorizationStatusRestricted == status) {
        [self showAlertMessage:KBSSDKErrorLocation];
        self.locationFail = YES;
    } else if (status != kCLAuthorizationStatusNotDetermined){
        [locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self locationManagerUpdateLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation * newLocation = [locations lastObject];
    [self locationManagerUpdateLocation:newLocation];
}

- (void)locationManagerUpdateLocation:(CLLocation*)newLocation {
    NSDate * newLocDate = newLocation.timestamp;
    NSTimeInterval interval = [newLocDate timeIntervalSinceNow];
    DLog(@"%f", interval);
//    if (abs(interval) < 5) {
        //        CLLocationCoordinate2D coord = newLocation.coordinate;
        //        if (coord.latitude == 0 && coord.longitude == 0) {
        //            SetDefaultLocation;
        //            goto out;
        //        }
        
        if (oldLocation) {
            offsetdistance = [newLocation distanceFromLocation:oldLocation];
        }
        oldLocation = newLocation;
        if (offsetdistance > 0) {
            NSString * changeStr=[NSString stringWithFormat:@"位置发生移动:%f米", offsetdistance];
            DLog(@"%@", changeStr);
        }
        
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注意" message:changeStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alertView show];
        
        self.locService.delegate = self;
        [[self locService] startUserLocationService];
        if (alwaysUpdateLocation) {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:LocationUpdateNotification object:self];
            return;
        }
        //        out:
        //        [locationManager stopUpdatingLocation];
//    } else {
//        [locationManager startUpdatingLocation];
//    }
}

/**
 *用户位置更新后，会调用此函数
 *@param mapView 地图View
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation {
    if (userLocation != nil) {
        [_locService stopUserLocationService];
        located = YES;
        self.userLocation = userLocation;
        CLLocationDegrees lat = userLocation.location.coordinate.latitude;
        CLLocationDegrees lng = userLocation.location.coordinate.longitude;
        self.coordinate = kLocationMake(lat, lng);
        
        // 反地理编码
        
        self.bmkgeocoder.delegate = self;
        BMKReverseGeoCodeOption *op = [[BMKReverseGeoCodeOption alloc] init];
        op.reverseGeoPoint = CLLocationCoordinate2DMake(lat, lng);
        [_bmkgeocoder reverseGeoCode:op];
        
        if (block) {
            block(forLocationFinished);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:LocationUpdateNotification object:nil];
    }
}

- (BMKGeoCodeSearch*)bmkgeocoder {
    if (!_bmkgeocoder) {
        _bmkgeocoder = [[BMKGeoCodeSearch alloc] init];
    }
    return _bmkgeocoder;
}
/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    
}
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    geocodeGot = YES;
    // 在此处添加您对地理编码结果的处理
    _bmkgeocoder.delegate = nil;
    if (error > 0) {
        self.locationText = @"未知位置";
    } else {
        self.coordinate = coordinate;
        self.locationText = result.address;
        self.addressDetail = result.addressDetail;
    }
#ifdef DEBUG
    NSLog(@"当前位置:%@", self.locationText);
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:GeoInitNotification object:nil];
}

- (NSString*)locationCity {
    return self.addressDetail.city;
}

@end
