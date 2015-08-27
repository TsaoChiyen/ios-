//
//  SessionNewsDetailViewController.m
//  reSearchDemo
//
//  Created by helfy  on 15-4-17.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "SessionNewsDetailViewController.h"
#import "PhotoSeeViewController.h"
#import "JSON.h"
#import "Message.h"
#import "ReportViewController.h"
#import "SessionMenuView.h"
#import "SessionDetailViewController.h"
#import "SubPlat.h"
#import "SessionChangeFontView.h"
#import "GAWebViewController.h"

@interface SessionNewsDetailViewController ()
{
    UIWebView *textWebView;
    
    UIActivityIndicatorView *indicatorView;
    
    NSDictionary *newsDic;
}
@end

@implementation SessionNewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

 
    textWebView  = [UIWebView new];
    [self.view addSubview:textWebView];
    textWebView.backgroundColor = [UIColor clearColor];
    textWebView.scrollView.showsVerticalScrollIndicator = NO;
    textWebView.scrollView.showsHorizontalScrollIndicator = NO;
    textWebView.scrollView.backgroundColor = [UIColor clearColor];
    textWebView.scrollView.opaque = NO;
    textWebView.opaque = NO;
    textWebView.delegate = (id)self;
    [textWebView mas_makeConstraints:^(MASConstraintMaker *make) {
    
        UIView *topLayoutGuide = (id)self.topLayoutGuide;
        make.top.equalTo(topLayoutGuide.mas_bottom);
    
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
    }];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:indicatorView];
    [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(40);
    }];
    
}


- (void)getCloudUserByID:(NSString *)cloudId{
       if ([super startRequest]) {
           BSClient *cloudClient = [[BSClient alloc] initWithDelegate:self action:@selector(requestCloudDidFinish:obj:)];
           [cloudClient subsDetail:cloudId userId:[BSEngine currentUserId]];

       }
 
}

- (BOOL)requestCloudDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        if (dic.count > 0) {
            SubPlat *plat = [SubPlat objWithJsonDic:dic];
            //TODO ZYM  加载 需求"6"中的界面
            //            [self pushViewController:con];
            
            SessionDetailViewController *detail = [[SessionDetailViewController alloc] init];
            [detail setSubPlat:plat];
            [self pushViewController:detail];
        }
    }
    return YES;
}

-(void)filterValueChanged:(SEFilterControl *)control
{
    NSArray *size = @[@"14",@"16",@"18",@"20",@"22"];
    
    [textWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"doZoom(%@)",size[control.SelectedIndex]]];
    
}

-(void)showMenu{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"传播给朋友",@"云分享",@"收藏",@"复杂链接",@"查看云平台",@"在浏览器打开",@"调整字体",@"举报", nil];
//    [sheet showInView:self.view];
   
    SessionMenuView *meun = [[SessionMenuView alloc] init];
    [meun setItems:@[[SessionMenuItem sessionMenuItemFor:@"传播给朋友" iconFileName:@"图标---传播给朋友"],
                     [SessionMenuItem sessionMenuItemFor:@"云分享" iconFileName:@"图标---云分享"],
                     [SessionMenuItem sessionMenuItemFor:@"收藏" iconFileName:@"图标---收藏"],
                     [SessionMenuItem sessionMenuItemFor:@"复制链接" iconFileName:@"图标---复制链接"],
                     [SessionMenuItem sessionMenuItemFor:@"查看公众号" iconFileName:@"图标---查看平台号"],
                     [SessionMenuItem sessionMenuItemFor:@"浏览器打开" iconFileName:@"图标---在浏览器中打开"],
                     [SessionMenuItem sessionMenuItemFor:@"调整字体" iconFileName:@"图标---调整字体"],
                     [SessionMenuItem sessionMenuItemFor:@"举报" iconFileName:@"图标---举报"],
                     ]];
    
    [meun setChooseBlock:^(NSInteger index) {
        switch (index) {
            case 0://传播给朋友
            {
                
                Message *messagee =[[Message alloc] init];
                messagee.typefile = forFileText;
                messagee.content = [NSString stringWithFormat:@"%@，详见：%@",newsDic[@"title"],newsDic[@"url"]];
                [self forwordWithMsg:messagee];
            }
                break;
            case 1://云分享
            {
                
            
                PhotoSeeViewController * con = [[PhotoSeeViewController alloc] init];
             
                [self pushViewController:con];
                [con setShareText:[NSString stringWithFormat:@"%@，详见：%@",newsDic[@"title"],newsDic[@"url"]]];
            
            }
                break;
            case 2://收藏
            {
                if (!client) {
                    [self setLoading:YES content:@"收藏中"];
                    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestFavDidFinish:obj:)];
                    
                    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                    [dic setObject:newsDic[@"url"] forKey:@"content"];
                    [dic setObject:[NSString stringWithFormat:@"%d", forSingleNews]  forKey:@"typefile"];
                    [client addfavorite:newsDic[@"newsid"] otherid:nil content:[newsDic JSONString]];
                } else {
                    [self showText:@"网络繁忙，请等等吧"];
                }
            }
                break;
            case 3://复制
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = newsDic[@"url"];
                [self showText:@"已复制到剪切板"];
            }
                break;
            case 4://查看平台号
            {
                
                [self getCloudUserByID:newsDic[@"uid"]];

            }
                break;
            case 5://在浏览器中打开
            {
                GAWebViewController *web = [[GAWebViewController alloc] init];
                [web loadUrl:newsDic[@"url"]];
                [self pushViewController:web];
            }
                break;
            case 6://调整字体
            {
                
                SessionChangeFontView *changeFontView = [[SessionChangeFontView alloc] init];
                 [changeFontView.filterControl addTarget:self action:@selector(filterValueChanged:) forControlEvents:UIControlEventValueChanged];
                
                [changeFontView showInView:self.navigationController.view];
//                [textWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'"];
            }
                break;
            case 7://举报
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self reportAsk];
                });
                
            }
                break;
            default:
                break;
        }
    }];
    
    [meun showInView:self.navigationController.view];

}
-(void)setNewsDic:(NSDictionary *)news
{
    newsDic =news;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"..." style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"actionbar_more_icon"] forState:UIControlStateNormal];
    button.size = CGSizeMake(40, 40);
    [button addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

}

