//
//  ShopCommentViewController.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/9.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShopCommentViewController.h"
#import "Shop.h"
#import "Star.h"
#import "Comment.h"
#import "BaseTableViewCell.h"

@interface ShopCommentViewController ()

@end

@implementation ShopCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"评论列表";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        [super startRequest];
        [client commentList:_goods.id page:currentPage];
    }
}

- (void)prepareLoadMoreWithPage:(int)page sinceID:(int)sinceID {
    [client commentList:_goods.id page:page];
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray * arr = [obj getArrayForKey:@"data"];
        
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Comment * it = [Comment objWithJsonDic:obj];
                [contentArr addObject:it];
            }];
        }
        
        [tableView reloadData];
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 68;
    Comment * it = [contentArr objectAtIndex:indexPath.row];
    CGSize size = [it.content sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:APP_Frame_Height - 20 maxNumberLines:0];
    height += size.height;
    return height;
}

- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * BusCellidentifier = @"BaseTableViewCell";
    BaseTableViewCell * cell = (BaseTableViewCell *)[sender dequeueReusableCellWithIdentifier:BusCellidentifier];
    Star * star = VIEWWITHTAG(cell.contentView, 11);
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:BusCellidentifier];
        star = [[Star alloc] initWithFrame:CGRectMake(60, 35, 100, 30)];
        star.tag = 11;
        [cell.contentView addSubview:star];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    Comment * it = [contentArr objectAtIndex:indexPath.row];
    star.show_star = it.star.integerValue;
    cell.textLabel.text = it.user.nickname;
    cell.detailTextLabel.text = it.content;
    
    [cell update:^(NSString *name) {
        cell.imageView.frame = CGRectMake(5, 10, 50, 50);
        cell.textLabel.frame = CGRectMake(cell.imageView.right+10, 8, 200, 27);
        CGSize size = [it.content sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:APP_Frame_Height - 20 maxNumberLines:0];
        cell.detailTextLabel.frame = CGRectMake(10, 65, size.width, size.height);
    }];
    return cell;
}

- (NSString *)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    Comment * it = [contentArr objectAtIndex:indexPath.row];
    return it.user.headsmall;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    Comment * it = [contentArr objectAtIndex:indexPath.row];
    [self getUserByName:it.user.uid];
}
@end
