//
//  ShopCell.m
//  LfMall
//
//  Created by 微慧Sam团队 on 13-8-19.
//  Copyright (c) 2013年 微慧Sam团队. All rights reserved.
//

#import "ShopCell.h"
#import "Globals.h"
#import "ImageTouchView.h"
#import "Shop.h"
#import "Good.h"
#import "UIImageView+WebCache.h"
#import "picture.h"

@interface ShopCell ()<ImageTouchViewDelegate> {
}

@end

@implementation ShopCell
@synthesize shop;

- (void)setShop:(Shop *)it {
    shop = it;
    self.shopName.text = it.name;
    
    float distance = it.distance.floatValue;
    NSString *strDistance = nil;
    
    if (distance > 0) {
        if (distance > 100000.0) {
            distance /= 1000.0;
            strDistance = [NSString stringWithFormat:@"距离 %d 公里", (int)distance];
        } else if (distance > 1000.0) {
            distance /= 1000.0;
            strDistance = [NSString stringWithFormat:@"距离 %.2f 公里", distance];
        } else {
            strDistance = [NSString stringWithFormat:@"距离 %d 米", (int)distance];
        }
        [self.shopDistance setHidden:NO];
    } else {
        [self.shopDistance setHidden:YES];
    }
    
    self.shopDistance.text = strDistance;
    self.price0.text = self.price1.text = self.price2.text = nil;
    self.imgView0.hidden = YES;
    self.imgView1.hidden = YES;
    self.imgView2.hidden = YES;
    
    self.imgView0.clipsToBounds =
    self.imgView1.clipsToBounds =
    self.imgView2.clipsToBounds = YES;
    
    self.imgView0.contentMode =
    self.imgView1.contentMode =
    self.imgView2.contentMode = UIViewContentModeScaleAspectFill;
    if (shop.goods && shop.goods.count > 0) {
        self.showView.height = 141;
    } else {
        self.showView.height = 35;
    }
    
    if (it.goods && it.goods.count > 0) {
        [it.goods enumerateObjectsUsingBlock:^(Good * obj, NSUInteger idx, BOOL *stop) {
            if (idx == 0) {
                self.price0.left = self.imgView0.left;
                self.price0.width = self.imgView0.width;
                self.price0.text = [NSString stringWithFormat:@"￥%@", obj.price];
                self.imgView0.hidden = NO;
                self.imgView0.tag = @"0";
                [self.imgView0 sd_setImageWithUrlString:[obj logo] placeholderImage:[Globals getImageGoodHeadDefault]];
            } else if(idx == 1) {
                self.price1.left = self.imgView1.left;
                self.price1.width = self.imgView1.width;
                self.price1.text = [NSString stringWithFormat:@"￥%@", obj.price];
                self.imgView1.hidden = NO;
                self.imgView1.tag = @"1";
                [self.imgView1 sd_setImageWithUrlString:[obj logo] placeholderImage:[Globals getImageGoodHeadDefault]];
            } else if(idx == 2) {
                self.price2.left = self.imgView2.left;
                self.price2.width = self.imgView2.width;
                self.price2.text = [NSString stringWithFormat:@"￥%@", obj.price];
                self.imgView2.hidden = NO;
                self.imgView2.tag = @"2";
                [self.imgView2 sd_setImageWithUrlString:[obj logo] placeholderImage:[Globals getImageGoodHeadDefault]];
            }
        }];
    }
}

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([self.superTableView.delegate respondsToSelector:@selector(tableViewDidTapImageAtIndexPath:tag:)]) {
        [self.superTableView.delegate performSelector:@selector(tableViewDidTapImageAtIndexPath:tag:) withObject:self.indexPath withObject:sender.tag];
    }
}

@end
