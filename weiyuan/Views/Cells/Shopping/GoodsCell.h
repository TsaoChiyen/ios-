//
//  GoodsCell.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-20.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseTableViewCell.h"

@class Good;

@protocol GoodsCellDelegate <NSObject>

@optional
- (void)cell:(UITableViewCell *)sender willDeleteGoods:(Good *)goods;
- (void)cell:(UITableViewCell *)sender willEditGoods:(Good *)goods;
@end

@interface GoodsCell : BaseTableViewCell

@property(nonatomic, strong) Good * goods;

@property(nonatomic, weak) id<GoodsCellDelegate> delegate;

@end
