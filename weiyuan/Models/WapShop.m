//
//  WapShop.m
//  weihui
//
//  Created by Kiwaro on 15/1/28.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "WapShop.h"
#import "BSEngine.h"

@implementation WapShop
/// host
+ (NSString*)host {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
}
+ (NSString*)eventlist {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"eventlist"];
}

+ (NSString*)goodslist {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"goodslist"];
}

+ (NSString*)home {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"home"];
}

+ (NSString*)merchantlist {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"merchantlist"];
}

+ (NSString*)search {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"search"];
}

+ (NSString*)tuanlist {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"tuanlist"];
}

+ (NSString*)youhuilist {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"youhuilist"];
}

+ (NSString*)game {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"game"];
}

- (void) insertDB {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_host forKey:@"host"];
    [defaults setObject:_eventlist forKey:@"eventlist"];
    [defaults setObject:_goodslist forKey:@"goodslist"];
    [defaults setObject:_home forKey:@"home"];
    [defaults setObject:_merchantlist forKey:@"merchantlist"];
    [defaults setObject:_search forKey:@"search"];
    [defaults setObject:_tuanlist forKey:@"tuanlist"];
    [defaults setObject:_youhuilist forKey:@"youhuilist"];
    [defaults setObject:_game forKey:@"game"];
    [defaults synchronize];
}

@end
