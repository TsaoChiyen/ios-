//
//  ShopCategroyListController.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/13.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShopCategroyListController.h"
#import "ShopCategroy.h"
#import "BaseTableViewCell.h"

@interface ShopCategroyListController ()

@end

@implementation ShopCategroyListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"商品类别";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (isFirstAppear) {
        if (![ShopCategroy hasData]) {
            [super startRequest];
            [client getShopCategoryList];
        } else {
            [contentArr removeAllObjects];
            [contentArr addObjectsFromArray:[ShopCategroy getCategoryArray]];
            [contentArr removeObjectAtIndex:0];
            [tableView reloadData];
        }
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray * arr = [obj getArrayForKey:@"data"];

        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ShopCategroy * item = [ShopCategroy objWithJsonDic:obj];
                [contentArr addObject:item];
            }];
        }
        
        [tableView reloadData];
    }
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell * cell =  (id)[super tableView:sender cellForRowAtIndexPath:indexPath];
    ShopCategroy * item = [contentArr objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    ShopCategroy * item = [contentArr objectAtIndex:indexPath.row];
    return item.logo;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    if ([_delegate respondsToSelector:@selector(shopCategroyFinished:_category:)]) {
        ShopCategroy * item = [contentArr objectAtIndex:indexPath.row];
        [_delegate shopCategroyFinished:item.id _category:item.name];
    }
    [self popViewController];
}

@end
