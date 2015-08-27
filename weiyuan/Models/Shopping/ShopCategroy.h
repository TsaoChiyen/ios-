//
//  ShopCategroy.h
//  weiyuan
//
//  Created by Kiwaro on 15/2/7.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NSBaseObject.h"

@interface ShopCategroy : NSBaseObject

@property (nonatomic, strong) NSString  * id;           //
@property (nonatomic, strong) NSString  * logo;         //
@property (nonatomic, strong) NSString  * name;         //
@property (nonatomic, strong) NSString  * vieworder;    //

+ (void)setCategoryArray:(NSArray *)array;
+ (NSArray *)getCategoryArray;

+ (BOOL)hasData;

+ (NSArray *)getCategoryNameArray;

+ (ShopCategroy *)getCategoryByIdx:(NSInteger)idx;
+ (NSInteger )getCategoryIdByIdx:(NSInteger)idx;
+ (NSString *)getCategoryNameByIdx:(NSInteger)idx;
+ (NSString *)getCategoryLogoByIdx:(NSInteger)idx;

+ (ShopCategroy *)getCategoryByName:(NSString *)name;
+ (NSInteger)getCategoryIdxByName:(NSString *)name;
+ (NSInteger)getCategoryIdByName:(NSString *)name;
+ (NSString *)getCategoryLogoByName:(NSString *)name;

+ (ShopCategroy *)getCategoryByCategoryid:(NSInteger)categoryid;
+ (NSInteger)getCategoryIdxByCategoryid:(NSInteger)categoryid;
+ (NSString *)getCategoryNameByCategoryid:(NSInteger)categoryid;
+ (NSString *)getCategoryLogoByCategoryid:(NSInteger)categoryid;

@end
