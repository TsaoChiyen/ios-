//
//  GoodsShelfCell.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-19.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol GoodsShelfCellDelegate <NSObject>
- (BOOL)cellView:(UITableViewCell *)sender didCheckRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@class Good, ImageTouchView;

@interface GoodsShelfCell : BaseTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *goodsName;
@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *number;
@property (strong, nonatomic) IBOutlet ImageTouchView *logo;
@property (strong, nonatomic) IBOutlet UIButton *btnSelect;

- (IBAction)goodsSelected:(UIButton *)sender;

@property (strong, nonatomic) Good *goods;
@property (nonatomic, strong) id<GoodsShelfCellDelegate> delegate;

@end
