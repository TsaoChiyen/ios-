//
//  OrderAccountCell.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-20.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseTableViewCell.h"

@class Order;

@interface OrderAccountCell : BaseTableViewCell

@property(nonatomic, strong) Order *order;

@end
