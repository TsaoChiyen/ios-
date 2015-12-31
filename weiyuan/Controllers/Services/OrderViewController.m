//
//  OrderViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderViewController.h"
#import "BaseTableViewCell.h"
#import "ImageTouchView.h"
#import "MenuView.h"
#import "Order.h"
#import "Good.h"
#import "Shop.h"
#import "ShopService.h"
#import "Globals.h"
#import "OrderSubviewController.h"

@interface OrderViewController ()
{
    NSInteger currentStatus;
    UIView  * actionBar; //
}
@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];

    self.navigationItem.title = @"订单";
    _shopType = 0;

    [self setRightBarButtonImage:LOADIMAGE(@"actionbar_more_icon") highlightedImage:nil selector:@selector(chooseStatus:)];
}

- (void)chooseStatus:(id)sender
{
    MenuView * menuView = [[MenuView alloc] initWithButtonTitles:[Order getStatusArray]
                                                    withDelegate:self];
    
    if (menuView) {
        menuView.tag = 0;
        [menuView showInView:self.view origin:CGPointMake(tableView.width - MENUVIEW_WIDTH, 0)];
    }
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    [client getOrderListWithShopType:_shopType
                                page:1
                           andStatus:currentStatus andType:2];
}

#pragma mark - MenuViewDelegate

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (sender.tag == 0) {
        currentStatus = buttonIndex;
        [self requestData];
    }
}

- (void)popoverViewCancel:(MenuView *)sender {
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isFirstAppear) {
        [self requestData];
    }
}

- (void)requestData {
    self.loading = YES;
    [super startRequest];
    
    [contentArr removeAllObjects];

    [client getOrderListWithShopType:_shopType
                                page:1
                           andStatus:currentStatus andType:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *array = [obj getArrayForKey:@"data"];
        
        if (array && array.count) {
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Order *item = [Order objWithJsonDic:obj];

                if ([[obj objectForKey:@"goods"] isKindOfClass:[NSArray class]]) {
                    NSArray *goodsArr = [obj objectForKey:@"goods"];
                    
                    if (goodsArr && goodsArr.count > 0) {
                        NSMutableArray *goods = [NSMutableArray array];
                        
                        [goodsArr enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
                            
                            [goods addObject:[Good objWithJsonDic:item]];
                        }];
                        
                        item.goods = goods;
                    }
                }
                
                if ([[obj objectForKey:@"shop"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dicShop = [obj objectForKey:@"shop"];
                    item.shop = [Shop objWithJsonDic:dicShop];
                    
                    NSArray *srvs = [dicShop getArrayForKey:@"service"];
                    NSMutableArray *services = [NSMutableArray array];
                    
                    if (srvs && srvs.count) {
                        [srvs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            ShopService *item = [ShopService objWithJsonDic:obj];
                            [services addObject:item];
                        }];
                        
                        item.shop.services = services;
                    }
                }

                [contentArr addObject:item];
            }];
        }
        
        [tableView reloadData];
    }
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*)[super tableView:sender cellForRowAtIndexPath:indexPath];
    Order * order = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    
    [cell update:^(NSString *name) {
        cell.textLabel.height = cell.height * 0.6;
        cell.textLabel.width = cell.width - 72;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        cell.detailTextLabel.height = cell.height * 0.3;
        cell.detailTextLabel.width = cell.width - 72;
        cell.detailTextLabel.top = cell.height * 0.6;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        
        cell.labOther.frame = CGRectMake(cell.width - 64, 0, 64, cell.height);
        cell.labOther.textAlignment = NSTextAlignmentCenter;
        cell.labOther.numberOfLines = 3;
        cell.labOther.font = [UIFont systemFontOfSize:12];
    }];
    
    __block NSInteger   total = 0;
    __block CGFloat     totalPrice = 0;
    __block NSString    *name;

    if (order.goods && order.goods.count > 0) {
        [order.goods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Good *item = obj;
            
            if (item) {
                if (!name) {
                    name = item.name;
                }
                
                total += item.count.integerValue;
                totalPrice += item.price.floatValue * item.count.floatValue;
            }
        }];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@ %ld件商品", name, order.goods.count > 1 ? @"等":@"", total];
    
    cell.detailTextLabel.text = [Globals convertDateFromString:order.createtime timeType:1];
    cell.labOther.text = [NSString stringWithFormat:@"%@\n\n%0.2f", [order getStatusString], totalPrice];

    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Order * order = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];

    if (order.goods && order.goods.count) {
        Good *goods = order.goods[0];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:goods.logo]];
        UIImage *img = [UIImage imageWithData:data];
        cell.imageView.image = img;
    }
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [sender cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    Order *order = [contentArr objectAtIndex:indexPath.row];
    OrderSubviewController *con = [[OrderSubviewController alloc] init];
    
    if (con) {
        con.data = order;
        [self pushViewController:con];
    }
    
}

@end
