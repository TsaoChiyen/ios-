//
//  BaseListPageViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//


#import "BaseListPageViewController.h"
#import "BaseTableViewController.h"
#import "ScrollViewHeaderView.h"
#import "BaseTableViewCell.h"
#import "UserCell.h"
#import "UserInfoViewController.h"
#import "FriendsAddViewController.h"
#import <sys/utsname.h>

#define MENUHEIGHT 55
#define MENUCOUNT 5

@interface BaseListPageViewController ()<UIScrollViewDelegate>

/**
 *  滑动比例
 *
 */
@property (nonatomic, assign, readonly) CGFloat     displacementRatio;
/**
 *  ［名称滑动层］可视宽度内最大容纳名称数量
 *
 */
@property (nonatomic, assign, readonly) int         numberOfPackets;

/**
 *  标识当前页码
 */
@property (nonatomic, assign) NSInteger selectedPage;
@end

@implementation BaseListPageViewController
@synthesize viewControllers, nameArray, className, scrollheaderView;
@dynamic displacementRatio, numberOfPackets;

- (id)init {
    if (self = [super init]) {
        // Custom initialization
        self.viewControllers = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [self.view addSubview:self.centerView];
        [self reloadData];
    }
    __block BaseListPageViewController * blockView = self;
    self.scrollheaderView.selecdBlock = ^(NSInteger selected) {
        [blockView setSelectedPage:selected];
        [UIView animateWithDuration:0.3 animations:^{
            blockView.pagingScrollView.contentOffset = CGPointMake(selected * blockView.pagingScrollView.width, blockView.pagingScrollView.contentOffset.y);
        }];
    };

}

- (void)viewDidDisappear:(BOOL)animated {
    self.scrollheaderView.selecdBlock = nil;
    self.loading = NO;
}

//获得设备型号
+ (NSString *)getCurrentDeviceModel:(UIViewController *)controller
{
    struct utsname u;
    uname(&u); ///-----get device struct info
    NSString *platform =  [NSString stringWithCString:u.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

- (ScrollViewHeaderView*)scrollheaderView {
    if (!scrollheaderView) {
        CGFloat statusHeight=60;
        struct utsname u;
        uname(&u); ///-----get device struct info
        NSString *machine =  [NSString stringWithCString:u.machine encoding:NSUTF8StringEncoding];
        
        if ([machine isEqualToString:@"iPhone1,1"]) {
            // iPhone 1G
            statusHeight=40;
        }
        if ([machine isEqualToString:@"iPhone1,2"]) {
            // iPhone 3G
            statusHeight=40;
        }
        if ([machine isEqualToString:@"iPhone2,1"]) {
            // iPhone 3GS
            statusHeight=40;
        }
        //iPhone 4
        if ([machine isEqualToString:@"iPhone3,1"]) {
            // iPod touch 1G
            statusHeight=60;
        }
        if ([machine isEqualToString:@"iPhone3,2"]) {
            // iPod touch 1G
            statusHeight=60;
        }
        if ([machine isEqualToString:@"iPhone3,3"]) {
            // iPod touch 1G
            statusHeight=60;
        }
        if ([machine isEqualToString:@"iPhone4,1"]) {
            statusHeight=60;
            
        }
        //iPhone 5
        if ([machine isEqualToString:@"iPhone5,1"]) {

            statusHeight=60;
        }
        if ([machine isEqualToString:@"iPhone5,2"]) {
            
           statusHeight=60;
        }

        if ([machine isEqualToString:@"iPhone5,3"]) {
            
           statusHeight=60;
        }

        if ([machine isEqualToString:@"iPhone5,4"]) {
            
           statusHeight=60;
        }
        //iPhone 5s
        if ([machine isEqualToString:@"iPhone6,1"]) {
            
          statusHeight=60;
        }
        if ([machine isEqualToString:@"Phone6,2"]) {
            
             statusHeight=60;
        }
        //iPhone 6 Plus
        if ([machine isEqualToString:@"iPhone7,1"]) {
            
            statusHeight=60;
        }
        //iPhone 6
        
        if ([machine isEqualToString:@"iPhone7,2"]) {
            
            statusHeight=60;
        }
        
        scrollheaderView = [[ScrollViewHeaderView alloc] initWithFrame:CGRectMake(0, self.view.height-MENUHEIGHT-statusHeight, self.view.width, MENUHEIGHT)];
        scrollheaderView.menucount=MENUCOUNT;
        [self.view addSubview:scrollheaderView];
    }

    return scrollheaderView;
}

- (void)setNameArray:(NSArray *)arr {
    nameArray = arr;
    
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class class = NSClassFromString(className[idx]);
        BaseTableViewController * tmpCon = [[class alloc] init];
        tmpCon.tag = idx;
        [self.viewControllers addObject:tmpCon];
    }];
    
    self.scrollheaderView.nameArray = arr;
    
    self.scrollheaderView.backgroundColor = [UIColor whiteColor];
}

