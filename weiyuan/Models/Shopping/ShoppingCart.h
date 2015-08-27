//
//  ShoppingCart.h
//  weiyuan
//
//  Created by Kiwaro on 15/2/9.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NSBaseObject.h"

@interface ShoppingCart : NSBaseObject

@property (nonatomic, strong) NSString  * goodid;
@property (nonatomic, strong) NSString  * goodCount;
@property (nonatomic, strong) NSString  * shopid;

+ (id)goodsFromshopid:(id)shopid;
+ (id)goodsFromeDB:(NSString *)goodid shopid:(id)shopid;
+ (int)goodsCount;
@end
