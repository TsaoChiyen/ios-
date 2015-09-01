//
//  ViewController.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ViewController.h"
#import "BasicNavigationController.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "MenuView.h"
#import "Area.h"
#import "SupplementaryInformationViewController.h"
#import "CameraActionSheet.h"
#import "PhotoSeeViewController.h"
#import "UIImage+Resize.h"
#import "Contact.h"
#import "SessionViewController.h"
#import "SearchAllViewController.h"
#import "Message.h"
#import "XMPPManager.h"
#import "FindViewController.h"
#import "WapShop.h"
#import "TextEditController.h"
#import "ShopManagerViewController.h"
#import "ImageTouchView.h"
#import "TextInput.h"

@interface ViewController ()<UIGestureRecognizerDelegate, MenuViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageTouchViewDelegate> {
/*
 UIView  * actionBar;
 */
    UIButton *leftBtn;
}

@end

@implementation ViewController

- (id)init {
    if (self = [super init]) {
        // Custom initialization
        self.className = @[@"SessionViewController",
                           @"ServiceViewController",
                           @"FinanceViewController",
                           @"ShoppingCityViewController",
                           @"ExibitionViewController"];
        
        [self setMenuIconsArray:@[@"menu_msg.png",
                                  @"menu_found.png",
                                  @"menu_finance.png",
                                  @"menu_shop.png",
                                  @"menu_show.png"]
                    AddSelected:@[@"menu_msg_select.png",
                                  @"menu_found_select.png",
                                  @"menu_finance_d.png",
                                  @"menu_shop_select.png",
                                  @"menu_show_d.png"]];

        [self setNameArray:@[@" 消息",
                             @" 服务",
                             @" 财经",
                             @" 商城",
                             @" 展会"]];
       
       
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enablefilter = YES;
    
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    self.navigationItem.title = AppDisplayName;
    self.navigationItem.titleView = self.titleView;

    __block UIImage *headIcon = [Globals getImageUserHeadDefault];
    
    [Globals imageDownload:^(UIImage * image) {
        if (image) {
            headIcon = image;
        }

        leftBtn = [self setLeftBarButtonImage:headIcon
                                     selector:@selector(btnItemPressed:)];
    } url:[BSEngine currentUser].headsmall];


/*    // ACTIONBAR
    UIView * actionbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.navigationItem.titleView = actionbar;
    actionBar = actionbar;
    // left icon
    int i = 0;
    UIButton * btn = [self buttonInLeftbar:i++ actionbar:actionbar];
    [btn setImage:[Globals getImageUserHeadDefault] forState:UIControlStateNormal];

    [Globals imageDownload:^(UIImage * image) {
        if (image) {
            [btn setImage:image forState:UIControlStateNormal];
        }
    } url:[BSEngine currentUser].headsmall];
    
    UILabel * lab = [UILabel linesText:AppDisplayName font:[UIFont boldSystemFontOfSize:18] wid:100 lines:0 color:[UIColor whiteColor]];
    lab.origin = CGPointMake((actionbar.width - lab.width)/2 - 20, 10);
    [actionbar addSubview:lab];
    
    btn = [self buttonInActionbar:i++ actionbar:actionbar];
    [btn setImage:LOADIMAGE(@"actionbar_search_icon") forState:UIControlStateNormal];
    
    btn = [self buttonInActionbar:i++ actionbar:actionbar];
    [btn setImage:LOADIMAGE(@"actionbar_add_icon") forState:UIControlStateNormal];
    
    btn = [self buttonInActionbar:i++ actionbar:actionbar];
    [btn setImage:LOADIMAGE(@"actionbar_more_icon") forState:UIControlStateNormal];
  */
    [self requstArea];
}

- (void)individuationTitleView {
    [self.titleView addSubview:[self moreButton]];
    self.moreButton.left = self.titleView.width - 36;
    
    self.searchButton.image = LOADIMAGE(@"btn_search");
    self.searchButton.highlightedImage = LOADIMAGE(@"btn_search_d");
    self.searchButton.left = self.titleView.width - 108;
    self.searchView.width = 0;
    
    self.addButton.tag = @"add";
    self.addButton.image = LOADIMAGE(@"btn_add");
    self.addButton.left = self.titleView.width - 72;

    if (self.value) {
        self.addButton.userInteractionEnabled = NO;
    }
    
    self.addButton.alpha =
    self.searchButton.alpha = 1;
    [self updateTitleLabel];
}

- (void)updateTitleLabel {
    titlelab.text = [NSString stringWithFormat:@"%@ - 消息", AppDisplayName];
    CGRect rc = self.titleView.frame;
    rc.origin.x = 0;
    rc.size.width = self.view.width - 108;
    titlelab.frame = rc;
    titlelab.left = -10;
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /**标准情况下, 只要姓名存在即可以登录*/
    /*
    if ([[BSEngine currentUser] canLogin]) {
        // 登录后 刷新 actionbar 各栏上的数量标记
        NSString * str = [[BSEngine currentUser] readConfigWithKey:@"newNotifyCount"];
        if (str.intValue > 0) {
            [self setBadgeValueforPage:3 withContent:@"-1"];
        }
        str = [[BSEngine currentUser] readConfigWithKey:@"FriendsCircle"];
        if (str.intValue > 0) {
            [self setBadgeValueforPage:1 withContent:@"-1"];
        }
        str = [[BSEngine currentUser] readConfigWithKey:@"NewMeetMessage"];
        if (str.intValue > 0) {
            [self setBadgeValueforPage:1 withContent:@"-1"];
        }
    }*/
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self showLoginIfNeed]) {
        if (![[BSEngine currentUser] canLogin]) {
            // 完善基本信息
            SupplementaryInformationViewController * con = [[SupplementaryInformationViewController alloc] init];
            con.editType = forSupplementaryInfo;
            BasicNavigationController *subNav = [[BasicNavigationController alloc] initWithRootViewController:con];
            [self presentViewController:subNav animated:YES completion:nil];
        } else if (![[XMPPManager shareManager] exist]){
            /*
            if (![WapShop host]) {
                
            } else {
                [self autoLoginWeb];
            }
           */

            // 登录成功 启动通知监听 配置 声音震动
            User *user = [[BSEngine currentEngine] user];
            BOOL canplayVoice = [user readConfigWithKey:@"canplayVoice"].boolValue;
            BOOL canplayShake = [user readConfigWithKey:@"canplayShake"].boolValue;

            if (canplayVoice && canplayShake) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound| UIRemoteNotificationTypeAlert];
            } else if (canplayVoice && !canplayShake) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
            } else if (!canplayVoice && canplayShake) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert];
            } else if (canplayVoice) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
            } else {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge];
            }
                // 加载会话列表
            SessionViewController * tmpCon = [self.viewControllers objectAtIndex:0];
            [tmpCon loginSuccess];
                // 登录openfire
            [[AppDelegate instance] signIn];
            _timefromLastTime = [[NSDate date] timeIntervalSince1970];
            dispatch_async(kQueueDEFAULT, ^{
                [self checkNow];
            });
        } else {
            [[XMPPManager shareManager] connectAgain];
        }
    }
}

