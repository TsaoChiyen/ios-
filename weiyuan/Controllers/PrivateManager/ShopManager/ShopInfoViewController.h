//
//  ShopInfoViewController.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseTableViewController.h"

typedef void(^deletedShopService)(BOOL del);

@class Shop;

@interface ShopInfoViewController : BaseTableViewController

@property(nonatomic, strong) Shop *shop;

@property (nonatomic, strong) deletedShopService block;

@end
