//
//  OrderCustomerCell.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-20.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol OrderCustomerCellDelegate <NSObject>
@optional
- (void)cell:(UITableViewCell *)cell willCallPhone:(NSString *)phone;
- (void)cell:(UITableViewCell *)cell willTalkWithUserID:(NSString *)userId;
- (void)cell:(UITableViewCell *)cell willSendDeleteAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface OrderCustomerCell : BaseTableViewCell

@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, weak) id<OrderCustomerCellDelegate> delegate;

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, assign) CGFloat textHeight;

- (void)addConnectButton;
- (void)addDeleteButton;

- (void)autoShowButton:(NSInteger)index;

@end
