//
//  FinanceViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "FinanceViewController.h"
#import "ImagePlayerView.h"
#import "BaseMenuItem.h"
#import "BaseTableViewCell.h"
#import "FinancingViewController.h"

@interface FinanceViewController () <ImagePlayerViewDelegate>
{
    ImagePlayerView * bannerView;
    UIActivityIndicatorView *activityIndicator;

    NSArray             *arrMenu;
    NSArray             *arrClass;
    NSArray             *arrImage;
}

@end

@implementation FinanceViewController

- (id)init {
    if ((self = [super init])) {
        arrMenu = @[@"账单管理"
                  , @"融资贷款"];
//                  , @"投资理财"];
        
        arrClass = @[@"FinanceCheckViewController"
                   , @"FinancingViewController"];
//                   , @""];
        
        arrImage = @[@""
                     ,@""];
//                   ,@""];
    }
    
    return self;
}

- (void)viewDidLoad {
    self.enablefilter = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    
    [self initMenu];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:self.view.center];
    activityIndicator.color = kbColor;
    activityIndicator.left = (Main_Screen_Width - 32)/2;
    [self.view addSubview:activityIndicator];
    
    [activityIndicator startAnimating];

    bannerView = [[ImagePlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 128)];
    [self.view insertSubview:bannerView atIndex:0];
    bannerView.imagePlayerViewDelegate = self;
    bannerView.alpha = 0;
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    CGRect frame = tableView.bounds;
    
    frame.origin.y = 128;
    frame.size.height -= 128;

    tableView.frame = frame;
    self.tableViewCellHeight = 72;
    tableView.scrollEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [bannerView reloadData];
 
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

- (void)initMenu {
    if (contentArr) {
        [contentArr removeAllObjects];
    }
    
    if (arrMenu && arrMenu.count) {
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


#pragma mark - BannerViewDelegate

- (NSInteger)numberOfItemsInPlayerView:(ImagePlayerView *)sender {
    return 2;
}

- (void)imagePlayerView:(ImagePlayerView *)sender loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index {
    NSString *imgFile = [NSString stringWithFormat:@"广告素材%d", index + 1];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = LOADIMAGE(imgFile);
}

- (void)imagePlayerView:(ImagePlayerView *)sender didTapAtIndex:(NSInteger)index {

}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseTableViewCell *cell = (BaseTableViewCell *)[super tableView:sender cellForRowAtIndexPath:indexPath];
    BaseMenuItem * item = [contentArr objectAtIndex:indexPath.row];

    [cell update:^(NSString *name) {
        cell.textLabel.height = cell.height;
    }];
    
    cell.textLabel.text = item.name;
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    [cell addArrowRight];
//    cell.imageView.hidden = NO;
//    cell.imageView.image = LOADIMAGE(item.name);
    return cell;
}

- (void)tableView:(UITableView *)sender willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseMenuItem * item = [contentArr objectAtIndex:indexPath.row];
    
    if (item.name && item.name.length > 0) {
        UIImage *img = LOADIMAGE(item.name);
        cell.imageView.image = img;
    }
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseMenuItem * item = contentArr[indexPath.row];

    if (item) {
        id con = [[[NSClassFromString(item.className) class] alloc] init];
        
        if ([con isKindOfClass:[UIViewController class]]) {
            [self pushViewController:con];
        }
    }
}

@end
