//
//  Order.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "Order.h"
#import "Good.h"
#import "Shop.h"

@implementation Order

+ (NSArray *)getStatusArray
{
    return @[@"所有状态", @"待发货", @"已发货", @"未付款", @"退货中", @"已退单", @"已完成", @"已退货", @"结款中", @"已结款"];

}

+ (NSString *)getStatusByIdx:(NSInteger)idx
{
    NSArray *arrStatus = [Order getStatusArray];
    return arrStatus[idx];
}

- (NSString *)getStatusString
{
    if (self.status.integerValue < 8) {
        return [Order getStatusByIdx:_status.integerValue];
    }
    
    return @"";
}

@end
