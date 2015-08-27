//
//  OrderGoodsCell.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-20.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderGoodsCell.h"

@interface OrderGoodsCell ()
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelPrice;
@property (strong, nonatomic) IBOutlet UILabel *labelNumber;
@property (strong, nonatomic) IBOutlet UILabel *labelTotal;

@end


@implementation OrderGoodsCell

- (void)setData:(NSString *)it
{
    _data = it;
    
    if (_data) {
        NSArray *arr = [_data componentsSeparatedByString:@"^"];
        
        if (arr && arr.count) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *str = obj;
                
                if (idx == 0) {
                    self.labelName.text = str;
                } else if (idx == 1) {
                    self.labelPrice.text = str;
                } else if (idx == 2) {
                    self.labelNumber.text = str;
                } else if (idx == 3) {
                    self.labelTotal.text = str;
                }
            }];
        }
    }
}

@end
