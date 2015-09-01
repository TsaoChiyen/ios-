//
//  ShopInfoViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "ShopInfoViewController.h"
#import "User.h"
#import "Shop.h"
#import "ShopService.h"
#import "BaseTableViewCell.h"
#import "OrderCustomerCell.h"
#import "BankEditViewController.h"
#import "AddServiceViewController.h"
#import "ShopPasswordViewController.h"

@interface ShopInfoViewController () < BankEditViewDelegate, ServiceViewDelegate, OrderCustomerCellDelegate >
{
    NSString *strBank;
    NSString *strBankUser;
    NSString *strBankCard;
    
    NSMutableArray *arrServices;
}

@end

@implementation ShopInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    
    arrServices = [NSMutableArray array];
    
    self.shop = [[BSEngine currentEngine] user].shop;
    
    [self setRightBarButtonImage:LOADIMAGE(@"OK") highlightedImage:nil selector:@selector(modifyAction)];
    self.navigationItem.title = @"商家信息维护";

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isFirstAppear) {
        [self loadServices];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)modifyAction {
    [self refreshCurrentUser];
    [self popViewController];
}

- (void)loadServices {
    if (_shop) {
        BSClient *clientService = [[BSClient alloc] initWithDelegate:self action:@selector(requestServiceDidFinish:obj:)];
        
        [clientService serviceListWithShopId:_shop.id];
    }
}

/**
 *  data contain four section:
 *  1.  shop base information, at section head show notice, contain:
 *      1.1 shop name
 *      1.2 shop address
 *      1.3 shop contact
 *      1.4 phone of the contact
 *      1.5 address of the contact
 *  2.  shop's bank information, at section head show notice,contain:
 *      2.1 bank name
 *      2.2 bank user name
 *      2.3 bank account number
 *  3.  shop service list,contain several services.
 *      At the sectiion head, put an icon on the right for add sevice.
 *  4.  shop's independence password, only one data.
 *
 */
- (void)prepareData {
    if (_shop) {
        // 1.  shop base information
        [contentArr addObject:[self prepareBaseInfo]];
        // 2.  shop's bank information
        [contentArr addObject:[self preparBankInfo]];
        // 3.  shop service list
        [contentArr addObject:[self preparServiceList]];
        // 4.  shop's independence password, only one data.
        User *user = [[BSEngine currentEngine] user];
        NSString *str = [NSString stringWithFormat:@"%@^%@", @"独立密码",user.hasShopPass?@"已设置":@"未设置"];
        [contentArr addObject:@[str]];
        
        [tableView reloadData];
    }
}

/**
 *  1.  shop base information, at section head show notice, contain:
 *      1.1 shop name
 *      1.2 shop address
 *      1.3 shop contact
 *      1.4 phone of the contact
 *      1.5 address of the contact
 */
- (NSArray *)prepareBaseInfo {
    NSMutableArray *marr = [NSMutableArray array];
    
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"商户名称", _shop.name]];
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"商户地址", _shop.address]];
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"联系人", _shop.username]];
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"联系电话", _shop.phone]];
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"联系地址", (_shop.useraddress?_shop.useraddress:@"")]];
    
    return marr;
}

/**
 *  2.  shop's bank information, at section head show notice,contain:
 *      2.1 bank name
 *      2.2 bank user name
 *      2.3 bank account number
 */
- (NSArray *)preparBankInfo {
    NSMutableArray *marr = [NSMutableArray array];
    
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"开户银行", _shop.bank.length > 4?_shop.bank:@""]];
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"户名", _shop.bankName.length > 4?_shop.bankName:@""]];
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"账号", _shop.bankCard.length > 4?_shop.bankCard:@""]];
    
    return marr;
}

/**
 *  3.  shop service list,contain several services.
 *      At the sectiion head, put an icon on the right for add sevice.
 */
- (NSArray *)preparServiceList {
    NSMutableArray *marr = [NSMutableArray array];
    
    [arrServices removeAllObjects];
    
    if (_shop.services && _shop.services.count) {
        [_shop.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShopService *item = obj;
            NSString *str = [NSString stringWithFormat:@"客服名称\n账号^%@\n%@", item.name, item.username];

            if (str) {
                [marr addObject:str];
                [arrServices addObject:item];
            }
        }];
    }
    
    return marr;
}

