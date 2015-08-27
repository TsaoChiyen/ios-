//
//  Shop.h
//  weiyuan
//
//  Created by Kiwaro on 15/2/7.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NSBaseObject.h"
#import "Good.h"
@class User;

@interface Shop : NSBaseObject

@property (nonatomic, strong) NSString  * id;           //< 商户ID
@property (nonatomic, strong) NSString  * uid;          //< 用户ID
@property (nonatomic, strong) NSString  * logo;         //< 商户LOGO
@property (nonatomic, strong) NSString  * name;         //< 商户名称
@property (nonatomic, strong) NSString  * username;     //< 联系人
@property (nonatomic, strong) NSString  * phone;        //< 联系手机
@property (nonatomic, strong) NSString  * content;      //< 备注
@property (nonatomic, strong) NSString  * useraddress;  //< 联系地址
@property (nonatomic, strong) NSString  * address;      //< 商户地址
@property (nonatomic, strong) NSString  * lat;          //< 纬度
@property (nonatomic, strong) NSString  * lng;          //< 经度
@property (nonatomic, strong) NSString  * city;         //< 商家城市
@property (nonatomic, strong) NSString  * shopPaper;    //< 营业执照
@property (nonatomic, strong) NSString  * authPaper;    //< 授权证书
@property (nonatomic, strong) NSString  * bank;         //< 银行名
@property (nonatomic, strong) NSString  * bankName;     //< 银行用户名
@property (nonatomic, strong) NSString  * bankCard;     //< 银行账户
@property (nonatomic, strong) NSString  * status;       //< 商户状态
@property (nonatomic, strong) NSString  * createtime;   //< 入驻时间
@property (nonatomic, strong) NSString  * pasword;      //< 独立密码
@property (nonatomic, strong) NSString  * distance;

@property (nonatomic, strong) NSMutableArray    * goods;
@property (nonatomic, strong) User              * user;
@property (nonatomic, strong) NSMutableArray    * services;

@end
