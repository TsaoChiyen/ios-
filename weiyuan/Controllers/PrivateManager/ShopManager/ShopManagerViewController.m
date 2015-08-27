//
//  ShopManagerViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-14.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "ShopManagerViewController.h"
#import "BaseTableViewCell.h"

@interface ShopManagerViewController ()
{
    NSArray *arrData;
    NSArray *arrClass;
    NSInteger category;
}

@end

@implementation ShopManagerViewController

- (id)init {
    self = [super init];
    
    if (self) {
        category = 0;
        arrClass = nil;
        arrData = nil;
    }
    
    return self;
}

- (id)initWithCategory:(NSInteger)aCategory {
    self = [super init];
    
    if (self) {
        category = aCategory;
        arrClass = nil;
        arrData = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableViewCellHeight = 44;
    
    if (category == 0) {
        self.navigationItem.title = @"商城管理";

        arrData = @[@"商铺信息维护",
                    @"商品库管理",
                    @"商品上架管理",
                    @"商城订单管理",
                    @"商城结款管理"];
        
        arrClass = @[@"ShopInfoViewController",
                     @"GoodsManagerViewController",
                     @"GoodsShelfViewController",
                     @"OrderManagerViewController",
                     @"OrderForPaymentViewController"];
    } else {
        self.navigationItem.title = @"展会管理";

        arrData = @[@"商家信息维护",
                    @"展区申请",
                    @"商品库管理",
                    @"参展商品上架管理",
                    @"展会订单管理",
                    @"展会结款管理"];
    }

    [tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    UIImageView * clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (UIView *)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UIImageView *clearView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 10)];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"BaseTableViewCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell addArrowRight];
    cell.textLabel.text = arrData[indexPath.row];
    cell.className = arrClass[indexPath.row];

    [cell update:^(NSString *name) {
        cell.imageView.frame = CGRectMake(10, (cell.height - 23)/2, 23, 23);
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.textLabel.left = 40;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    }];

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = LOADIMAGE(cell.textLabel.text);
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    
    BaseTableViewCell *cell = (BaseTableViewCell*)[sender cellForRowAtIndexPath:indexPath];

    Class class = NSClassFromString(cell.className);
   
    id tmpCon = [[class alloc] init];

    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        UIViewController* con = (UIViewController*)tmpCon;
        [self pushViewController:con];
    }
}

@end
