//
//  AddGoodViewController.h
//  weiyuan
//
//  Created by Kiwaro on 15/2/13.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "BaseViewController.h"

@protocol GoodsEditDelegate <NSObject>

- (void)goodsEditDidFinish:(id)sender;

@end

@class Good;

@interface AddGoodViewController : BaseViewController

@property(nonatomic, strong) Good * goods;
@property(nonatomic, weak) id<GoodsEditDelegate> delegate;

@end
