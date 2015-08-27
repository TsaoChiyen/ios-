//
//  Demand.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"
#import "User.h"

@interface Demand : NSBaseObject

@property (nonatomic, strong) NSString  * id;
@property (nonatomic, strong) NSString  * uid;
@property (nonatomic, strong) NSString  * content;
@property (nonatomic, strong) NSString  * lat;
@property (nonatomic, strong) NSString  * lng;
@property (nonatomic, strong) NSString  * distance;
@property (nonatomic, strong) NSString  * createtime;

@property (nonatomic, strong) User  * user;

@end
