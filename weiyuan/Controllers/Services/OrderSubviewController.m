//
//  OrderSubviewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderSubviewController.h"
#import "Order.h"
#import "ShopService.h"
#import "Shop.h"
#import "Good.h"
#import "BaseTableViewCell.h"
#import "OrderGoodsCell.h"
#import "OrderCustomerCell.h"
#import "Globals.h"
#import "TextEditController.h"
#import "Session.h"
#import "UniPay.h"
#import "UPPayPlugin.h"
#import "BSClient.h"

static NSString * cellIdentifier = @"OrderGoodsCell";

@interface OrderSubviewController () < OrderCustomerCellDelegate, UPPayPluginDelegate >
{
    UILabel                 * lblOrder;
    float                   totals;
    int                     totalGoods;
    
    UINib                   * fileGoodsNib;
    UINib                   * fileGoodsNibFilter;
    
    UINib                   * fileCustomerNib;
    UINib                   * fileCustomerNibFilter;
}

@end

@implementation OrderSubviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    self.navigationItem.title = @"详细订单";
    _shopType = 0;
    
    tableView.tableFooterView = self.footerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [NSString stringWithFormat:@"订单:%@", _data.ordersn];
    
    if (isFirstAppear) {
        if (_data) {
            totals = 0;
            totalGoods = 0;
            
            [contentArr removeAllObjects];
            [contentArr addObject:[self getOrderGoods]];
            [contentArr addObject:[self getOrderSeller]];
            [contentArr addObject:[self getMyInfo]];
        }
    }
}

- (NSArray *)getOrderGoods
{
    NSMutableArray *array =[NSMutableArray array];
    
    if (_data.goods.count > 0) {
        NSString *str = @"商品名称^单价^数量^金额";
        
        [array addObject:str];
        
        if (_data.goods && _data.goods.count > 0) {
            [_data.goods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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

- (NSArray *)getOrderSeller
{
    NSMutableArray *array =[NSMutableArray array];
    Shop *shop = _data.shop;
    
    if (shop) {
        [array addObject:[NSString stringWithFormat:@"商家名称^%@", shop.name]];
        [array addObject:[NSString stringWithFormat:@"联系电话^%@", shop.phone]];
        [array addObject:[NSString stringWithFormat:@"商家地址^%@", shop.address]];
        
        if (shop.services && shop.services.count) {
            [shop.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ShopService *service = obj;
                NSString *title = @"";
                
                if (idx == 0) {
                    title = @"在线客服";
                }
                
                [array addObject:[NSString stringWithFormat:@"%@^客服名称: %@\n联系电话: %@", title, service.name, service.username]];
            }];
        }
    }
    
    return array;
}

- (NSArray *)getMyInfo
{
    NSMutableArray *array =[NSMutableArray array];
    
    [array addObject:[NSString stringWithFormat:@"呢称^%@", _data.username]];
    [array addObject:[NSString stringWithFormat:@"联系电话^%@", _data.phone]];
    [array addObject:[NSString stringWithFormat:@"收货地址^%@", _data.address]];
    
    return array;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)footerView {
    CGRect rc = CGRectMake(0, 0, tableView.width, 48);
    UIView *view = [[UIView alloc] initWithFrame:rc];
    view.backgroundColor = UIColorFromRGB(0xffffff);
    
    CGPoint pos = CGPointMake(32, 2);

    if ([[_data getStatusString] isEqualToString:@"未付款"]) {
        [self buttonInActionbar:view title:@"立即付款" position:pos].tag = 0;
        pos.x += 148;
        [self buttonInActionbar:view title:@"修改收货地址" position:pos].tag = 1;
    } else if ([[_data getStatusString] isEqualToString:@"待发货"]) {
        [self buttonInActionbar:view title:@"提醒发货" position:pos].tag = 2;
        pos.x += 148;
        [self buttonInActionbar:view title:@"修改收货地址" position:pos].tag = 1;
    } else if ([[_data getStatusString] isEqualToString:@"已发货"]) {
        [self buttonInActionbar:view title:@"确认收货" position:pos].tag = 4;
        pos.x += 148;
        [self buttonInActionbar:view title:@"查看物流" position:pos].tag = 3;
    } else /*if ([[_data getStatusString] isEqualToString:@"待发货"])*/ {
        pos.x += 74;
        [self buttonInActionbar:view title:@"查看物流" position:pos].tag = 3;
    }

    return view;
}

- (UIButton *)buttonInActionbar:(UIView*)actionbar title:(NSString *)text position:(CGPoint)pos {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [btn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = CGRectMake(pos.x, pos.y, 108, 44);
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)btnItemPressed:(UIButton*)sender {
    
    switch (sender.tag) {
        case 0:     //  pay
            [self payForOrder];
            break;
        case 1:     //  address
        {
            TextEditController * con = [[TextEditController alloc] initWithDel:self type:TextEditTypeDefault title:@"修改收货地址" value:_data.address];
            con.minTextCount = 2;
            con.maxTextCount = 128;
            con.indexPath = [NSIndexPath indexPathForItem:2 inSection:2];
            [self pushViewController:con];
        }
            break;
        case 2:     //  delivery
            [self getUserByName:_data.shop.uid];
            break;
        case 3:     //  logistics
            break;
        case 4:     //  确认收货
        {
            BSClient *clientRecieve = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
            
            [clientRecieve recieveGoodsWithShopType:_shopType
                                            orderId:_data.id];
        }
            break;
        default:
            break;
    }
}

- (void) payForOrder {
    BSClient *payOrder = [[BSClient alloc] initWithDelegate:self action:@selector(requestPayFinish:obj:)];
    
    [payOrder payOrderWithShopType:_shopType
                           orderId:_data.id];
}

- (BOOL)requestPayFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        UniPay *uniPay = [UniPay objWithJsonDic:[obj objectForKey:@"data"]];
        
        if (uniPay) {
            if (uniPay.tn &&
                uniPay.tn.length > 0 &&
                ![uniPay.tn isEqual:@"0"]) {
                [self startUPPayWithPayTN:uniPay.tn];
            }
        }
    }

    return YES;
}

- (void)startUPPayWithPayTN:(NSString *)payTN {
    if (payTN == nil || payTN.length == 0) {
        return;
    }
    
    [UPPayPlugin startPay:payTN mode:@"01" viewController:self delegate:self];
}

-(void)UPPayPluginResult:(NSString*)result {
    NSString *msg = @"";
    
    if ([result isEqual:@"success"]) {
        msg = @"支付成功！";
    } else if ([result isEqual:@"fail"]) {
        msg = @"支付失败！";
    } else if ([result isEqual:@"cancel"]) {
        msg = @"用户取消了支付";
    }
    
    [self showText:msg];
}

- (UILabel *)labelInActionView:(UIView*)view title:(NSString *)text {
    UILabel *lbl = [UILabel singleLineText:text font:[UIFont systemFontOfSize:14] wid:tableView.width];
    [lbl setTextColor:UIColorFromRGB(0x404040)];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.frame = CGRectMake(0, 0, tableView.width, 32);
    [view addSubview:lbl];
    return lbl;
}

- (UIView *)headerViewWithTitle:(NSString *)title {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 32)];
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    lblOrder = [self labelInActionView:view title:title];
    return view;
}

