//
//  AddRepaymentBillViewController.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseViewController.h"

@class Bill;

@interface AddRepaymentBillViewController : BaseViewController

@property (nonatomic, assign) NSInteger  billType;

@property (nonatomic, assign) Bill  *bill;

@end
