//
//  ShoppingCartViewController.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/9.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "ShoppingCart.h"
#import "JSON.h"
#import "Shop.h"
#import "UIButton+NSIndexPath.h"
#import "BaseTableViewCell.h"
#import "Globals.h"
#import "GoodDetailViewController.h"
#import "ImageTouchView.h"
#import "TextInput.h"
#import "UIImage+FlatUI.h"
#import "AddCartViewController.h"

@interface ShoppingCartViewController ()<ImageTouchViewDelegate> {
    NSArray  *   shoppingCartArray;
    int         selectedSection;
    UIButton * lastSelected;
    UIView * footerView;
}

@end

@implementation ShoppingCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableViewCellHeight = 80;
    tableView.backgroundColor =
    self.view.backgroundColor = RGBCOLOR(239, 239, 239);
    
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 100)];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(40, 50, App_Frame_Width - 80, 40);
    button.backgroundColor = RGBCOLOR(203,69,75);
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(172,11,39) cornerRadius:0] forState:UIControlStateHighlighted];
    [footerView addSubview:button];
    [button addTarget:self action:@selector(sendCart) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sendCart {
    if (btnRight.selected) {
        [self showText:@"请完成购物车修改后在提交订单"];
    } else {
        Shop * it = [contentArr objectAtIndex:selectedSection];
        AddCartViewController * con = [[AddCartViewController alloc] init];
        con.shop = it;
        [self pushViewController:con];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    shoppingCartArray = [ShoppingCart valueListFromDB];
    self.title = [NSString stringWithFormat:@"购物车(%d)", [ShoppingCart goodsCount]];
    if (shoppingCartArray.count > 0) {
        selectedSection = 0;
        [self setRightBarButtonImage:LOADIMAGE(@"购物车编辑") highlightedImage:LOADIMAGE(@"购物车编辑按下") selector:@selector(edit:)];
        [btnRight setImage:LOADIMAGE(@"购物车编辑完成") forState:UIControlStateSelected];
        btnRight.enabled = YES;
    } else {
        btnRight.enabled = NO;
        tableView.tableFooterView = nil;
    }
    if (contentArr.count > 0) {
        NSMutableArray * delArr = [NSMutableArray array];
        
        if (contentArr && contentArr.count > 0) {
            [contentArr enumerateObjectsUsingBlock:^(Shop *obj, NSUInteger idx, BOOL *stop) {
                if (obj.goods.count == 0) {
                    [delArr addObject:obj];
                }
            }];
        }

        if (delArr && delArr.count > 0) {
            [delArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [contentArr removeObject:obj];
            }];
        }

        [tableView reloadData];
    }
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        NSString * str = [self jsonString];
        if (str.hasValue) {
            [super startRequest];
            [client cartGoodsList:str];
        }
    } else {
        [tableView reloadData];
    }
}

- (void)edit:(UIButton*)sender {
    sender.selected = !sender.selected;
    [tableView reloadData];
}

- (NSString*)jsonString {
    NSMutableArray * arr = [NSMutableArray array];
    int countCart = 0;
    
    while (countCart < shoppingCartArray.count) {
        ShoppingCart * cart = [shoppingCartArray objectAtIndex:countCart];
        __block NSMutableDictionary * found = nil;
        
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                if ([[obj allKeys][0] isEqualToString:cart.shopid]) {
                    [arr removeObject:obj];
                    found = [NSMutableDictionary dictionaryWithDictionary:obj];
                    *stop = YES;
                }
            }];
        }

        if (found) {
            NSArray * test = [[found allValues][0] componentsSeparatedByString:@","];
            NSMutableArray * allValues = [NSMutableArray arrayWithArray:test];
            [allValues addObject:cart.goodid];
            [found setObject:[allValues componentsJoinedByString:@","] forKey:cart.shopid];
        
        } else {
            found = [NSMutableDictionary dictionaryWithObject:cart.goodid forKey:cart.shopid];
        }
        [arr addObject:found];
        countCart++;
    }
    NSMutableString * jsonString = nil;
    if (arr.count > 0) {
        jsonString = [[NSMutableString alloc] initWithString:@"{"];
        
        if (arr && arr.count > 0) {
            [arr enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                if (jsonString.length > 1) {
                    [jsonString appendString:@","];
                }
                [jsonString appendFormat:@"\"%@\":\"%@\"", obj.allKeys[0], obj.allValues[0]];
                
            }];
        }

        [jsonString appendString:@"}"];
    }
    // such as {"1":"1,2,3,4","2":"5,6,7"}
    return jsonString;
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        NSArray * array = [obj getArrayForKey:@"data"];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Shop * it = [Shop objWithJsonDic:obj];
            [contentArr addObject:it];
        }];
        [tableView reloadData];
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)sender {
    return contentArr.count;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    Shop * it = [contentArr objectAtIndex:section];
    return it.goods.count;
}

- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    return 28;
}

- (CGFloat)tableView:(UITableView *)sender heightForFooterInSection:(NSInteger)section {
    return 45;
}

- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    static NSString * HeaderIdentifier = @"HeaderIdentifier";
    UITableViewHeaderFooterView *myHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
    UIButton * button = VIEWWITHTAG(myHeader.contentView, 111);
    if(!myHeader) {
        [tableView registerClass:UITableViewHeaderFooterView.class forHeaderFooterViewReuseIdentifier:@"HeaderIdentifier"];
        myHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:HeaderIdentifier];
        myHeader.contentView.backgroundColor = RGBCOLOR(229,229,229);
    }
    Shop * it = [contentArr objectAtIndex:section];
    UILabel * label = [UILabel linesText:it.name font:[UIFont systemFontOfSize:16] wid:sender.width - 50 lines:1 color:RGBCOLOR(34,34,34)];
    label.height = 28;
    label.left = 40;
    [myHeader.contentView addSubview:label];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 111;
    button.frame = CGRectMake(10, 5, 18, 18);
    [button setImage:LOADIMAGECACHES(@"订单") forState:UIControlStateNormal];
    [button setImage:LOADIMAGECACHES(@"订单选中") forState:UIControlStateSelected];
    [button addTarget:self action:@selector(preBuy:) forControlEvents:UIControlEventTouchUpInside];
    button.indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [myHeader.contentView addSubview:button];
    button.selected = section == selectedSection;
    return myHeader;
}

- (UIView*)tableView:(UITableView *)sender viewForFooterInSection:(NSInteger)section {
    static NSString * HeaderIdentifier = @"FooterIdentifier";
    UITableViewHeaderFooterView *myFooter = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];

    if(!myFooter) {
        [tableView registerClass:UITableViewHeaderFooterView.class forHeaderFooterViewReuseIdentifier:@"HeaderIdentifier"];
        myFooter = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:HeaderIdentifier];
        myFooter.contentView.backgroundColor = RGBCOLOR(239,239,239);
    }
    
    Shop * it = [contentArr objectAtIndex:section];
    __block double money = 0;
    [it.goods enumerateObjectsUsingBlock:^(Good * obj, NSUInteger idx, BOOL *stop) {
        ShoppingCart * cart = [ShoppingCart goodsFromeDB:obj.id shopid:obj.shopid];
        money += obj.price.doubleValue * cart.goodCount.intValue;
    }];
    NSString * mon = [NSString stringWithFormat:@"¥ %0.2f", money];
    NSString * str = [NSString stringWithFormat:@"您需支付: %@", mon];
    NSRange range = [str rangeOfString:mon];
    UILabel * label = [UILabel linesText:it.name font:[UIFont systemFontOfSize:14] wid:sender.width - 50 lines:1 color:RGBCOLOR(34,34,34)];
    label.textAlignment = NSTextAlignmentRight;
    label.width = sender.width - 20;
    label.height = 45;
    label.right = sender.right - 10;
    
    NSMutableAttributedString * attriString = [[NSMutableAttributedString alloc] initWithString:str];
    [attriString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(224,58,47) range:range];
    label.attributedText = attriString;
    [myFooter.contentView addSubview:label];
    return myFooter;
}