/*
- (UIButton*)buttonInActionbar:(int)number actionbar:(UIView*)actionbar{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = number;
    [btn setImage:LOADIMAGE(@"actionbar_add_icon") forState:UIControlStateNormal];
    btn.frame = CGRectMake(self.view.width - 44*(4-number), 6, 32, 32);
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIButton*)buttonInLeftbar:(int)number actionbar:(UIView*)actionbar{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = number;
    [btn setImage:LOADIMAGE(@"actionbar_add_icon") forState:UIControlStateNormal];
    btn.frame = CGRectMake(4, 6, 32, 32);
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
*/

#pragma mark - ImageTouchViewDelegate

- (void)imageTouchViewDidSelected:(ImageTouchView *)sender {
    NSString *tag = sender.tag;
    MenuView * menuView;

    if ([tag isEqualToString:@"more"]) {
        //  更多
        NSString * strShop = nil;
        User *user = [BSEngine currentUser];
        if (user.isshop) {
            strShop = @"商城管理";
        } else {
            strShop = @"申请入驻商城";
        }
        
        NSString * strExbi = nil;
        if (user.isexhi) {
            strExbi = @"展会管理";
        } else {
            strExbi = @"申请参加展会";
        }
        
        NSString * strComm = nil;
        if (user.iscomm) {
            strComm = @"公众号管理";
        } else {
            strComm = @"申请公众号";
        }
        
        menuView = [[MenuView alloc] initWithButtonTitles:@[strShop, strExbi, strComm] withDelegate:self];
        menuView.tag = 3;
    } else if ([tag isEqualToString:@"add"]) {
        if (self.searchView.width == 0) {
            // 添加
            menuView = [[MenuView alloc] initWithButtonTitles:@[@"发起群聊",@"添加朋友",@"扫一扫",@"拍照分享"] withDelegate:self];
            menuView.tag = 2;
        } else {
            self.searchField.text = @"";
            [self textFieldDidChange:self.searchField];
        }
    } else {
        if ([self getCurrentPageIndex] == 0) {
            SearchAllViewController * con = [[SearchAllViewController alloc] init];
            [self pushViewController:con];
        } else {
            if ([tag isEqualToString:@"none"]) {
                sender.tag = @"changed";
                [self showSearch];
            } else {
                sender.tag = @"none";
                [self hideSearch];
            }
        }
    }

    if (menuView) {
        if (sender.tag == 0) {
            [menuView showInView:self.view origin:CGPointMake(0, 0)];
        } else {
            [menuView showInView:self.view origin:CGPointMake(tableView.width - MENUVIEW_WIDTH, 0)];
        }
    }
}

