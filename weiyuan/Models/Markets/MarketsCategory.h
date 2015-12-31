//
//  MarketsCategory.h
//  chengxin
//
//  Created by Tsao Chiyen on 15/10/24.
//  Copyright © 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

@interface MarketsCategory : NSBaseObject

@property (nonatomic, strong) NSString  * id;           //
@property (nonatomic, strong) NSString  * logo;         //
@property (nonatomic, strong) NSString  * name;         //
@property (nonatomic, strong) NSString  * vieworder;    //

+ (void)setCategoryArray:(NSArray *)array;
+ (NSArray *)getCategoryArray;

+ (BOOL)hasData;

+ (NSArray *)getCategoryNameArray;

+ (MarketsCategory *)getCategoryByIdx:(NSInteger)idx;
+ (NSInteger )getCategoryIdByIdx:(NSInteger)idx;
+ (NSString *)getCategoryNameByIdx:(NSInteger)idx;
+ (NSString *)getCategoryLogoByIdx:(NSInteger)idx;

+ (MarketsCategory *)getCategoryByName:(NSString *)name;
+ (NSInteger)getCategoryIdxByName:(NSString *)name;
+ (NSInteger)getCategoryIdByName:(NSString *)name;
+ (NSString *)getCategoryLogoByName:(NSString *)name;

+ (MarketsCategory *)getCategoryByCategoryid:(NSInteger)categoryid;
+ (NSInteger)getCategoryIdxByCategoryid:(NSInteger)categoryid;
+ (NSString *)getCategoryNameByCategoryid:(NSInteger)categoryid;
+ (NSString *)getCategoryLogoByCategoryid:(NSInteger)categoryid;

@end
