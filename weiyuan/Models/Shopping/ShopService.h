//
//  ShopService.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

/**
 *  商家客服表
 */
@interface ShopService : NSBaseObject

@property(nonatomic, strong) NSString *id;          //< 客服id
@property(nonatomic, strong) NSString *uid;         //< 客服的 openfire id
@property(nonatomic, strong) NSString *shopid;      //< 客服所属商家id
@property(nonatomic, strong) NSString *name;        //< 客服名称
@property(nonatomic, strong) NSString *username;    //< 客服账户

@end