-(void)setTitle:(NSString *)title filePath:(NSString *)filePath
{
    [self view];
    
    self.title =title;
    [textWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    [indicatorView startAnimating];
}
-(void)setTitle:(NSString *)title url:(NSURL *)urlPath
{
    [self view];
    
    self.title =title;
    
    
    [textWebView loadRequest:[NSURLRequest requestWithURL:urlPath]];
    [indicatorView startAnimating];
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
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [indicatorView stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
}

/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.cancelButtonIndex == buttonIndex)return;
    switch (buttonIndex) {
        case 0://传播给朋友
        {
            
            Message *messagee =[[Message alloc] init];
            messagee.typefile = forSingleNews;
            messagee.content = newsDic[@"url"];
         
            messagee.typechat = forChatTypeServiceChat;
    
//            messagee.displayName = newsDic[@"title"];
//            messagee.displayImgUrl = newsDic[@"imgurl"];
            
            [self forwordWithMsg:messagee];
        }
            break;
        case 1://云分享
        {
//            img = [img resizeImageGreaterThan:1024];
            PhotoSeeViewController * con = [[PhotoSeeViewController alloc] init];
//            con.preImage = img;
            [self pushViewController:con];
        }
            break;
        case 2://收藏
        {
            if (!client) {
                [self setLoading:YES content:@"收藏中"];
                client = [[BSClient alloc] initWithDelegate:self action:@selector(requestFavDidFinish:obj:)];
                
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:newsDic[@"url"] forKey:@"content"];
                [dic setObject:[NSString stringWithFormat:@"%d", forSingleNews]  forKey:@"typefile"];
                [client addfavorite:newsDic[@"newsid"] otherid:nil content:[newsDic JSONString]];
            } else {
                [self showText:@"网络繁忙，请等等吧"];
            }
        }
            break;
        case 3://复制
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = newsDic[@"url"];
            [self showText:@"已复制到剪切板"];
        }
            break;
        case 4://查看平台号
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"云库号" message:newsDic[@"newsid"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                
                [alert show];
            });
        }
            break;
        case 5://在浏览器中打开
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newsDic[@"url"]]];
        }
            break;
        case 6://调整字体
        {
         [textWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'"];
        }
            break;
        case 7://举报
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reportAsk];
            });
            
        }
            break;
        default:
            break;
    }

    
}
*/

-(void)reportAsk
{
//    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"举报原因" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
//    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    UITextField *textFilde =( UITextField *) [dialog textFieldAtIndex:0];
//    textFilde.placeholder = @"请输入举报原因";
//    [dialog show];
    
    ReportViewController *report = [[ReportViewController alloc] initWithuid:newsDic[@"newsid"] ];
    [self.navigationController pushViewController:report animated:YES];
}

-(void)reportRequst:(NSString *)content
{
    
    if ([super startRequest]) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:[[BSEngine currentEngine] user].uid forKey:@"uid"];
        [dic setObject:content forKey:@"content"];
        [dic setObject:newsDic[@"newsid"] forKey:@"fid"];
        [client requestFor:dic methodName:@"/User/Api/jubaoSub"];
    }
}


- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
     
    }
    return NO;
}

/**收藏回调*/
- (BOOL)requestFavDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
    }
    return YES;
}
@end
