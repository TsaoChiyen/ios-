//
//  Area.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-17.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

@interface Area : NSBaseObject

@property (nonatomic, strong) NSString  * areaid;
@property (nonatomic, strong) NSString  * name;
@property (nonatomic, strong) NSString  * parentid;
@property (nonatomic, strong) NSString  * vieworder;
@property (nonatomic, strong) NSString  * state;

+ (BOOL)isLocalized;
+ (NSString *)getAreaIdByAddress:(NSString *)address;
+ (NSString *)getAreaNameById:(NSString *)areaid;
+ (Area *)getAreaByAddress:(NSString *)address;

+ (NSString *)getCombinedAddressByAreaId:(NSString *)areaid;

/*
+ (void)setShopArray:(NSArray *)array;
+ (NSArray *)getShopArray;

 + (BOOL)hasData;
 
+ (NSArray *)getShopAreaNameArray;

+ (Area *)getShopAreaByIdx:(NSInteger)idx;
+ (NSInteger )getShopAreaIdByIdx:(NSInteger)idx;
+ (NSString *)getShopAreaNameByIdx:(NSInteger)idx;

+ (Area *)getShopAreaByName:(NSString *)name;
+ (NSInteger)getShopAreaIdxByName:(NSString *)name;
+ (NSInteger)getShopAreaIdByName:(NSString *)name;

+ (Area *)getShopAreaByAreaid:(NSInteger)areaid;
+ (NSInteger)getShopAreaIdxByAreaid:(NSInteger)areaid;
+ (NSString *)getShopAreaNameByAreaid:(NSInteger)areaid;
*/

@end
