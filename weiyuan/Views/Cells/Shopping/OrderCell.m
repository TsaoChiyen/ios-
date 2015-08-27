//
//  OrderCell.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-19.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderCell.h"
#import "Order.h"
#import "Good.h"
#import "Globals.h"

@interface OrderCell ()
{
    IBOutlet UILabel *labelSerial;
    
    IBOutlet UILabel *labelOrderNo;
    IBOutlet UILabel *labelDetail;
    IBOutlet UILabel *labelStatus;

    NSInteger total;
    float totals;
}

@end

@implementation OrderCell

@synthesize order = _order;

- (void)setOrder:(Order *)data
{
    _order = data;
    
    if (_order) {
        NSString *createTime = [Globals convertDateFromString:_order.createtime timeType:1];
        
        total = 0;
        totals = 0;
        
        if (_order.goods && _order.goods.count > 0) {
            [_order.goods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Good *it = obj;
                
                if (it) {
                    total += it.count.integerValue;
                    totals += it.count.integerValue * it.price.integerValue;
                }
            }];
        }
        
        labelSerial.text = @(self.indexPath.row + 1).stringValue;
        labelOrderNo.text = [NSString stringWithFormat:@"订单号:%@", _order.ordersn];
        labelDetail.text = [NSString stringWithFormat:@"总金额:%0.2f元  共计%d件商品\n下单时间:%@", totals, total,  createTime];
        labelStatus.text = [_order getStatusString];
    }
}

- (void)setIndex:(NSInteger)index
{
    labelSerial.text = @(index).stringValue;
}

@end
