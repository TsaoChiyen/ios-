//
//  LocationManager.h
//  ReSearch
//
//  Created by NigasMone on 14-8-5.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "BMapKit.h"
#import "Declare.h"

#define GeoInitNotification             @"GeoInitNotification"
#define LocationDisabledNotification    @"LocationDisabledNotification"
#define LocationUpdateNotification      @"LocationUpdateNotification"
#define KBSSDKErrorLocation             @"获取位置信息失败，请在”设置 - 隐私 - 位置“中允许我们访问你的位置"
typedef enum {
    forLocationError = 0,
    forLocationSuccess,
    forLocationFinished,
} LocationType;

typedef void(^LocationUpdate)(LocationType locationType);
@interface LocationManager : NSObject<BMKLocationServiceDelegate>

@property (strong, nonatomic) BMKLocationService * locService;
@property (strong, nonatomic) BMKUserLocation    * userLocation;
@property (nonatomic, assign) Location           coordinate;
@property (nonatomic, assign) BOOL               located;
@property (nonatomic, assign) BOOL               geocodeGot;
@property (nonatomic, strong) NSString           * locationText;
@property (nonatomic, strong) LocationUpdate     block;
@property (nonatomic, assign) BOOL               alwaysUpdateLocation;
@property (nonatomic, assign) BOOL               locationFail;
@property (nonatomic, assign, readonly)          BOOL locationServicesEnabled;
@property (nonatomic, assign) CLLocationDistance offsetdistance; // 和上次定位的位移
///层次化地址信息
@property (nonatomic, strong) BMKAddressComponent* addressDetail;
+ (LocationManager*)sharedManager;
+ (void)setDealloc;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (NSString*)locationCity;
- (CLLocationManager *)locationManager;
/**
 *用户位置更新后，会调用此函数
 *@param mapView 地图View
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
@end
