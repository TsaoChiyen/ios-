//
//  MarketsCategory.m
//  chengxin
//
//  Created by Tsao Chiyen on 15/10/24.
//  Copyright © 2015年 dreamisland. All rights reserved.
//

#import "MarketsCategory.h"

static NSMutableArray *categoryArray = nil;

@implementation MarketsCategory

+ (void)setCategoryArray:(NSArray *)array {
    if (!categoryArray) {
        categoryArray = [NSMutableArray array];
    } else {
        [categoryArray removeAllObjects];
    }
    
    if (array && array.count > 0) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MarketsCategory *item = obj;
            [categoryArray addObject:item];
        }];
    }
}

+ (NSArray *)getCategoryArray {
    return categoryArray;
}

+ (NSArray *)getCategoryNameArray {
    if (!categoryArray || categoryArray.count == 0) {
        return nil;
    }
    
    __block NSMutableArray *array = [NSMutableArray array];
    
    if (categoryArray && categoryArray.count > 0) {
        [categoryArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MarketsCategory *item = obj;
            [array addObject:item.name];
        }];
    }
    
    return array;
}

+ (BOOL)hasData {
    return (categoryArray != nil) && (categoryArray.count > 0);
}

+ (MarketsCategory *)getCategoryByIdx:(NSInteger)idx {
    if (!categoryArray || categoryArray.count == 0) {
        return nil;
    }
    
    MarketsCategory *category = nil;
    
    if (idx >= 0 && idx < categoryArray.count) {
        category = [categoryArray objectAtIndex:idx];
    }
    
    return category;
}

+ (NSInteger )getCategoryIdByIdx:(NSInteger)idx {
    MarketsCategory *item = [MarketsCategory getCategoryByIdx:idx];
    
    if (item) {
        return item.id.integerValue;
    }
    
    return 0;
}

+ (NSString *)getCategoryNameByIdx:(NSInteger)idx {
    MarketsCategory *item = [MarketsCategory getCategoryByIdx:idx];
    
    if (item) {
        return item.name;
    }
    
    return nil;
}

+ (NSString *)getCategoryLogoByIdx:(NSInteger)idx {
    MarketsCategory *item = [MarketsCategory getCategoryByIdx:idx];
    
    if (item) {
        return item.logo;
    }
    
    return nil;
}

+ (MarketsCategory *)getCategoryByName:(NSString *)name {
    if (!categoryArray || categoryArray.count == 0) {
        return nil;
    }
    
    __block MarketsCategory *category = nil;
    
    if (categoryArray && categoryArray.count > 0) {
        [categoryArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MarketsCategory *item = obj;
            
            if ([item.name isEqualToString:name]) {
                category = item;
                *stop = YES;
            }
        }];
    }
    
    return category;
}

+ (NSInteger)getCategoryIdxByName:(NSString *)name {
    if (!categoryArray || categoryArray.count == 0) {
        return 0;
    }
    
    __block NSInteger index = 0;
    
    if (categoryArray && categoryArray.count > 0) {
        [categoryArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MarketsCategory *item = obj;
            
            if ([item.name isEqualToString:name]) {
                index =idx;
                *stop = YES;
            }
        }];
    }
    
    return index;
}

+ (NSInteger)getCategoryIdByName:(NSString *)name {
    MarketsCategory *item = [MarketsCategory getCategoryByName:name];
    
    if (item) {
        return item.id.integerValue;
    }
    
    return 0;
}

+ (NSString *)getCategoryLogoByName:(NSString *)name {
    MarketsCategory *item = [MarketsCategory getCategoryByName:name];
    
    if (item) {
        return item.logo;
    }
    
    return nil;
}

+ (MarketsCategory *)getCategoryByCategoryid:(NSInteger)categoryid {
    if (!categoryArray || categoryArray.count == 0) {
        return nil;
    }
    
    __block MarketsCategory *category = nil;
    
    if (categoryArray && categoryArray.count > 0) {
        [categoryArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MarketsCategory *item = obj;
            
            if (item.id.integerValue == categoryid) {
                category = item;
                *stop = YES;
            }
        }];
    }
    
    return category;
}

+ (NSInteger)getCategoryIdxByCategoryid:(NSInteger)categoryid {
    if (!categoryArray || categoryArray.count == 0) {
        return 0;
    }
    
    __block NSInteger index = 0;
    
    if (categoryArray && categoryArray.count > 0) {
        [categoryArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MarketsCategory *item = obj;
            
            if (item.id.integerValue == categoryid) {
                index = idx;
                *stop = YES;
            }
        }];
    }
    
    return index;
}

+ (NSString *)getCategoryNameByCategoryid:(NSInteger)categoryid {
    MarketsCategory *item = [MarketsCategory getCategoryByCategoryid:categoryid];
    
    if (item) {
        return item.name;
    }
    
    return nil;
}

+ (NSString *)getCategoryLogoByCategoryid:(NSInteger)categoryid {
    MarketsCategory *item = [MarketsCategory getCategoryByCategoryid:categoryid];
    
    if (item) {
        return item.logo;
    }
    
    return nil;
}

@end
