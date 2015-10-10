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
#import "UniPay.h"

#import <objc/runtime.h>

@implementation Order

+ (NSArray *)getStatusArray
{
    return @[@"所有状态", @"待发货", @"已发货", @"未付款", @"退货中", @"已退单", @"已完成", @"已退货", @"结款中", @"已结款", @"已收货"];

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

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    
    NSArray *goods = [dic getArrayForKey:@"goods"];
    
    if (goods && goods.count > 0) {
        NSMutableArray * marr = [NSMutableArray array];
        
        [goods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Good * it = [Good objWithJsonDic:obj];
            [marr addObject:it];
        }];
        
        _goods = marr;
    }
    
    if ([dic objectForKey:@"shop"]) {
        _shop = [Shop objWithJsonDic:[dic objectForKey:@"shop"]];
    }

    if ([dic objectForKey:@"pay"]) {
        _uniPay = [UniPay objWithJsonDic:[dic objectForKey:@"pay"]];
    }
}

@end
