//
//  ServiceViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "ServiceViewController.h"
#import "UserCollectionViewCell.h"
#import "Favorite.h"
#import "Globals.h"
#import "Address.h"
#import "MapViewController.h"
#import "Message.h"
#import "CollectionDetailViewController.h"
#import "ImagePlayerView.h"
#import "BaseMenuItem.h"

@interface ServiceViewController () <ImagePlayerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    ImagePlayerView * bannerView;
    UIActivityIndicatorView *activityIndicator;

    UICollectionView * collectionView;

    NSArray             *arrMenu;
    NSArray             *arrClass;
    NSArray             *arrImage;
}

@end

@implementation ServiceViewController

- (id)init {
    if ((self = [super init])) {
        arrMenu = @[@"扫码",
                     @"需求",
                     @"游乐场",
                     @"订单",
                     @" 公众号 ",
                     @"住宿",
                     @"景点",
                     @"维修"];

        arrClass = @[@"QRcodeReaderViewController",
                    @"DemandViewController",
                    @"",
                    @"OrderViewController",
                    @"",
                    @"",
                    @"",
                    @""];

        arrImage = @[@"",
                     @"",
                     @"",
                     @"",
                     @"",
                     @"",
                     @"",
                     @""];
    }
    
    return self;
}

const float BANNER_HEIGHT = 129;

- (void)viewDidLoad {
    enablefilter = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];

    [self initCollectionMenu];
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];

    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:self.view.center];
    activityIndicator.color = kbColor;
    activityIndicator.left = (Main_Screen_Width - 32)/2;
    [self.view addSubview:activityIndicator];

    [activityIndicator startAnimating];

    bannerView = [[ImagePlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, BANNER_HEIGHT)];
    [self.view insertSubview:bannerView atIndex:0];
    bannerView.imagePlayerViewDelegate = self;
    bannerView.alpha = 0;
    [bannerView reloadData];

    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    CGRect frame = tableView.bounds;
    
    frame.origin.y = BANNER_HEIGHT;
    frame.size.height -= BANNER_HEIGHT;
    
    collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    //注册
    [collectionView registerClass:[UserCollectionViewCell class] forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    //设置代理
    collectionView.tag = 10;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:collectionView atIndex:0];
    collectionView.scrollEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        tableView.hidden = YES;
        [bannerView reloadData];
        [collectionView reloadData];
        
        [UIView animateWithDuration:0.25 animations:^{
            bannerView.alpha = 1;
        } completion:^(BOOL finished) {
            [activityIndicator stopAnimating];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCollectionMenu {
    if (contentArr) {
        [contentArr removeAllObjects];
    }
    
    if (arrMenu) {
        [arrMenu enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BaseMenuItem *menu = [[BaseMenuItem alloc] init];
            
            if (menu) {
                menu.name = arrMenu[idx];
                menu.className = arrClass[idx];
                menu.image = arrImage[idx];
                
                [contentArr addObject:menu];
            }
        }];
    }
    
}

- (BOOL)startRequest {
    return NO;
}

#pragma mark - BannerViewDelegate

- (NSInteger)numberOfItemsInPlayerView:(ImagePlayerView *)sender {
    return 2;
}

- (void)imagePlayerView:(ImagePlayerView *)sender loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index {
    NSString *imgFile = [NSString stringWithFormat:@"广告素材%d", index + 1];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = LOADIMAGE(imgFile);
//    [imageView  placeholderImage:[Globals getImageDefault]];
}

- (void)imagePlayerView:(ImagePlayerView *)sender didTapAtIndex:(NSInteger)index {
//    
//    picture *item = [self.goods.picture objectAtIndex:index];
//    CGRect frameStart = [scrollView convertRect:sender.frame toView:self.navigationController.view];
//    ImageViewController * con = [[ImageViewController alloc] initWithFrameStart:frameStart supView:self.navigationController.view pic:item.originUrl preview:(id)item.smallUrl];
//    con.bkgImage = [self.view screenshot];
//    [self presentModalController:con animated:NO];
//    
}

#pragma mark - collectionView delegate
//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)sender {
    return 1;
}
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)sender numberOfItemsInSection:(NSInteger)section {
    return contentArr.count;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(105,105);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(1.5,1.5,0,1.5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)sender cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"UserCollectionViewCell";
    UserCollectionViewCell *cell = [sender dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    [cell.contentView setAlpha:1];
    cell.superCollectionView = sender;
    
    cell.backgroundColor = [UIColor clearColor];
    
    BaseMenuItem *menu = contentArr[indexPath.row];
    cell.title = menu.name;
    cell.nameLabel.frame = CGRectMake(0, 60, 105, 45);
    
    if (menu.name && menu.name.length > 0) {
        cell.imageView.hidden = NO;
        cell.imageView.frame = CGRectMake(0, 0, 105, 105);
        cell.image = LOADIMAGE(menu.name);
    }

    cell.contentView.height = cell.height;
    return cell;
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)sender shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)sender didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BaseMenuItem * item = contentArr[indexPath.row];
    if (item) {
       id con = [[[NSClassFromString(item.className) class] alloc] init];
        
        if ([con isKindOfClass:[UIViewController class]]) {
            [self pushViewController:con];
        }
    }
}

@end
