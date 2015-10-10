//
//  GoodDetailViewController.m
//  BluetoothBus
//
//  Created by Kiwaro on 14-12-23.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import "GoodDetailViewController.h"
#import "ImagePlayerView.h"
#import "picture.h"
#import "Shop.h"
#import "Globals.h"
#import "UIImageView+WebCache.h"
#import "ImageViewController.h"
#import "AddCommentViewController.h"
#import "Comment.h"
#import "Star.h"
#import "ShopGoodsViewController.h"
//#import "TalkingViewController.h"
#import "Session.h"
#import "ShopCommentViewController.h"
#import "ImageTouchView.h"
#import "ShoppingCart.h"
#import "ShoppingCartViewController.h"
#import "UserInfoViewController.h"
#import "JSBadgeView.h"

@interface GoodDetailViewController ()<ImagePlayerViewDelegate, UIWebViewDelegate, UIScrollViewDelegate, AddCommentDelegate, ImageTouchViewDelegate> {
    ImagePlayerView * bannerView;
    IBOutlet UILabel * nameLabel;
    IBOutlet UILabel * placeLabel;
    IBOutlet UIScrollView * scrollView;
    UIActivityIndicatorView *activityIndicator;
    UIActivityIndicatorView *activityIndicatorweb;
    IBOutlet UIView * viewSection0;
    IBOutlet UIView * viewSection1;
    IBOutlet UIView * viewSection2;
    IBOutlet UIView * viewTool;
    IBOutlet UIButton * buttonCall;
    IBOutlet UIButton * buttonShop;
    IBOutlet UIWebView * webView0;
    
    IBOutlet UIButton * buttonFav;
    IBOutlet UIButton * buttonAdd;
    IBOutlet UIView   * viewtip;
    IBOutlet UIView   * labeltip;
    
//    IBOutlet UIView     * view1inViewSection1;
//    IBOutlet UIButton   * buttonLookComment;
//    IBOutlet UILabel    * commentCountLabel;
//    
    IBOutlet UIButton   * buttonInfo;
    IBOutlet UIButton   * buttonCanshu;
    
//    IBOutlet UILabel    * commentName;
//    IBOutlet UILabel    * commentContent;
//    IBOutlet UILabel    * commentTime;
//    IBOutlet Star       * commentStar;
//    IBOutlet UIImageView    * commentHeaderView;
    Comment             * commentNew;
    JSBadgeView         * jSBadgeView;
}

@end

@implementation GoodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    [buttonCall borderStyle];
    [buttonShop borderStyle];
    self.navigationItem.title = @"商品详细";

    nameLabel.text = _goods.name;
    placeLabel.text =  [NSString stringWithFormat:@"￥%@", _goods.price];

    buttonFav.backgroundColor = RGBCOLOR(255,181,57);
    buttonAdd.backgroundColor = RGBCOLOR(255,129,57);
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:viewSection0.center];
    activityIndicator.color = kbColor;
    activityIndicator.left = (Main_Screen_Width - 32)/2;
    [viewSection0 addSubview:activityIndicator];
    
    
    [activityIndicator startAnimating];
    
    [webView0 removeFromSuperview];
    webView0.alpha = 0;
    webView0.scrollView.delegate = self;
    //
    [self setRightBarButtonImage:LOADIMAGE(@"商品加入购物车") highlightedImage:nil selector:@selector(shoppingCart)];
    jSBadgeView = [[JSBadgeView alloc] initWithParentView:btnRight alignment:JSBadgeViewAlignmentTopRight];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        webView0.frame = CGRectMake(0, 40, self.view.width, self.view.height - 40 - viewTool.height);
        
        labeltip.left = (self.view.width - labeltip.width)/2;
        viewTool.top = self.view.height - viewTool.height;
        
        scrollView.height = self.view.height - viewtip.height;
        scrollView.contentSize = CGSizeMake(0, viewtip.bottom + 1);
        
        bannerView = [[ImagePlayerView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, 200)];
        [viewSection0 addSubview:bannerView];
        bannerView.imagePlayerViewDelegate = self;
        bannerView.alpha = 0;
        [bannerView reloadData];
        
        activityIndicatorweb = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((App_Frame_Width - 32)/2, APP_Frame_Height/3, 32.0f, 32.0f)];
        activityIndicator.left = (Main_Screen_Width - 32)/2;
        activityIndicatorweb.color = kbColor;
        [webView0 addSubview:activityIndicatorweb];
        
    }
    jSBadgeView.badgeText = @([ShoppingCart goodsCount]).stringValue;
    [buttonFav setTitle:_goods.isfavorite.boolValue?@" 取消收藏":@" 收藏" forState:UIControlStateNormal];