- (BOOL)requestServiceDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *array = [obj getArrayForKey:@"data"];
        
        if (array && array.count) {
            NSMutableArray *marr = [NSMutableArray array];
            
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ShopService *item = [ShopService objWithJsonDic:obj];
                [marr addObject:item];
            }];
            
            _shop.services = marr;
        }
        
        [self prepareData];
    }
    
    return YES;
}

- (UIView *) headerViewWithTitle:(NSString *)title
                       andPrompt:(NSString *)prompt
                          button:(NSString *)button
                       buttontag:(NSInteger)tag
{
    CGRect rc;

    if (prompt) {
        rc = CGRectMake(0, 0, tableView.width, 48);
    } else {
        rc = CGRectMake(0, 0, tableView.width, 36);
    }
    
    UIView *view = [[UIView alloc] initWithFrame:rc];
    view.backgroundColor = UIColorFromRGB(0xeeeeee);

    UILabel *lblTitle = [UILabel singleLineText:title
                                           font:[UIFont systemFontOfSize:17]
                                            wid:tableView.width
                                          color:[UIColor blackColor]];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.frame = CGRectMake(0, 0, tableView.width, 36);
    [view addSubview:lblTitle];

    if (prompt) {
        UILabel *lblPrompt = [UILabel multLinesText:prompt
                                               font:[UIFont systemFontOfSize:11]
                                                wid:tableView.width - 20
                                              color:[UIColor lightGrayColor]];
        lblPrompt.textAlignment = NSTextAlignmentCenter;
        lblPrompt.frame = CGRectMake(10, 24, tableView.width - 20, 24);
        [view addSubview:lblPrompt];
    }
    
    if (button) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn borderStyle];
        btn.tag = tag;
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setTitle:button forState:UIControlStateNormal];
        btn.frame = CGRectMake(tableView.width - 64, (rc.size.height - 28) * 0.5, 58, 28);
        [view addSubview:btn];
        [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return view;
}

- (void)btnItemPressed:(UIButton *)sender {
    if (sender.tag == 0) {
        
    } else if (sender.tag == 1) {
        BankEditViewController *con = [[BankEditViewController alloc] init];
        
        if (con) {
            con.delegate = self;
            [self pushViewController:con];
        }
    } else if (sender.tag == 2) {
        AddServiceViewController *con = [[AddServiceViewController alloc] init];
        
        if (con) {
            con.delegate = self;
            [self pushViewController:con];
            
        }
    } else if (sender.tag == 3) {
        ShopPasswordViewController *con = [[ShopPasswordViewController alloc] init];
        [self pushViewController:con];
    }
}

- (void)editDidFinishedWithBank:(NSString *)bank
                           user:(NSString *)user
                        account:(NSString *)account
{
    strBank = bank;
    strBankUser = user;
    strBankCard = account;
    
    NSMutableArray *marr = [NSMutableArray array];
    
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"开户银行", strBank]];
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"户名", strBankUser]];
    [marr addObject:[NSString stringWithFormat:@"%@^%@", @"账号", strBankCard]];
    
    [contentArr removeObjectAtIndex:1];
    [contentArr insertObject:marr atIndex:1];
    [tableView reloadData];
    
    User *currentUser = [BSEngine currentEngine].user;
    
    currentUser.shop.bank = bank;
    currentUser.shop.bankName = user;
    currentUser.shop.bankCard = account;
    [[BSEngine currentEngine] setCurrentUser:currentUser password:[[BSEngine currentEngine] passWord]];
}

- (void)editDidFinishedWithName:(NSString *)name account:(NSString *)account {
    [self refreshServices];
}

- (void)refreshServices {
    if (_shop) {
        BSClient *clientService = [[BSClient alloc] initWithDelegate:self action:@selector(refreshDidFinish:obj:)];
        
        [clientService serviceListWithShopId:_shop.id];
    }
}

