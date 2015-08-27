//
//  Area.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-17.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "Area.h"

//static NSMutableArray *areaArray = nil;

@implementation Area

+(void)createTableIfNotExists
{
    Statement *stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (areaid, name, parentid, vieworder, state, primary key(areaid))", [self tableName]]];
    int step = [stmt step];
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }
}

- (void)insertDB
{
    //    DLog(@"insertDB for tb_Notify");
    Statement *stmt = nil;
    
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO tb_Area VALUES(?, ?, ?, ?, ?)"];
    }
    
    int i = 1;
    
    [stmt bindString:self.areaid forIndex:i++];
    [stmt bindString:self.name forIndex:i++];
    [stmt bindString:self.parentid forIndex:i++];
    [stmt bindString:self.vieworder forIndex:i++];
    [stmt bindString:self.state forIndex:i++];
    
    int step = [stmt step];
    
    if (step != SQLITE_DONE) {
        [DBConnection alert];
    }

    [stmt reset];
}

+ (BOOL)isLocalized
{
    Statement * stmt = [DBConnection statementWithQueryString:[NSString stringWithFormat:@"SELECT count(areaid) FROM %@", [self tableName]]];

    int step = [stmt step];
    int icount = 0;

    if (step == SQLITE_ROW) {
        int i = 0;
        icount = [stmt getInt32:i++];
    }
    
    return icount > 0;
}

+ (NSString *)getAreaNameById:(NSString *)areaid {
    Statement * stmt = [DBConnection statementWithQueryString:@"SELECT name FROM tb_Area WHERE areaid = ?"];
    
    NSString *areaName = nil;
    int i = 1;
    
    [stmt bindString:areaid forIndex:i++];
    
    int step = [stmt step];
    
    if (step == SQLITE_ROW) {
        int i = 0;
        areaName = [stmt getString:i++];
    }
    
    return areaName;
}

+ (NSString *)getAreaIdByAddress:(NSString *)address {
    Statement * stmt = [DBConnection statementWithQueryString:@"SELECT areaid FROM tb_Area WHERE length(replace(?, name, '')) < length(?)"];
//    select * from tb_area where length(replace('重庆市渝北区', name, '')) < length('重庆市渝北区')
    
    NSString *areaID = nil;
    int i = 1;
    
    [stmt bindString:address forIndex:i++];
    [stmt bindString:address forIndex:i++];
    
    int step = [stmt step];

    if (step == SQLITE_ROW) {
        int i = 0;
        areaID = [stmt getString:i++];
    }
    
    return areaID;
}

+ (NSString *)getCombinedAddressByAreaId:(NSString *)areaid {
    NSString *address;
    
    if (areaid.length > 2) {
        Statement * stmt = [DBConnection statementWithQueryString:@"select name, (select name from tb_Area B where B.areaid = A.parentid) as parent from tb_Area A where areaid = ?"];
        
        NSString *city = nil;
        NSString *state = nil;
        int i = 1;
        
        [stmt bindString:areaid forIndex:i++];
        
        int step = [stmt step];
        
        if (step == SQLITE_ROW) {
            int i = 0;
            city = [stmt getString:i++];
            state = [stmt getString:i++];
            
            address = [NSString stringWithFormat:@"%@.%@", state, city];
        }
    } else {
        Statement * stmt = [DBConnection statementWithQueryString:@"select name from tb_Area A where areaid = ?"];
        
        int i = 1;
        
        [stmt bindString:areaid forIndex:i++];
        
        int step = [stmt step];
        
        if (step == SQLITE_ROW) {
            int i = 0;
            address = [stmt getString:i++];
        }
    }
    
    return address;
}