- (void)showSearch {
    [UIView animateWithDuration:0.3 animations:^{
        self.searchView.width = self.view.width - 65;
        self.searchButton.left = self.searchView.left + 5;

        if (self.getCurrentPageIndex == 3) {
            self.addButton.alpha = 1;
        }
        
        self.addButton.left = self.titleView.width - 45;
        self.searchButton.image = LOADIMAGE(@"btn_search_d");
        self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
        self.searchView.alpha = 1;
        self.moreButton.alpha = 0;
        leftBtn.alpha = 0;
    } completion:^(BOOL finished) {
        self.addButton.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.15 animations:^{
            self.addButton.image = LOADIMAGE(@"btn_clear");
            self.addButton.highlightedImage = LOADIMAGE(@"btn_clear_d");
        } completion:^(BOOL finished) {
            [self.searchField becomeFirstResponder];
        }];
        
    }];
}

- (void)hideSearch {
    self.searchField.text = @"";
    [UIView animateWithDuration:0.3 animations:^{
        self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
        NSUInteger index = self.getCurrentPageIndex;

        if (index == 3) {
            self.searchButton.left = self.titleView.width - 72;
            self.addButton.alpha = 0;
        } else {
            self.searchButton.left = self.titleView.width - 108;
        }
        self.searchView.width = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.addButton.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:0.15 animations:^{
                self.addButton.left = self.titleView.width - 72;
                self.searchButton.image = LOADIMAGE(@"btn_search");
                self.addButton.image = LOADIMAGE(@"btn_add");
                self.addButton.highlightedImage = nil;
                self.moreButton.alpha = 1;
                leftBtn.alpha = 1;
            } completion:^(BOOL finished) {
                [self.searchField resignFirstResponder];
            }];
            
            [self textFieldDidChange:self.searchField];
        }
    }];
}

