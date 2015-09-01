//
//  OrderHandleViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderHandleViewController.h"
#import "Order.h"
#import "Good.h"
#import "BaseTableViewCell.h"
#import "OrderGoodsCell.h"
#import "OrderCustomerCell.h"
#import "Globals.h"
#import "OrderDeliveryViewController.h"
#import "OrderRetreatViewController.h"
#import "LogisticsViewController.h"
#import "Session.h"
//#import "TalkingViewController.h"


@interface OrderHandleViewController () < OrderCustomerCellDelegate >
{
    UILabel                 * lblOrder;
    float                   totals;
    int                     totalGoods;

    UINib                       * fileGoodsNib;
    UINib                       * fileGoodsNibFilter;

    UINib                       * fileCustomerNib;
    UINib                       * fileCustomerNibFilter;
}

@end

@implementation OrderHandleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    self.navigationItem.title = @"订单处理";

//    self.tableViewCellHeight = 22;
//    
//    tableView.tableHeaderView = self.headerView;
    tableView.tableFooterView = self.footerView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (isFirstAppear) {
        [tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setOrder:(Order *)data
{
    _order = data;
    
    if (_order) {
        totals = 0;
        totalGoods = 0;
        
        [contentArr removeAllObjects];
        [contentArr addObject:[self getOrderGoods]];
        [contentArr addObject:[self getOrderCustomer]];
    }
}

- (NSArray *)getOrderGoods
{
    NSMutableArray *array =[NSMutableArray array];
    
    if (_order.goods.count > 0) {
        NSString *str = @"商品名称^单价^数量^金额";
        
        [array addObject:str];
        
        if (_order.goods && _order.goods.count > 0) {
            [_order.goods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Good *goods = obj;
                float total = goods.price.floatValue * goods.count.integerValue;
                
                totalGoods += goods.count.integerValue;
                totals += total;
                
                NSString *str = [NSString stringWithFormat:@"%@^%@^%@^%0.2f",
                                 goods.name, goods.price, goods.count, total];
                
                [array addObject:str];
            }];
        }
    }
    
    return array;
}

- (NSArray *)getOrderCustomer
{
    NSMutableArray *array =[NSMutableArray array];
    
    [array addObject:[NSString stringWithFormat:@"顾客^%@", _order.username]];
    [array addObject:[NSString stringWithFormat:@"联系电话^%@", _order.phone]];
    [array addObject:[NSString stringWithFormat:@"收货地址^%@", _order.address]];
    [array addObject:[NSString stringWithFormat:@"顾客留言^%@", _order.content]];
    
    return array;
}

- (UIView *)headerView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 32)];
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    lblOrder = [self labelInActionView:view title:[NSString stringWithFormat:@"订单:%@", _order.ordersn]];
    return view;
}

- (UIView *)customerHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 32)];
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    lblOrder = [self labelInActionView:view title:@"顾客信息"];
    return view;
}

- (UIView *)footerView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 36)];
    view.backgroundColor = UIColorFromRGB(0xffffff);

    CGPoint pos = CGPointMake(24, 0);

    [self buttonInActionbar:view title:@"发货" position:pos].tag = 0;
    
    pos.x += 100;
    
    [self buttonInActionbar:view title:@"退单" position:pos].tag = 1;
    
    pos.x += 100;
    
    [self buttonInActionbar:view title:@"物流" position:pos].tag = 2;
    
    return view;
}

- (UILabel *)labelInActionView:(UIView*)view title:(NSString *)text {
    UILabel *lbl = [UILabel singleLineText:text font:[UIFont systemFontOfSize:14] wid:tableView.width];
    [lbl setTextColor:UIColorFromRGB(0x404040)];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.frame = CGRectMake(0, 0, tableView.width, 32);
    [view addSubview:lbl];
    return lbl;
}

