//
//  FinancingProductViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-24.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "FinancingProductViewController.h"
#import "FinancingProductDetailViewController.h"
#import "BaseTableViewCell.h"
#import "Financ.h"
#import "FinancGoods.h"
#import "User.h"
#import "Area.h"
#import "Globals.h"

@interface FinancingProductViewController ()

@end

@implementation FinancingProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    
    self.navigationItem.title = @"融资贷款服务产品管理";
    [self setRightBarButtonImage:LOADIMAGE(@"actionbar_add_icon") highlightedImage:nil selector:@selector(addProduct:)];

    self.tableViewCellHeight = 90;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)requestData {
    self.loading = YES;
    
    [super startRequest];
    User *user = [[BSEngine currentEngine] user];
    
    [client listGoodsOfFinacialWithShopId:user.financ.id];
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *array = [obj getArrayForKey:@"data"];
        
        [contentArr removeAllObjects];
        
        if (array && array.count) {
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                FinancGoods *item = [FinancGoods objWithJsonDic:obj];
                [contentArr addObject:item];
            }];
        }
        
        [tableView reloadData];
    }
    
    return YES;
}

- (UIButton *)buttonInView:(UIView*)view
                     title:(NSString *)title
                     frame:(CGRect)frame
                    action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btn borderStyle];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.frame = frame;
    [view addSubview:btn];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - Button Actions

- (void)addProduct:(UIButton*)sender {
    FinancingProductDetailViewController *con =
    [[FinancingProductDetailViewController alloc] init];
    [self pushViewController:con];
}

- (void)editProduct:(UIButton*)sender {
    FinancGoods *item = [contentArr objectAtIndex:sender.tag];
    
    if (item) {
        FinancingProductDetailViewController *con =
        [[FinancingProductDetailViewController alloc] init];
        
        if (con) {
            con.goods = item;
        }
        
        [self pushViewController:con];
    }
}

- (void)deleteProduct:(UIButton*)sender {
    [self showAlert:@"是否要删除本条融资产品?" isNeedCancel:YES];
    
    __block FinancingProductViewController *blockSelf = self;
    __block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    [blockSelf setBlock:^(BOOL isDel){
        if (isDel) {
            [self deleteProductAtIndexPath:indexPath];
        }
    }];
}

- (void)deleteProductAtIndexPath:(NSIndexPath *)indexPath {
    FinancGoods *item = [contentArr objectAtIndex:indexPath.row];
    
    if (item) {
        BSClient *deleteGoods = [[BSClient alloc] initWithDelegate:self action:@selector(deleteDidFinish:obj:)];
        [deleteGoods deleteGoodsOfFinacialWithGoodsId:item.id];
    }
}

- (BOOL)deleteDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
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

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return contentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*)[super tableView:sender cellForRowAtIndexPath:indexPath];
    FinancGoods * item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    
    [cell update:^(NSString *name) {
        cell.textLabel.height = cell.height * 0.4;
        cell.textLabel.width = cell.width - 80;
        cell.textLabel.left = 8;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        
        cell.detailTextLabel.height = cell.height * 0.3;
        cell.detailTextLabel.width = cell.width - 80;
        cell.detailTextLabel.top = cell.height * 0.4;
        cell.detailTextLabel.left = 8;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        
        cell.labOther.height = cell.height * 0.3;
        cell.labOther.width = cell.width - 80;
        cell.labOther.top = cell.height * 0.7;
        cell.labOther.left = 8;
        cell.labOther.font = [UIFont systemFontOfSize:12];
        cell.labOther.left = cell.textLabel.left;
        
        cell.imageView.hidden = YES;
    }];
    
    CGRect frame = CGRectMake(cell.width - 72, 8, 54, 32);
    UIButton *addButton = [self buttonInView:cell.contentView
                                    title:@"修改"
                                    frame:frame
                                   action:@selector(editProduct:)];
    addButton.tag = indexPath.row;

    frame = CGRectMake(cell.width - 72, 50, 54, 32);
    UIButton *deleteButton = [self buttonInView:cell.contentView
                                       title:@"删除"
                                       frame:frame
                                      action:@selector(deleteProduct:)];
    deleteButton.tag = indexPath.row;

    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", item.name, item.type];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"特征: %@", item.features];
    cell.labOther.text = [NSString stringWithFormat:@"需要材料: %@", item.material];
    
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FinancGoods *item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    
    if (item.headsmall && item.headsmall.length > 0) {
        [Globals imageDownload:^(UIImage * image) {
            if (image) {
                cell.imageView.image = image;
            }
        } url:item.headsmall];
    } else {
        cell.imageView.image = LOADIMAGE(@"defaultHeadImage");
    }
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
