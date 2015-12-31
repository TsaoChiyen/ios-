//
//  OrderDeliveryViewController.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseViewController.h"

@class Order;

@interface OrderDeliveryViewController : BaseViewController
@property (nonatomic, strong) Order *order;
@property (nonatomic, assign) int shopType;
@end
