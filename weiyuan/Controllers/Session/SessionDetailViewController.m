//
//  DetailViewController.m
//  reSearchDemo
//
//  Created by helfy  on 15-4-16.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "SessionDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "Globals.h"
#import "CameraActionSheet.h"
#import "Message.h"
#import "Session.h"
#import "TalkingViewController.h"
#import "ReportViewController.h"
@interface SessionDetailViewController ()
{
    SubPlat *currentSubPlat;
}
@end

@implementation SessionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"actionbar_more_icon"] forState:UIControlStateNormal];
    button.size = CGSizeMake(40, 40);
    [button addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    [self.tableView setTableHeaderView:[self tableHeadView]];
    [self.tableView setTableFooterView:[self tableFooterView]];
    
}

-(void)showMenu
{
    if(currentSubPlat.releation)
    {
        CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"推荐给朋友", @"清空内容",@"举报",@"不再关注", nil];
        [actionSheet show];
    }
    else{
    CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"推荐给朋友", @"清空内容",@"举报",@"关注", nil];
        [actionSheet show];
    }
}

- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            
            Message *messagee =[[Message alloc] init];
            messagee.typefile = forSingleNews;
            messagee.content = currentSubPlat.comment;
            messagee.typechat = forChatTypeServiceChat;

            
            [self forwordWithMsg:messagee];
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reportAsk];
            });
        }
            break;
        case 3:
        {
            [self attentionRequst];
        }
            break;
        default:
            break;
    }
}


-(UIView *)tableHeadView
{
    UIView *headView = [[UIView alloc] init];
    headView.height= 80;
    UIImageView *userHeadImage = [[UIImageView alloc] init];
    userHeadImage.layer.masksToBounds = YES;
    userHeadImage.layer.cornerRadius = 30;
    [headView addSubview:userHeadImage];
  
    
    [userHeadImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(60);
        make.top.equalTo(10);
        make.left.equalTo(10);
    }];
    
    

    [userHeadImage sd_setImageWithURL:[NSURL URLWithString:currentSubPlat.logo] placeholderImage:[Globals getImageUserHeadDefault]];
    
    UILabel *nameLabel = [UILabel new];
    [headView addSubview:nameLabel];
    nameLabel.text = currentSubPlat.name;
   
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(20);
        make.height.equalTo(20);
        make.left.equalTo(userHeadImage.mas_right).offset(15);
        make.right.equalTo(10);
        
    }];
  
    UILabel *numberLabel = [UILabel new];
    [headView addSubview:numberLabel];
    numberLabel.text = [NSString stringWithFormat:@"公众号:%@",currentSubPlat.uid];
  
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(5);
        make.height.equalTo(20);
        make.left.equalTo(userHeadImage.mas_right).offset(15);
        make.right.equalTo(10);
        
    }];
   
    return headView;
}

-(UIView *)tableFooterView
{
    UIView *footerView = [[UIView alloc] init];
    footerView.height = 100;
    
    UIButton *button = [UIButton new];
    [footerView addSubview:button];
    button.backgroundColor = [UIColor colorWithRed:65/255.0 green:196/255.0 blue:229/255.0 alpha:1];
    if(currentSubPlat.releation)
    {
        [button setTitle:@"进入公众号" forState:UIControlStateNormal];
    }
    else{
        [button setTitle:@"关注" forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(releation) forControlEvents:UIControlEventTouchUpInside];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(5);
        make.left.equalTo(10);
        make.right.equalTo(-10);
        make.height.equalTo(40);
    }];
   
    
    UIButton *reportButton = [UIButton new];
    [footerView addSubview:reportButton];
    reportButton.backgroundColor = [UIColor grayColor];
    [reportButton addTarget:self action:@selector(reportAsk) forControlEvents:UIControlEventTouchUpInside];
    [reportButton setTitle:@"举报" forState:UIControlStateNormal];
    
    [reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button.mas_bottom).offset(10);
        make.left.equalTo(10);
        make.right.equalTo(-10);
        make.height.equalTo(40);
    }];
    
    
    return footerView;
}

