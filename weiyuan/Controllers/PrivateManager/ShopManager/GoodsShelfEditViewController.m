//
//  GoodsShelfEditViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-19.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "GoodsShelfEditViewController.h"
#import "GoodsShelfEditCell.h"

@interface GoodsShelfEditViewController ()

@end

@implementation GoodsShelfEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    self.navigationItem.title = @"上架商品信息";
    [self setRightBarButtonImage:LOADIMAGE(@"OK") highlightedImage:nil selector:@selector(btnOK)];

    self.tableViewCellHeight = 128;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnOK
{
    [self editDidFinished];
}

- (void)setArrGoods:(NSArray *)arr
{
    [contentArr removeAllObjects];
    
    [contentArr addObjectsFromArray:arr];

    [tableView reloadData];
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"GoodsShelfEditCell";
    
    if (!fileNib) {
        [tableView registerClass:GoodsShelfEditCell.class forCellReuseIdentifier:@"GoodsShelfEditCell"];
        fileNib = [UINib nibWithNibName:@"GoodsShelfEditCell" bundle:nil];
        [tableView registerNib:fileNib forCellReuseIdentifier:cellIdentifier];
    }
    
    GoodsShelfEditCell * cell = [sender dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.superTableView = sender;
    Good *item = [inFilter?filterArr:contentArr objectAtIndex:indexPath.row];
    
    cell.goods = item;
    cell.imageView.hidden = YES;
    cell.topLine = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)editDidFinished
{
//    NSMutableArray *arrGoods = [NSMutableArray array];
    
}

@end
