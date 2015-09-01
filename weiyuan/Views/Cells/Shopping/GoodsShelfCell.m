//
//  GoodsShelfCell.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-19.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "GoodsShelfCell.h"
#import "Globals.h"
#import "UIImageView+WebCache.h"
#import "ImageTouchView.h"
#import "Good.h"

@interface GoodsShelfCell ()<ImageTouchViewDelegate> {
}

@end

@implementation GoodsShelfCell
@synthesize goods;

- (void)setGoods:(Good *)it {
    goods = it;
    self.goodsName.text = it.name;
    self.price.text = it.price;
    self.number.text = it.number;
    self.status.text = (it.status.integerValue == 2?@"已上架":@"未上架");
    self.btnSelect.selected = it.selected.boolValue;
    self.selected = it.selected.boolValue;
    
    [self.logo sd_setImageWithUrlString:it.logo placeholderImage:[Globals getImageGoodHeadDefault]];
}

- (IBAction)goodsSelected:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    
    self.selected = sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(cellView:didCheckRowAtIndexPath:)]) {
        BOOL ret = [self.delegate cellView:self didCheckRowAtIndexPath:self.indexPath];

        if (ret == NO) {
            sender.selected = !sender.selected;
            self.selected = sender.selected;
        }
    }
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([self.superTableView.delegate respondsToSelector:@selector(tableViewDidTapImageAtIndexPath:tag:)]) {
        [self.superTableView.delegate performSelector:@selector(tableViewDidTapImageAtIndexPath:tag:) withObject:self.indexPath withObject:sender.tag];
    }
}

@end
