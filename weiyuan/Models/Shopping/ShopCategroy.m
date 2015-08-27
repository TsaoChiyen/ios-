//
//  ShopCategroy.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/7.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShopCategroy.h"

static NSMutableArray *categoryArray = nil;

@implementation ShopCategroy

+ (void)setCategoryArray:(NSArray *)array {
    if (!categoryArray) {
        categoryArray = [NSMutableArray array];
    } else {
        [categoryArray removeAllObjects];
    }
    
    if (array && array.count > 0) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShopCategroy *item = obj;
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
            ShopCategroy *item = obj;
            [array addObject:item.name];
        }];
    }
    
    return array;
}

+ (BOOL)hasData {
    return (categoryArray != nil) && (categoryArray.count > 0);
}

+ (ShopCategroy *)getCategoryByIdx:(NSInteger)idx {
    if (!categoryArray || categoryArray.count == 0) {
        return nil;
    }
    
    ShopCategroy *category = nil;
    
    if (idx >= 0 && idx < categoryArray.count) {
        category = [categoryArray objectAtIndex:idx];
    }
    
    return category;
}

+ (NSInteger )getCategoryIdByIdx:(NSInteger)idx {
    ShopCategroy *item = [ShopCategroy getCategoryByIdx:idx];
    
    if (item) {
        return item.id.integerValue;
    }
    
    return 0;
}

+ (NSString *)getCategoryNameByIdx:(NSInteger)idx {
    ShopCategroy *item = [ShopCategroy getCategoryByIdx:idx];
    
    if (item) {
        return item.name;
    }
    
    return nil;
}

+ (NSString *)getCategoryLogoByIdx:(NSInteger)idx {
    ShopCategroy *item = [ShopCategroy getCategoryByIdx:idx];
    
    if (item) {
        return item.logo;
    }
    
    return nil;
}

+ (ShopCategroy *)getCategoryByName:(NSString *)name {
    if (!categoryArray || categoryArray.count == 0) {
        return nil;
    }
    
    __block ShopCategroy *category = nil;
    
    if (categoryArray && categoryArray.count > 0) {
        [categoryArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShopCategroy *item = obj;
            
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
            ShopCategroy *item = obj;
            
            if ([item.name isEqualToString:name]) {
                index =idx;
                *stop = YES;
            }
        }];
    }
    
    return index;
}

+ (NSInteger)getCategoryIdByName:(NSString *)name {
    ShopCategroy *item = [ShopCategroy getCategoryByName:name];
    
    if (item) {
        return item.id.integerValue;
    }
    
    return 0;
}

+ (NSString *)getCategoryLogoByName:(NSString *)name {
    ShopCategroy *item = [ShopCategroy getCategoryByName:name];
    
    if (item) {
        return item.logo;
    }
    
    return nil;
}

+ (ShopCategroy *)getCategoryByCategoryid:(NSInteger)categoryid {
    if (!categoryArray || categoryArray.count == 0) {
        return nil;
    }
    
    __block ShopCategroy *category = nil;

    if (categoryArray && categoryArray.count > 0) {
        [categoryArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShopCategroy *item = obj;
            
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
            ShopCategroy *item = obj;
            
            if (item.id.integerValue == categoryid) {
                index = idx;
                *stop = YES;
            }
        }];
    }

    return index;
}

+ (NSString *)getCategoryNameByCategoryid:(NSInteger)categoryid {
    ShopCategroy *item = [ShopCategroy getCategoryByCategoryid:categoryid];
    
    if (item) {
        return item.name;
    }
    
    return nil;
}

+ (NSString *)getCategoryLogoByCategoryid:(NSInteger)categoryid {
    ShopCategroy *item = [ShopCategroy getCategoryByCategoryid:categoryid];
    
    if (item) {
        return item.logo;
    }
    
    return nil;
}

@end
