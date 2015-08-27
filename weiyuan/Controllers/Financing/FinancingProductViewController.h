//
//  FinancingProductViewController.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-24.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseTableViewController.h"

typedef void(^deletedGoods)(BOOL del);

@interface FinancingProductViewController : BaseTableViewController

@property (nonatomic, strong) deletedGoods block;

@end
