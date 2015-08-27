//
//  NearbyViewController.m
//  weihui
//
//  Created by Kiwaro on 15/1/28.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NearbyViewController.h"
#import "LocationManager.h"
#import "UserCell.h"
#import "UIImage+FlatUI.h"
#import "UIButton+NSIndexPath.h"
#import "KWAlertView.h"
#import "MenuView.h"
@interface NearbyViewController ()<MenuViewDelegate> {
    NSString * gender;
}

@end

@implementation NearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"附近的人";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdateNotification) name:LocationUpdateNotification object:nil];
    gender = nil;
    [self setRightBarButton:@"筛选" selector:@selector(chooseSex)];
    [self enableSlimeRefresh];
    [self setEdgesNone];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        if ([[LocationManager sharedManager] located]) {
            Location loc = [[LocationManager sharedManager] coordinate];
            [super startRequest];
            [client nearbyUserWithlat:@(loc.lat).stringValue lng:@(loc.lng).stringValue gender:gender page:currentPage];
        }
    }
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    if ([[LocationManager sharedManager] located]) {
        Location loc;
        loc = [[LocationManager sharedManager] coordinate];
        [super startRequest];
        [client nearbyUserWithlat:@(loc.lat).stringValue lng:@(loc.lng).stringValue gender:gender page:page];
    } else {
        client = nil;
        self.loading = NO;
        [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.8];
    }
}

- (void)chooseSex {
    MenuView * menuView = [[MenuView alloc] initWithButtonTitles:@[@"全部", @"男", @"女"] withDelegate:self];
    [menuView showInView:self.view origin:CGPointMake(self.view.width - 180, 0)];
}

#pragma mark - MenuViewDelegate
- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        gender = nil;
    } else if (buttonIndex == 1) {
        gender = @"0";
    } else if (buttonIndex ==2) {
        gender = @"1";
    }
    if ([[LocationManager sharedManager] located]) {
        Location loc;
        isloadByslime = YES;
        currentPage = 1;
        loc = [[LocationManager sharedManager] coordinate];
        [super startRequest];
        [client nearbyUserWithlat:@(loc.lat).stringValue lng:@(loc.lng).stringValue gender:gender page:currentPage];
    }
}

- (void)popoverViewCancel:(MenuView *)sender {
}

- (void)locationUpdateNotification {
    if (client) {
        [client cancel];
        client = nil;
    }
    Location loc = [[LocationManager sharedManager] coordinate];
    [client nearbyUserWithlat:@(loc.lat).stringValue lng:@(loc.lng).stringValue gender:gender page:currentPage];
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray * data = [obj getArrayForKey:@"data"];
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            User * user = [User objWithJsonDic:obj];
            if (!user.isfriend) {
                [contentArr addObject:user];
            }
        }];
        [tableView reloadData];
    }
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"UserCell";
    UserCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
  
    UIButton * btn = VIEWWITHTAG(cell.contentView, 992);
    if (!cell) {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setlabTimeHide:YES];
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 992;
        [btn navStyle];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(254, 249, 233) cornerRadius:3] forState:UIControlStateHighlighted];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.frame = CGRectMake(sender.width - 100, (self.tableViewCellHeight- 30)/2, 60, 18);
        [cell.contentView addSubview:btn];
        [btn setTitle:@"打招呼" forState:UIControlStateNormal];
    }
    
    [btn addTarget:self action:@selector(opContact:) forControlEvents:UIControlEventTouchUpInside];
    btn.indexPath = indexPath;
    User * user = [contentArr objectAtIndex:indexPath.row];
    cell.withFriendItem = user;
    double dis = user.distance.doubleValue;
    if (dis>1000) {
        cell.labOther.text = [NSString stringWithFormat:@"%0.f公里", dis/1000];
    } else {
        cell.labOther.text = [NSString stringWithFormat:@"%0.f米", dis];
    }
    [cell update:^(NSString *name) {
        // 调整位置
        [cell autoAdjustText];
        CGSize size = [cell.textLabel.text sizeWithFont:cell.textLabel.font maxWidth:180 maxNumberLines:0];
        cell.textLabel.width = size.width;
        size = [cell.labOther.text sizeWithFont:cell.labOther.font maxWidth:80 maxNumberLines:0];
        cell.labOther.size = size;
        cell.labOther.right = cell.width - 5;
        btn.top = cell.labOther.top = cell.textLabel.top;
        btn.left = cell.textLabel.right + 5;
    }];
    
    cell.bottomLine = NO;
    if (indexPath.row == contentArr.count - 1) {
        cell.bottomLine = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    User * user = [contentArr objectAtIndex:indexPath.row];
    [self getUserByName:user.uid];
}
// 头像
- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath*)indexPath {
    User * user = [contentArr objectAtIndex:indexPath.row];
    return user.headsmall;
}

- (void)opContact:(UIButton*)sender {
    if (client) {
        return;
    }
    
    [KWAlertView showAlertFieldWithTitle:@"验证信息" delegate:self tag:(int)sender.indexPath.row];
}

#pragma mark - KWAlertViewDelegate
- (void)kwAlertView:(KWAlertView*)sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 1) {
        if (sender.field.text.hasValue && sender.field.text.length > 15) {
            [KWAlertView showAlertFieldWithTitle:@"验证信息" delegate:self tag:(int)sender.indexPath.row];
            [self showText:@"输入的申请信息长度在15个字以内!"];
            return;
        }
        User * user = [contentArr objectAtIndex:sender.tag];
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestaddContactDidFinish:obj:)];
        [client to_friend:user.uid content:sender.field.text];
    }
}

- (BOOL)requestaddContactDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
    }
    return YES;
}

@end
