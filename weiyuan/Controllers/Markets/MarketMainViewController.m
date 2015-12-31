//
//  MarketMainViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15/10/22.
//  Copyright © 2015年 dreamisland. All rights reserved.
//

#import "MarketMainViewController.h"
#import "BaseTableViewCell.h"
#import "ImageTouchView.h"
#import "TextInput.h"
#import "Globals.h"
#import "Good.h"
#import "Shop.h"
#import "MarketsCategory.h"
#import "Area.h"
#import "User.h"
#import "MenuView.h"
#import "picture.h"
#import "GoodsCollectionViewCell.h"
#import "ShopCell.h"
#import "GoodDetailViewController.h"
#import "ShopGoodsViewController.h"
//#import "ShopViewController.h"
#import "JSBadgeView.h"
#import "ShoppingCart.h"
#import "ShoppingCartViewController.h"
#import "LocationManager.h"

@interface MarketMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
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
    UICollectionView * filterCollectionView;
    
    UIView *collectionMenuView;
    UIView *tableMenuView;
    
    NSMutableArray *filterGoods;
    NSMutableArray *contentGoods;
    NSMutableArray *arrArea;
    NSArray *arrOrder;
    
    Good *currentGoods;
    NSInteger currentCategoryId;
    NSString *currentCity;
    NSString *currentShopCity;
    NSInteger currentSort;
    
    JSBadgeView         * jSBadgeView;
}

@end

@implementation MarketMainViewController

- (void)viewDidLoad {
    self.enablefilter = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    
    currentSort = 1;
    currentSearch = 0;
    _shopType = 1;
    
    self.navigationItem.title = @"菜篮子";
    self.navigationItem.titleView = self.titleView;
    self.tableViewCellHeight = 44;
    
    contentGoods = [NSMutableArray array];
    [contentArr addObject:@"0"];
    arrOrder = @[@"价格从低到高", @"价格从高到低"];
    
    headerView = self.headerBar;
    [self.view addSubview:headerView];
    tableView.top = headerView.height;
    tableView.height -= tableView.top;
    
    filterTableView.top = headerView.height;
    filterTableView.height -= filterTableView.top;
    
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
    
    if (self.enablefilter) {
        filterCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        //注册
        [filterCollectionView registerClass:[GoodsCollectionViewCell class] forCellWithReuseIdentifier:@"GoodsCollectionViewCell"];
        //设置代理
        filterCollectionView.tag = 11;
        filterCollectionView.delegate = self;
        filterCollectionView.dataSource = self;
        filterCollectionView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:filterCollectionView atIndex:0];
        
        filterGoods = [NSMutableArray array];
    }
    
    //    self.view.backgroundColor = [UIColor lightGrayColor];
    [self floatButton];
}

