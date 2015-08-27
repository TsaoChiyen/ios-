//
//  OrderCell.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-19.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseTableViewCell.h"

@class Order;

@interface OrderCell : BaseTableViewCell

@property (nonatomic, strong) Order *order;

- (void)setIndex:(NSInteger)index;

@end
