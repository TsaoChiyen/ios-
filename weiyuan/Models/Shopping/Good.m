//
//  Good.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/7.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "Good.h"

@implementation Good

- (NSString *)getShelfString
{
    NSArray *arr = @[_id, _price, _number];
    return [arr componentsJoinedByString:@","];
}

@end
