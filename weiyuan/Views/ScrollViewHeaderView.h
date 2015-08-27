//
//  ScrollViewHeaderView.h
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ScrollViewSelecd)(NSInteger seleted);

@interface ScrollViewHeaderView : UIScrollView
@property (nonatomic, strong) UIImageView *selecedBlackgroundView;
@property (nonatomic, assign) NSInteger selectedBtn;
@property (nonatomic, strong) NSArray* nameArray;
@property (nonatomic, strong) NSArray* iconsArray;
@property (nonatomic, strong) NSArray* iconsSelectedArray;
@property (nonatomic, copy) ScrollViewSelecd selecdBlock;
@property (nonatomic, assign) CGFloat maxButtonWidth;
@property (nonatomic, assign) NSInteger menucount;
/**
 *  为指定按钮更新消息数
 *
 */
- (void)setBadgeValueAtIndex:(NSInteger)idx withContent:(NSString*)content;
@end