- (void)individuationTitleView {
    if (self.value) {
        self.addButton.userInteractionEnabled = NO;
    }
    
    self.searchButton.image = LOADIMAGE(@"btn_search");
    self.searchButton.highlightedImage = LOADIMAGE(@"btn_search_d");
    self.searchButton.left = self.titleView.width - 35;
    
    self.searchView.width = 0;
    self.searchButton.alpha = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isFirstAppear) {
        [self requestData];
        
        if (![MarketsCategory hasData]) {
            self.loading = YES;
            BSClient *clientCategory = [[BSClient alloc] initWithDelegate:self action:@selector(requestCategoryDidFinish:obj:)];
            [clientCategory getShopCategoryListWithShopType:_shopType];
            
            BSClient *clientArea = [[BSClient alloc] initWithDelegate:self action:@selector(requestAreaDidFinish:obj:)];
            [clientArea getShopAreaListWithShopType:_shopType];
        }
        
        if (currentSearch == 0) {
            tableView.left = self.view.width;
            filterTableView.left = self.view.width;
        }
    }
    
    jSBadgeView.badgeText = @([ShoppingCart goodsCount]).stringValue;
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
        
        MarketsCategory * allitem = [[MarketsCategory alloc] init];
        allitem.name = @"全部商品";
        allitem.id = 0;
        [arrCategory addObject:allitem];
        
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MarketsCategory * item = [MarketsCategory objWithJsonDic:obj];
            [arrCategory addObject:item];
        }];
        
        [MarketsCategory setCategoryArray:arrCategory];
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
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    
    collectionMenuView = [self getCollectionMenuView];
    [view addSubview:collectionMenuView];
    
    tableMenuView = [self getTableMenuView];
    [view addSubview:tableMenuView];
    
    NSArray * arrSegmented = @[@"商品",@"商家"];
    
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
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    
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
    
    view.backgroundColor = UIColorFromRGB(0xeeeeee);
    
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
                filterCollectionView.left = 0;
                collectionMenuView.left = 0;
                tableView.left = self.view.width;
                filterTableView.left = self.view.width;
                tableMenuView.left = self.view.width;
            } completion:^(BOOL finished) {
                if (finished) {
                    tableView.hidden = YES;
                    filterTableView.hidden = YES;
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
                filterTableView.left = 0;
                tableMenuView.left = 0;
                
                collectionView.left = -self.view.width;
                filterCollectionView.left = -self.view.width;
                collectionMenuView.left = -self.view.width;
            } completion:^(BOOL finished) {
                if (finished) {
                    collectionView.hidden = YES;
                    filterCollectionView.hidden = YES;
                    collectionMenuView.hidden = YES;
                }
            }];
        } break;
            
        default:
            break;
    }
}

- (void)floatButton {
    UIButton *cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cartButton setFrame:CGRectMake(self.view.width - 72, self.view.height - 168, 44, 44)];
    [cartButton setImage:LOADIMAGE(@"商户购物车") forState:UIControlStateNormal];
    [cartButton addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    cartButton.tag = 0;
    [self.view insertSubview:cartButton aboveSubview:tableView];
    cartButton.contentMode = UIViewContentModeCenter;
    
    jSBadgeView = [[JSBadgeView alloc] initWithParentView:cartButton alignment:JSBadgeViewAlignmentTopRight];
}

- (void)btnItemPressed:(UIButton*)sender {
    switch (sender.tag) {
        case 0:
        {
            [self pushViewController:[[ShoppingCartViewController alloc] init]];
        }   break;
            
        case 10:
        {
            NSArray *arr = [MarketsCategory getCategoryNameArray];
            if (arr) {
                MenuView *menuView = [[MenuView alloc] initWithButtonTitles:arr withDelegate:self];
                menuView.tag = sender.tag;
                
                if (menuView) {
                    [menuView showInView:self.view origin:CGPointMake(0, 0)];
                }
            }
        }   break;
            
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
        }   break;
            
        case 12:
        {
            if (arrOrder) {
                MenuView *menuView = [[MenuView alloc] initWithButtonTitles:arrOrder withDelegate:self];
                menuView.tag = sender.tag;
                
                if (menuView) {
                    [menuView showInView:self.view origin:CGPointMake(tableView.width - MENUVIEW_WIDTH, 0)];
                }
            }
        }   break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark MenuViewDelegate

- (void)popoverView:(MenuView *)sender didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (sender.tag == 10) {
        MarketsCategory *item = [MarketsCategory getCategoryByIdx:buttonIndex];
        currentCategoryId = item.id.integerValue;
        [btnCategory setTitle:item.name forState:UIControlStateNormal];
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
        [client getGoodsListWithShopType:_shopType
                                  shopId:nil
                              categoryId:@(currentCategoryId).stringValue
                                    city:currentCity
                                    sort:@(currentSort).stringValue
                                    page:1];
    } else {
        Location currentLocation;
        
        if ([[LocationManager sharedManager] located]) {
            currentLocation = [[LocationManager sharedManager] coordinate];
        }
        
        [client getShopListWithShopType:_shopType
                                   page:1
                             categoryid:nil
                                    lat:@(currentLocation.lat).stringValue
                                    lng:@(currentLocation.lng).stringValue
                                   city:currentShopCity];
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
                    
                    [contentGoods addObject:item];
                }];
            }
        } else {
            NSArray *array = [obj getArrayForKey:@"data"];
            
            [contentArr removeAllObjects];
            
            if (array && array.count > 0) {
                [array enumerateObjectsUsingBlock:^(id shopData, NSUInteger idx, BOOL *stop) {
                    Shop *shop = [Shop objWithJsonDic:shopData];
                    
                    if (shop.goods.count > 0) {
                        NSMutableArray *arrGoods = [NSMutableArray array];
                        
                        [shop.goods enumerateObjectsUsingBlock:^(Good *goods, NSUInteger idx, BOOL *stop) {
                            if ([goods.status isEqual:@"2"]) {
                                [arrGoods addObject:goods];
                            }
                        }];
                        
                        shop.goods = arrGoods;
                        
                        if (shop.goods.count > 0) {
                            shop.user = [User objWithJsonDic:[shopData getDictionaryForKey:@"user"]];
                            [contentArr addObject:shop];
                        }
                    }
                }];
            }
        }
        
        if (currentSearch == 0) {
            [collectionView reloadData];
        } else {
            [tableView reloadData];
        }
    }
    
    return YES;
}

