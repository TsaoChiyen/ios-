//
//  WapShop.h
//  weihui
//
//  Created by Kiwaro on 15/1/28.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NSBaseObject.h"

@interface WapShop : NSBaseObject
/// 活动列表
@property (nonatomic, strong) NSString * eventlist;
/// 商城列表
@property (nonatomic, strong) NSString * goodslist;
/// 热门广场
@property (nonatomic, strong) NSString * home;
/// 商家列表
@property (nonatomic, strong) NSString * merchantlist;
/// 搜索
@property (nonatomic, strong) NSString * search;
/// 团购列表
@property (nonatomic, strong) NSString * tuanlist;
/// 优惠列表
@property (nonatomic, strong) NSString * youhuilist;
/// 游戏
@property (nonatomic, strong) NSString * game;
/// host
@property (nonatomic, strong) NSString * host;

/// host
+ (NSString*)host;
/// 活动列表
+ (NSString*)eventlist;
/// 商城列表
+ (NSString*)goodslist;
/// 热门广场
+ (NSString*)home;
/// 商家列表
+ (NSString*)merchantlist;
/// 搜索
+ (NSString*)search;
/// 团购列表
+ (NSString*)tuanlist;
/// 优惠列表
+ (NSString*)youhuilist;
/// 优惠列表
+ (NSString*)game;

@end
