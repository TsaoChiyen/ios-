//
//  ShopCommentViewController.h
//  weiyuan
//
//  Created by Kiwaro on 15/2/9.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "BaseTableViewController.h"
@class Good, Shop;

@interface ShopCommentViewController : BaseTableViewController
@property (nonatomic, strong) Good * goods;
@property (nonatomic, strong) Shop * shop;
@end
