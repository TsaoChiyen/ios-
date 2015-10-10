//
//  Order.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

@class Good, Shop, UniPay;

@interface Order : NSBaseObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *ordersn;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *shopid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *totalPrice;
@property (nonatomic, strong) NSString *createtime;
@property (nonatomic, strong) NSString *deliverytime;
@property (nonatomic, strong) NSString *overtime;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *logcompany;
@property (nonatomic, strong) NSString *lognumber;

@property (nonatomic, strong) NSString  * selected;
@property (nonatomic, strong) NSMutableArray *goods;
@property (nonatomic, strong) Shop *shop;
@property (nonatomic, strong) UniPay *uniPay;

+ (NSArray *)getStatusArray;

+ (NSString *)getStatusByIdx:(NSInteger)idx;

- (NSString *)getStatusString;

@end
