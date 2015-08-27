//
//  ImageViewController.h
//  huazhuangpin
//
//  Created by Kiwaro on 14-11-20.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

/**查看类型*/
typedef enum {
    /** 查看和分享收藏*/
    forLookPictureStateMore = 0,
    /** 仅查看*/
    forLookPictureStateNormal,
    /** 查看和删除*/
    forLookPictureStateDownload,
}LookPictureState;

@interface ImageViewController : BaseViewController <UIAlertViewDelegate>{
    IBOutlet UIScrollView            * scrollView;
    IBOutlet UIImageView             * detailImageView;
    IBOutlet UIActivityIndicatorView * indicatorView;
}
@property (nonatomic, strong) UIImage * bkgImage;
@property (nonatomic, assign) LookPictureState lookPictureState;

- (id)initWithFrameStart:(CGRect)fra supCon:(UINavigationController*)con pic:(NSString*)pic preview:(id)pre;
- (void)show;
@end
