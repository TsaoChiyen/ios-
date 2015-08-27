//
//  AddCommentViewController.h
//  weiyuan
//
//  Created by Kiwaro on 15-2-8.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "BaseViewController.h"
@class Good, Comment;
@protocol AddCommentDelegate <NSObject>
- (void)AddCommentAction:(NSString *)newCount newComment:(Comment*)newComment star:(NSString *)star;
@end

@interface AddCommentViewController : BaseViewController

@property (nonatomic, strong) Good * goods;
@property (nonatomic, strong) id<AddCommentDelegate> delegate;

@end
