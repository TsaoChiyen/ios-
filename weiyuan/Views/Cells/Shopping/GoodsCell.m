//
//  GoodsCell.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-20.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "GoodsCell.h"
#import "Good.h"

@interface GoodsCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imgLogo;
@property (strong, nonatomic) IBOutlet UILabel *lblBarcode;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UIButton *btnDel;
@property (strong, nonatomic) IBOutlet UIButton *btnEdt;

@end

@implementation GoodsCell

- (void)setGoods:(Good *)data
{
    _goods = data;
    
    if (_goods) {
        self.lblBarcode.text = [NSString stringWithFormat:@"条码:%@" ,_goods.barcode ];
        self.lblName.text = _goods.name;
        self.lblPrice.text = [NSString stringWithFormat:@"价格:%0.2f", _goods.price.floatValue];
        
        NSURL *url = [NSURL URLWithString:_goods.logo];
        NSData *imgData = [NSData dataWithContentsOfURL:url];
        _imgLogo.image = [UIImage imageWithData:imgData];
    }
}

- (IBAction)deleteGoods:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cell:willDeleteGoods:)]) {
        [self.delegate performSelector:@selector(cell:willDeleteGoods:) withObject:self withObject:_goods];
    }
}

- (IBAction)editGoods:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cell:willEditGoods:)]) {
        [self.delegate performSelector:@selector(cell:willEditGoods:) withObject:self withObject:_goods];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        self.btnDel.hidden = NO;
        self.btnEdt.hidden = NO;
    } else {
        self.btnDel.hidden = YES;
        self.btnEdt.hidden = YES;
    }
}

@end
