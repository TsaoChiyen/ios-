//
//  ShopViewController.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/6.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShopViewController.h"
#import "BaseCollectionViewCell.h"
#import "ImageTouchView.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "CollectionHeaderView.h"
#import "ShopCategroy.h"
#import "Globals.h"
#import "UIImageView+WebCache.h"
#import "LocationManager.h"
#import "Shop.h"
#import "ShopCell.h"
#import "GoodDetailViewController.h"
#import "ShopGoodsViewController.h"
#import "ShoppingCartViewController.h"
#import "ShoppingCart.h"
#import "JSBadgeView.h"
#import "LocationManager.h"

//#define TestArray @[@"全部", @"女装", @"男装", @"鞋包", @"母婴", @"化妆", @"数码", @"休闲", @"更多"]
@interface ShopViewController ()<ImageTouchViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout> {
    UICollectionView    * collectionView;
    UICollectionView    * collectionViewAll;
    NSMutableArray      * allshowArray;
    NSMutableArray      * showArray;
    CGFloat             widthButton; // 每一格的宽度
    UIView              * allshowBlackView;
    CGFloat             heightShow;
    CGFloat             heightAllShow;
    
    UIView              * tipViewShow; // 安置 上拉按钮
    BSClient            * clientCategroy;
    NSString            * categoryid;
    NSString            * city;
    UILabel             * cartLabel;
    JSBadgeView         * badgeView;
}

@end

@implementation ShopViewController
- (CGFloat)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section {
    if (collectionViewAll == sender) {
        return 38;
    }
    return 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdateNotification) name:LocationUpdateNotification object:nil];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    allshowArray = [[NSMutableArray alloc] init];
    showArray = [[NSMutableArray alloc] init];
    
    _shopType = 0;
    
    //注册
    CHTCollectionViewWaterfallLayout *flowLayout=[[CHTCollectionViewWaterfallLayout alloc] init];
    collectionView = [[UICollectionView alloc] initWithFrame:tableView.bounds collectionViewLayout:flowLayout];
    [collectionView registerClass:[BaseCollectionViewCell class] forCellWithReuseIdentifier:@"BaseCollectionViewCell"];
    //    collectionView.top = collectionView.height;
    collectionView.backgroundColor = RGBCOLOR(243, 243, 243);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    
    allshowBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, App_Frame_Width, APP_Frame_Height)];
    allshowBlackView.backgroundColor = RGBACOLOR(51, 51, 51, 0.8);
    allshowBlackView.alpha = 0;
    allshowBlackView.userInteractionEnabled = YES;
    [self.view addSubview:allshowBlackView];
    
    tipViewShow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 38)];
    tipViewShow.backgroundColor = RGBCOLOR(243, 243, 243);
    tipViewShow.userInteractionEnabled = YES;
    UILabel * label = [UILabel linesText:@"点击进入分类列表" font:[UIFont systemFontOfSize:14] wid:tipViewShow.width lines:1 color:RGBCOLOR(173, 171, 172)];
    label.size = tipViewShow.size;
    label.textAlignment = NSTextAlignmentCenter;
    [tipViewShow addSubview:label];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:LOADIMAGE(@"上拉") forState:UIControlStateNormal];
    button.frame = CGRectMake(tipViewShow.width - 100, 0, 100, 38);
    [button addTarget:self action:@selector(touchesBegan:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [tipViewShow addSubview:button];
    
    CHTCollectionViewWaterfallLayout *flowLayoutAll =[[CHTCollectionViewWaterfallLayout alloc] init];
    collectionViewAll = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, tableView.height) collectionViewLayout:flowLayoutAll];
    [collectionViewAll registerClass:CollectionHeaderView.class forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView"];
    UINib * fileNibs = [UINib nibWithNibName:@"CollectionHeaderView" bundle:nil];
    [collectionViewAll registerNib:fileNibs forSupplementaryViewOfKind:@"CollectionHeaderView" withReuseIdentifier:@"CollectionHeaderView"];
    [collectionViewAll registerClass:[BaseCollectionViewCell class] forCellWithReuseIdentifier:@"BaseCollectionViewCell"];
    collectionViewAll.backgroundColor = RGBCOLOR(243, 243, 243);
    collectionViewAll.delegate = self;
    collectionViewAll.dataSource = self;
    collectionViewAll.hidden = YES;
    [self.view addSubview:collectionViewAll];
    widthButton = (collectionView.width-6)/4;
    categoryid = @"0";
    self.tableViewCellHeight = 141;
    
    [self enableSlimeRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isFirstAppear) {
        self.loading = YES;
        clientCategroy = [[BSClient alloc] initWithDelegate:self action:@selector(requestCategroyDidFinish:obj:)];
        [clientCategroy getShopCategoryListWithShopType:_shopType];
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:LOADIMAGE(@"商户购物车") forState:UIControlStateNormal];
        button.frame = CGRectMake(self.view.width - 52, self.view.height - 52, 32, 32);
        [self.view addSubview:button];
        [button addTarget:self action:@selector(shoppingCart) forControlEvents: UIControlEventTouchUpInside];
    }

    [cartLabel removeFromSuperview];
    int co = [ShoppingCart goodsCount];
    if (co > 0) {
        cartLabel = [UILabel linesText:@(co).stringValue font:[UIFont systemFontOfSize:10] wid:20 lines:1 color:[UIColor whiteColor]];
        cartLabel.width += 6;
        cartLabel.frame = CGRectMake(self.view.width - cartLabel.width - 18, self.view.height - 32, cartLabel.width, cartLabel.height);
        cartLabel.userInteractionEnabled = NO;
        cartLabel.backgroundColor = RGBCOLOR(236,46,35);
        [self.view addSubview:cartLabel];
    }
}

