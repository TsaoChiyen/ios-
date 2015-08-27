//
//  ShoppingCityViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "ShoppingCityViewController.h"
#import "BaseTableViewCell.h"
#import "Globals.h"
#import "Good.h"
#import "Shop.h"
#import "ShopCategroy.h"
#import "Area.h"
#import "User.h"
#import "MenuView.h"
#import "picture.h"
#import "GoodsCollectionViewCell.h"
#import "ShopCell.h"
#import "GoodDetailViewController.h"
#import "ShopGoodsViewController.h"
//#import "ShopViewController.h"

@interface ShoppingCityViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    UIView *headerView;
    UIButton *btnGoodsArea;
    UIButton *btnShopArea;
    UIButton *btnAdv;
    
    UIButton *btnCategory;
    UIButton *btnAreaChooser;
    UIButton *btnShopAreaChooser;
    UIButton *btnOrderChooser;
    
    NSInteger currentSearch;

    UICollectionView * collectionView;
    
    UIView *collectionMenuView;
    UIView *tableMenuView;
    
    NSMutableArray *contentGoods;
    NSMutableArray *arrArea;
    NSArray *arrOrder;
    
    Good *currentGoods;
    NSInteger currentCategoryId;
    NSString *currentCity;
    NSString *currentShopCity;
    NSInteger currentSort;
}

@end

@implementation ShoppingCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];

    currentSort = 1;
    currentSearch = 0;
    
    contentGoods = [NSMutableArray array];
//    arrArea = [NSMutableArray array];
    [contentArr addObject:@"0"];
    arrOrder = @[@"价格从低到高", @"价格从高到低"];

    headerView = self.headerBar;
    [self.view addSubview:headerView];
    tableView.top = headerView.height;
    tableView.height -= tableView.top;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    CGRect frame = tableView.bounds;
    frame.origin.y = tableView.top;
    
    collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    //注册
    [collectionView registerClass:[GoodsCollectionViewCell class] forCellWithReuseIdentifier:@"GoodsCollectionViewCell"];
    //设置代理
    collectionView.tag = 10;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:collectionView atIndex:0];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isFirstAppear) {
        [self requestData];
        
        if (![ShopCategroy hasData]) {
            self.loading = YES;
            BSClient *clientCategory = [[BSClient alloc] initWithDelegate:self action:@selector(requestCategoryDidFinish:obj:)];
            [clientCategory getShopCategoryList];

            BSClient *clientArea = [[BSClient alloc] initWithDelegate:self action:@selector(requestAreaDidFinish:obj:)];
            [clientArea getShopAreaList];
        }
        
        if (currentSearch == 0) {
            tableView.left = self.view.width;
//            tableView.hidden = YES;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestCategoryDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *arr = [obj getArrayForKey:@"data"];
        __block NSMutableArray *arrCategory = [NSMutableArray array];
        
        ShopCategroy * allitem = [[ShopCategroy alloc] init];
        allitem.name = @"全部商品";
        allitem.id = 0;
        [arrCategory addObject:allitem];
        
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ShopCategroy * item = [ShopCategroy objWithJsonDic:obj];
            [arrCategory addObject:item];
        }];
        
        [ShopCategroy setCategoryArray:arrCategory];
    }
}

- (void)requestAreaDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray *arr = [obj getArrayForKey:@"data"];
        arrArea = [NSMutableArray array];
        
        [arrArea addObject:@"所有地区"];
        
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString * item = [(NSDictionary *)obj objectForKey:@"city"];
                NSArray *name = [item componentsSeparatedByString:@"."];
                
                if (name.count > 0) {
                    [arrArea addObject:name[0]];
                }
            }];
        }
    }
}

- (UIView *)headerBar {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 72)];
    view.backgroundColor = UIColorFromRGB(0xe0ae80);
    
    collectionMenuView = [self getCollectionMenuView];
    [view addSubview:collectionMenuView];
    
    tableMenuView = [self getTableMenuView];
    [view addSubview:tableMenuView];
    
    NSArray * arrSegmented = @[@"承芯商品",@"承芯商店"];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:arrSegmented];

    float width = self.view.width;
    
    segmentedControl.frame = CGRectMake(width *0.1, 4.0, self.view.width * 0.7, 32.0);
    segmentedControl.layer.cornerRadius = 0;
//    segmentedControl.backgroundColor = [UIColor darkGrayColor];
//    segmentedControl.tintColor = [UIColor darkGrayColor];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;//设置样式
//    segmentedControl.momentary = YES;//设置在点击后是否恢复原样
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:segmentedControl];
    
    CGRect frame = CGRectMake(self.view.width - 40.0, 4, 40.0, 32);
    btnAdv = [self buttonInActionbar:view title:@"G" frame:frame];
    btnAdv.tag = 2;
    
    return view;
}

