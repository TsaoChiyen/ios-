//
//  GoodsManagerViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "GoodsManagerViewController.h"
#import "Globals.h"
#import "MenuView.h"
#import "ShopCategroy.h"
#import "BaseTableViewCell.h"
#import "Shop.h"
#import "Good.h"
#import "GoodsCell.h"
#import "AddGoodViewController.h"

@interface GoodsManagerViewController () < GoodsCellDelegate, GoodsEditDelegate >
{
    UIView              * headerView;
    BSClient            * clientCategory;
    UIButton            * btnCategory;

    NSInteger           currentCategoryId;
    NSInteger           currentAreaId;
}

@end

@implementation GoodsManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    _shopType = 0;
    self.navigationItem.title = @"商品管理";
    
    [self setRightBarButtonImage:LOADIMAGE(@"actionbar_add_icon") highlightedImage:nil selector:@selector(addGoods:)];

    headerView = self.headerBar;
    [self.view addSubview:headerView];
    tableView.top = headerView.height;
    tableView.height = self.view.height - getDeviceStatusHeight() - tableView.top;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        if (![ShopCategroy hasData]) {
            self.loading = YES;
            clientCategory = [[BSClient alloc] initWithDelegate:self action:@selector(requestCategoryDidFinish:obj:)];
            [clientCategory getShopCategoryListWithShopType:_shopType];
        }
        
        [self requstData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)headerBar {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    CGPoint pos = CGPointMake(6, 4);
    
    btnCategory = [self buttonInActionbar:view title:@"商品分类" position:pos];
    btnCategory.tag = 0;
    
    return view;
}

- (UIButton *)buttonInActionbar:(UIView*)actionbar title:(NSString *)text position:(CGPoint)pos {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = CGRectMake(pos.x, pos.y, 100, 32);
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)btnItemPressed:(UIButton*)sender {
    MenuView * menuView;
    
    switch (sender.tag) {
        case 0:
            menuView = [[MenuView alloc] initWithButtonTitles:[ShopCategroy getCategoryNameArray] withDelegate:self];
            menuView.tag = sender.tag;
            break;
        default:
            break;
    }
    
    if (menuView) {
        [menuView showInView:self.view origin:CGPointMake(sender.left - 6, 0)];
    }
}

- (void)requestCategoryDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *arr = [obj getArrayForKey:@"data"];
        __block NSMutableArray *arrCategory = [NSMutableArray array];
        
        ShopCategroy * allitem = [[ShopCategroy alloc] init];
        allitem.name = @"全部商品";
        allitem.id = 0;
        [arrCategory addObject:allitem];
        
        if (arr && arr.count) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ShopCategroy * item = [ShopCategroy objWithJsonDic:obj];
                [arrCategory addObject:item];
            }];
        }

        [ShopCategroy setCategoryArray:arrCategory];
        
        if (btnCategory) {
            [btnCategory setTitle:allitem.name forState:UIControlStateNormal];
        }
        
        [self requstData];
    }
}

- (void)requstData
{
    if (!client) {
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
    }

    self.loading = YES;

    [client getProductListWithCategoryid:currentCategoryId andStatus:0];
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        [contentArr removeAllObjects];
        
        NSArray * arr = [obj getArrayForKey:@"data"];
        
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Good * item = [Good objWithJsonDic:obj];
                [contentArr addObject:item];
            }];
        }
        
        [tableView reloadData];
    }
    
    return YES;
}

#pragma mark - MenuViewDelegate

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (sender.tag == 0) {
        ShopCategroy *item = [ShopCategroy getCategoryByIdx:buttonIndex];
        currentCategoryId = item.id.integerValue;
        [btnCategory setTitle:item.name forState:UIControlStateNormal];
        [contentArr removeAllObjects];
        [self requstData];
    }
}

- (void)popoverViewCancel:(MenuView *)sender {
    
}

- (void)addGoods:(id)sender {
    id tmpCon = [[NSClassFromString(@"AddGoodViewController") alloc] init];
    
    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        UIViewController* con = (UIViewController*)tmpCon;
        [self pushViewController:con];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"GoodsCell";
    
    if (!fileNib) {
        [tableView registerClass:GoodsCell.class forCellReuseIdentifier:@"GoodsCell"];
        fileNib = [UINib nibWithNibName:@"GoodsCell" bundle:nil];
        [tableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
    }
    
    GoodsCell *cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.superTableView = sender;
    cell.delegate = self;
    
    Good *goods = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    
    cell.goods = goods;
    cell.imageView.hidden = YES;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)cell:(UITableViewCell *)sender willDeleteGoods:(Good *)goods
{
    if (goods) {
        BSClient *deleteClient = [[BSClient alloc] initWithDelegate:self action:@selector(goodsDeleteDidFinish:obj:)];
        
        if (deleteClient) {
            NSArray *arr = @[goods.id];
            [deleteClient deleteGoodsWithIds:arr];
        }
    }
}

- (void)cell:(UITableViewCell *)sender willEditGoods:(Good *)goods
{
    if (goods) {
        AddGoodViewController *con = [[AddGoodViewController alloc] init];
        
        if (con) {
            con.goods = goods;
            con.delegate = self;
            
            [self pushViewController:con];
        }
    }
}

- (BOOL)goodsDeleteDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        [self requstData];
    }
    
    return YES;
}

- (void)goodsEditDidFinish:(id)sender {
    [self requstData];
}

@end
