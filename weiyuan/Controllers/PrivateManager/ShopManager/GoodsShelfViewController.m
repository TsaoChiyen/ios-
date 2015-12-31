//
//  GoodsShelfViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-14.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "GoodsShelfViewController.h"
#import "MenuView.h"
#import "BSClient.h"
#import "ShopCategroy.h"
#import "UIImageView+WebCache.h"
#import "Globals.h"
#import "Good.h"
#import "GoodsShelfCell.h"
#import "GoodDetailViewController.h"
#import "GoodsShelfEditController.h"

@interface GoodsShelfViewController () <GoodsShelfCellDelegate, GoodsShelfEditDelegate>
{
    UIView *headerView;
    UIView *footerView;
    
    UIButton *btnCategory;
    UIButton *btnStatus;

    BSClient            * clientCategory;
    NSArray             * arrStatus;
    
    NSInteger           currentCategoryId;
    NSInteger           currentStatus;
    
    Good *currentGoods;
}

@end

@implementation GoodsShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];

    arrStatus = @[@"所有状态",@"未上架",@"已上架"];
    currentStatus = 0;
    _shopType = 0;
    
    self.navigationItem.title = @"商品上架管理";
    headerView = self.headerBar;
    [self.view addSubview:headerView];
    footerView = self.footerBar;
    [self.view addSubview:footerView];
    tableView.top = headerView.height;
    tableView.height = footerView.top - tableView.top;
    
    self.tableViewCellHeight = 60;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        self.loading = YES;
        
        if (![ShopCategroy hasData]) {
            clientCategory = [[BSClient alloc] initWithDelegate:self action:@selector(requestCategroyDidFinish:obj:)];
            [clientCategory getShopCategoryListWithShopType:_shopType];
        }

        [self requestData];
    }
}

- (void)requestData
{
    self.loading = YES;
    [super startRequest];
    [client getProductListWithCategoryid:currentCategoryId
                               andStatus:currentStatus];
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
    
    pos.x += 100;
    btnStatus = [self buttonInActionbar:view title:@"所有状态" position:pos];
    btnStatus.tag = 1;
    
    return view;
}

- (UIView *)footerBar {
    CGFloat statusHeight = getDeviceStatusHeight();

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - statusHeight - 40, self.view.width, 40)];
    view.backgroundColor = UIColorFromRGB(0xffffff);
    float width = view.width / 2;
    CGPoint pos = CGPointMake((width - 100) *0.5, 4);
    
    [self buttonInActionbar:view title:@"确认上架" position:pos].tag = 2;
    
    pos.x += width;
    [self buttonInActionbar:view title:@"确认下架" position:pos].tag = 3;
//
//    pos.x += width;
//    
//    [self buttonInActionbar:view title:@"确认修改" position:pos].tag = 4;
//    
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
        case 1:
            menuView = [[MenuView alloc] initWithButtonTitles:arrStatus withDelegate:self];
            menuView.tag = sender.tag;
            break;
        case 2:
            [self sendRequestWithStatus:2];
            break;
        case 3:
            [self sendRequestWithStatus:1];
            break;
//        case 4:
//            [self editSelectedGoods];
//            break;
        default:
            break;
    }

    if (menuView) {
        [menuView showInView:self.view origin:CGPointMake(sender.left - 6, 0)];
    }
}

- (void)requestCategroyDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *arr = [obj getArrayForKey:@"data"];
        NSMutableArray *arrCategory = [NSMutableArray array];

        ShopCategroy * allitem = [[ShopCategroy alloc] init];
        allitem.name = @"全部商品";
        allitem.id = 0;
        [arrCategory addObject:allitem];

        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ShopCategroy * item = [ShopCategroy objWithJsonDic:obj];
                [arrCategory addObject:item];
            }];
        }
        
        [ShopCategroy setCategoryArray:arrCategory];
        
        if (btnCategory) {
            [btnCategory setTitle:allitem.name forState:UIControlStateNormal];
        }
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *arr = [obj getArrayForKey:@"data"];
        [contentArr removeAllObjects];
        
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Good *goods = [Good objWithJsonDic:obj];
                [contentArr addObject:goods];
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
        [btnCategory setTitle:item.name forState:UIControlStateNormal];
        currentCategoryId = item.id.integerValue;
    } else if (sender.tag == 1) {
        [btnStatus setTitle:arrStatus[buttonIndex] forState:UIControlStateNormal];
        currentStatus = buttonIndex;
    }
    
    [self requestData];
}

- (void)popoverViewCancel:(MenuView *)sender {

}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"GoodsShelfCell";

    if (!fileNib) {
        [tableView registerClass:GoodsShelfCell.class forCellReuseIdentifier:@"GoodsShelfCell"];
        fileNib = [UINib nibWithNibName:@"GoodsShelfCell" bundle:nil];
        [tableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
    }

    GoodsShelfCell * cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.superTableView = sender;
    cell.delegate = self;

    Good *item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];

    cell.goods = item;
    cell.imageView.hidden = YES;
    cell.topLine = YES;

    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentGoods = [contentArr objectAtIndex:indexPath.row];
    GoodsShelfEditController *con = [[GoodsShelfEditController alloc] init];
    
    if (con) {
        con.goods = currentGoods;
        con.delegate = self;
        [self pushViewController:con];
    }
}

//- (void)editSelectedGoods
//{
//    NSMutableArray *arrGoods = [NSMutableArray array];
//    
//    if (contentArr && contentArr.count > 0) {
//        [contentArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            Good *goods = obj;
//            
//            if ([goods.selected isEqual:@"1"]) {
//                [arrGoods addObject:goods];
//            }
//        }];
//    }
//    
//    if (arrGoods.count > 0) {
//        GoodsShelfEditViewController *con = [[GoodsShelfEditViewController alloc] init];
//        
//        if (con) {
//            con.arrGoods = arrGoods;
//            [self pushViewController:con];
//        }
//    }
//}
//
- (void)sendRequestWithStatus:(NSInteger)status
{
    NSMutableArray *arrGoods = [NSMutableArray array];
    
    if (contentArr && contentArr.count > 0) {
        [contentArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Good *goods = obj;
            
            if ([goods.selected isEqual:@"1"]) {
                [arrGoods addObject:goods];
                
                if (status == 1 && (goods.price.floatValue == 0 || goods.number.integerValue == 0)) {
                    *stop = YES;
                    [self showText:[NSString stringWithFormat:@"商品《%@》还未设置单价或上架的数量，不能上架", goods.name]];
                    [arrGoods removeAllObjects];
                }
            }
        }];
    }
    
    if (arrGoods.count > 0) {
        BSClient *goodsShelf = [[BSClient alloc] initWithDelegate:self action:@selector(updateGoodsShelfStatusDidFinish:obj:)];
        [goodsShelf shelfGoodsWithStatus:status data:arrGoods];
    }
}

- (BOOL)updateGoodsShelfStatusDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        [self requestData];
    }
    
    return YES;
}

- (BOOL)cellView:(UITableViewCell *)sender didCheckRowAtIndexPath:(NSIndexPath *)indexPath
{
    Good *goods = [contentArr objectAtIndex:indexPath.row];
    [goods setSelected:@(sender.selected).stringValue];
    return YES;
}

- (void)view:(id)sender didEditFinishWithGoods:(Good *)goods
{
    currentGoods.price = goods.price;
    currentGoods.number = goods.number;
    
    [tableView reloadData];
    
}

@end
