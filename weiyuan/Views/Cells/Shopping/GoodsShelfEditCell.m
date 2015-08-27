//
//  GoodsShelfEditCell.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-19.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "GoodsShelfEditCell.h"
#import "Globals.h"
#import "ImageTouchView.h"
#import "UIImageView+WebCache.h"
#import "TextInput.h"
#import "Good.h"

@interface GoodsShelfEditCell () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet ImageTouchView *logo;
@property (strong, nonatomic) IBOutlet UILabel *goodsName;
@property (strong, nonatomic) IBOutlet KTextField *txtPrice;
@property (strong, nonatomic) IBOutlet KTextField *txtNumber;

@end

@implementation GoodsShelfEditCell
@synthesize goods = _goods;

- (void)setGoods:(Good *)it {
    _goods = it;
    self.goodsName.text = it.name;
    self.txtPrice.text = it.price;
    self.txtNumber.text = it.number;
    
    [self.logo sd_setImageWithUrlString:it.logo placeholderImage:[Globals getImageGoodHeadDefault]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        self.goods.price = textField.text;
    } else if (textField.tag == 2) {
        self.goods.number = textField.text;
    }
    
    return YES;
}

@end
