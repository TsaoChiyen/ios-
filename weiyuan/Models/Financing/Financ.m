//
//  Financ.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "Financ.h"

#import <objc/runtime.h>

@implementation Financ

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
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(propertyList);
}

@end
