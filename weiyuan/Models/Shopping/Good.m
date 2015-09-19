//
//  Good.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/7.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "Good.h"
#import "Comment.h"
#import "picture.h"

@implementation Good

- (NSString *)getShelfString
{
    NSArray *arr = @[_id, _price, _number];
    return [arr componentsJoinedByString:@","];
}

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    
    NSArray * list = [dic getArrayForKey:@"picture"];
    
    if (list && list.count > 0) {
        NSMutableArray * marr = [NSMutableArray array];
        
        [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            picture * it = [picture objWithJsonDic:obj];
            [marr addObject:it];
        }];
        
        _picture = marr;
    }

    if ([dic getDictionaryForKey:@"comment"]) {
        _comment = [Comment objWithJsonDic:[dic getDictionaryForKey:@"comment"]];
    }
}

@end
