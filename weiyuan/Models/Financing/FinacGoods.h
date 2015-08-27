//
//  FinancGoods.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

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

@end
