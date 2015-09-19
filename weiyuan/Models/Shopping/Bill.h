//
//  Bill.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

@class User;

@interface Bill : NSBaseObject

@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * uid;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * bank;
@property (nonatomic, strong) NSString * card;
@property (nonatomic, strong) NSString * price;
@property (nonatomic, strong) NSString * number;
@property (nonatomic, strong) NSString * mechanism;
@property (nonatomic, strong) NSString * repayment;

@property (nonatomic, strong) User * user;

@end
