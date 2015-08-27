//
//  Shop.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/7.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "Shop.h"
#import "Good.h"
#import "User.h"
#import "ShopService.h"

#import <objc/runtime.h>

@implementation Shop

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    
//    _user = [User objWithJsonDic:[dic objectForKey:@"user"]];
    
    NSArray * goods = [dic getArrayForKey:@"goods"];

    if (goods && goods.count > 0) {
        NSMutableArray * marr = [NSMutableArray array];
        
        [goods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Good * it = [Good objWithJsonDic:obj];
            [marr addObject:it];
        }];
        
        _goods = marr;
    }

    NSArray * services = [dic getArrayForKey:@"services"];
    
    if (services && services.count > 0) {
        NSMutableArray * marr = [NSMutableArray array];
        
        [services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShopService * it = [ShopService objWithJsonDic:obj];
            [marr addObject:it];
        }];
        
        _services = marr;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int propertyCount = 0;
        objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
        for (int i=0; i<propertyCount; i++) {
            objc_property_t * thisProperty = propertyList + i;
            const char * propertyName = property_getName(*thisProperty);
            NSString * key = [NSString stringWithUTF8String:propertyName];
            id value = [aDecoder decodeObjectForKey:key];
            if (value) {
                [self setValue:value forKey:key];
            }
        }
        free(propertyList);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int propertyCount = 0;
    objc_property_t * propertyList = class_copyPropertyList([self class], &propertyCount);
    for (int i=0; i<propertyCount; i++) {
        objc_property_t *thisProperty = propertyList + i;
        const char* propertyName = property_getName(*thisProperty);
        NSString * key = [NSString stringWithUTF8String:propertyName];
        if ([key isEqualToString:@"user"]) {
            continue;
        }
        if ([key isEqualToString:@"goods"]) {
            continue;
        }
        if ([key isEqualToString:@"services"]) {
            continue;
        }
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(propertyList);
}

@end