- (void)refreshDataListIfNeed {
    if (isFirstLoadData) {
        isFirstLoadData = NO;
        if (client) {
            [client cancel];
            client = nil;
        }

        [super startRequest];
        isloadByslime = YES;
        
        Location currentLocation;
        
        if ([[LocationManager sharedManager] located]) {
            currentLocation = [[LocationManager sharedManager] coordinate];
        }

        [client getShopListWithShopType:_shopType
                                   page:1
                             categoryid:nil
                                    lat:@(currentLocation.lat).stringValue
                                    lng:@(currentLocation.lng).stringValue
                                   city:city];
    }
}

- (void)shoppingCart {
    [self pushViewController:[[ShoppingCartViewController alloc] init]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.35 animations:^{
        collectionViewAll.top = - collectionViewAll.height;
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:0.15 animations:^{
        allshowBlackView.alpha = 0;
    } completion:^(BOOL finished) {
        allshowBlackView.hidden = YES;
    }];
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    Location currentLocation;
    
    if ([[LocationManager sharedManager] located]) {
        currentLocation = [[LocationManager sharedManager] coordinate];
    }

    [client getShopListWithShopType:_shopType
                               page:page
                         categoryid:nil
                                lat:@(currentLocation.lat).stringValue
                                lng:@(currentLocation.lng).stringValue
                               city:city];
}

- (void)requestCategroyDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        
        NSArray * arr = [obj getArrayForKey:@"data"];
        [allshowArray removeAllObjects];
        ShopCategroy * allitem = [[ShopCategroy alloc] init];
        allitem.name = @"全部商品";
        allitem.id = 0;
        [allshowArray addObject:allitem];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShopCategroy * item = [ShopCategroy objWithJsonDic:obj];
            [allshowArray addObject:item];
        }];
        while (allshowArray.count%4 != 0) {
            ShopCategroy * item = [[ShopCategroy alloc] init];
            item.name = @"";
            [allshowArray addObject:item];
        }
        ShopCategroy * item = [[ShopCategroy alloc] init];
        item.name = @"";
        collectionViewAll.hidden = NO;
        [showArray addObjectsFromArray:@[allshowArray[0], allshowArray[1] ,allshowArray[2], item]];
        [collectionView reloadData];
        [collectionViewAll reloadData];
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if (![[BSEngine currentEngine] isLoggedIn]) {//没登录时
        NSArray * arr = [obj getArrayForKey:@"data"];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Shop * shop = [Shop objWithJsonDic:obj];
            [contentArr addObject:shop];
            
        }];
        CGFloat hei = widthButton;
        tableView.top = hei;
        tableView.height = self.view.height - hei;
        [tableView reloadData];
    }
    else
    {
        if ([super requestDidFinish:sender obj:obj]) {
            NSArray * arr = [obj getArrayForKey:@"data"];
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Shop * shop = [Shop objWithJsonDic:obj];
                [contentArr addObject:shop];
                
            }];
            CGFloat hei = widthButton;
            tableView.top = hei;
            tableView.height = self.view.height - hei;
            [tableView reloadData];
        }
    }
    
    return YES;
}

- (void)locationUpdateNotification {
    isloadByslime = YES;
    currentPage = 1;

    if (client) {
        return;
    }
    
    client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
    
    Location currentLocation;
    
    if ([[LocationManager sharedManager] located]) {
        currentLocation = [[LocationManager sharedManager] coordinate];
    }

    [client getShopListWithShopType:_shopType
                               page:currentPage
                         categoryid:nil
                                lat:@(currentLocation.lat).stringValue
                                lng:@(currentLocation.lng).stringValue
                               city:city];
}

- (void)imageTouchViewDidSelected:(id)sender {
    
}

