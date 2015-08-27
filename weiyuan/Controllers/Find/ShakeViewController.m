//
//  ShakeViewController.m
//  reSearchDemo
//
//  Created by helfy  on 15-4-17.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShakeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreFoundation/CoreFoundation.h>
#import <MapKit/MapKit.h>
#import "ShakeFineUserView.h"
#import "UserInfoViewController.h"
@interface ShakeViewController ()
{
     SystemSoundID                 soundID;
    
    UIImageView *shakeImage;
    
    CLLocationManager *locationManager;
    
    CLLocation *currentLoction;
    
    BOOL isRequst;
    
    ShakeFineUserView *shake;
    
    User *findUser;
    
}
@end

@implementation ShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"摇一摇";
    // Do any additional setup after loading the view.
    shakeImage = [[UIImageView alloc] init];
    [self.view addSubview:shakeImage];
    shakeImage.image = LOADIMAGECACHES(@"shake1");
//    shakeImage.backgroundColor = [UIColor grayColor];
    [shakeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(200);
        make.centerY.equalTo(self.view).offset(-50);
        make.centerX.equalTo(self.view);
        
    }];
    
    
    locationManager    = [[CLLocationManager alloc] init];

    locationManager.delegate= (id)self;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        //用户拒绝或者未能授权
        [self showText:@"请在隐私设置中授权定位服务"];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        // 启动位置更新
        if(kCLAuthorizationStatusNotDetermined== status)
        {//对于这个应用程序用户还未做出的选择
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f){
                [locationManager requestWhenInUseAuthorization];
            }
        }
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = 1000.0f;
    [locationManager startUpdatingLocation];

}
- (void)addAnimations
{
    if(isRequst)return;
    AudioServicesPlaySystemSound(1012);
    
    CABasicAnimation *anima=[CABasicAnimation animation];
    anima.keyPath=@"transform";
    anima.fromValue= [ NSValue valueWithCATransform3D: CATransform3DMakeRotation( -M_2_PI/4, 0, 0, 1.0) ]; ;;
    anima.toValue= [ NSValue valueWithCATransform3D: CATransform3DMakeRotation( M_2_PI/4 , 0, 0, 1.0) ]; ;

    anima.removedOnCompletion=YES;
    anima.autoreverses = YES;
    anima.repeatCount=5;
    anima.duration=0.1;
    anima.fillMode=kCAFillModeForwards;
    [shakeImage.layer addAnimation:anima forKey:nil];
    
    [self sendRequst];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)sendRequst
{
    if(currentLoction)
    {
        
        if ([super startRequest]) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[[BSEngine currentEngine] user].uid forKey:@"uid"];
            [dic setObject:[NSString stringWithFormat:@"%f",currentLoction.coordinate.longitude] forKey:@"lng"];
            [dic setObject:[NSString stringWithFormat:@"%f",currentLoction.coordinate.latitude] forKey:@"lat"];
            
            
            [client requestFor:dic methodName:@"User/Api/rock_rock"];
            isRequst = YES;
        }
    }
    else
    {
        [self showText:@"正在获取地理位置,请稍后再试"];
    }

}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    isRequst = NO;
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = obj[@"data"];

        if(dic.allValues.count == 0){
            [self showText:@"没有找到"];
             if(shake)[shake removeFromSuperview];
        }
        else{
        
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:@"http://123.56.101.233:8082/weiyuan/Uploads/Picture/avatar/45/s_8d3639ab7fa64a946d0bcc3518beaee1.jpg" forKey:@"headsmall"];
//        [dic setObject:@"昵称" forKey:@"nickname"];
//        [dic setObject:@"1" forKey:@"gender"];
//        [dic setObject:@"45" forKey:@"uid"];
//        [dic setObject:@"445278.1726126045" forKey:@"distance"];
        //    "nickname": "\u6d4b\u8bd5\u8ba2\u9605\u53f7",  //昵称
        //    "gender": "0",  //性别： 0-男 1-女 2-未填写
        //    "uid": "45",    //用户ID: 满足摇一摇条件的另外那一人的
        //    "distance": "445278.1726126045"  //距离，单位：米
            
            if(findUser == nil)
            {
                findUser = [[User alloc] init];
            }
            [findUser updateWithJsonDic:dic];
            [self loadUserWithDic:dic];
        }
        
    }
    return NO;
}


-(void)showUserInfo
{
    UserInfoViewController *con = [[UserInfoViewController alloc] init];
    [con setUser:findUser];
    [self pushViewController:con];
}

-(void)loadUserWithDic:(NSDictionary *)dic
{
    
    if(shake)[shake removeFromSuperview];
    shake = [[ShakeFineUserView alloc] initWithDic:dic];
    [self.view addSubview:shake];
    [shake mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(10);
        make.right.equalTo(-10);
        make.height.equalTo(60);
        make.top.equalTo(shakeImage.mas_bottom).offset(20);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserInfo)];
    
    [shake addGestureRecognizer:tap];
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake )
    {
        // User was shaking the device. Post a notification named "shake".
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
        [self addAnimations];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{	
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - CLLocationManagerDelegate
// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [manager stopUpdatingLocation];
    
//    newLocation =[newLocation locationMarsFromEarth];
    //火星左边转化
    currentLoction = newLocation;
    
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        
        
        [self showText:@"请在隐私设置中授权定位服务"];
    }
    
}
@end
