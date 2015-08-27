//
//  ShoppingCart.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/9.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShoppingCart.h"
#import "BSEngine.h"

@implementation ShoppingCart

+ (NSString*)primaryKey {
    return @"goodid, currentUser";
}

+ (id)goodsFromshopid:(id)shopid {
    id result = nil;
    Statement * stmt = [DBConnection statementWithQuery:[[NSString stringWithFormat:@"SELECT * FROM %@ WHERE shopid = ? and currentUser = ?", [self tableName]] UTF8String]];
    
    int i = 1;
    [stmt bindString:shopid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    NSMutableArray * list = [NSMutableArray array];
    int ret = [stmt step];
    while (ret == SQLITE_ROW) {
        result = [[[self class] alloc] initWithStatement:stmt];
        if (result) {
            [list insertObject:result atIndex:0];
        }
        ret = [stmt step];
    }
    return list;
}

+ (id)goodsFromeDB:(NSString *)goodid shopid:(id)shopid {
    id result = nil;
    Statement * stmt = [DBConnection statementWithQuery:[[NSString stringWithFormat:@"SELECT * FROM %@ WHERE goodid = ? and shopid = ? and currentUser = ?", [self tableName]] UTF8String]];
    
    int i = 1;
    [stmt bindString:goodid forIndex:i++];
    [stmt bindString:shopid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int ret = [stmt step];
    if (ret == SQLITE_ROW) {
        result = [[[self class] alloc] initWithStatement:stmt];
    }
    
    return result;
}


+ (int)goodsCount {
    NSArray * arr = [self valueListFromDB];
    __block int co = 0;
    if (arr && arr.count > 0) {
        [arr enumerateObjectsUsingBlock:^(ShoppingCart *obj, NSUInteger idx, BOOL *stop) {
            co += obj.goodCount.intValue;
        }];
    }
    return co;
}

- (void)updateVaule:(id)value key:(NSString*)key {
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"update %@ set %@=? WHERE goodid=? and shopid=? and currentUser = ?", [[self class] tableName], key]];
    int i = 1;
    if ([value isKindOfClass:[NSString class]]) {
        [stmt bindString:value forIndex:i++];
    } else {
        [stmt bindValue:value forIndex:i++];
    }
    [stmt bindString:_goodid forIndex:i++];
    [stmt bindString:_shopid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

- (void)deleteFromDB {
    Statement * stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"delete from %@ where goodid=? and shopid=? and currentUser = ?", [[self class] tableName]]];
    int i = 1;
    [stmt bindString:_goodid forIndex:i++];
    [stmt bindString:_shopid forIndex:i++];
    [stmt bindString:[BSEngine currentUserId] forIndex:i++];
    
    int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
}

@end
