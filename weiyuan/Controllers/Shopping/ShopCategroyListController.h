//
//  CartGoodsViewController.h
//  weiyuan
//
//  Created by Kiwaro on 15/2/13.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "BaseTableViewController.h"

@protocol ShopCategroyDelegate <NSObject>
- (void)shopCategroyFinished:(NSString*)_categoryid _category:(NSString*)_category;
@end

@interface ShopCategroyListController : BaseTableViewController
@property (nonatomic, strong) id<ShopCategroyDelegate> delegate;
@property (nonatomic, assign) int shopType;
@end
