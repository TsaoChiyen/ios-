//
//  FinancGoods.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

@class User, Financ;

/**
 *  融资商品表
 */
@interface FinancGoods : NSBaseObject

@property(nonatomic, strong) NSString *id;          //< 商品id
@property(nonatomic, strong) NSString *shopid;      //< 融资商id
@property(nonatomic, strong) NSString *name;        //< 商品名
@property(nonatomic, strong) NSString *type;        //< 商品类型
@property(nonatomic, strong) NSString *features;    //< 特征
@property(nonatomic, strong) NSString *material;    //< 材料
@property(nonatomic, strong) NSString *bidding;     //< 竞价排名价格
@property(nonatomic, strong) NSString *adPrice;     //< 广告位价格
@property(nonatomic, strong) NSString *createtime;  //< 登记时间

@property(nonatomic, strong) NSString *uid;         //< 用户uid
@property(nonatomic, strong) NSString *headsmall;   //< 用户头像图标
@property(nonatomic, strong) NSString *lng;         //< 用户注册位置的经度
@property(nonatomic, strong) NSString *lat;         //< 用户注册位置的纬度
@property(nonatomic, strong) NSString *distance;    //< 用户头像图标

@property(nonatomic, strong) User   *user;         //< 用户对象
@property(nonatomic, strong) Financ *financ;       //< 用户的融资商户信息对象

@end