- (UIView *)getCollectionMenuView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.width, 32)];
    view.backgroundColor = UIColorFromRGB(0xe0e0e0);
    
    CGRect frame = CGRectMake(16, 0, 96, 32);
    btnCategory = [self buttonInActionbar:view title:@"商品分类" frame:frame];
    btnCategory.tag = 10;
    
    frame.origin.x += 96;
    btnAreaChooser = [self buttonInActionbar:view title:@"地区分类" frame:frame];
    btnAreaChooser.tag = 11;
    
    frame.origin.x += 96;
    btnOrderChooser = [self buttonInActionbar:view title:@"排序" frame:frame];
    btnOrderChooser.tag = 12;

    return view;
}

- (UIView *)getTableMenuView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(320, 40, self.view.width, 32)];

    view.backgroundColor = UIColorFromRGB(0xe0e0e0);
    
    CGRect frame = CGRectMake(112, 0, 96, 32);
    btnShopAreaChooser = [self buttonInActionbar:view title:@"地区筛选" frame:frame];
    btnShopAreaChooser.tag = 20;
    
    return view;
}

- (UIButton *)buttonInActionbar:(UIView*)actionbar title:(NSString *)text frame:(CGRect)frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.frame = frame;
    [actionbar addSubview:btn];
    [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)segmentAction:(UISegmentedControl *)Seg {
    currentSearch = Seg.selectedSegmentIndex;
    [self requestData];
    
    switch (currentSearch) {
        case 0:
        {
            collectionView.hidden = NO;
            collectionMenuView.hidden = NO;
            
            [UIView animateWithDuration:0.25 animations:^{
                collectionView.left = 0;
                collectionMenuView.left = 0;
                tableView.left = self.view.width;
                tableMenuView.left = self.view.width;
            } completion:^(BOOL finished) {
                if (finished) {
                    tableView.hidden = YES;
                    tableMenuView.hidden = YES;
                }
            }];
        } break;
            
        case 1:
        {
            tableView.hidden = NO;
            tableMenuView.hidden = NO;
            
            [UIView animateWithDuration:0.25 animations:^{
                tableView.left = 0;
                tableMenuView.left = 0;
                
                collectionView.left = -self.view.width;
                collectionMenuView.left = -self.view.width;
            } completion:^(BOOL finished) {
                if (finished) {
                    collectionView.hidden = YES;
                    collectionMenuView.hidden = YES;
                }
            }];
        } break;

        default:
            break;
    }
}