+ (Area *)getAreaByAddress:(NSString *)address {
    Area *area = [[Area alloc] init];
    
    Statement * stmt = [DBConnection statementWithQueryString:@"SELECT * FROM tb_Area WHERE name LIKE ?"];
    int i = 1;
    NSString *str = [NSString stringWithFormat:@"%%%@%%", address];
    [stmt bindString:str forIndex:i++];

    int step = [stmt step];
    
    if (step == SQLITE_ROW) {
        int i = 0;
        area.areaid = [stmt getString:i++];
        area.name = [stmt getString:i++];
        area.parentid = [stmt getString:i++];
        area.vieworder = [stmt getString:i++];
        area.state = [stmt getString:i++];
    }

    return area;
}

/*
+ (void)setShopArray:(NSArray *)array {
    if (!areaArray) {
        areaArray = [NSMutableArray array];
    } else {
        [areaArray removeAllObjects];
    }
    
    if (array && array.count) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Area *area = obj;
            [areaArray addObject:area];
        }];
    }
}

+ (NSArray *)getShopArray {
    return areaArray;
}

+ (BOOL)hasData {
    return (areaArray != nil) && (areaArray.count > 0);
}

+ (NSArray *)getShopAreaNameArray {
    if (!areaArray || areaArray.count == 0) {
        return nil;
    }
 
    __block NSMutableArray *array = [NSMutableArray array];
 
    [areaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Area *item = obj;
        [array addObject:item.name];
    }];
 
    return array;
}
 
+ (Area *)getShopAreaByIdx:(NSInteger)idx {
    if (!areaArray || areaArray.count == 0) {
        return nil;
    }
    
    Area *area = nil;
    
    if (idx >= 0 && idx < areaArray.count) {
        area = [areaArray objectAtIndex:idx];
    }
    
    return area;
}

+ (NSInteger )getShopAreaIdByIdx:(NSInteger)idx {
    Area *item = [Area getShopAreaByIdx:idx];
    
    if (item) {
        return item.areaid.integerValue;
    }
    
    return 0;
}

+ (NSString *)getShopAreaNameByIdx:(NSInteger)idx {
    Area *item = [Area getShopAreaByIdx:idx];
    
    if (item) {
        return item.name;
    }
    
    return @"所有地区";
}

+ (Area *)getShopAreaByName:(NSString *)name {
    if (!areaArray || areaArray.count == 0) {
        return nil;
    }
    
    __block Area *ShopArea = nil;
    
    [areaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Area *item = obj;
        
        if ([item.name isEqualToString:name]) {
            ShopArea = item;
            *stop = YES;
        }
    }];
    
    return ShopArea;
}

+ (NSInteger)getShopAreaIdxByName:(NSString *)name {
    if (!areaArray || areaArray.count == 0) {
        return 0;
    }
    
    __block NSInteger index = 0;
    
    [areaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Area *item = obj;
        
        if ([item.name isEqualToString:name]) {
            index =idx;
            *stop = YES;
        }
    }];
    
    return index;
}

+ (NSInteger)getShopAreaIdByName:(NSString *)name {
    Area *item = [Area getShopAreaByName:name];
    
    if (item) {
        return item.areaid.integerValue;
    }
    
    return 0;
}

+ (Area *)getShopAreaByAreaid:(NSInteger)areaid {
    if (!areaArray || areaArray.count == 0) {
        return nil;
    }
    
    __block Area *ShopArea = nil;
    
    [areaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Area *item = obj;
        
        if (item.areaid.integerValue == areaid) {
            ShopArea = item;
            *stop = YES;
        }
    }];
    
    return ShopArea;
}

+ (NSInteger)getShopAreaIdxByAreaid:(NSInteger)areaid {
    if (!areaArray || areaArray.count == 0) {
        return 0;
    }
    
    __block NSInteger index = 0;
    
    [areaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Area *item = obj;
        
        if (item.areaid.integerValue == areaid) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

+ (NSString *)getShopAreaNameByAreaid:(NSInteger)areaid {
    Area *item = [Area getShopAreaByAreaid:areaid];
    
    if (item) {
        return item.name;
    }
    
    return nil;
}
*/
@end
