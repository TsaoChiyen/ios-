//
//  FinancingViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-23.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "FinancingViewController.h"
#import "FinancingInfoViewController.h"
#import "FinancingProductViewController.h"
#import "BaseTableViewCell.h"
#import "ImageTouchView.h"
#import "KLocation.h"
#import "KLocatePickView.h"
#import "MapViewController.h"
#import "MenuView.h"
#import "Financ.h"
#import "FinancGoods.h"
#import "User.h"
#import "Area.h"
#import "Globals.h"
#import "LocationManager.h"

@interface FinancingViewController () < MapViewDelegate >
{
    NSArray *arrMore;
    Location currentLoc;
}

@end

@implementation FinancingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    
    self.navigationItem.title = @"融资贷款";
    [self setRightBarButtonImage:LOADIMAGE(@"actionbar_more_icon") highlightedImage:nil selector:@selector(chooseMore:)];

    UIView *headerView = self.headerBar;
    [self.view addSubview:headerView];
    tableView.top = headerView.height;
    tableView.height = self.view.height - tableView.top;
    self.tableViewCellHeight = 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isFirstAppear) {
        if ([[LocationManager sharedManager] located]) {
            currentLoc = [[LocationManager sharedManager] coordinate];
            BMKPoiInfo *bmkPoiInfo = [[BMKPoiInfo alloc] init];
            [bmkPoiInfo setPt:CLLocationCoordinate2DMake(currentLoc.lat, currentLoc.lng)];
            [self requestDataWithType:bmkPoiInfo];
        } else {
            [self requestDataWithType:nil];
        }
    }
}

- (void)requestDataWithType:(id)data {
    self.loading = YES;
    [super startRequest];

    if ([data isKindOfClass:[NSString class]]) {
        [client listGoodsOfFinacialShopOptionCityId:data
                                                lat:nil
                                                lng:nil];
    } else if ([data isKindOfClass:[BMKPoiInfo class]]) {
        BMKPoiInfo * bmkPoiInfo =(BMKPoiInfo *)data;
        [client listGoodsOfFinacialShopOptionCityId:nil
                                                lat:@(bmkPoiInfo.pt.latitude).stringValue
                                                lng:@(bmkPoiInfo.pt.longitude).stringValue];
    } else {
        [client listGoodsOfFinacialShopOptionCityId:nil
                                                lat:nil
                                                lng:nil];
    }
}

- (void)chooseMore:(id)sender
{
    User *user = [[BSEngine currentEngine] user];
    NSInteger status = user.isfinanc;
    int tag = 0;
    
    if (status == 0) {
        arrMore = @[@"申请入驻"];
    } else if (status == 2) {
        arrMore = @[@"审核中..."];
        tag = 1;
    } else {
        arrMore = @[@"基本信息管理", @"服务产品管理"];
        tag = 2;
    }
        
    if (arrMore && arrMore.count) {
        MenuView * menuView = [[MenuView alloc] initWithButtonTitles:arrMore
                                                        withDelegate:self];
        
        if (menuView) {
            menuView.tag = tag;
            [menuView showInView:self.view origin:CGPointMake(tableView.width - MENUVIEW_WIDTH, 0)];
        }
    }
}

- (UIView *)headerBar {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    view.backgroundColor = UIColorFromRGB(0xe0e0e0e0);

    CGRect frame = CGRectMake(10, 4, (self.view.width - 20) * 0.5, 36);
    UIButton *btn = [self buttonInView:view title:@"定位城市" frame:frame];
    [btn navStyle];
    btn.tag = -1;
    
    frame.origin.x = self.view.width * 0.5;
    btn = [self buttonInView:view title:@"选择城市" frame:frame];
    [btn navStyle];
    btn.tag = -2;

    return view;
}

- (UIButton *)buttonInView:(UIView*)view title:(NSString *)title frame:(CGRect)frame
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btn borderStyle];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.frame = frame;
    [view addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)btnItemPressed:(UIButton*)sender {
    int tag = sender.tag;

    if (tag < 0) {
        if (tag == -1) {
            MapViewController * con = [[MapViewController alloc] initWithDelegate:self];
                con.location = currentLoc;
            [self pushViewController:con];
        } else if (tag == -2) {
            KLocatePickView *locateView = [[KLocatePickView alloc] initWithTitle:@"选择城市" delegate:self];
            [locateView showInView:self.view];
        }
    } else {
        FinancGoods *item = [contentArr objectAtIndex:sender.tag];
        
        if (item) {
            BSClient *userRequst = [[BSClient alloc] initWithDelegate:self action:@selector(requestUserDidFinish:obj:)];
            
            [userRequst getUserInfoWithuid:item.uid];
        }
    }
}

#pragma mark - Callback For KLocatePickView

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        KLocatePickView *locateView = (KLocatePickView *)actionSheet;
        KLocation *location = locateView.locate;
        NSString *city = nil;
        
        if (location.city.hasValue) {
            city = location.city;
        } else {
            city = location.state;
        }

        [self requestDataWithType:city];
    }
}


- (BOOL)requestUserDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        if (dic.count > 0) {
            User *user = [User objWithJsonDic:dic];
            [user insertDB];
            [Globals talkToUser:user andUid:user.uid withController:self];
        }
    }
    
    return YES;
}

#pragma mark - MenuViewDelegate

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (sender.tag == 0) {  // 提出申请
        if (buttonIndex == 0) {
            FinancingInfoViewController *con = [[FinancingInfoViewController alloc] init];
            
            [self pushViewController:con];
        }
    } else if (sender.tag == 1) {   // 什么都不做
        
    } else {                //  管理商城
        if (buttonIndex == 0) {
            FinancingInfoViewController *con = [[FinancingInfoViewController alloc] init];
            User *user = [[BSEngine currentEngine] user];
            
            if (user.financ) {
                con.financ = user.financ;
            }
            
            [self pushViewController:con];
        } else {
            FinancingProductViewController *con = [[FinancingProductViewController alloc] init];
            [self pushViewController:con];
        }
    }
}

#pragma mark -

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

#pragma mark - 更新 地理位置
- (void)mapViewControllerSetPoiInfo:(BMKPoiInfo *)selectBMKPoiInfo {
    currentLoc.lat = selectBMKPoiInfo.pt.latitude;
    currentLoc.lng = selectBMKPoiInfo.pt.longitude;
    [self requestDataWithType:selectBMKPoiInfo];
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
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        
        cell.detailTextLabel.height = cell.height * 0.3;
        cell.detailTextLabel.width = cell.width - 80;
        cell.detailTextLabel.top = cell.height * 0.38;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        
        cell.labOther.height = cell.height * 0.3;
        cell.labOther.width = cell.width - 80;
        cell.labOther.top = cell.height * 0.64;
        cell.labOther.font = [UIFont systemFontOfSize:12];
        cell.labOther.left = cell.textLabel.left;
    }];
    
    CGRect frame = CGRectMake(cell.width - 72, 14, 54, 32);
    UIButton *button = [self buttonInView:cell.contentView
                                    title:@"咨询"
                                    frame:frame];
    button.tag = indexPath.row;
    
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
