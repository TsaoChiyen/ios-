//
//  AddCartViewController.h
//  weiyuan
//
//  Created by Kiwaro on 15/2/9.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "BaseViewController.h"
@class Shop;

@interface AddCartViewController : BaseViewController
@property (nonatomic, strong) Shop * shop;
@property (nonatomic, assign) int shopType;
@end