//    buttonLookComment.hidden =
//    view1inViewSection1.hidden = _goods.commentcount.intValue == 0;
//    commentCountLabel.text = [NSString stringWithFormat:@"(%@)", _goods.commentcount];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [super startRequest];
        [client getShopDetail:_goods.id];
        
        //        [client commentList:_goods.id];
        [UIView animateWithDuration:0.25 animations:^{
            bannerView.alpha = 1;
        } completion:^(BOOL finished) {
            [activityIndicator stopAnimating];
        }];
    }
}

- (void)shoppingCart {
    [self pushViewController:[[ShoppingCartViewController alloc] init]];
}

- (BOOL)requestUserByNameDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *dic = [obj getDictionaryForKey:@"data"];
        if (dic.count > 0) {
            User *user = [User objWithJsonDic:dic];
            [user insertDB];
            UserInfoViewController *con = [[UserInfoViewController alloc] init];
            [con setUser:user];
            [self pushViewController:con];
        }
    }
    return YES;
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if ([sender.tag isEqualToString: @"favorite"]) {
            _goods.isfavorite = @(!_goods.isfavorite.boolValue).stringValue;
            [self showText:sender.errorMessage];
            [buttonFav setTitle:_goods.isfavorite.boolValue?@" 取消收藏":@" 收藏" forState:UIControlStateNormal];
            return YES;
        }
        NSDictionary * dic = [obj getDictionaryForKey:@"data"];
        Good * it = [Good objWithJsonDic:dic];
        NSDictionary * comment = [dic getDictionaryForKey:@"comment"];
        [self.goods copyfrom:it];
        if (comment.count>0) {
            commentNew = [Comment objWithJsonDic:comment];
//            buttonLookComment.hidden =
//            view1inViewSection1.hidden = NO;
//            commentContent.text = commentNew.content;
//            commentName.text = commentNew.user.nickname;
//            commentStar.show_star = commentNew.star.integerValue;
//            commentTime.text = [Globals timeStringForListWith:commentNew.createtime.doubleValue];
//            [commentHeaderView sd_setImageWithUrlString:commentNew.user.headsmall placeholderImage:LOADIMAGE(@"默认头像")];
        }
    }
    return YES;
}

- (IBAction)buttonViewSection2:(UIButton*)sender {
    buttonInfo.selected =
    buttonCanshu.selected = NO;
    [webView0 stopLoading];
    if (sender == buttonInfo) {
        buttonInfo.selected = YES;
        
        [webView0 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_goods.content]]];
    } else {
        buttonCanshu.selected = YES;
        [webView0 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_goods.parameter]]];
    }
}

- (IBAction)buttonViewSection0:(UIButton*)sender {
    
    if (sender == buttonCall) {
        [Globals talkToUser:_shop.user
                     andUid:_shop.uid
             withController:self];
    } else {
        ShopGoodsViewController * con = [[ShopGoodsViewController alloc] init];
        con.shop = _shop;
        [self pushViewController:con];
    }
}

- (IBAction)buttonViewTool:(UIButton*)sender {
    if (sender == buttonFav) {
        [super startRequest];
        [client favorite:_goods.id action:@(!_goods.isfavorite.boolValue).stringValue];
        client.tag = @"favorite";
    } else {
        // 加入购物车
        ShoppingCart * cart = [ShoppingCart goodsFromeDB:_goods.id shopid:_shop.id];
        if (!cart) {
            cart = [[ShoppingCart alloc] init];
            cart.goodid = _goods.id;
            cart.shopid = _shop.id;
            cart.goodCount = @"1";
            [cart insertDB];
        } else {
            int d = cart.goodCount.intValue;
            d++;
            cart.goodCount = @(d).stringValue;
            [cart updateVaule:cart.goodCount key:@"goodCount"];
        }
        [self showText:@"加入成功！"];
        jSBadgeView.badgeText = @([ShoppingCart goodsCount]).stringValue;
    }
}

