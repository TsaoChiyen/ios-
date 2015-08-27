//
//  Comment.h
//  weiyuan
//
//  Created by Kiwaro on 15-2-8.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NSBaseObject.h"

@class User;

@interface Comment : NSBaseObject

@property (nonatomic, strong) NSString  * content;
@property (nonatomic, strong) NSString  * createtime;
//@property (nonatomic, strong) NSString  * goods_id;
@property (nonatomic, strong) NSString  * id;
@property (nonatomic, strong) NSString  * star;
@property (nonatomic, strong) NSString  * uid;
@property (nonatomic, strong) User  * user;
@end