- (UIButton *)buttonInActionbar:(UIView*)actionbar title:(NSString *)text position:(CGPoint)pos {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [btn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = CGRectMake(pos.x, pos.y, 72, 36);
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)btnItemPressed:(UIButton*)sender {
    id tmpCon = nil;
    int tag = sender.tag;
    
    switch (tag) {
        case 0:
        {
            OrderDeliveryViewController *con = [[OrderDeliveryViewController alloc] init];
            con.order = _order;
            tmpCon = con;
        }
            break;
        case 1:
        {
            OrderRetreatViewController *con = [[OrderRetreatViewController alloc] init];
            con.order = _order;
            tmpCon = con;
        }
            break;
        case 2:
        {
            LogisticsViewController *con = [[LogisticsViewController alloc] init];
            con.order = _order;
            tmpCon = con;
        }
            break;
        default:
            break;
    }

    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        UIViewController* con = (UIViewController*)tmpCon;
        [self pushViewController:con];
    }
}

- (BOOL)requestUserByNameDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        if (dic.count > 0) {
            User *user = [User objWithJsonDic:dic];
            [user insertDB];
            [Globals talkToUser:user
                         andUid:user.uid
                 withController:self];
        }
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 36;
    } else {
        return 44;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender
{
    return contentArr.count;
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 32;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [self headerView];
    } else {
        return [self customerHeaderView];
    }
}

- (UIView *)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sender.width, 32)];
        view.backgroundColor = UIColorFromRGB(0xffffff);
        lblOrder = [self labelInActionView:view
                                     title:[NSString stringWithFormat:@"共计: %d件商品\t总计金额: %0.2f", totalGoods, totals]];
        return view;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = contentArr[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseTableViewCell *cell = nil;

    NSArray *arr = [contentArr objectAtIndex:indexPath.section];
    
    if (indexPath.section == 0) {
        static NSString * goodsCellIdentifier = @"OrderGoodsCell";
        
        if (!fileGoodsNib) {
            [tableView registerClass:OrderGoodsCell.class forCellReuseIdentifier:@"OrderGoodsCell"];
            fileGoodsNib = [UINib nibWithNibName:@"OrderGoodsCell" bundle:nil];
            [tableView registerNib:fileGoodsNib forCellReuseIdentifier:goodsCellIdentifier];
        }
        
        cell = [sender dequeueReusableCellWithIdentifier:goodsCellIdentifier forIndexPath:indexPath];

        [(OrderGoodsCell *)cell setData:[arr objectAtIndex:indexPath.row]];
    } else {
        static NSString * customerCellIdentifier = @"OrderCustomerCell";
       
        if (!fileCustomerNib) {
            [tableView registerClass:OrderCustomerCell.class forCellReuseIdentifier:@"OrderCustomerCell"];
            fileCustomerNib = [UINib nibWithNibName:@"OrderCustomerCell" bundle:nil];
            [tableView registerNib:fileCustomerNib forCellReuseIdentifier:customerCellIdentifier];
        }
        
        cell = [sender dequeueReusableCellWithIdentifier:customerCellIdentifier forIndexPath:indexPath];

        [(OrderCustomerCell *)cell setData:[arr objectAtIndex:indexPath.row]];
        
        if (indexPath.row == 1) {
            [(OrderCustomerCell *)cell addConnectButton];
            [(OrderCustomerCell *)cell setDelegate:self];
            [(OrderCustomerCell *)cell setUid:_order.uid];
        }
    }

    cell.superTableView= sender;
    cell.imageView.hidden = YES;
    cell.topLine = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseTableViewCell *cell = (BaseTableViewCell *)[sender cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;

    if (indexPath.section == 1 && indexPath.row == 1) {
        
        UIWebView*callWebview =[[UIWebView alloc] init];
        NSURL *telURL =[NSURL URLWithString:@"tel:100100"];
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        //记得添加到view上
        [self.view addSubview:callWebview];
    }
}

- (void)cell:(UITableViewCell *)cell willCallPhone:(NSString *)phone
{
    [Globals callAction:phone parentView:self.view];
}

- (void)cell:(UITableViewCell *)cell willTalkWithUserID:(NSString *)userId
{
    [self getUserByName:userId];
}


@end