- (void) setMenuIconsArray:(NSArray *)arr AddSelected:(NSArray *)selectArr{
    self.scrollheaderView.iconsArray = arr;
    self.scrollheaderView.iconsSelectedArray = selectArr;
}

- (UIScrollView *)pagingScrollView {
    if (!_pagingScrollView) {
        _pagingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _centerView.height)];
        _pagingScrollView.bounces = NO;
        _pagingScrollView.pagingEnabled = YES;
        [_pagingScrollView setScrollsToTop:NO];
        _pagingScrollView.delegate = self;
        _pagingScrollView.showsVerticalScrollIndicator = NO;
        _pagingScrollView.showsHorizontalScrollIndicator = NO;
        [_pagingScrollView.panGestureRecognizer addTarget:self action:@selector(panGestureRecognizerHandle:)];
    }
    
    return _pagingScrollView;
}

- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - scrollheaderView.height)];
        _centerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _centerView.backgroundColor = [UIColor whiteColor];
        [_centerView addSubview:self.pagingScrollView];
    }
    return _centerView;
}

- (void)reloadData {
    [_pagingScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.viewControllers enumerateObjectsUsingBlock:^(BaseTableViewController *viewController, NSUInteger idx, BOOL *stop) {
        CGRect contentViewFrame = viewController.view.bounds;
        contentViewFrame.origin.x = idx * _pagingScrollView.width;
        contentViewFrame.size.height = _pagingScrollView.height;
        viewController.view.frame = contentViewFrame;
        [_pagingScrollView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }];
    [_pagingScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds) * self.viewControllers.count, 0)];
}

#pragma mark - DataSource

- (NSInteger)getCurrentPageIndex {
    return self.selectedPage;
}

/**
 *  为指定页码更新消息数
 *
 */
- (void)setBadgeValueforPage:(int)page withContent:(NSString*)withContent {
    [scrollheaderView setBadgeValueAtIndex:page withContent:withContent];
}

- (void)addNewFriend {
    FriendsAddViewController * con = [[FriendsAddViewController alloc] init];
    [self pushViewController:con];
}

#pragma mark - PanGesture Handle Method

- (void)panGestureRecognizerHandle:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint contentOffset = self.pagingScrollView.contentOffset;
    CGSize contentSize = self.pagingScrollView.contentSize;
    CGFloat baseWidth = CGRectGetWidth(self.pagingScrollView.bounds);
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (contentOffset.x <= 0) {
            // 滑动到最左边
            [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
        } else if (contentOffset.x >= contentSize.width - baseWidth) {
            // 滑动到最右边
            [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
        }
    }
}

- (void)setupScrollToTop {
    for (int i = 0; i < self.viewControllers.count; i ++) {
        UITableView *_tableView = (UITableView *)[self subviewWithClass:[UITableView class] onView:[self getPageViewControllerAtIndex:i].view];
        if (_tableView) {
            if (self.selectedPage == i) {
                [_tableView setScrollsToTop:YES];
            } else {
                [_tableView setScrollsToTop:NO];
            }
        }
    }
}

- (UIViewController *)getPageViewControllerAtIndex:(NSInteger)index {
    if (index < self.viewControllers.count) {
        return self.viewControllers[index];
    } else {
        return nil;
    }
}


//翻页事件（切换tab事件)
- (void)setSelectedPage:(NSInteger)selectedPage {
    self.scrollheaderView.selectedBtn = selectedPage;
    if (_selectedPage == selectedPage)
        return;
    BaseTableViewController * selectedTableView=  [self.viewControllers objectAtIndex:selectedPage];

    if (selectedTableView) {
        [selectedTableView pageCurrent];
    }
    _selectedPage = selectedPage;
    [self setupScrollToTop];
    [self pageHasChanged];
}

- (void)pageHasChanged {
    //to be impletemented in sub-class
}

#pragma mark - View Helper Method
- (UIView *)subviewWithClass:(Class)cuurentClass onView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:cuurentClass]) {
            return subView;
        }
    }
    return nil;
}

- (int)numberOfPackets {
    return self.centerView.width/self.scrollheaderView.maxButtonWidth;
}

- (CGFloat)displacementRatio {
    return self.scrollheaderView.maxButtonWidth/self.centerView.width;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    self.scrollheaderView.selecedBlackgroundView.left = sender.contentOffset.x * self.displacementRatio;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    // 得到每页宽度
    CGFloat pageWidth = sender.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    self.selectedPage = floor((sender.contentOffset.x - pageWidth/2) / pageWidth)+ 1;
    //if (nameArray.count > 4) {
    if (nameArray.count > MENUHEIGHT) {
        [UIView animateWithDuration:0.3 animations:^{
            if (_selectedPage == nameArray.count - 1) {
                self.scrollheaderView.contentOffset = CGPointMake(self.scrollheaderView.maxButtonWidth * (_selectedPage-2), self.scrollheaderView.contentOffset.y);
            } else {
                self.scrollheaderView.contentOffset = CGPointMake((_selectedPage/self.numberOfPackets)*self.centerView.width/2, self.scrollheaderView.contentOffset.y);
            }
        }];
    }
}

@end