//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)sender{
    return 1;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionCellView 的大小
- (CGSize)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((sender.width-6)/4,(sender.width-6)/4-15);
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)sender shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)collectionView:(UICollectionView *)sender numberOfItemsInSection:(NSInteger)section {
    if (collectionViewAll == sender) {
        return allshowArray.count;
    }
    return showArray.count;
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)sender cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"BaseCollectionViewCell";
    BaseCollectionViewCell * cell = [sender dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSArray * arr = (collectionViewAll == sender)?allshowArray:showArray;
    cell.superCollectionView = sender;
    ShopCategroy * item = arr[indexPath.row];
    cell.title = item.name;
    cell.nameLabel.textColor = RGBCOLOR(99 ,99, 99);
    cell.nameLabel.font = [UIFont systemFontOfSize:12];
    cell.nameLabel.frame = CGRectMake(0, 40, cell.width, 20);
    UIImage * lao = LOADIMAGECACHES(@"下拉");
    if ((collectionViewAll != sender) && indexPath.row == 3) {
        cell.imageView.frame = cell.bounds;
        cell.imageView.image = lao;
        cell.imageView.contentMode = UIViewContentModeCenter;
    } else {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.frame = CGRectMake((cell.width - 32)/2, 10, 32, 27);
        
        if (indexPath.row == 0) {
            cell.imageView.image = LOADIMAGECACHES(@"全部");
        } else if (item.name.hasValue) {
            [cell.imageView sd_setImageWithUrlString:item.logo placeholderImage:[Globals getImageDefault]];
        } else {
            cell.imageView.image = nil;
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == arr.count - 1) {
        if (collectionViewAll == sender) {
            heightAllShow = [sender convertPoint:cell.origin toView:self.view].y + cell.height+2;
            sender.top = - heightAllShow;
            sender.height = heightAllShow;
            sender.hidden = NO;
        } else {
            heightShow = [sender convertPoint:cell.origin toView:self.view].y + cell.height+2;
            sender.height = [sender convertPoint:cell.origin toView:self.view].y + cell.height+2;
        }
        
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)sender didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionViewAll != sender && indexPath.row == 3) {
        // 展开
        allshowBlackView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            collectionViewAll.top = 0;
            allshowBlackView.alpha = 1;
        }];
        [sender reloadData];
    } else {
        NSArray * arr = (collectionViewAll == sender)?allshowArray:showArray;
        ShopCategroy * item = arr[indexPath.row];
        categoryid = item.id?item.id:@"0";

        [super startRequest];
        isloadByslime = YES;

        Location currentLocation;
        
        if ([[LocationManager sharedManager] located]) {
            currentLocation = [[LocationManager sharedManager] coordinate];
        }

        [client getShopListWithShopType:_shopType
                                   page:currentPage
                             categoryid:nil
                                    lat:@(currentLocation.lat).stringValue
                                    lng:@(currentLocation.lng).stringValue
                                   city:city];
        
        [self touchesBegan:nil withEvent:nil];
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)sender viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CollectionHeaderView* headerView;
    if (sender==collectionViewAll && [kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        headerView = [sender dequeueReusableSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView" forIndexPath:indexPath];
        if (![headerView.subviews containsObject:tipViewShow]) {
            [headerView addSubview:tipViewShow];
        }
        return headerView;
    }
    return headerView;
}

-(CGSize)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(sender.width, 38);
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return contentArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Shop * shop = [contentArr objectAtIndex:indexPath.section];
    if (shop.goods && shop.goods.count > 0) {
        return 141;
    }
    return 35;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"ShopCell";
    if (!fileNib) {
        [tableView registerClass:ShopCell.class forCellReuseIdentifier:@"ShopCell"];
        fileNib = [UINib nibWithNibName:@"ShopCell" bundle:nil];
        [tableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
    }
    ShopCell * cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.superTableView = sender;
    Shop * shop = [contentArr objectAtIndex:indexPath.section];
    cell.shop = shop;
    cell.imageView.hidden = YES;
    cell.topLine = NO;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:sender didSelectRowAtIndexPath:indexPath];
    Shop * shop = [contentArr objectAtIndex:indexPath.section];
    ShopGoodsViewController * con = [[ShopGoodsViewController alloc] init];
    con.shop = shop;
    [self pushViewController:con];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableViewDidTapImageAtIndexPath:(NSIndexPath*)indexPath tag:(NSString*)tag {
    Shop * shop = [contentArr objectAtIndex:indexPath.section];
    Good * good = shop.goods[tag.intValue];
    GoodDetailViewController * con = [[GoodDetailViewController alloc] init];
    con.goods = good;
    con.shop = shop;
    [self pushViewController:con];
}
@end
