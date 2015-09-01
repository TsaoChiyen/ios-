//
//  OrderForPaymentViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderForPaymentViewController.h"
#import "Globals.h"
#import "Order.h"
#import "BSClient.h"
#import "OrderAccountCell.h"

@interface OrderForPaymentViewController ()
{
    UIView *headerView;
    UIView *footerView;
    
    UILabel *lblSummary;
    UILabel *labelSummary;
    CGFloat totals;
    NSInteger selectedCount;
    NSInteger currentSearch;
}


@end

@implementation OrderForPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];

    self.navigationItem.title = @"结款管理";
    headerView = self.headerBar;
    [self.view addSubview:headerView];
    footerView = self.footerBar;
    [self.view addSubview:footerView];
    tableView.top = headerView.height;
    tableView.height = footerView.top - tableView.top;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (isFirstAppear) {
        [self requestData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *arr = [obj getArrayForKey:@"data"];
        totals = 0;
        [contentArr removeAllObjects];
        labelSummary.hidden = YES;
        
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Order *item = [Order objWithJsonDic:obj];
                totals += item.totalPrice.floatValue;
                [contentArr addObject:item];
            }];
        }
        
        lblSummary.text = [NSString stringWithFormat:@"订单:%lu个 \t金额:%0.2f元", (unsigned long)contentArr.count, totals];
        
        [tableView reloadData];
    }
    
    return YES;
}

- (UIView *)headerBar {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 58)];
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    
    NSArray * arrSegmented = @[@"可结款",@"历史结款"];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:arrSegmented];
    
    segmentedControl.frame = CGRectMake(10.0, 2.0, self.view.width - 20.0, 32.0);
    segmentedControl.layer.cornerRadius = 0;
//    segmentedControl.backgroundColor = [UIColor darkGrayColor];
//    segmentedControl.tintColor = [UIColor darkGrayColor];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;//设置样式
//    segmentedControl.momentary = YES;//设置在点击后是否恢复原样
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:segmentedControl];

    lblSummary = [self labelInActionbar:view
                                  title:@"订单:5个 \t金额:20000.00元"
                               frame:CGRectMake(0, 36, self.view.width, 16)];

    return view;
}

- (UIView *)footerBar {
    CGFloat statusHeight = getDeviceStatusHeight();
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - statusHeight - 40, self.view.width, 40)];
    view.backgroundColor = UIColorFromRGB(0xffffff);
    CGPoint pos = CGPointMake(42, 4);
    
    [self buttonInActionbar:view title:@"确定结款" position:pos].tag = 2;
    
    pos.x += 160;
    
    [self buttonInActionbar:view title:@"异常申诉" position:pos].tag = 3;
    
    return view;
}

- (UIButton *)buttonInActionbar:(UIView*)actionbar title:(NSString *)text position:(CGPoint)pos {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = CGRectMake(pos.x, pos.y, 76, 32);
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UILabel *)labelInActionbar:(UIView*)actionbar title:(NSString *)text frame:(CGRect)frame {
    UILabel *lbl = [UILabel multLinesText:text font:[UIFont systemFontOfSize:12] wid:100];
    [lbl setTextColor:[UIColor lightGrayColor]];
    lbl.frame = frame;
    lbl.textAlignment = NSTextAlignmentCenter;
    [actionbar addSubview:lbl];
    return lbl;
}

-(void)segmentAction:(UISegmentedControl *)Seg {
    currentSearch = Seg.selectedSegmentIndex;
    [self requestData];
}

- (void)btnItemPressed:(UIButton*)sender {
    switch (sender.tag) {
        case 0:
            currentSearch = 0;
            [self requestData];
            break;
        case 1:
            currentSearch = 1;
            [self requestData];
            break;
        case 2:
            [self sendRequest];
            break;
        case 3:
        {
            id tmpCon = [[NSClassFromString(@"AbnormalAppealViewController") alloc] init];
            
            if ([tmpCon isKindOfClass:[UIViewController class]]) {
                UIViewController* con = (UIViewController*)tmpCon;
                [self pushViewController:con];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"OrderAccountCell";
    
    if (!fileNib) {
        [tableView registerClass:OrderAccountCell.class
          forCellReuseIdentifier:@"OrderAccountCell"];
        fileNib = [UINib nibWithNibName:@"OrderAccountCell" bundle:nil];
        [tableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
    }
    
    OrderAccountCell *cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.superTableView = sender;
    
    [cell setOrder:[contentArr objectAtIndex:indexPath.row]];
    cell.imageView.hidden = YES;
    cell.bottomLine = YES;
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [sender cellForRowAtIndexPath:indexPath];
    Order *order = [contentArr objectAtIndex:indexPath.row];
    [order setSelected:@(cell.selected).stringValue];
    [self sumaryOfSelected];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView*)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    if (!labelSummary) {
        labelSummary = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sender.width, 30)];
        labelSummary.backgroundColor = sender.backgroundColor;
        labelSummary.textAlignment = NSTextAlignmentCenter;
        labelSummary.textColor = [UIColor lightGrayColor];
    }
    
    return labelSummary;
}

- (void)sumaryOfSelected
{
    totals = 0;
    selectedCount = 0;
    
    if (contentArr && contentArr.count > 0) {
        [contentArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Order *item = obj;
            
            if (item.selected.boolValue) {
                selectedCount += 1;
                totals += item.totalPrice.floatValue;
            }
        }];
    }
    
    if (selectedCount > 0) {
        labelSummary.text = [NSString stringWithFormat:@"已选择 %d 个订单  共计 %0.2f 元", selectedCount, totals];
        labelSummary.hidden = NO;
    } else {
        labelSummary.hidden = YES;
    }
}

- (void)requestData
{
    self.loading = YES;
    [super startRequest];
    
    if (currentSearch == 0) {
        [client accountSettleable];
    } else {
        [client accountHistory];
    }
}

- (void)sendRequest
{
    NSMutableArray *arr = [NSMutableArray array];

    if (contentArr && contentArr.count > 0) {
        [contentArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Order *item = obj;
            
            if (item.selected) {
                [arr addObject:item.id];
            }
        }];
    }
    
    BSClient *accountClient = [[BSClient alloc] initWithDelegate:self action:@selector(applyAccountDidFinish:obj:)];
    [accountClient applyAccountSettleWithIds:arr];
}

- (void)applyAccountDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        [self requestData];
    }
}
@end