- (BaseTableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"BaseTableViewCell";
    BaseTableViewCell * cell = [sender dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton * buttonplus = VIEWWITHTAG(cell.contentView, 111);
    UIButton * buttonminus = VIEWWITHTAG(cell.contentView, 112);
    KTextField  * tField = VIEWWITHTAG(cell.contentView, 113);
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = RGBCOLOR(46,46,46);
        cell.detailTextLabel.textColor = RGBCOLOR(224,45,31);
        cell.labOther.textAlignment = NSTextAlignmentRight;
        cell.touchButton = [[UIButton alloc] init];
        [cell.touchButton setImage:LOADIMAGE(@"icon_delete") forState:UIControlStateNormal];
        [cell.touchButton addTarget:self action:@selector(imageTouchViewDidSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:cell.touchButton];
        cell.touchButton.alpha = 0;
        cell.touchButton.contentMode = UIViewContentModeCenter;
        
        buttonplus = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonplus.tag = 111;
        [buttonplus setImage:LOADIMAGE(@"购物车添加") forState:UIControlStateNormal];
        [cell.contentView addSubview:buttonplus];
        [buttonplus addTarget:self action:@selector(plusPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        buttonminus = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonminus.tag = 112;
        [buttonminus setImage:LOADIMAGE(@"购物车减少") forState:UIControlStateNormal];
        [cell.contentView addSubview:buttonminus];
        [buttonminus addTarget:self action:@selector(minusPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        tField = [[KTextField alloc] init];
        tField.tag = 113;
        tField.enabled = NO;
        [tField enableBorder];
        [cell.contentView addSubview:tField];
        tField.placeholder = @"1";
        tField.font = [UIFont systemFontOfSize:12];
    }
    
    buttonminus.indexPath =
    buttonplus.indexPath = indexPath;
    
    Shop * it = [contentArr objectAtIndex:indexPath.section];
    Good * good = it.goods[indexPath.row];
    ShoppingCart * cart = [ShoppingCart goodsFromeDB:good.id shopid:it.id];
    cell.labOther.text =
    tField.text = cart.goodCount;
    cell.textLabel.text = good.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"¥ %0.2f", good.price.doubleValue];
    [cell update:^(NSString *name) {
        CGSize size = [good.name sizeWithFont:cell.textLabel.font maxWidth:sender.width - (cell.height - 20) - 20 maxNumberLines:2];
        cell.textLabel.size = size;
        cell.userInteractionEnabled = YES;
        size = [cell.detailTextLabel.text sizeWithFont:cell.textLabel.font maxWidth:sender.width - (cell.height - 20) - 20 maxNumberLines:1];
        cell.detailTextLabel.size = size;
        
        cell.imageView.frame = CGRectMake(10, 10, cell.height - 20, cell.height - 20);
        cell.textLabel.origin = CGPointMake(cell.imageView.right + 10, cell.imageView.top);
        cell.detailTextLabel.left = cell.imageView.right + 10;
        cell.detailTextLabel.bottom = cell.imageView.bottom;
        cell.labOther.frame = CGRectMake(cell.width - 50, cell.detailTextLabel.top, 40, 20);
        headImageViewSize = (cell.height - 20)*2;
        
       [UIView animateWithDuration:0.25
                        animations:^{
                            if (btnRight.selected) {
                                cell.touchButton.alpha = 1;
                                cell.contentView.left = 30;
//                                tableView.allowsSelection = NO;
                                buttonminus.hidden =
                                buttonplus.hidden =
                                tField.hidden = NO;
                                tableView.allowsSelection = NO;
                            } else {
//                                tableView.allowsSelection = YES;
                                cell.touchButton.alpha = 0;
                                cell.contentView.left = 0;
                                buttonminus.hidden =
                                buttonplus.hidden =
                                tField.hidden = YES;
                                tableView.allowsSelection = YES;
                            }
                        }];
        cell.touchButton.size = CGSizeMake(30, cell.height);
        cell.touchButton.origin = CGPointMake(0, (cell.height - cell.touchButton.height)/2);
        cell.touchButton.indexPath = indexPath;
        buttonminus.frame = CGRectMake(cell.width - 140, cell.detailTextLabel.top- 10, 30, 24);
        tField.frame = CGRectMake(cell.width - 105, cell.detailTextLabel.top - 10, 30, 24);
        buttonplus.frame = CGRectMake(cell.width - 70, cell.detailTextLabel.top - 10, 30, 24);
    }];
    if (contentArr.count == indexPath.section + 1) {
        tableView.tableFooterView = footerView;
    }
    return cell;
}

- (void)plusPressed:(UIButton *)sender {
    Shop * it = [contentArr objectAtIndex:sender.indexPath.section];
    Good * good = it.goods[sender.indexPath.row];
    ShoppingCart * cart = [ShoppingCart goodsFromeDB:good.id shopid:it.id];
 
    int d = cart.goodCount.intValue;
    d++;
    cart.goodCount = @(d).stringValue;
    [cart updateVaule:cart.goodCount key:@"goodCount"];
    
    [tableView reloadRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationNone];
    self.title = [NSString stringWithFormat:@"购物车(%d)", [ShoppingCart goodsCount]];
}

- (void)minusPressed:(UIButton *)sender {
    Shop * it = [contentArr objectAtIndex:sender.indexPath.section];
    Good * good = it.goods[sender.indexPath.row];
    ShoppingCart * cart = [ShoppingCart goodsFromeDB:good.id shopid:it.id];
    if (cart.goodCount.intValue > 1) {
        int d = cart.goodCount.intValue;
        d--;
        cart.goodCount = @(d).stringValue;
        [cart updateVaule:cart.goodCount key:@"goodCount"];
        [tableView reloadRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    self.title = [NSString stringWithFormat:@"购物车(%d)", [ShoppingCart goodsCount]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [tableView resignFirstResponder];
}

- (void)tableView:(UITableView *)sender willDisplayCell:(BaseTableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [Globals getImageGoodHeadDefault];
    NSInvocationOperation * opHeadItem = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadHeadImageWithIndexPath:) object:indexPath];
    [baseOperationQueue addOperation:opHeadItem];
}

- (NSString*)baseTableView:(UITableView *)sender imageURLAtIndexPath:(NSIndexPath *)indexPath {
    Shop * it = [contentArr objectAtIndex:indexPath.section];
    Good * good = it.goods[indexPath.row];
    return good.logo;
}

- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    Shop * shop = [contentArr objectAtIndex:indexPath.section];
    Good * good = shop.goods[indexPath.row];
    GoodDetailViewController * con = [[GoodDetailViewController alloc] init];
    con.goods = good;
    con.shop = shop;
    [self pushViewController:con];
}

- (void)imageTouchViewDidSelected:(UIButton*)sender {
    
    Shop * it = [contentArr objectAtIndex:sender.indexPath.section];
    Good * good = it.goods[sender.indexPath.row];
    
    ShoppingCart * cart = [ShoppingCart goodsFromeDB:good.id shopid:it.id];
    [cart deleteFromDB];
    [it.goods removeObject:good];
    if (it.goods.count == 0) {
        [contentArr removeObject:it];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:sender.indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        [tableView deleteRowsAtIndexPaths:@[sender.indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView reloadData];
        shoppingCartArray = [ShoppingCart valueListFromDB];
        if (shoppingCartArray.count == 0) {
            tableView.tableFooterView = nil;
        }
        self.title = [NSString stringWithFormat:@"购物车(%d)", [ShoppingCart goodsCount]];
    });
}

- (void)preBuy:(UIButton*)sender {
    UIView * view = [tableView headerViewForSection:selectedSection];
    UIButton * button = VIEWWITHTAG(view, 111);
    button.selected = NO;
    
    selectedSection = (int)sender.indexPath.section;
    sender.selected = YES;
    
    [tableView reloadData];
}

@end