- (BOOL)refreshDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *array = [obj getArrayForKey:@"data"];
        
        if (array && array.count) {
            NSMutableArray *marr = [NSMutableArray array];
            
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ShopService *item = [ShopService objWithJsonDic:obj];
                [marr addObject:item];
            }];
            
            _shop.services = marr;
        }
        
        NSArray *newArray = [self preparServiceList];
        
        
        [contentArr removeObjectAtIndex:2];
        [contentArr insertObject:newArray atIndex:2];
        
        [tableView reloadData];
    }
    
    return YES;
}

- (void)cell:(UITableViewCell *)cell willSendDeleteAtIndexPath:(NSIndexPath *)indexPath {
    [self showAlert:@"是否要删除本条客服信息?" isNeedCancel:YES];

    __block ShopInfoViewController *blockSelf = self;
    
    [blockSelf setBlock:^(BOOL isDel){
        if (isDel) {
            [self deleteShopServiceAtIndexPath:indexPath];
        }
    }];
}

- (void)deleteShopServiceAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [contentArr objectAtIndex:indexPath.section];
    ShopService *service = [arrServices objectAtIndex:indexPath.row];
    
    if (service.id && service.id.integerValue > 0) {
        BSClient *delClient = [[BSClient alloc] initWithDelegate:self action:@selector(deleteDidFinish:obj:)];
        
        [delClient delServiceOfShopById:service.id];
    }
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray removeObjectAtIndex:indexPath.row];
    [arrServices removeObjectAtIndex:indexPath.row];
    [contentArr removeObjectAtIndex:indexPath.section];
    [contentArr insertObject:newArray atIndex:indexPath.section];
}

- (BOOL)deleteDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [tableView reloadData];
    }
    return YES;
}

#pragma mark - KWAlertViewDelegate

- (void)kwAlertView:(id)sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 1) {
        if (self.block) {
            self.block(YES);
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        return 44;
    }
    
    return 32;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return contentArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    
    if (section == 0) {
        height = 48;
    } else if (section == 1) {
        height = 48;
    } else if (section == 2) {
        height = 36;
    } else if (section == 3) {
        height = 36;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    NSString * button = nil;
    
    if (section == 0) {
        return [self headerViewWithTitle:@"基本信息"
                               andPrompt:@"一旦设定，不可自主修改，提交资料申请变更。"
                                  button:button
                               buttontag:0];
    } else if (section == 1) {
        if (_shop.bank.length < 4) {
            button = @"设置";
        }
        
        return [self headerViewWithTitle:@"银行信息"
                               andPrompt:@"一旦设定，不可自主修改，申请变更。"
                                  button:button
                               buttontag:1];
    } else if (section == 2) {
        button = @"添加";
        
        return [self headerViewWithTitle:@"客服信息"
                               andPrompt:nil
                                  button:button
                               buttontag:2];
    } else if (section == 3) {
        if (![[BSEngine currentEngine] user].hasShopPass) {
            button = @"设置";
        }
        
        return [self headerViewWithTitle:@"商城独立密码"
                               andPrompt:nil
                                  button:button
                               buttontag:3];
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = contentArr[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"OrderCustomerCell";
    
    if (!fileNib) {
        [tableView registerClass:OrderCustomerCell.class
          forCellReuseIdentifier:@"OrderCustomerCell"];
        fileNib = [UINib nibWithNibName:@"OrderCustomerCell" bundle:nil];
        [tableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
    }
    
    OrderCustomerCell *cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSArray *arr = [contentArr objectAtIndex:indexPath.section];
    
    [cell update:^(NSString *name) {
        cell.textHeight = cell.height;
    }];
    
    cell.data = [arr objectAtIndex:indexPath.row];
    cell.textFont = [UIFont systemFontOfSize:13];

    if (indexPath.section == 2) {
        [cell addDeleteButton];
        [cell autoShowButton:2];
        cell.delegate = self;
    }
    
    cell.superTableView= sender;
    cell.imageView.hidden = YES;
    cell.topLine = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        ShopPasswordViewController *con = [[ShopPasswordViewController alloc] init];
        con.password = @"hasPassowrd";
        [self pushViewController:con];
    }
}

@end
