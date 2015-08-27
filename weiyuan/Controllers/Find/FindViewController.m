//
//  FindViewController.m
//  ReSearch
//
//  Created by kiwi on 14-8-13.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "FindViewController.h"
#import "BaseTableViewCell.h"
#import "AppDelegate.h"
#import "WebViewController.h"
#import "WapShop.h"

@interface FindViewController ()

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFriendCircle:) name:@"receivedFriendCircle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFriendCircle:) name:@"resetFriendCircle" object:nil];
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    if (section == 4) {
        return 6;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"tableCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
       
    }
    [cell setBottomLine:NO];
    User * user = [BSEngine currentUser];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.className = @"FriendsCircleViewController";
            cell.textLabel.text = @"朋友圈";
            [cell setBadgeValue:[[user readValueWithKey:@"FriendsCircle"] intValue]];
        } else {
            cell.className = @"MeetingViewController";
            cell.textLabel.text = @"秘室";
            NSString * str = [user readValueWithKey:@"NewMeetMessage"];
            [cell setNewBadge:(str&&str.intValue > 0)];
        }
    } else if (indexPath.section == 1) {
        cell.className = @"NearbyViewController";
        cell.textLabel.text = @"附近的人";
    }
     else if (indexPath.section == 2) {
        
        cell.className = @"QRcodeReaderViewController";
        cell.textLabel.text = @"扫一扫";
    }
     else if (indexPath.section == 3) {
         cell.className = @"ShakeViewController";
         cell.textLabel.text = @"摇一摇";
     }
    
     else if (indexPath.section == 4) {
      if (indexPath.row == 0) {
         cell.textLabel.text = @"微购物";
      }
         else if (indexPath.row == 1) {
             cell.textLabel.text = @"商家";
         }
         else if (indexPath.row == 2) {
             cell.textLabel.text = @"优惠";
         }
        else if (indexPath.row == 3) {
             cell.textLabel.text = @"团购";
         }
        else if (indexPath.row == 4) {
             cell.textLabel.text = @"活动";
         }
        else if (indexPath.row == 5) {
             cell.textLabel.text = @"游乐场";
         }
     }
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
           
            //@"朋友圈";
            cell.imageView.image = LOADIMAGE(@"find_frends");
            
        } else {
           
           //@"会议";
             cell.imageView.image = LOADIMAGE(@"find_meet");
           
        }
    } else if (indexPath.section == 1) {
       
       // @"附近的人";
         cell.imageView.image = LOADIMAGE(@"find_near");
    }
    else if (indexPath.section == 2) {
         cell.imageView.image = LOADIMAGE(@"发现扫一扫");
              // @"扫一扫";
    }
    else if (indexPath.section == 3) {
        cell.imageView.image = LOADIMAGE(@"摇一摇");
        // @"扫一扫";
    }
    
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
           // @"微购物";
             cell.imageView.image = LOADIMAGE(@"find_weibuy");
        }
        else if (indexPath.row == 1) {
            // @"商家";
             cell.imageView.image = LOADIMAGE(@"find_seller");
        }
        else if (indexPath.row == 2) {
            // @"优惠";
             cell.imageView.image = LOADIMAGE(@"find_off");
        }
        else if (indexPath.row == 3) {
            //@"团购";
            cell.imageView.image = LOADIMAGE(@"find_buys");

            
        }
        else if (indexPath.row == 4) {
            // @"活动";
             cell.imageView.image = LOADIMAGE(@"find_active");
        }
        else if (indexPath.row == 5) {
            // @"游戏";
             cell.imageView.image = LOADIMAGE(@"find_game");
        }
    }
    /*
    return;
    if(indexPath.section == 2) {
        cell.imageView.image = LOADIMAGE(@"发现扫一扫");
    }
    else if (indexPath.section == 3) {
         cell.imageView.image = LOADIMAGE(@"发现扫一扫");
    }
    else {
        cell.imageView.image = LOADIMAGE(cell.textLabel.text);
    }
   */
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    BaseTableViewCell *cell = (BaseTableViewCell*)[sender cellForRowAtIndexPath:indexPath];
    Class class = NSClassFromString(cell.className);
    if ([cell.className isEqualToString:@"FriendsCircleViewController"]) {
        [self resetFriendCircle:nil];
    } else {
        [self resetNewMeetMessage];
    }
    if (indexPath.section == 4) {
        
        if (indexPath.row == 0) {
            // @"微购物";
            // 商城
            WebViewController * con = [[WebViewController alloc] init];
            con.url = [WapShop goodslist];
            NSLog(@"%@",con.url);
            [self pushViewController:con];
        }
        else if (indexPath.row == 1) {
            // 商家;
            WebViewController * con = [[WebViewController alloc] init];
            con.url = [WapShop merchantlist];
            [self pushViewController:con];
        }
        else if (indexPath.row == 2) {
            // 优惠;
            WebViewController * con = [[WebViewController alloc] init];
            con.url = [WapShop youhuilist];
            [self pushViewController:con];
        }
        else if (indexPath.row == 3) {
            // 团购
            WebViewController * con = [[WebViewController alloc] init];
            con.url = [WapShop tuanlist];
            [self pushViewController:con];
        }
        else if (indexPath.row == 4) {
            
            // 活动
            WebViewController * con = [[WebViewController alloc] init];
            con.url = [WapShop eventlist];
            [self pushViewController:con];
        }
        else if (indexPath.row == 5) {
            // @"游戏";
            WebViewController * con = [[WebViewController alloc] init];
            con.url = [WapShop game];
            [self pushViewController:con];
        }
        return;
    }

    
    id tmpCon = [[class alloc] init];
    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        UIViewController* con = (UIViewController*)tmpCon;
        [self pushViewController:con];
    }
}



- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Requests
- (BOOL)startRequest {
    return NO;
}

/**重置朋友圈消息数（小红点）*/
- (void)resetFriendCircle:(NSNotification*)sender {
    User * user = [BSEngine currentUser];
    [user saveConfigWhithKey:@"FriendsCircle" value:[NSString stringWithFormat:@"%d", 0]];
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [[AppDelegate instance] setBadgeValueforPage:1 withContent:@"0"];
}

/**重置会议消息数（小红点）*/
- (void)resetNewMeetMessage {
    User * user = [BSEngine currentUser];
    [user saveConfigWhithKey:@"NewMeetMessage" value:[NSString stringWithFormat:@"%d", 0]];
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [[AppDelegate instance] setBadgeValueforPage:1 withContent:@"0"];
}

#pragma mark - 赞或评论的通知
- (void)receivedFriendCircle:(NSNotification*)sender {
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 会议消息的通知
- (void)receivedNewMeetMessage {
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
@end
