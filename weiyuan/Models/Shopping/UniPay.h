//
//  UniPay.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-9-29.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "NSBaseObject.h"

@interface UniPay : NSBaseObject

@property (nonatomic, strong) NSString *accessType;
@property (nonatomic, strong) NSString *bizType;
@property (nonatomic, strong) NSString *certId;
@property (nonatomic, strong) NSString *encoding;
@property (nonatomic, strong) NSString *merId;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *respCode;
@property (nonatomic, strong) NSString *respMsg;
@property (nonatomic, strong) NSString *signMethod;
@property (nonatomic, strong) NSString *tn;
@property (nonatomic, strong) NSString *txnSubType;
@property (nonatomic, strong) NSString *txnTime;
@property (nonatomic, strong) NSString *txnType;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *signature;

@end