#pragma mark -

- (void)btnItemPressed:(UIButton*)sender {
    MenuView * menuView;
    switch (sender.tag) {
        case 0:
            // 用户
            menuView = [[MenuView alloc] initWithButtonTitles:@[[BSEngine currentUser].nickname,@"我的相册",@"我的收藏",@"设置",@"反馈意见"] withDelegate:self];
            menuView.tag = -1;
            break;
/*
        case 1:
            // 搜索
        {
            SearchAllViewController * con = [[SearchAllViewController alloc] init];
            [self pushViewController:con];
        }
            break;
        case 2:
            // 添加
            menuView = [[MenuView alloc] initWithButtonTitles:@[@"发起群聊",@"添加朋友",@"扫一扫",@"拍照分享"] withDelegate:self];
            menuView.tag = sender.tag;
            break;
        case 3:
        {
            //  更多
            NSString * strShop = nil;
            User *user = [BSEngine currentUser];
            if (user.isshop) {
                strShop = @"商城管理";
            } else {
                strShop = @"申请入驻商城";
            }

            NSString * strExbi = nil;
            if (user.isexhi) {
                strExbi = @"展会管理";
            } else {
                strExbi = @"申请参加展会";
            }
            
            NSString * strComm = nil;
            if (user.iscomm) {
                strComm = @"公众号管理";
            } else {
                strComm = @"申请公众号";
            }

            menuView = [[MenuView alloc] initWithButtonTitles:@[strShop, strExbi, strComm] withDelegate:self];
            menuView.tag = sender.tag;
        }
           
            break;
 */
            
        default:
            break;
    }
 
    if (menuView) {
        if (sender.tag == 0) {
            [menuView showInView:self.view origin:CGPointMake(0, 0)];
        } else {
            [menuView showInView:self.view origin:CGPointMake(tableView.width - MENUVIEW_WIDTH, 0)];
        }
    }
}

#pragma mark - TextEditControllerDelegate

- (void)textEditControllerDidEdit:(NSString*)text idx:(NSIndexPath*)idx {
    BSClient *verifyClient = [[BSClient alloc] initWithDelegate:self action:@selector(verifyDidFinish:obj:)];

    [verifyClient verifyShopPassword:text];
}

- (BOOL) verifyDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if (sender.hasError) {
            [self showAlert:sender.errorMessage isNeedCancel:NO];
        } else {
            UIViewController * tmpCon = [[NSClassFromString(@"ShopManagerViewController") alloc] init];
            [self pushViewController:tmpCon];
        }
    }
    return YES;
}

#pragma mark - 聊天相关

