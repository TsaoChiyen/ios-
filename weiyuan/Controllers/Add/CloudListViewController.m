//
//  CloudListViewController.m
//  reSearchDemo
//
//  Created by Jinjin on 15/4/15.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "CloudListViewController.h"
#import "SubPlatCell.h"
#import "MenuView.h"
#import "SubPlat.h"
#import "SRRefreshView.h"
#import "SearchCloudViewController.h"
#import "TalkingViewController.h"
#import "Session.h"

@interface CloudListViewController ()<UISearchBarDelegate>
@property (nonatomic,assign) UIButton *showAddPlatBtn;
@property (nonatomic,strong) NSArray *searchArray;
@end

@implementation CloudListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self enableSlimeRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataList) name:@"refreshList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSectionZero) name:@"updateSectionZero" object:nil];
    
    self.navigationItem.titleView = nil;
    self.title = @"公众号";
    
    tableView.tableHeaderView = self.searchBar;
    
    NSArray *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"CloudPlatDatas"];
    NSMutableArray *curContent = [@[] mutableCopy];
    for (NSDictionary *dic in data) {
        SubPlat * item = [SubPlat objWithJsonDic:dic];
        [curContent addObject:item];
    }
    contentArr = curContent;
    [tableView reloadData];

    
    [self startRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.showAddPlatBtn removeFromSuperview];
    self.showAddPlatBtn = nil;
    
    UIButton * btn = [self buttonInActionbar:0 actionbar:nil];
    btn.frame = CGRectMake(SCREEN_WIDTH-44, 0, 44, 44);
    [btn setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    [btn addTarget:self action:@selector(showAddPlatView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:btn];
    self.showAddPlatBtn = btn;
}

- (void)viewDidAppear:(BOOL)animated
{
     [self startRequest];
    
}

- (void)viewWillDisappear:(BOOL)animated{
   
    [super viewWillAppear:animated];
    [self.showAddPlatBtn removeFromSuperview];
    self.showAddPlatBtn = nil;
   
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)showAddPlatView{
    UIViewController * tmpCon = [[NSClassFromString(@"SearchCloudViewController") alloc] init];
    [self pushViewController:tmpCon];
}


- (UIButton*)buttonInActionbar:(int)number actionbar:(UIView*)actionbar{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = number;
    [btn setImage:LOADIMAGE(@"actionbar_add_icon") forState:UIControlStateNormal];
    btn.frame = CGRectMake(self.view.width - 44*(3-number), 6, 32, 32);
    [actionbar addSubview:btn];
    return btn;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSMutableArray *curSearch = [@[] mutableCopy];
    for (SubPlat * plat in contentArr) {
        if ([[plat.name lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) {
            [curSearch addObject:plat];
        }
    }
    // 索引排序
    self.searchArray = curSearch;
    [tableView reloadData];
}


- (NSArray *)currentDataSource{
    return self.searchBar.text.length?self.searchArray:contentArr;
}

/**更新好友名字*/
- (void)updateName:(NSNotification*)sender {
    
}

#pragma mark - Request
- (BOOL)startRequest {
    if ([super startRequest]) {
        [self prepareLoadMoreWithPage:currentPage sinceID:sinceID];
        return YES;
    }
    return NO;
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *data = [obj getArrayForKey:@"data"];
        NSMutableArray *curContent = [@[] mutableCopy];
        
        NSMutableArray *newArray = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            SubPlat * item = [SubPlat objWithJsonDic:dic];
            [curContent addObject:item];
            
            //缓存云平台
            NSMutableDictionary *newDic = [@{} mutableCopy];
            for (id key  in [dic allKeys]) {
                id obj = [dic objectForKey:key];
                if (obj && obj!=[NSNull null]) {
                    [newDic setObject:obj forKey:key];
                }
            }
            [newArray addObject:newDic];
        }
        
        if (newArray) {
            [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"CloudPlatDatas"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        contentArr = curContent;
        [tableView reloadData];
    }
    return YES;
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sID {
    [client myFollowSubs:[[BSEngine currentUser] uid]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
   
    return 1;
}



#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}

- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
   
    return nil;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return [[self currentDataSource] count];
}


- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}

/**更新[新的朋友]的数量 如果这个视图被加载出来了*/
- (void) updateSectionZero {
    if ([self currentDataSource].count > 0) {
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    SubPlatCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[SubPlatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    SubPlatCell * plat = [[self currentDataSource] objectAtIndex:indexPath.row];
    cell.withItem = plat;
    [cell update:^(NSString *name) {
        // 调整位置
        [cell autoAdjustText];
        if (indexPath.section == 0) {
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
//            cell.textLabel.top = 0;
//            cell.textLabel.height = cell.height;
        }
    }];
    cell.superTableView = sender;
    
    
    cell.bottomLine = NO;
    if (indexPath.row == [[self currentDataSource] count] - 1) {
        cell.bottomLine = YES;
    }
    cell.newBadge = NO;
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:sender willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (int)baseTableView:(UITableView *)sender imageTagAtIndexPath:(NSIndexPath *)indexPath {
    return -1;
}

// 头像
- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    SubPlat * plat = [[self currentDataSource] objectAtIndex:indexPath.row];
    return plat.logo;
}

// 点击好友 查看好友信息/点击 系统图标跳到下一级目录
- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];

    SubPlat * plat = [[self currentDataSource] objectAtIndex:indexPath.row];
    Session * session = [Session getSessionWithID:plat.uid];
    if (!session) {
        session = [Session sessionWithSubPlat:plat];
    }
    TalkingViewController * con = [[TalkingViewController alloc] initWithSession:session];
    [self pushViewController:con];
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath *)indexPath {
    SubPlat * plat = [[self currentDataSource] objectAtIndex:indexPath.row];
    [self getCloudUserByID:plat.uid];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.searchBar resignFirstResponder];
    refreshControl.frame = CGRectMake(0, refreshControl.top, SCREEN_WIDTH, refreshControl.height);
    self.currectTableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//    refreshControl.frame = CGRectMake(0, refreshControl.top, SCREEN_WIDTH, refreshControl.height);
    self.currectTableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    refreshControl.frame = CGRectMake(0, refreshControl.top, SCREEN_WIDTH, refreshControl.height);
    self.currectTableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
}
@end
