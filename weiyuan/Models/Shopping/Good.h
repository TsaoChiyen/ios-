//
//  Good.h
//  weiyuan
//
//  Created by Kiwaro on 15/2/7.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NSBaseObject.h"

@class Comment;

@interface Good : NSBaseObject

@property (nonatomic, strong) NSString  * id;
@property (nonatomic, strong) NSString  * shopid;
@property (nonatomic, strong) NSString  * categoryid;
@property (nonatomic, strong) NSString  * name;
@property (nonatomic, strong) NSString  * logo;
@property (nonatomic, strong) NSString  * price;
@property (nonatomic, strong) NSString  * star;
@property (nonatomic, strong) NSString  * commentcount;
@property (nonatomic, strong) NSString  * createtime;
@property (nonatomic, strong) NSString  * isfavorite;
@property (nonatomic, strong) NSString  * introduce;
@property (nonatomic, strong) NSString  * content;
@property (nonatomic, strong) NSString  * parameter;
@property (nonatomic, strong) NSString  * barcode;
@property (nonatomic, strong) NSString  * number;
@property (nonatomic, strong) NSString  * status;
@property (nonatomic, assign) NSString  * selected;
@property (nonatomic, strong) NSString  * count;

@property (nonatomic, strong) NSArray   * picture;
@property (nonatomic, strong) Comment   * comment;

- (NSString *)getShelfString;

@end
