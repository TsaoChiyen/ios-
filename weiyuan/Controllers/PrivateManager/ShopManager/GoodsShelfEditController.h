//
//  GoodsShelfEditController.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-19.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseViewController.h"

@class Good;

@protocol GoodsShelfEditDelegate <NSObject>
- (void)view:(id)sender didEditFinishWithGoods:(Good *)goods;
@end


@interface GoodsShelfEditController : BaseViewController

@property (nonatomic, strong) Good *goods;
@property (nonatomic, weak) id<GoodsShelfEditDelegate> delegate;

@end