/**更新[新的朋友]的数量*/
- (void)setNewNotifyCount {
    NSString * str = [[BSEngine currentUser] readConfigWithKey:@"newNotifyCount"];
    if (!str) {
        str = @"1";
    } else {
        str = [NSString stringWithFormat:@"%d", str.intValue + 1];
    }
    [[[BSEngine currentEngine] user] saveConfigWhithKey:@"newNotifyCount" value:str];
    [self setBadgeValueforPage:3 withContent:@"-1"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSectionZero" object:nil];
}

/**更新总的未读聊天消息数*/
- (void)refreshNewChatMessage:(int)value {
    NSString *str = nil;
    if (value > 0) {
        str = [NSString stringWithFormat:@"%d", value];
    } else {
        str = nil;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = value;
    [self setBadgeValueforPage:0 withContent:str];
    
    DLog(@"更新总的未读消息数 : %d", value);
}

/**更新总的未读聊吧消息数*/
- (void)updateNewMeetMessage:(BOOL)hasNew {
    NSString *str = nil;
    User * user = [BSEngine currentUser];

    if (hasNew) {
        str = @"-1";
    } else {
        str = nil;
    }
    [user saveConfigWhithKey:@"NewMeetMessage" value:[NSString stringWithFormat:@"%d", hasNew]];
    
    [self setBadgeValueforPage:1 withContent:str];
//    
//    FindViewController * con = (FindViewController*)[self.viewControllers objectAtIndex:1];
//    [con receivedNewMeetMessage];
}

#pragma mark receivedMessage
/**Message Get: xmpp收到的消息会转发到此函数里进行处理*/
- (void)receivedMessage:(Message*)msg {
    if (msg.isSendByMe && msg.state == forMessageStateError) {
        // 本地存在的消息更新数据
        [msg updateId];
    } else {
        // 不存在的插入数据
        [msg insertDB];
    }
    if (msg.typechat == forChatTypeMeet) {
        [self updateNewMeetMessage:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMessage" object:msg];
}

#pragma mark message notify
/**重置新消息数量*/
- (void)reSetNewFriendAdd {
    [[[BSEngine currentEngine] user] saveConfigWhithKey:@"newNotifyCount" value:@"0"];
    [self setBadgeValueforPage:3 withContent:nil];
}

/**收到好友申请后，点亮相应的小红点*/
- (void)hasNewFriendAdd {
    [self setBadgeValueforPage:3 withContent:@"-1"];
}

#pragma mark cleanMessageWithSession
/**执行清除不必要的会话*/
- (void)cleanMessageWithSession:(id)item {
    SessionViewController * tmpCon = [self.viewControllers objectAtIndex:0];
    [tmpCon cleanMessageWithSession:item];
}

#pragma mark do Contact
/**保留接口 可以使用来处理收到移除好友的消息*/
- (void)doRemoveContact:(User *)item {
    DLog(@"doRemoveContact");
}

/**保留接口 可以使用来处理收到添加好友的消息*/
- (void)doAddContact:(User *)item {
    DLog(@"doAddContact");
}

- (void)pushViewController:(id)con fromIndex:(int)idx {
    BaseViewController * tmpCon = [self.viewControllers objectAtIndex:idx];
    [tmpCon pushViewController:con];
}

#pragma mark - MenuViewDelegate
- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString * str = nil;
    if (sender.tag == -1) {
        switch (buttonIndex) {
            case 0:                // 本人信息
                str = @"MySettingViewController";
                break;
            case 1:                // 相册
                str = @"FriendPhotosViewController";
                break;
            case 2:                // 收藏
                str = @"CollectionViewController";
                break;
            case 3:                // 设置
                str = @"SystemSettingViewController";
                break;
            case 4:                // 反馈
                str = @"FeedbackViewController";
                break;
            default:
                break;
        }
        
    } else if (sender.tag == 2) {
        switch (buttonIndex) {
            case 0:                // 发起群聊
                str = @"SessionNewController";
                break;
            case 1:                // 添加朋友
                str = @"FriendsAddViewController";
                break;
            case 2:                // 扫一扫
                str = @"QRcodeReaderViewController";
                break;
            case 3:                // 拍照分享
            {
                CameraActionSheet *actionSheet = [[CameraActionSheet alloc] initWithActionTitle:nil TextViews:nil CancelTitle:@"取消" withDelegate:self otherButtonTitles:@"从相册选择",  @"拍一张", nil];
                actionSheet.tag = -1;
                [actionSheet show];
            }
                break;
                
            default:
                break;
        }
    } else if (sender.tag == 3) {
        User *user = [BSEngine currentUser];

        switch (buttonIndex) {
            case 0:                // 申请入驻商城
                if (user.isshop) {
                    if (user.hasShopPass) {
                        TextEditController *con = [[TextEditController alloc] initWithDel:self
                                                                                     type:TextEditTypePassword
                                                                                    title:@"输入商铺的独立密码"
                                                                                    value:@""];
                        con.maxTextCount = 15;
                        con.minTextCount = 6;
                        [self pushViewController:con];
                    } else {
                        str = @"ShopManagerViewController";
                    }
                } else {
                    str = @"ApplyShopViewController";
                }
                break;
            case 1:                // 申请参加展会
                if ([[BSEngine currentUser] isexhi]) {
                } else {
                    str = @"ExbitionMainViewController";
                }
                break;
            case 2:                // 申请公众号
                if ([[BSEngine currentUser] iscomm]) {
                } else {
                    str = @"CloudListViewController";
                }
                break;
            default:
                break;
        }
    }
    
    if (str) {
        UIViewController * tmpCon = [[NSClassFromString(str) alloc] init];
        [self pushViewController:tmpCon];
    }
}

- (void)popoverViewCancel:(MenuView *)sender {

}

#pragma mark - CameraActionSheetDelegate

/**选择图片*/
- (void)cameraActionSheet:(CameraActionSheet *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;

    if (buttonIndex == 0){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            [self showText:@"无法打开相机"];
        }
    }
    [self presentModalController:picker animated:YES];
}

#pragma mark - ImagePickerDelegate

/**新建分享*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage * img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        img = [img resizeImageGreaterThan:1024];
        PhotoSeeViewController * con = [[PhotoSeeViewController alloc] init];
        con.preImage = img;
        [self pushViewController:con];
    }];
}

/**检测新的朋友*/
- (void)checkNow {
    if ([Contact canAccessBook]) {
        NSArray * arr = [Contact readABAddressBook];
        NSMutableString * str = [NSMutableString string];
        NSMutableArray * uploadArr = [NSMutableArray array];
        NSMutableArray * uploadPersonId = [NSMutableArray array];
        for (Contact *item in arr) {
            // 电话号码对比本地存储的数据库，筛选可以被上传的号码
            if ([Contact isInlastContacts:item.phone]||[Contact contactWithPhone:item.phone]) {
                continue;
            }
            if (str.length > 0) {
                [str appendString:@","];
            }
            [str appendFormat:@"%@",item.phone];
            [uploadArr addObject:item.phone];
            [uploadPersonId addObject:[NSString stringWithFormat:@"%d", item.personId]];
        }
        if (str.length > 0 ) {
            // 可以被上传的号码添加进数据库
            [Contact putInlastContacts:uploadArr];
            dispatch_async(kQueueMain, ^{
                BSClient * clientContact = [[BSClient alloc] initWithDelegate:self action:@selector(requestCheckNowDidFinish:obj:)];
                clientContact.tag = (id)uploadArr;
                clientContact.indexPath = (id)uploadPersonId;
                [clientContact newFriends:str];
            });
        }
    }
}

#pragma mark - Rrequest

- (BOOL)requestCheckNowDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if (!sender.hasError) {
        NSArray * arr = [obj getArrayForKey:@"data"];
        NSMutableArray * uploadArr = (id)sender.tag;
        NSMutableArray * uploadPersonId = (id)sender.indexPath;
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Contact * item = [Contact objWithJsonDic:obj];
            item.nickname = [obj getStringValueForKey:@"name" defaultValue:@""];
            [uploadArr enumerateObjectsUsingBlock:^(NSString * phone, NSUInteger idx, BOOL *stop) {
                if ([phone isEqualToString:item.phone]) {
                    *stop = YES;
                    item.personId = ((NSString*)uploadPersonId[idx]).intValue;
                }
            }];
            [item insertDB];
        }];
        if (arr.count > 0) {
            // 通知更新数据库和界面显示
            [[[BSEngine currentEngine] user] saveConfigWhithKey:@"newNotifyCount" value:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
            [self setBadgeValueforPage:3 withContent:@"-1"];
        }
    }
    
    sender = nil;
    return YES;
}