#pragma mark - searchFilter

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)sender {
    if (sender.text.length == 0) {
        if (currentSearch == 0) {
            [filterGoods removeAllObjects];
            [filterCollectionView reloadData];
            [collectionView reloadData];
        } else {
            [filterArr removeAllObjects];
            [filterTableView reloadData];
            [tableView reloadData];
        }
        inFilter = NO;
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sender {
    if (currentSearch == 0) {
        [filterGoods removeAllObjects];
        [filterCollectionView reloadData];
        [collectionView reloadData];
    } else {
        [filterArr removeAllObjects];
        [filterTableView reloadData];
        [tableView reloadData];
    }
    
    inFilter = NO;
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	搜索时根据输入的字符过滤tableview
 *
 */
- (void)textFieldDidChange:(UITextField*)sender {
    if (sender.markedTextRange != nil) {
        return;
    }
    if (currentSearch == 0) {
        [filterGoods removeAllObjects];
    } else {
        [filterArr removeAllObjects];
    }
    UITextField *_field = (UITextField *)sender;
    NSString * str = _field.text;
    if (str.length == 0) {
        if (currentSearch == 0) {
            [filterCollectionView reloadData];
            [UIView animateWithDuration:0.25 animations:^{
                filterCollectionView.alpha = 0;
                collectionView.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    inFilter = NO;
                    filterCollectionView.hidden = YES;
                }
            }];
        } else {
            [filterTableView reloadData];
            [UIView animateWithDuration:0.25 animations:^{
                filterTableView.alpha = 0;
                tableView.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    inFilter = NO;
                    filterTableView.hidden = YES;
                }
            }];
        }
    } else {
        [self filterContentForSearchText:_field.text scope:nil];
        if (!inFilter) {
            if (currentSearch == 0) {
                filterCollectionView.alpha = 0;
                filterCollectionView.hidden = NO;
                inFilter = YES;
                [UIView animateWithDuration:0.25 animations:^{
                    collectionView.alpha = 0;
                    filterCollectionView.alpha = 1;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [filterCollectionView reloadData];
                    }
                }];
            } else {
                filterTableView.alpha = 0;
                filterTableView.hidden = NO;
                inFilter = YES;
                [UIView animateWithDuration:0.25 animations:^{
                    tableView.alpha = 0;
                    filterTableView.alpha = 1;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [filterTableView reloadData];
                    }
                }];
            }
        } else {
            if (currentSearch == 0) {
                [filterCollectionView reloadData];
            } else {
                [filterTableView reloadData];
            }
        }
        
    }
    
}

- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope
{
    if (currentSearch == 0) {
        for (Good *it in contentGoods) {
            if (([it.content rangeOfString:searchText].location <= it.content.length) ||
                ([it.name rangeOfString:searchText].location <= it.name.length) ||
                ([it.price rangeOfString:searchText].location <= it.price.length) ||
                ([it.introduce rangeOfString:searchText].location <= it.introduce.length) ||
                ([it.barcode rangeOfString:searchText].location <= it.barcode.length)) {
                [filterGoods addObject:it];
            }
        }
    } else {
        for (Shop *it in contentArr) {
            if (([it.content rangeOfString:searchText].location <= it.content.length) ||
                ([it.name rangeOfString:searchText].location <= it.name.length) ||
                ([it.username rangeOfString:searchText].location <= it.username.length) ||
                ([it.city rangeOfString:searchText].location <= it.city.length)) {
                [filterArr addObject:it];
            }
        }
    }
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
    return inFilter?filterGoods.count:contentGoods.count;
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
    
    Good *item = [inFilter?filterGoods:contentGoods objectAtIndex:indexPath.row];
    cell.name = item.name;
    cell.price = [NSString stringWithFormat:@"￥%0.2f", item.price.floatValue];
    cell.priceLabel.width = cell.width;
    cell.priceLabel.left = 0;
    cell.priceLabel.textAlignment = NSTextAlignmentCenter;
    cell.shop = [NSString stringWithFormat:@"已售 %ld 件", item.number.integerValue];
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
    [shopRequst getShopWithShopType:_shopType
                             shopId:currentGoods.shopid];
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
    return inFilter?filterArr.count:contentArr.count;
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
        fileNib = [UINib nibWithNibName:@"ShopCell" bundle:nil];
        
        [tableView registerClass:ShopCell.class forCellReuseIdentifier:@"ShopCell"];
        [tableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
        
        if (self.enablefilter) {
            [filterTableView registerClass:ShopCell.class forCellReuseIdentifier:@"ShopCell"];
            [filterTableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
        }
    }
    ShopCell * cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.superTableView = sender;
    Shop * shop = [inFilter?filterArr:contentArr objectAtIndex:indexPath.section];
    //[contentArr objectAtIndex:indexPath.section];
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

#pragma mark - navi menu selected

- (void)imageTouchViewDidSelected:(ImageTouchView*)sender {
    if ([sender.tag isEqualToString:@"none"]) {
        sender.tag = @"changed";
        
        [UIView animateWithDuration:0.3 animations:^{
            self.searchView.width = self.view.width - 65;
            self.searchButton.left = self.searchView.left + 5;
            self.addButton.left = self.titleView.width - 45;
            self.searchButton.image = LOADIMAGE(@"btn_search_d");
            self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
            self.searchView.alpha = 1;
        } completion:^(BOOL finished) {
            self.addButton.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:0.15 animations:^{
                self.addButton.image = LOADIMAGE(@"btn_clear");
                self.addButton.highlightedImage = LOADIMAGE(@"btn_clear_d");
            } completion:^(BOOL finished) {
                [self.searchField becomeFirstResponder];
            }];
            
        }];
    } else {
        sender.tag = @"none";
        self.searchField.text = @"";
        [UIView animateWithDuration:0.3 animations:^{
            self.addButton.transform = CGAffineTransformMakeRotation((45.0f * M_PI) / 180.0f);
            self.searchButton.left = self.titleView.width - 75;
            self.searchView.width = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.addButton.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:0.15 animations:^{
                    self.addButton.left = self.titleView.width - 35;
                    self.searchButton.image = LOADIMAGE(@"btn_search");
                    self.addButton.image = LOADIMAGE(@"btn_add");
                    self.addButton.highlightedImage = nil;
                } completion:^(BOOL finished) {
                    [self.searchField resignFirstResponder];
                }];
            }
        }];
    }
}

@end
