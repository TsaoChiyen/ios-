//
//  OrderAccountCell.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-20.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderAccountCell.h"
#import "Globals.h"
#import "Order.h"

@interface OrderAccountCell ()

@property (strong, nonatomic) IBOutlet UIButton *btnCheck;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblOrderSn;
@property (strong, nonatomic) IBOutlet UILabel *lblAacount;

@end

@implementation OrderAccountCell

- (void)setOrder:(Order *)data
{
  
    _order = data;
    self.lblOrderSn.text = [NSString stringWithFormat:@"订单:%@", _order.ordersn];
    self.lblAacount.text = [NSString stringWithFormat:@"金额:%@", _order.totalPrice];
    self.lblDate.text = [NSString stringWithFormat:@"完成交易日期:%@", [Globals convertDateFromString:_order.overtime timeType:2]];
}

- (IBAction)btnCheck:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    
    self.selected = sender.selected;
    
    if ([self.superTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.superTableView.delegate performSelector:@selector(tableView:didSelectRowAtIndexPath:)
                                           withObject:self.superTableView
                                           withObject:self.indexPath];

        self.selected = sender.selected;
    }
}

@end
