//
//  SessionMenuView.h
//  reSearchDemo
//
//  Created by helfy  on 15-4-19.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionMenuItem : NSObject
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *iconFileName;
@property (nonatomic,strong) UIImage *iconImage;

+(id)sessionMenuItemFor:(NSString *)title iconImage:(UIImage *)iconImage;

+(id)sessionMenuItemFor:(NSString *)title iconFileName:(NSString *)iconFileName;
@end



@interface SessionMenuView : UIView

-(void)showInView:(UIView *)targetView;

-(void)setItems:(NSArray *)items;

@property(nonatomic,strong) void(^chooseBlock)(NSInteger meunIndex);
@end
