//
//  NewsView.h
//  reSearchDemo
//
//  Created by Jinjin on 15/4/17.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Message;
typedef void(^NewsDidTapBlock) (NSDictionary *newsDict);

@interface NewsView : UIView

- (void)loadNewsWithNews:(id)news;
+ (CGFloat)heightForMessage:(Message*)item;
@property (nonatomic,strong) NewsDidTapBlock newsDidTap;
@end
