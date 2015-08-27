//
//  DemandViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "DemandViewController.h"
#import "ImageTouchView.h"
#import "TextInput.h"
#import "BaseTableViewCell.h"
#import "LocationManager.h"
#import "Demand.h"
#import "Message.h"
#import "Globals.h"
#import "Session.h"
//#import "TalkingViewController.h"
#import "DemandPublishViewController.h"

@interface DemandViewController () <ImageTouchViewDelegate>
{
    Location currentLocation;
}

@end

@implementation DemandViewController

- (void)viewDidLoad {
    enablefilter = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    self.navigationItem.title = @"需求";
    self.navigationItem.titleView = self.titleView;
    self.tableViewCellHeight = 44;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshDataList];
    [self.view addKeyboardPanningWithActionHandler:nil];
}

- (void)refreshDataList {
    [super refreshDataList];
    //    if ([[LocationManager sharedManager] located]) {
    currentLocation = [[LocationManager sharedManager] coordinate];
    [super startRequest];
    [client getDemandWithPage:1
                       andKey:nil
                          lat:@(currentLocation.lat).stringValue
                          lng:@(currentLocation.lng).stringValue];
    //    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)individuationTitleView {
    self.addButton.tag = @"addTouchView";
    self.addButton.image = LOADIMAGE(@"btn_add");
    
    self.addButton.left = self.titleView.width - 35;

    if (self.value) {
        self.addButton.userInteractionEnabled = NO;
    }
    
    self.searchButton.image = LOADIMAGE(@"btn_search");
    self.searchButton.highlightedImage = LOADIMAGE(@"btn_search_d");
    self.searchButton.left = self.titleView.width - 75;
    
    self.searchView.width = 0;
    self.addButton.alpha = 1;
    self.searchButton.alpha = 1;
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    [client getDemandWithPage:page
                       andKey:nil
                          lat:@(currentLocation.lat).stringValue
                          lng:@(currentLocation.lng).stringValue];
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray* array = [obj objectForKey:@"data"];
        
        if (array && array.count > 0) {
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Demand * demand = [Demand objWithJsonDic:obj];
                
                if (demand) {
                    [contentArr addObject:demand];
                }
            }];
        }

        [tableView reloadData];
    }
    return YES;
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

#pragma mark - searchFilter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope
{
    for (Demand *it in contentArr) {
        if ([it.content rangeOfString:searchText].location <= it.content.length) {
            [filterArr addObject:it];
        }
    }
}

#pragma mark - navi menu selected

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"addTouchView"]) {
        if (self.searchView.width == 0) {
            id con = [[[NSClassFromString(@"DemandPublishViewController") class] alloc] init];
            
            if ([con isKindOfClass:[UIViewController class]]) {
                [self pushViewController:con];
            }
        } else {
            self.searchField.text = @"";
            [self textFieldDidChange:self.searchField];
        }
    } else {
        if ([sender.tag isEqualToString:@"none"]) {
            sender.tag = @"changed";
            
            [UIView animateWithDuration:0.3 animations:^{
                self.searchView.width = self.view.width - 65;
                self.searchButton.left = self.searchView.left + 5;
                self.addButton.left = self.titleView.width - 45;
                self.searchButton.image = LOADIMAGE(@"btn_search_d");
                self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
                self.searchView.alpha = 1;
            } completion:^(BOOL finished) {
                self.addButton.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:0.15 animations:^{
                    self.addButton.image = LOADIMAGE(@"btn_clear");
                    self.addButton.highlightedImage = LOADIMAGE(@"btn_clear_d");
                } completion:^(BOOL finished) {
                    [self.searchField becomeFirstResponder];
                }];
                
            }];
        } else {
            sender.tag = @"none";
            self.searchField.text = @"";
            [UIView animateWithDuration:0.3 animations:^{
                self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
                self.searchButton.left = self.titleView.width - 75;
                self.searchView.width = 0;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.addButton.transform = CGAffineTransformIdentity;
                    [UIView animateWithDuration:0.15 animations:^{
                        self.addButton.left = self.titleView.width - 35;
                        self.searchButton.image = LOADIMAGE(@"btn_search");
                        self.addButton.image = LOADIMAGE(@"btn_add");
                        self.addButton.highlightedImage = nil;
                    } completion:^(BOOL finished) {
                        [self.searchField resignFirstResponder];
                    }];
                }
            }];
        }
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*)[super tableView:sender cellForRowAtIndexPath:indexPath];
    Demand * demand = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];

    [cell update:^(NSString *name) {
        cell.textLabel.height = cell.height;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.width = cell.width - 72;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
        cell.detailTextLabel.frame = CGRectMake(cell.width - 60, 0, 60, cell.height);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
        cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    }];
    
    NSString *text;
    if (demand.content.length > 40) {
        text = [demand.content substringToIndex:40];
    } else {
        text = demand.content;
    }
    
    cell.textLabel.text = text;
    NSInteger km = demand.distance.integerValue / 1000;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"距离\n%d公里", km];
    cell.imageView.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    Demand * demand = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];

    if ([self.searchButton.tag isEqualToString: @"changed"]) {
        [self imageTouchViewDidSelected:self.searchButton];
        [self textFieldDidChange:self.searchField];
    }

    [self getUserByName:demand.uid];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    cell.imageView.image = [Globals getImageRoomHeadDefault];
//    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
//    [baseOperationQueue addOperation:opHeadItem];
//}
//
#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView*)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sender.width, 30)];
    if (sender == tableView) {
        if (contentArr.count > 0) {
            lab.text = [NSString stringWithFormat:@"%d项需求", (int)contentArr.count];
        }
    } else {
        lab.text = [NSString stringWithFormat:@"%d项需求", (int)filterArr.count];
    }
    
    lab.backgroundColor = sender.backgroundColor;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor lightGrayColor];
    return lab;
}

@end
