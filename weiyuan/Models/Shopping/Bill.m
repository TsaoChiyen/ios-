//
//  Bill.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "Bill.h"
#import "User.h"

@implementation Bill

-(void)updateWithJsonDic:(NSDictionary *)dic {
    [super updateWithJsonDic:dic];
    
    if ([dic getDictionaryForKey:@"user"]) {
        _user = [User objWithJsonDic:[dic getDictionaryForKey:@"user"]];
    }
}
@end