-(int)getTextHeight:(NSString*)text andFont: (UIFont *)font andWidth:(float)width {
    CGSize constrain = CGSizeMake(width, 1000000);
    return [text boundingRectWithSize:constrain options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:Nil].size.height;
}
-(void)setupData
{
    self.cellObjs = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    YMParameterCellObj *obj = [[YMParameterCellObj alloc] initWithObjType:YMParameterCellObjTypeLabel];
   UILabel *label = (UILabel *)obj.accessoryView;
    obj.title = @"功能介绍";
    obj.value =currentSubPlat.info;
    obj.accessoryViewWidth = [[UIScreen mainScreen] bounds].size.width -140;
    
    obj.cellHeigth =[self getTextHeight: obj.value andFont:label.font andWidth:obj.accessoryViewWidth ];
    if(obj.cellHeigth <40)obj.cellHeigth =40;
    [array addObject:obj];
    
    obj = [[YMParameterCellObj alloc] initWithObjType:YMParameterCellObjTypeLabel];
    obj.accessoryViewWidth = [[UIScreen mainScreen] bounds].size.width -20;
    
     label = (UILabel *)obj.accessoryView;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor redColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dataStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[currentSubPlat.authend doubleValue]]];
   label.text = [NSString stringWithFormat:@"认证信息:%@\n认证期限为:%@\n认证资料:%@\n备注:%@",currentSubPlat.account,dataStr,currentSubPlat.authmaterial,currentSubPlat.comment];

    obj.cellHeigth =70;
    [array addObject:obj];
    
    [self.cellObjs addObject:array];
    array = [NSMutableArray array];
    obj = [[YMParameterCellObj alloc] initWithObjType:YMParameterCellObjTypeSwitch];
    obj.title = @"接受消息";
    obj.value = @"1";
    obj.accessoryViewWidth= 60;
    [array addObject:obj];
    [self.cellObjs addObject:array];

    array = [NSMutableArray array];
    obj = [[YMParameterCellObj alloc] initWithObjType:YMParameterCellObjTypeNone];
    obj.title = @"查看历史消息";
    obj.accessoryViewWidth= 60;
    obj.cellAction = @selector(pushToMessage);
    obj.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [array addObject:obj];
    
    [self.cellObjs addObject:array];
    
}

-(void)setSubPlat:(SubPlat *)subPlatObj
{
    currentSubPlat = subPlatObj;
    
    self.title = subPlatObj.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)keyboardWillShow:(NSNotification *)notification{
}

-(void)keyboardWillHide:(NSNotification *)notification{
    }
#pragma mark  UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if( alertView.tag  == 123)
    {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            
        if ([super startRequest]) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:[[BSEngine currentEngine] user].uid forKey:@"uid"];
            [dic setObject:[NSString stringWithFormat:@"%i",!currentSubPlat.releation] forKey:@"type"];
            [dic setObject:currentSubPlat.uid forKey:@"fid"];
            [client requestFor:dic methodName:@"/User/Api/followSub"];
        }
        }
    
    }
    else{
    if(buttonIndex != alertView.cancelButtonIndex)
    {
        UITextField *textFilde =( UITextField *) [alertView textFieldAtIndex:0];
        
        [self reportRequst:textFilde.text];
    }
    }
}

-(void)releation
{
    if(currentSubPlat.releation)
    {
        
        [self pushToMessage];
    }
    else{
        [self attentionRequst];
    }
}

-(void)pushToMessage
{ Session * session = [Session getSessionWithID:currentSubPlat.uid];
    if (!session) {
        //session = [Session sessionWithUser:[BSEngine currentUser]];
        session = [Session sessionWithSubPlat:currentSubPlat];
    }
    TalkingViewController * con = [[TalkingViewController alloc] initWithSession:session];
    [self pushViewController:con];
   
}

#pragma mark - Request

-(void)reportAsk
{
//    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"举报原因" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
//    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    UITextField *textFilde =( UITextField *) [dialog textFieldAtIndex:0];
//    textFilde.placeholder = @"请输入举报原因";
//    [dialog show];
    ReportViewController *report = [[ReportViewController alloc] initWithuid:currentSubPlat.uid];
    [self.navigationController pushViewController:report animated:YES];
}

-(void)reportRequst:(NSString *)content
{
    
    if ([super startRequest]) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[[BSEngine currentEngine] user].uid forKey:@"uid"];
        [dic setObject:content forKey:@"content"];
         [dic setObject:currentSubPlat.uid forKey:@"fid"];
        [client requestFor:dic methodName:@"/User/Api/jubaoSub"];
    }
}

-(void)attentionRequst
{
    
    if(currentSubPlat.releation)
    {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定对%@不再关注",currentSubPlat.name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.tag =123;
    [alert show];
    
    }else{
    
    if ([super startRequest]) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[[BSEngine currentEngine] user].uid forKey:@"uid"];
        [dic setObject:[NSString stringWithFormat:@"%i",!currentSubPlat.releation] forKey:@"type"];
        [dic setObject:currentSubPlat.uid forKey:@"fid"];
        [client requestFor:dic methodName:@"/User/Api/followSub"];
    }
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        currentSubPlat.releation = !currentSubPlat.releation;
        [self.tableView setTableFooterView:[self tableFooterView]];
//        [self.tableView reloadData];
        
    }
    return NO;
}


-(void)attention
{

}

@end