#pragma mark - TextEditControllerDelegate

- (void)textEditControllerDidEdit:(NSString*)text idx:(NSIndexPath*)idx {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[contentArr objectAtIndex:idx.section]];
    NSString *item = [arr objectAtIndex:idx.row];
    item = [NSString stringWithFormat:@"收货地址^%@", text];

    [arr removeObjectAtIndex:idx.row];
    [arr insertObject:item atIndex:idx.row];
    [contentArr removeObjectAtIndex:idx.section];
    [contentArr insertObject:arr atIndex:idx.section];
    
    [tableView reloadRowsAtIndexPaths:@[idx] withRowAnimation:UITableViewRowAnimationFade];
    
    if (!client) {
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
    }
    
    [client editShippingAddress:text andOrderId:_data.id];
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

#pragma mark - UITableViewDelegate

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
    if (section == 0) {
        return 0;
    }
    
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
        return nil;
    } else if (section == 1) {
        return [self headerViewWithTitle:@"商家信息"];
    } else {
        return [self headerViewWithTitle:@"我的信息"];
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
        
        if (indexPath.section == 1 && (indexPath.row == 1 || indexPath.row >= 3)) {
            [(OrderCustomerCell *)cell addConnectButton];
            [(OrderCustomerCell *)cell setDelegate:self];
            
            NSString *uid = _data.shop.uid;;
            
            if (indexPath.row >= 3) {
                NSInteger idx = indexPath.row - 3;
                
                ShopService *service = [_data.shop.services objectAtIndex:idx];
                uid = service.uid;
            }
            
            [(OrderCustomerCell *)cell setUid:uid];
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
}

- (void)cell:(UITableViewCell *)cell willCallPhone:(NSString *)phone
{
    NSArray *arr = [phone componentsSeparatedByString:@":"];

    if (arr.count > 0) {
        [Globals callAction:[arr lastObject] parentView:self.view];
    }
}

- (void)cell:(UITableViewCell *)cell willTalkWithUserID:(NSString *)userId
{
    [self getUserByName:userId];
}

@end
