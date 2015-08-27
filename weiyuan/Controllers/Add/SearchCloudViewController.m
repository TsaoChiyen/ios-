//
//  SearchCloudViewController.m
//  reSearchDemo
//
//  Created by Jinjin on 15/4/16.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "SearchCloudViewController.h"
#import "SubPlatCell.h"
#import "SubPlat.h"
#import "SessionDetailViewController.h"
#import "TalkingViewController.h"
#import "Session.h"
@interface SearchCloudViewController ()<UISearchBarDelegate>

@end

@implementation SearchCloudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"查找公众号";
    tableView.tableHeaderView = self.searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self startRequest];
    [client searchSubs:[[BSEngine currentUser] uid] andKey:searchBar.text];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.searchBar.text.length>0) {
        [self searchBarSearchButtonClicked:self.searchBar];
       
    }
    
}

#pragma mark - Request
- (BOOL)startRequest {
    return [super startRequest];
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *data = [obj getArrayForKey:@"data"];
        NSMutableArray *curContent = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            SubPlat * item = [SubPlat objWithJsonDic:dic];
            [curContent addObject:item];
        }
        // 索引排序
        contentArr = curContent;
        [tableView reloadData];
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
  
    return 1;
}



#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {

    if ([contentArr count] > 0 && section != 0) {
        return 20;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    if ([contentArr count] > 0 && section != 0) {
        UIImageView *bkgImageView = [[UIImageView alloc] init];
        bkgImageView.backgroundColor = [UIColor whiteColor];
        UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 120, 14)];
        tLabel.textColor=[UIColor blackColor];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.font = [UIFont systemFontOfSize:14];
        if (section == 1) {
            tLabel.text = @"星标朋友";
        } else {
            tLabel.text = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section-2];
        }
        [bkgImageView addSubview:tLabel];
        return bkgImageView;
    }
    
    if (section==0) {
        //        return self.searchBar;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return [contentArr count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)section {
    return @"相关公众账号";
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    SubPlatCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[SubPlatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    SubPlat * user = [contentArr objectAtIndex:indexPath.row];
    cell.withItem = user;
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
    
    cell.accessoryType = user.releation==1?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    if (user.releation==1) {
        //cell.accessoryType =  UITableViewCellAccessoryDetailDisclosureButton;
        cell.textLabel.textColor =[UIColor blueColor];
        cell.detailTextLabel.textColor =[UIColor blueColor];
    }
    else
    {
        cell.textLabel.textColor =[UIColor blackColor];
        cell.detailTextLabel.textColor =[UIColor blackColor];
        // cell.accessoryType =UITableViewCellAccessoryNone;
    }

    cell.bottomLine = NO;
    if (indexPath.row == [contentArr count] - 1) {
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
    SubPlat * plat = [contentArr objectAtIndex:indexPath.row];
    return plat.logo;
}

- (void)tableView:(id)sender didTapHeaderAtIndexPath:(NSIndexPath *)indexPath {
    SubPlat * plat = [contentArr objectAtIndex:indexPath.row];
     [self getCloudUserByID:plat.uid];
}

// 点击好友 查看好友信息/点击 系统图标跳到下一级目录
- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    SubPlat * plat = [contentArr objectAtIndex:indexPath.row];
    if (plat.releation==0) {
        //未关注 跳转到  测试
        SessionDetailViewController * tmpCon = [[SessionDetailViewController alloc] initWithNibName:nil bundle:nil];
        [tmpCon setSubPlat:plat];
        [self pushViewController:tmpCon];
    }else{
        //已经关注 进入回话
        Session * session = [Session getSessionWithID:plat.uid];
        if (!session) {
           // session = [Session sessionWithUser:[BSEngine currentUser]];
            session = [Session sessionWithSubPlat:plat];
        }
        TalkingViewController * con = [[TalkingViewController alloc] initWithSession:session];
        [self pushViewController:con];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.searchBar resignFirstResponder];
}
@end