- (void)btnItemPressed:(UIButton*)sender {
    switch (sender.tag) {
        case 2:
            break;
            
        case 10:
        {
            NSArray *arr = [ShopCategroy getCategoryNameArray];
            if (arr) {
                MenuView *menuView = [[MenuView alloc] initWithButtonTitles:arr withDelegate:self];
                menuView.tag = sender.tag;
                
                if (menuView) {
                    [menuView showInView:self.view origin:CGPointMake(0, 0)];
                }
            }
        }
            break;
            
        case 11:
        case 20:
        {
            if (arrArea) {
                MenuView *menuView = [[MenuView alloc] initWithButtonTitles:arrArea withDelegate:self];
                menuView.tag = sender.tag;
                
                if (menuView) {
                    [menuView showInView:self.view origin:CGPointMake(96, 0)];
                }
            }
        }

            break;
            
        case 12:
        {
            if (arrOrder) {
                MenuView *menuView = [[MenuView alloc] initWithButtonTitles:arrOrder withDelegate:self];
                menuView.tag = sender.tag;
                
                if (menuView) {
                    [menuView showInView:self.view origin:CGPointMake(tableView.width - MENUVIEW_WIDTH, 0)];
                }
            }
        }

            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark MenuViewDelegate

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (sender.tag == 10) {
        currentCategoryId = buttonIndex;
        [btnCategory setTitle:[ShopCategroy getCategoryNameByIdx:buttonIndex]
                     forState:UIControlStateNormal];
        [self requestData];
    } else if (sender.tag == 11) {
        if (buttonIndex > 0) {
            currentCity = [arrArea objectAtIndex:buttonIndex];
            [btnAreaChooser setTitle:currentCity forState:UIControlStateNormal];
        } else {
            currentCity = nil;
            [btnAreaChooser setTitle:@"所有地区" forState:UIControlStateNormal];
        }

        [self requestData];
    } else if (sender.tag == 12) {
        currentSort = buttonIndex + 1;
        
        [btnOrderChooser setTitle:[arrOrder objectAtIndex:buttonIndex]
                         forState:UIControlStateNormal];
        [self requestData];
    } else if (sender.tag == 20) {
        if (buttonIndex > 0) {
            currentShopCity = [arrArea objectAtIndex:buttonIndex];
            [btnShopAreaChooser setTitle:currentShopCity forState:UIControlStateNormal];
        } else {
            currentShopCity = nil;
            [btnShopAreaChooser setTitle:@"所有地区" forState:UIControlStateNormal];
        }

        [self requestData];
    }

}

- (void)popoverViewCancel:(MenuView *)sender {
    
}

#pragma mark -

- (void)requestData
{
    self.loading = YES;
    [super startRequest];
    
    if (currentSearch == 0) {
        [client getGoodsListWithShopId:nil
                            categoryId:@(currentCategoryId).stringValue
                                  city:currentCity
                                  sort:@(currentSort).stringValue
                                  page:1];
    } else {
        [client getShopListWithPage:1
                      andCategoryid:nil
                            andCity:currentShopCity];
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        NSDictionary *result = [obj getDictionaryForKey:@"state"];
        NSString *url = [result objectForKey:@"url"];
        
        if ([url isEqualToString:@"Shop/Api/goodsList"]) {
            NSArray *array = [obj getArrayForKey:@"data"];
            
            [contentGoods removeAllObjects];

            if (array && array.count > 0) {
                [array enumerateObjectsUsingBlock:^(id goodData, NSUInteger idx, BOOL *stop) {
                    Good *item = [Good objWithJsonDic:goodData];
                    
                    NSArray *pics = [goodData getArrayForKey:@"picture"];
                    NSMutableArray *arrPics = [NSMutableArray array];
                    
                    if (pics && pics.count > 0) {
                        [pics enumerateObjectsUsingBlock:^(id picData, NSUInteger idx, BOOL *stop) {
                            picture *pic = [picture objWithJsonDic:picData];
                            [arrPics addObject:pic];
                        }];
                    }
                    
                    item.picture = arrPics;
                    
                    [contentGoods addObject:item];
                }];
            }
        } else {
            NSArray *array = [obj getArrayForKey:@"data"];
            
            [contentArr removeAllObjects];

            if (array && array.count > 0) {
                [array enumerateObjectsUsingBlock:^(id shopData, NSUInteger idx, BOOL *stop) {
                    Shop *item = [Shop objWithJsonDic:shopData];
                    item.user = [User objWithJsonDic:[shopData getDictionaryForKey:@"user"]];
                    [contentArr addObject:item];
                }];
            }
        }
        
        if (currentSearch == 0) {
            [collectionView reloadData];
//            collectionView.hidden = NO;
//            tableView.hidden = YES;
        } else {
            [tableView reloadData];
//            collectionView.hidden = YES;
//            tableView.hidden = NO;
        }
    }

    return YES;
}

#pragma mark - collectionView delegate
//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)sender {
    return 1;
}
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)sender numberOfItemsInSection:(NSInteger)section {
    if (currentSearch == 1) {
        return 0;
    }
    return contentGoods.count;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(105,144);
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
    static NSString *identify = @"GoodsCollectionViewCell";
    GoodsCollectionViewCell *cell = [sender dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];

    cell.superCollectionView = sender;
    cell.backgroundColor = [UIColor clearColor];
    
    Good *item = contentGoods[indexPath.row];
    cell.name = item.name;
    cell.price = [NSString stringWithFormat:@"￥%0.2f", item.price.floatValue];
    cell.priceLabel.width = cell.width;
    cell.priceLabel.left = 0;
    cell.priceLabel.textAlignment = NSTextAlignmentCenter;
    cell.shop = [NSString stringWithFormat:@"已售 %d 件", item.number.integerValue];
    cell.shopLabel.hidden = YES;

    if (item.picture.count) {
        picture *pic = [item.picture objectAtIndex:0];
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pic.smallUrl]];
        UIImage *img = [UIImage imageWithData:imgData];
        cell.imageView.hidden = NO;
//        cell.imageView.frame = CGRectMake(0, 0, 90, 85);
        cell.image = img;
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
    BSClient *shopRequst = [[BSClient alloc] initWithDelegate:self action:@selector(requestShopDidFinish:obj:)];
    currentGoods = [contentGoods objectAtIndex:indexPath.row];
    [shopRequst getShopByShopId:currentGoods.shopid];
}

- (BOOL)requestShopDidFinish:(id)sender obj:(NSDictionary *)obj
{
    if ([super requestDidFinish:sender obj:obj]) {
        Shop *shop = [Shop objWithJsonDic:[obj getDictionaryForKey:@"data"]];
        
        if (shop) {
            //    ShopViewController *con = [[ShopViewController alloc] init];
            GoodDetailViewController * con = [[GoodDetailViewController alloc] init];
            
            con.goods = currentGoods;
            con.shop = shop;
            [self pushViewController:con];
        }
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (currentSearch == 0) {
        return 0;
    }
    return contentArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (currentSearch == 0) {
        return 0;
    }
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
