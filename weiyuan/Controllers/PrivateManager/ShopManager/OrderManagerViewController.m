//
//  OrderManagerViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderManagerViewController.h"
#import "OrderHandleViewController.h"
#import "MenuView.h"
#import "Globals.h"
#import "Order.h"
#import "Good.h"
#import "OrderCell.h"
#import "BaseTableViewCell.h"

@interface OrderManagerViewController ()
{
    UIView              * headerView;
    UIView              * footerView;

    UILabel             * lblCount;
    UILabel             * lblUnhandle;
    UILabel             * lblException;
    
    UIButton            * btnStatus;
    NSArray             * arrStatus;

    NSInteger unhandle;
    NSInteger exception;
    NSInteger currentStatus;
}

@end

@implementation OrderManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    arrStatus = [Order getStatusArray];

    self.navigationItem.title = @"商品订单管理";
    headerView = self.headerBar;
    [self.view addSubview:headerView];
    footerView = self.footerBar;
    [self.view addSubview:footerView];
    tableView.top = headerView.height;
    tableView.height = footerView.top - tableView.top;
    self.tableViewCellHeight = 74;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        [self requestData];
    }
}

- (void)requestData
{
    self.loading = YES;
    [super startRequest];
    [client getOrderListWithPage:1 andStatus:currentStatus andType:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)headerBar {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    CGPoint pos = CGPointMake(6, 4);
    
    btnStatus = [self buttonInActionbar:view title:@"所有状态" position:pos];
    btnStatus.tag = 0;
    
    return view;
}

- (UIView *)footerBar {
    CGFloat statusHeight = getDeviceStatusHeight();
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - statusHeight - 40, self.view.width, 40)];
    view.backgroundColor = UIColorFromRGB(0xffffff);

    CGPoint pos = CGPointMake(10, 0);
    lblCount = [self labelInActionbar:view title:@"总计\n75个订单" position:pos];

    pos.x += 100;
    lblUnhandle = [self labelInActionbar:view title:@"未处理\n1个订单" position:pos];
    
    pos.x += 100;
    lblException = [self labelInActionbar:view title:@"异常\n1个订单" position:pos];
    
    return view;
}

- (UIButton *)buttonInActionbar:(UIView*)actionbar title:(NSString *)text position:(CGPoint)pos {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [btn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = CGRectMake(pos.x, pos.y, 108, 32);
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UILabel *)labelInActionbar:(UIView*)actionbar title:(NSString *)text position:(CGPoint)pos {
    UILabel *lbl = [UILabel multLinesText:text font:[UIFont systemFontOfSize:12] wid:100];
    [lbl setTextColor:UIColorFromRGB(0x404040)];
    lbl.frame = CGRectMake(pos.x, pos.y, 100, 40);
    [actionbar addSubview:lbl];
    return lbl;
}

- (void)btnItemPressed:(UIButton*)sender {
    MenuView * menuView;
    
    switch (sender.tag) {
        case 0:
            menuView = [[MenuView alloc] initWithButtonTitles:arrStatus withDelegate:self];
            menuView.tag = sender.tag;
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        default:
            break;
    }
    
    if (menuView) {
        [menuView showInView:self.view origin:CGPointMake(sender.left - 6, 0)];
    }
}

#pragma mark - MenuViewDelegate

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (sender.tag == 0) {
        currentStatus = buttonIndex;
        [self requestData];
    } else if (sender.tag == 1) {
    }
}

- (void)popoverViewCancel:(MenuView *)sender {
    
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray* array = [obj objectForKey:@"data"];
        unhandle = 0;
        exception = 0;
        
        [contentArr removeAllObjects];
        
        if (array && array.count > 0) {
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Order * order = [Order objWithJsonDic:obj];
                
                if (order) {
                    if (order.status.integerValue == 0) {
                        unhandle ++;
                    }
                    
                    if (order.status.integerValue < 0) {
                        exception ++;
                    }
                    
                    NSArray *goodsArr = [obj objectForKey:@"goods"];
                    
                    if (goodsArr && goodsArr.count > 0) {
                        order.goods = [NSMutableArray array];
                        
                        [goodsArr enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
                            
                            [order.goods addObject:[Good objWithJsonDic:item]];
                        }];
                    }
                    
                    [contentArr addObject:order];
                }
            }];
        }
        
        [btnStatus setTitle:arrStatus[currentStatus] forState:UIControlStateNormal];
        lblCount.text = [NSString stringWithFormat:@"%@\n%d个订单", arrStatus[currentStatus], contentArr.count];
        lblUnhandle.text = [NSString stringWithFormat:@"未处理\n%d个订单", unhandle];
        lblException.text = [NSString stringWithFormat:@"异常\n%d个订单", exception];

        [tableView reloadData];
    }
    return YES;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"OrderCell";
    
    if (!fileNib) {
        [tableView registerClass:OrderCell.class forCellReuseIdentifier:@"OrderCell"];
        fileNib = [UINib nibWithNibName:@"OrderCell" bundle:nil];
        [tableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
    }
    
    OrderCell *cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.superTableView = sender;
    
    Order *order = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];

    cell.order = order;
    cell.imageView.hidden = YES;
    cell.topLine = YES;
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderHandleViewController *con = [[OrderHandleViewController alloc] init];
    [self pushViewController:con];
    UITableViewCell *cell = [sender cellForRowAtIndexPath:indexPath];
    con.order = [contentArr objectAtIndex:indexPath.row];
    cell.selected = NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(OrderCell *)cell setIndex:indexPath.row + 1];
}

@end
