//
//  SubPlat.h
//  reSearchDemo
//
//  Created by Jinjin on 15/4/16.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NSBaseObject.h"

typedef NS_ENUM(int, AFRole) {
    AFRoleNormal = 0,
    AFRoleSub = 2,
    AFRoleService = 1
};

//0-普通用户 1-服务号 2-订阅号


@interface SubPlat : NSBaseObject
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSString *logo;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *account;
@property (nonatomic,strong) NSString *info;
@property (nonatomic,strong) NSString *authend;
@property (nonatomic,strong) NSString *authmaterial;
@property (nonatomic,strong) NSString *comment;
@property (nonatomic,assign) NSInteger releation;
@property (nonatomic,assign) AFRole usertype;
@end
