//
//  SessionChangeFontView.m
//  reSearchDemo
//
//  Created by helfy  on 15-4-21.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "SessionChangeFontView.h"

@implementation SessionChangeFontView
{
    UIView *contentView;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        contentView = [UIView new];
        [self addSubview:contentView];
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(100);
            make.bottom.equalTo(self).offset(100);
            make.left.right.equalTo(self);
            
        }];
        
        
        
    self.filterControl = [[SEFilterControl alloc]initWithFrame:CGRectMake(10, 20, [[UIScreen mainScreen] bounds].size.width-20, 100) Titles:[NSArray arrayWithObjects:@"14", @"16", @"18", @"20", @"22",  nil]];
//            [filter addTarget:self action:@selector(filterValueChanged:) forControlEvents:UIControlEventValueChanged];
            [contentView addSubview: self.filterControl ];
        
        
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView);
            
        }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    tap.delegate = (id)self;
    [self addGestureRecognizer:tap];
        contentView.backgroundColor = RGB(240, 242, 242);
        
    }
    return self;
}

-(void)setCustomView:(UIView *)coustomView
{
//    SEFilterControl *filter = [[SEFilterControl alloc]initWithFrame:CGRectMake(10, 20, 300, 70) Titles:[NSArray arrayWithObjects:@"Articles", @"News", @"Updates", @"Featured", @"Newest", @"Oldest", nil]];
//    [filter addTarget:self action:@selector(filterValueChanged:) forControlEvents:UIControlEventValueChanged];
//    [self addSubview:filter];
}
-(void)cancel
{
    [contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(100);
        make.bottom.equalTo(self).offset(100);
        make.left.right.equalTo(self);
        
    }];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor clearColor];
        [contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    
}

-(void)showInView:(UIView *)targetView
{
    //    [self loadViewFor:type];
    
    [targetView addSubview:self];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(targetView);
    }];
    [contentView layoutIfNeeded];
    [contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(100);
        make.bottom.equalTo(self);
        make.left.right.equalTo(self);
        
    }];
    
    
    [UIView beginAnimations:nil context:nil];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [contentView layoutIfNeeded];
    [UIView commitAnimations];
    
}
@end
