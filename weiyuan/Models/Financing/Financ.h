//
//  Financ.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

/**
 *  融资商户注册表
 */
@interface Financ : NSBaseObject

@property(nonatomic, strong) NSString *id;              //< 融资商户id
@property(nonatomic, strong) NSString *uid;             //< 用户id
@property(nonatomic, strong) NSString *company;         //< 公司名称
@property(nonatomic, strong) NSString *workPaper;       //< 工作证明
@property(nonatomic, strong) NSString *idcard;          //< 身份证
@property(nonatomic, strong) NSString *certificate;     //< 从业资格证
@property(nonatomic, strong) NSString *city;            //< 公司所在城市编码
@property(nonatomic, strong) NSString *address;         //< 办公地址
@property(nonatomic, strong) NSString *lat;             //< 地理纬度
@property(nonatomic, strong) NSString *lng;             //< 地理经度
@property(nonatomic, strong) NSString *status;          //< 状态
@property(nonatomic, strong) NSString *money;           //< 融资资金
@property(nonatomic, strong) NSString *createtime;      //< 申请入驻时间

@end
