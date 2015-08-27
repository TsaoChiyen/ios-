//
//  MySetting.m
//  weiyuan
//
//  Created by wjp on 15/3/19.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "MySettingViewController.h"
#import "BaseTableViewCell.h"
#import "AppDelegate.h"
#import "FriendPhotosViewController.h"
#import "Globals.h"
#import "BSEngine.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"
#import "ImageTouchView.h"
#import "UIImage+FlatUI.h"

@interface MySettingViewController ()
{

    ImageTouchView * imgview ;
    UIImageView * rightImageView;
    UILabel * signlab ;
    UILabel * namelab ;
}

@end

@implementation MySettingViewController

-(void)pageCurrent
{
    [super pageCurrent];
    User * user = [[BSEngine currentEngine] user];
    if(user)
    {
        [imgview sd_setImageWithUrlString:user.headsmall placeholderImage:[Globals getImageUserHeadDefault]];
        signlab.text=user.sign;
        //signlab.text=@"你先使用你先使用你先使用你先使用你先使用你先使用你先使用";
       namelab.text=user.nickname;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 76)];
    headerView.backgroundColor = [UIColor clearColor];
    imgview  = [[ImageTouchView alloc] initWithFrame:CGRectMake(216, 5, 64, 64)] ;
    imgview.image = [Globals getImageUserHeadDefault];
   
    //UIImageView *imgview=[[UIImageView alloc] initWithImage:image];
    [imgview setFrame:CGRectMake(8,8, headerView.height-8*2, headerView.height-8*2)];
    imgview.layer.masksToBounds = YES;
    imgview.layer.cornerRadius = 5;
    [headerView  addSubview:imgview];
    
    signlab = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, headerView.width-64-50-30, 20)];
    signlab.origin = CGPointMake(imgview.width+20, imgview.originY+5);
    signlab.font = [UIFont systemFontOfSize:12];
    signlab.text=@"";
    signlab.numberOfLines=0;
    signlab.textColor=[UIColor grayColor];
   // signlab.lineBreakMode = NSLineBreakByCharWrapping;
    [headerView  addSubview:signlab];
    
    self.navigationItem.title = @"我的承芯";
    
    namelab = [[UILabel alloc] initWithFrame:CGRectMake(10, 100,  headerView.width-64-50-30, 30)];
    namelab.origin = CGPointMake(imgview.width+20,  imgview.originY+signlab.height);
    namelab.text=@"";
    namelab.numberOfLines=0;
    namelab.textColor=[UIColor grayColor];
    namelab.minimumScaleFactor = 0.5;
    [headerView  addSubview:namelab];
    
    UIButton *addbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    addbutton.backgroundColor= [UIColor clearColor];

    [addbutton setImage:[UIImage imageNamed:@"findme.png"] forState:UIControlStateNormal];
    [addbutton setWidth:40];
    [addbutton setHeight:40];
    addbutton.origin=CGPointMake(headerView.width-addbutton.width-2-20, (headerView.height - addbutton.height)/2);
    [addbutton addTarget:self
                  action:@selector(editUserInfo:)
      forControlEvents:UIControlEventTouchUpInside
     ];
    [headerView  addSubview:addbutton];
    
    UIView * bkgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 15, 62)];
    bkgView.origin=CGPointMake(headerView.width-bkgView.width, (headerView.height - bkgView.height)/2);
    bkgView.backgroundColor = [UIColor clearColor];
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(bkgView.width - 10, 0, 8, bkgView.height);
    layer.contentsGravity = kCAGravityResizeAspect;
    layer.contents = (id)[UIImage imageNamed:@"arrow_right" isCache:YES].CGImage;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        layer.contentsScale = [[UIScreen mainScreen] scale];
    }
      [[bkgView layer] addSublayer:layer];
    
    [headerView  addSubview:bkgView];

    tableView.tableHeaderView = headerView;
    
}
-(void) editUserInfo:(UIButton*)sender
{
      Class class = NSClassFromString(@"SupplementaryInformationViewController");
    id tmpCon = [[class alloc] init];
    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        UIViewController* con = (UIViewController*)tmpCon;
        [self pushViewController:con];
    }
    
    

}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 2;
    }
   
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}



- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"tableCell";
    BaseTableViewCell* cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [cell setBottomLine:NO];
   if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.className = @"FriendsCircleViewController";
            cell.textLabel.text = @"相册";
             cell.imageView.image = LOADIMAGE(@"ico_my_pic");
           
        } else {
            cell.className = @"CollectionViewController";
            cell.textLabel.text = @"收藏";
                   }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
                    cell.textLabel.text = @"钱包";
        }
        else
        {
          
            cell.textLabel.text = @"卡包";
        }
    }
    else if (indexPath.section == 2) {
        
        cell.className = @"SystemSettingViewController";
        cell.textLabel.text = @"设置";
    }
    

    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
  if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.imageView.image = LOADIMAGE(@"ico_my_pic");
            
        } else {
             cell.imageView.image = LOADIMAGE(@"ico_my_shoucang");
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.imageView.image = LOADIMAGE(@"ico_my_money");
        }
        else
        {
             cell.imageView.image = LOADIMAGE(@"ico_my_card");
        }
    }
    else if (indexPath.section == 2) {
        
         cell.imageView.image = LOADIMAGE(@"ico_my_setting");    }
    
    
    
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [sender deselectRowAtIndexPath:indexPath animated:YES];
    
    
    BaseTableViewCell *cell = (BaseTableViewCell*)[sender cellForRowAtIndexPath:indexPath];
    Class class = NSClassFromString(cell.className);
  
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//相册
           
            User *user = [[BSEngine currentEngine] user];
            FriendPhotosViewController *con = [[FriendPhotosViewController alloc] initWithUser:user];
            [self pushViewController:con];
            return;
        }
      
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
          
            //cell.textLabel.text = @"钱包";
        }
        else
        {
           
           // cell.textLabel.text = @"卡包";
        }
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                      message:@"正在开发中....."
                                                     delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    id tmpCon = [[class alloc] init];
    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        UIViewController* con = (UIViewController*)tmpCon;
        [self pushViewController:con];
    }
    

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}


- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (BOOL)startRequest {
    return NO;
}
@end

