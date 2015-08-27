//
//  GoodDetailViewController.h
//  BluetoothBus
//
//  Created by Kiwaro on 14-12-23.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import "BaseViewController.h"

@class Good, Shop;

@interface GoodDetailViewController : BaseViewController
@property (nonatomic, strong) Good * goods;
@property (nonatomic, strong) Shop * shop;

@end