#pragma mark - Page Handle Funcion

/**页码发送改变后会调用这个函数*/
- (void)pageHasChanged {
    BaseTableViewController * tmpCon = [self.viewControllers objectAtIndex:self.getCurrentPageIndex];
    [tmpCon refreshDataListIfNeed];
    NSUInteger index = self.getCurrentPageIndex;
    
    titlelab.text = [NSString stringWithFormat:@"%@ - %@", AppDisplayName, [self.nameArray objectAtIndex:index]];
    
    if(index == 3) {
        [UIView animateWithDuration:0.15 animations:^{
            self.addButton.alpha = 0;
            self.searchButton.alpha = 1;
            self.searchButton.left = self.titleView.width - 72;
            titlelab.left = 0;
        } completion:^(BOOL finished) {
        }];
        
        if ([self.searchButton.tag isEqual:@"none"]) {
            [self hideSearch];
        } else {
            [self showSearch];
        }
    } else if (index == 0) {
        [UIView animateWithDuration:0.15 animations:^{
            self.addButton.alpha = 1;
            self.searchButton.alpha = 1;
            self.searchButton.left = self.titleView.width - 108;
            titlelab.left = -10;
        } completion:^(BOOL finished) {
        }];

        [self hideSearch];
    } else {
        [UIView animateWithDuration:0.15 animations:^{
            self.addButton.alpha = 0;
            self.searchButton.alpha = 0;
            titlelab.left = 0;
        } completion:^(BOOL finished) {
        }];

        [self hideSearch];
    }
}