- (IBAction)buttonComment {
    AddCommentViewController * con = [[AddCommentViewController alloc] init];
    con.goods = _goods;
    con.delegate = self;
    [self pushViewController:con];
}

- (IBAction)moreComments:(id)sender {
    ShopCommentViewController * con = [[ShopCommentViewController alloc] init];
    con.goods = _goods;
    con.shop = _shop;
    [self pushViewController:con];
}

- (void)AddCommentAction:(NSString *)newCount newComment:(Comment*)newComment star:(NSString *)star {
    
    _goods.commentcount = newCount;
    _goods.star = star;
    commentNew = newComment;
    
//    commentCountLabel.text = [NSString stringWithFormat:@"(%@)", _goods.commentcount];
//    buttonLookComment.hidden =
//    view1inViewSection1.hidden = NO;
//    commentContent.text = commentNew.content;
//    commentName.text = commentNew.user.nickname;
//    commentStar.show_star = commentNew.star.integerValue;
//    commentTime.text = [Globals timeStringForListWith:commentNew.createtime.doubleValue];
//    [commentHeaderView sd_setImageWithUrlString:commentNew.user.headsmall placeholderImage:LOADIMAGE(@"默认头像")];
}

- (void)imageTouchViewDidSelected:(id)sender {
    [self getUserByName:commentNew.user.uid];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据name搜索详细资料
 *
 */
- (void)getUserByName:(NSString *)name {
    if (client) {
        return;
    }
    if (needToLoad) {
        self.loading = YES;
    }
    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestUserByNameDidFinish:obj:)];
    [client getUserInfoWithuid:name];
}

#pragma mark - BannerViewDelegate

- (NSInteger)numberOfItemsInPlayerView:(ImagePlayerView *)sender {
    return self.goods.picture.count;
}

- (void)imagePlayerView:(ImagePlayerView *)sender loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index {
    NSString *url = [self.goods.picture objectAtIndex:index];
    picture *item = [self.goods.picture objectAtIndex:index];
//    url = item.smallUrl;
    url = item.originUrl;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[Globals getImageDefault]];
}

- (void)imagePlayerView:(ImagePlayerView *)sender didTapAtIndex:(NSInteger)index {

    picture *item = [self.goods.picture objectAtIndex:index];
    CGRect frameStart = [scrollView convertRect:sender.frame toView:self.navigationController.view];
    ImageViewController * con = [[ImageViewController alloc] initWithFrameStart:frameStart supView:self.navigationController.view pic:item.originUrl preview:(id)item.smallUrl];
    con.bkgImage = [self.view screenshot];
    [self presentModalController:con animated:NO];

}

#define  REFRESH_REGION_HEIGHT 55.0f
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [activityIndicatorweb startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [activityIndicatorweb stopAnimating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)sender willDecelerate:(BOOL)decelerate {
    if (sender == scrollView) {
        if (sender.contentOffset.y+(sender.frame.size.height) > sender.contentSize.height+REFRESH_REGION_HEIGHT)  {
            CGFloat offset = sender.contentOffset.y;
            if (offset>0) {
                scrollView.scrollEnabled = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.view insertSubview:webView0 belowSubview:viewTool];
                    webView0.top = viewtip.bottom;
                    webView0.alpha = 1;
                    scrollView.height = viewtip.bottom+40;
                    [UIView animateWithDuration:0.25 animations:^{
                        scrollView.top = - viewtip.bottom ;
                        webView0.top = 40;
                    } completion:^(BOOL finished) {
                        if (buttonInfo.selected) {
                            [webView0 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_goods.content]]];
                        } else {
                            [webView0 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_goods.parameter]]];
                        }
                    }];
                });
            }
        }
    } else if (sender == webView0.scrollView) {
        if (sender.contentOffset.y <= - 65.0f) {
            scrollView.scrollEnabled = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25 animations:^{
                    scrollView.top = 0;
                    scrollView.height = self.view.height - viewtip.height;
                    webView0.top = APP_Frame_Height;
                } completion:^(BOOL finished) {
                    [webView0 removeFromSuperview];
                    scrollView.contentSize = CGSizeMake(0, viewtip.bottom + 1);
                }];
            });
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
  
}

@end
