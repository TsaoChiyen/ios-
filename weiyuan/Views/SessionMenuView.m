//
//  SessionMenuView.m
//  reSearchDemo
//
//  Created by helfy  on 15-4-19.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "SessionMenuView.h"
#import "MButton.h"
@implementation SessionMenuItem

+(id)sessionMenuItemFor:(NSString *)title iconImage:(UIImage *)iconImage
{
    SessionMenuItem *meunItem = [SessionMenuItem alloc];
    meunItem.title = title;
    meunItem.iconImage = iconImage;
    
    return meunItem;
}

+(id)sessionMenuItemFor:(NSString *)title iconFileName:(NSString *)iconFileName
{
    SessionMenuItem *meunItem = [SessionMenuItem alloc];
    meunItem.title = title;
    meunItem.iconFileName = iconFileName;
    
    return meunItem;
}


@end

@implementation SessionMenuView
{
    UIView *contentView;
    UIButton *cancelButton;
    
    NSArray *itemArrays;
}


-(id)init
{
    self = [super init];
    if(self)
    {
        contentView = [UIView new];
        [self addSubview:contentView];
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(260);
            make.bottom.equalTo(self).offset(260);
            make.left.right.equalTo(self);
            
        }];
        
        cancelButton = [[UIButton alloc] init];
        [contentView addSubview:cancelButton];
      
        [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(contentView);
            make.left.right.equalTo(contentView);
            make.height.equalTo(60);
        }];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
//        tap.delegate = (id)self;
//        [self addGestureRecognizer:tap];
        contentView.backgroundColor = RGB(240, 242, 242);
    
    }
    return self;
}

-(void)setItems:(NSArray *)items
{
    
    int w = [[UIScreen mainScreen] bounds].size.width/4;
    UIView *preView=nil;
    for (int index=0;index<items.count;index++) {
        SessionMenuItem *item = items[index];
        MButton *button = [[MButton alloc] init];
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        
        
        [button  setImageShowSize:CGSizeMake(60, 60)];
        button.arrangement = MButtonContentArrangementVertical;
        [contentView addSubview:button];
        [button setTitle:item.title forState:UIControlStateNormal];
        if(item.iconImage)
        {
        [button setImage:item.iconImage forState:UIControlStateNormal];
        }
        else{
            [button setImage:[UIImage imageNamed:item.iconFileName] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[item.iconFileName stringByAppendingString:@"按下"]] forState:UIControlStateHighlighted];
            
        }
        button.tag = index;
        [button addTarget:self action:@selector(menuButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(w);
            make.height.equalTo(100);
            
            if(index%4 != 0)
            {
                if(preView)
                {
                    make.top.equalTo(preView);
                    make.left.equalTo(preView.mas_right);
                }
                else{
                    make.top.equalTo(contentView);
                    make.left.equalTo(contentView);

                }
            }
            else{
                if(preView)
                {
                    make.left.equalTo(contentView);
                    make.top.equalTo(preView.mas_bottom);
                }
                else{
                    make.left.equalTo(contentView);
                    make.top.equalTo(contentView);
                    
                }
            }
        }];
        
        preView =button;
      
    
    }
}

-(void)menuButtonDidTap:(MButton *)button
{
    self.chooseBlock(button.tag);
    [self cancel];
}

-(void)cancel
{
    [contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(260);
        make.bottom.equalTo(self).offset(260);
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
        make.height.equalTo(260);
        make.bottom.equalTo(self);
        make.left.right.equalTo(self);
        
    }];
    
    
    [UIView beginAnimations:nil context:nil];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [contentView layoutIfNeeded];
    [UIView commitAnimations];
 
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (CGRectContainsPoint(contentView.frame, [touch locationInView:contentView])) {
        return NO;
    }
    
    return YES;
}
@end
