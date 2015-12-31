//
//  ShopGoodsViewController.m
//  weiyuan
//
//  Created by Kiwaro on 15-2-9.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShopGoodsViewController.h"
#import "BaseTableViewCell.h"
#import "GoodDetailViewController.h"
#import "Shop.h"
#import "User.h"
#import "Star.h"
#import "Globals.h"

@interface ShopGoodsViewController ()
{
    UIView * footerView;
    UILabel * phoneLabel;
    UILabel * addrLabel;
    UIButton * callButton;
}
@end

@implementation ShopGoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = _shop.name;
    [self enableSlimeRefresh];
    [self setEdgesNone];
    _shopType = 0;
    headImageViewSize = 200;
    footerView = [[UIView alloc] init];
    phoneLabel = [[UILabel alloc] init];
    phoneLabel.font = [UIFont systemFontOfSize:18];
    [footerView addSubview:phoneLabel];
    addrLabel = [[UILabel alloc] init];
    phoneLabel.font = [UIFont systemFontOfSize:15];
    [footerView addSubview:addrLabel];
    
    [self.view addSubview:footerView];
    phoneLabel.text = [NSString stringWithFormat:@"联系电话: %@", _shop.phone];
    addrLabel.text = [NSString stringWithFormat:@"地址: %@", _shop.address];
    callButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [callButton setImage:LOADIMAGE(@"联系商家") forState:UIControlStateNormal];
    [callButton addTarget:self action:@selector(callAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:callButton];
}

- (void)callAction {
    [Globals callAction:_shop.phone parentView:tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (isFirstAppear) {
        [super startRequest];
        [client getGoodsListWithShopType:_shopType
                                  shopId:_shop.id
                              categoryId:0
                                    city:nil
                                    sort:nil
                                    page:currentPage];

        CGSize size = [addrLabel.text sizeWithFont:addrLabel.font maxWidth:self.view.width - 20 maxNumberLines:0];
        addrLabel.frame = CGRectMake(10, 30, self.view.width - 50 - 20, size.height);
        footerView.frame = CGRectMake(0, self.view.height, self.view.width, size.height + 16 + 20);
        size = [phoneLabel.text sizeWithFont:phoneLabel.font maxWidth:self.view.width - 20 maxNumberLines:0];
        phoneLabel.frame = CGRectMake(10, 8, self.view.width - 50 - 20, 20);
        
        footerView.backgroundColor = RGBCOLOR(192, 192, 192);
        [UIView animateWithDuration:0.25 animations:^{
            footerView.bottom = self.view.height;
        }];
        
        footerView.layer.masksToBounds = YES;
        footerView.layer.borderWidth = 0.5;
        footerView.layer.borderColor = RGBACOLOR(140, 140, 140, 0.8).CGColor;
        tableView.height -= footerView.height;
        callButton.frame = CGRectMake(footerView.width - 50, 0, 50, footerView.height);
    } else {
        [tableView reloadData];
    }
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    [client getGoodsListWithShopType:_shopType
                              shopId:_shop.id
                          categoryId:0
                                city:nil
                                sort:nil
                                page:page];
}

- (BOOL)requestDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray * arr = [obj getArrayForKey:@"data"];
        
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Good * it = [Good objWithJsonDic:obj];
                [contentArr addObject:it];
            }];
        }

        [tableView reloadData];
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 8 + 17 + 20 + 8;
    Good * it = [contentArr objectAtIndex:indexPath.row];
    CGSize size = [it.name sizeWithFont:[UIFont systemFontOfSize:15] maxWidth:APP_Frame_Height - 80 maxNumberLines:0];
    height += size.height;
    return height;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * BusCellidentifier = @"BaseTableViewCell";
    BaseTableViewCell * cell = (BaseTableViewCell *)[sender dequeueReusableCellWithIdentifier:BusCellidentifier];
    Star * star = VIEWWITHTAG(cell.contentView, 11);
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:BusCellidentifier];
        cell.detailTextLabel.textColor = RGBCOLOR(235,89,99);
        star = [[Star alloc] initWithFrame:CGRectMake(60, 24, 100, 30)];
        star.tag = 11;
        [cell.contentView addSubview:star];
        star.userInteractionEnabled = NO;
        cell.imageView.userInteractionEnabled = NO;
    }
    Good * it = [contentArr objectAtIndex:indexPath.row];
    star.show_star = it.star.integerValue;
    cell.textLabel.text = it.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%@", it.price];
    
    [cell update:^(NSString *name) {
        cell.imageView.frame = CGRectMake(5, 10, 50, 50);
        CGSize size = [it.name sizeWithFont:[UIFont systemFontOfSize:15] maxWidth:APP_Frame_Height - 80 maxNumberLines:0];
        cell.textLabel.frame = CGRectMake(cell.imageView.right+10, 8, size.width, size.height);
        cell.detailTextLabel.frame = CGRectMake(cell.imageView.right+10, cell.textLabel.bottom + 24, cell.width - cell.imageView.right - 20, 21);
    }];
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //to be impletemented in sub-class
    cell.imageView.image = [Globals getImageGoodHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
}

- (NSString *)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    Good * it = [contentArr objectAtIndex:indexPath.row];
    return it.logo;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    GoodDetailViewController * con = [[GoodDetailViewController alloc] init];
    con.goods = [contentArr objectAtIndex:indexPath.row];
    con.shop = _shop;
    [self pushViewController:con];
}

@end
