//
//  FinanceCheckViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "FinanceCheckViewController.h"
#import "ImageTouchView.h"
#import "TextInput.h"
#import "BaseTableViewCell.h"
#import "Bill.h"
#import "Message.h"
#import "Globals.h"
#import "MenuView.h"
#import "AddRepaymentBillViewController.h"

@interface FinanceCheckViewController () <ImageTouchViewDelegate, MenuViewDelegate>

@end

@implementation FinanceCheckViewController

- (void)viewDidLoad {
    self.enablefilter = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    self.navigationItem.title = @"我的账单";
    self.navigationItem.titleView = self.titleView;
    self.tableViewCellHeight = 44;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.loading = YES;
    [contentArr removeAllObjects];
    [super startRequest];
    [client getBillListWithPage:1];
    
    [self.view addKeyboardPanningWithActionHandler:nil];
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

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray* array = [obj objectForKey:@"data"];
        
        if (array && array.count > 0) {
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Bill * bill = [Bill objWithJsonDic:obj];
                
                if (bill) {
                    [contentArr addObject:bill];
                }
            }];
        }
        
        [tableView reloadData];
    }
    return YES;
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    [client getBillListWithPage:page];
}

#pragma mark - searchFilter

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope
{
    for (Bill *it in contentArr) {
        if ([it.name rangeOfString:searchText].location <= it.name.length || [it.bank rangeOfString:searchText].location <= it.bank.length) {
            [filterArr addObject:it];
        }
    }
}

#pragma mark - navi menu selected

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"addTouchView"]) {
        if (self.searchView.width == 0) {
            MenuView *menuView = [[MenuView alloc] initWithButtonTitles:@[@"贷款还款提醒", @"信用卡还款提醒"] withDelegate:self];

            if (menuView) {
                [menuView showInView:self.view origin:CGPointMake(tableView.width - MENUVIEW_WIDTH, 0)];
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

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return inFilter?filterArr.count:contentArr.count;
//}
//
- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell * cell = (BaseTableViewCell*)[super tableView:sender cellForRowAtIndexPath:indexPath];
    Bill * bill = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    
    [cell update:^(NSString *name) {
        CGFloat width = cell.width - 20;
        CGFloat height = cell.height - 8;
        CGFloat top = 4;
        CGFloat left = 10;
        
        CGRect frame = CGRectMake(left, top, width * 0.6, height * 0.6);

        cell.textLabel.frame = frame;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        frame.origin.y = top + height * 0.6;
        frame.size.height = height * 0.4;
        
        cell.detailTextLabel.frame = frame;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        
        frame = CGRectMake(left + width * 0.6, top, width * 0.4, height);
        cell.labOther.frame = frame;
        cell.labOther.textAlignment = NSTextAlignmentRight;
        cell.labOther.font = [UIFont systemFontOfSize:17];
        cell.labOther.textColor = [UIColor orangeColor];
        
        cell.imageView.hidden = YES;
    }];

    if (bill.type.integerValue == 1) {
        cell.textLabel.text = bill.name;
    } else {
        cell.textLabel.text = bill.bank;
    }
    
    int date = bill.repayment.intValue;
    date = date % 31;
    if (date == 0) date = 31;

    cell.detailTextLabel.text = [NSString stringWithFormat:@"每月%d日提醒", date];
    
    if (bill.type.integerValue == 1) {
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"每月%@日提醒", bill.repayment];
        cell.labOther.text =  [NSString stringWithFormat:@"￥%0.2f", bill.price.floatValue];
    } else {
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 到期", [Globals convertDateFromString:bill.repayment timeType:4]];
        cell.labOther.text =  @"信用卡还款";
    }

    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AddRepaymentBillViewController *con = [[AddRepaymentBillViewController alloc] init];
    con.bill = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    [self pushViewController:con];

    [sender deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.searchButton.tag isEqualToString: @"changed"]) {
        [self imageTouchViewDidSelected:self.searchButton];
        [self textFieldDidChange:self.searchField];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageRoomHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    return 30;
}

- (UIView*)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sender.width, 30)];
    if (sender == tableView) {
        if (contentArr.count > 0) {
            lab.text = [NSString stringWithFormat:@"%d项账单", (int)contentArr.count];
        }
    } else {
        lab.text = [NSString stringWithFormat:@"%d项账单", (int)filterArr.count];
    }
    
    
    lab.backgroundColor = sender.backgroundColor;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor lightGrayColor];
    return lab;
}

#pragma mark - MenuViewDelegate

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    AddRepaymentBillViewController *con = [[AddRepaymentBillViewController alloc] init];
    con.billType = buttonIndex + 1;
    [self pushViewController:con];
}

- (void)popoverViewCancel:(MenuView *)sender {
    
}

@end
