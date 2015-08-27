//
//  ScrollViewHeaderView.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "ScrollViewHeaderView.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "JSBadgeView.h"

@interface ScrollViewHeaderView ()

@end
@implementation ScrollViewHeaderView
@synthesize nameArray, selectedBtn, selecdBlock, selecedBlackgroundView,menucount,iconsArray,iconsSelectedArray;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self loadView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadView];
    }
    return self;
}

- (void)loadView {
    menucount=5;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = RGBCOLOR(247, 247, 247);
    self.alwaysBounceHorizontal = YES;
    //选中背景设置
   //self.selecedBlackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height - 2, 78, 2)];
   // self.selecedBlackgroundView.image = [UIImage imageWithColor:kbColor cornerRadius:1];
    
     //  [self addSubview:[self selecedBlackgroundView]];
}

- (void)dealloc {
    self.selecedBlackgroundView = nil;
    self.nameArray = nil;
    self.iconsArray=nil;
    self.iconsSelectedArray=nil;
}

- (void)setNameArray:(NSArray *)arr {
    nameArray = arr;
    if (arr.count <= menucount) {
        self.maxButtonWidth = self.width/arr.count;
    } else {
        self.maxButtonWidth = 80;
    }
    
    self.selecedBlackgroundView.width = self.maxButtonWidth;
    self.selecedBlackgroundView.left = 0;
    [self reloadData];
}

- (void)setSelectedBtn:(NSInteger)selected {
    selectedBtn = selected + 100;
    for (UIButton *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            btn.selected = NO;
            if (btn.tag == selected) {
                btn.selected = YES;
                [UIView animateWithDuration:0.1 animations:^{
                    self.selecedBlackgroundView.left = selected*selecedBlackgroundView.width;
                }];
            }
        }
    }
}

/**
 *  为指定按钮更新消息数
 *
 */
- (void)setBadgeValueAtIndex:(NSInteger)idx withContent:(NSString*)content {
    if ([content isEqualToString:@"0"]) {
        content = nil;
    }
    UIView * btn = VIEWWITHTAG(self, idx);
    UIImageView * badgeView = VIEWWITHTAG(btn, 11);
    badgeView.hidden = YES;
    if ([content isEqual:@"-1"]) {
        badgeView.hidden = NO;
    } else {
        UIButton * btn = VIEWWITHTAG(self, idx);
        JSBadgeView * badgeView = VIEWWITHTAG(btn, 10);
        badgeView.badgeText = content;
    }
    
}

- (void)reloadData
{
    // 计算排列间距，每页最大为5；
    for (UIButton *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn removeFromSuperview];
        }
        if ([btn isKindOfClass:[UIImageView class]] && btn.tag > 0) {
            [btn removeFromSuperview];
        }
    }
    CGFloat totalWidth = 16;
    //设置菜单按钮
    for (int i = 0;i < nameArray.count;i++) {
        UIButton *btn = [self buttonWithTitle:nameArray[i]];
        btn.tag = i;
       
        //btn.frame = CGRectMake(totalWidth, 0, _maxButtonWidth-10, self.height-10);
        //self.backgroundColor=[UIColor blackColor];
        btn.frame = CGRectMake(totalWidth, 0, 56, self.height-5);
        
        btn.contentVerticalAlignment =UIControlContentVerticalAlignmentTop;
        btn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        //btn.backgroundColor=[UIColor redColor];
        btn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
        
        if (iconsArray && i < [iconsArray count]) {
            [btn setImage:[UIImage imageNamed:iconsArray[i]]  forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:iconsSelectedArray[i]]  forState:UIControlStateSelected];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0,0, 0, 10)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(30, -30, 0, 0)];
        } else {
            [btn setContentMode:UIViewContentModeCenter];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(10, 4, 0, 0)];
        }

        if (i == selectedBtn) {
            btn.selected = YES;
            
        }
        [self addSubview:btn];
        
        /*
        JSBadgeView * badgeView = [[JSBadgeView alloc] init];
        badgeView.badgeAlignment = JSBadgeViewAlignmentNone;
        
        badgeView.origin = CGPointMake(btn.titleLabel.right+2, self.height);
        [btn addSubview:badgeView];
        badgeView.tag = 10;
        
        UIImageView * redView = [[UIImageView alloc] init];
        redView.size = CGSizeMake(7, 7);
        redView.image = LOADIMAGE(@"bkg_find");
        redView.origin = CGPointMake(btn.titleLabel.right+5, (self.height - redView.height)/2);
        [btn addSubview:redView];
        redView.hidden = YES;
        redView.tag = 11;
        
        UIImageView * view = [[UIImageView alloc] initWithFrame:CGRectMake(totalWidth, 10, 1, 24)];
        view.image = [UIImage imageNamed:@"SecretaryCut_line" isCache:YES];
        [self addSubview:view];
         */
        totalWidth += _maxButtonWidth;
    }
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(totalWidth, 10, 1, 24)];
    view.image = [UIImage imageNamed:@"SecretaryCut_line" isCache:YES];
    [self addSubview:view];
    
    // 翻页
    [self setContentSize:CGSizeMake(totalWidth, self.height)];
}


- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] cornerRadius:0] forState:UIControlStateNormal];
    [btn setTitleColor:RGBCOLOR(69, 192, 27) forState:UIControlStateSelected];
    [btn setTitleColor:RGBCOLOR(126, 126, 126) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(reloadBySelect:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}


- (void)reloadBySelect:(UIButton*)sender
{
    if (selectedBtn == sender.tag) {
        return;
    }
    sender.selected = !sender.selected;
    selectedBtn = sender.tag;
    for (UIButton *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            if (sender.tag != btn.tag) {
                btn.selected = NO;
            }
        }
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.selecedBlackgroundView.left = sender.tag * selecedBlackgroundView.width;
    } completion:^(BOOL finished) {
        if (finished) {
            if (self.selecdBlock) {
                self.selecdBlock(selectedBtn);
            }
        }
    }];
}

@end
