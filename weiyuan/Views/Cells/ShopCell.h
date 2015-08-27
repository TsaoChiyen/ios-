//
//  CommentCell.h
//  LfMall
//
//  Created by 微慧Sam团队 on 13-8-19.
//  Copyright (c) 2013年 微慧Sam团队. All rights reserved.
//

#import "BaseTableViewCell.h"

@class Shop, ImageTouchView;

@interface ShopCell : BaseTableViewCell
@property (nonatomic, strong) IBOutlet UIView  * showView;
@property (nonatomic, strong) IBOutlet UILabel * price0;
@property (nonatomic, strong) IBOutlet UILabel * price1;
@property (nonatomic, strong) IBOutlet UILabel * price2;
@property (nonatomic, strong) IBOutlet UILabel * shopName;

@property (nonatomic, strong) IBOutlet ImageTouchView * imgView0;
@property (nonatomic, strong) IBOutlet ImageTouchView * imgView1;
@property (nonatomic, strong) IBOutlet ImageTouchView * imgView2;
@property (nonatomic, strong) Shop * shop;

@end