/*
- (void)autoLoginWeb {
    NSString * str = [NSString stringWithFormat:@"%@?ctl=login&email=%@@weihui.com&pwd=%@&post_type=json", [WapShop home],[[BSEngine currentUser] phone], [[BSEngine currentEngine] passWord]];
    NSURL * loginUrl = [NSURL URLWithString:str];
    
//    [self setLoading:YES content:@"同步信息中"];
    NSURLRequest *request = [NSURLRequest requestWithURL:loginUrl
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:5];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData * data, NSError * error) {
                               if (data) {
                                   NSArray * arr = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
                                   
                                   NSHTTPCookie * cookie = [arr firstObject];
                                   NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                   [sharedHTTPCookieStorage setCookie:cookie];
                                   DLog(@"login cookie saved");
                                   
                                   dispatch_async(kQueueMain, ^{
                                       [self setLoading:NO];
                                   });
                               }
                           }];
}
*/

#pragma mark - Read Area Date
- (void)requstArea
{
    if (![Area isLocalized]) {
        BSClient * clientArea = [[BSClient alloc] initWithDelegate:self action:@selector(requestAreaDidFinish:obj:)];
        [clientArea getAreaList];
    }
}

- (BOOL)requestAreaDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *arr = [obj getArrayForKey:@"data"];
        
        if (arr) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Area *area = [Area objWithJsonDic:obj];
                
                if (area) {
                    [area insertDB];
                }
            }];
        }
    }

    return YES;
}

#pragma mark - searchFilter

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)sender {
    BaseTableViewController * tmpCon = [self.viewControllers objectAtIndex:self.getCurrentPageIndex];
    
    if (tmpCon.enablefilter) {
        [tmpCon searchBarShouldEndEditing:sender];
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sender {
    BaseTableViewController * tmpCon = [self.viewControllers objectAtIndex:self.getCurrentPageIndex];
    
    if (tmpCon.enablefilter) {
        [tmpCon searchBarCancelButtonClicked:sender];
    }
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	搜索时根据输入的字符过滤tableview
 *
 */
- (void)textFieldDidChange:(UITextField*)sender {
    BaseTableViewController * tmpCon = [self.viewControllers objectAtIndex:self.getCurrentPageIndex];
    
    if (tmpCon.enablefilter) {
        [tmpCon textFieldDidChange:sender];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    BaseTableViewController * tmpCon = [self.viewControllers objectAtIndex:self.getCurrentPageIndex];
    
    if (tmpCon.enablefilter) {
        [tmpCon filterContentForSearchText:searchText scope:scope];
    }
}

@end