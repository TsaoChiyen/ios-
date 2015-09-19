//
//  Comment.m
//  weiyuan
//
//  Created by Kiwaro on 15-2-8.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

- (void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    
    if ([dic getDictionaryForKey:@"user"]) {
        _user = [User objWithJsonDic:[dic getDictionaryForKey:@"user"]];
    }
}

@end
