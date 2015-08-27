//
//  ImageViewController.m
//  huazhuangpin
//
//  Created by Kiwaro on 14-11-20.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import "ImageViewController.h"
#import "UIImageView+WebCache.h"

@interface ImageViewController ()<UIGestureRecognizerDelegate> {
    CGRect screenFrame;
    CGFloat hw;
    CGFloat std_hw;
    
    CGRect startFrame;
    NSString * imageURL;
    
    id preURL;
    
    UINavigationController * supCon;
    CGRect contentFrame;
    id weak;
}

@property (nonatomic, assign) CGRect startFrame;

@end

@implementation ImageViewController
@synthesize startFrame;

- (id)initWithFrameStart:(CGRect)fra supCon:(UINavigationController*)con pic:(NSString*)pic preview:(id)pre {
    if (self = [super initWithNibName:@"ImageViewController" bundle:nil]) {
        // Custom initialization
        supCon = con;
        startFrame = fra;
        imageURL = pic;
        preURL = pre;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.view.backgroundColor = [UIColor clearColor];
    
    scrollView.userInteractionEnabled = NO;
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    imgV.frame = self.startFrame;
    imgV.clipsToBounds = YES;
    imgV.contentMode = UIViewContentModeScaleAspectFill;
    
    if (_bkgImage) {
        UIImageView * bkgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:bkgView atIndex:0];
        detailImageView.image = _bkgImage;
    }
    self.navigationItem.title = @"详细";
    
    if (_lookPictureState == forLookPictureStateDownload) {
        [self setRightBarButtonImage:@"icon_download" highlightedImage:nil selector:@selector(morePressed)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isFirstAppear) {
        if (_lookPictureState == forLookPictureStateDownload) {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        } else {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
        [UIView beginAnimations:@"SHOW" context:nil];
        [UIView setAnimationDuration:0.35];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];
        scrollView.backgroundColor = [UIColor blackColor];
        [self updateImage];
        [UIView commitAnimations];
    }
}

- (void)morePressed {
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    UIImageWriteToSavedPhotosAlbum([imgV image], self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
}

- (void)show {
    weak = self;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    self.view.frame = window.screenFrame;
    [self viewDidAppear:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    if (!error) {
        [self showText:@"图片已经保存到相册"];
    } else {
        [self showText:error.localizedFailureReason];
    }
}

- (void)kwAlertView:(id)sender didDismissWithButtonIndex:(NSInteger)index {
    if (index == 1) {
        [self back];
    }
}

- (void)back {
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    if (imgV) {
        [imgV sd_cancelCurrentImageLoad];
    }
#if __IPHONE_7_0
    if ([UIDevice currentDevice].systemVersion.intValue < 7) {
#endif
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
#if __IPHONE_7_0
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
#endif
    if (scrollView.zoomScale > 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
        [self performSelector:@selector(backAnimation) withObject:nil afterDelay:0.3];
    } else {
        [self performSelector:@selector(backAnimation)];
    }
}

- (void)doubleTap{
    if (scrollView.zoomScale > 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
    } else {
        [scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
    }
}

- (void)popViewController {
    [self back];
}

- (void)singleTap {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self popViewController];
}

- (void)backAnimation {
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    [UIView animateWithDuration:0.35 animations:^{
        imgV.frame = self.startFrame;
        scrollView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        if (_lookPictureState == forLookPictureStateDownload) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
        [self.navigationController popViewControllerAnimated:NO];
        [self.view removeFromSuperview];
        Release(weak);
    }];
    
}

- (void)animationEnd:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    if ([animationID isEqualToString:@"SHOW"]) {
        UIWindow * window = [UIApplication sharedApplication].keyWindow;
        window.userInteractionEnabled = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [scrollView addGestureRecognizer:doubleTapGesture];
        
        UITapGestureRecognizer * singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        singleTapGesture.numberOfTapsRequired = 1;
        [scrollView addGestureRecognizer:singleTapGesture];
        
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        scrollView.userInteractionEnabled = YES;
        
        if (_lookPictureState == forLookPictureStateDownload) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    } else if ([animationID isEqualToString:@"HIDE"]) {
        if (_lookPictureState == forLookPictureStateDownload) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        }
        [self.navigationController popViewControllerAnimated:NO];
        [self.view removeFromSuperview];
        Release(weak);
        
    }
}


#pragma mark -
#pragma mark - Scroll View Zoom

- (void)updateImage {
    screenFrame = self.view.bounds;
    [indicatorView startAnimating];
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    [self updateImage:preURL];
    [imgV sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:(id)preURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [indicatorView stopAnimating];
        if (image) {
            [self updateImage:image];
        }
    }];
}

- (void)updateImage:(UIImage*)image {
    UIImageView * imgV = (UIImageView*)[scrollView viewWithTag:63];
    std_hw = screenFrame.size.height/screenFrame.size.width;
    CGFloat kw = screenFrame.size.width;
    CGFloat kh = screenFrame.size.height;
    hw = image.size.height/image.size.width;
    
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat contentWidth = kw;
        CGFloat contentHeight = kh;
        if (hw > std_hw) {
            contentWidth = contentHeight/hw;
            [imgV setFrame:CGRectMake((kw-contentWidth)/2, -5, contentWidth, contentHeight+10)];
        } else if (hw < std_hw) {
            contentHeight = contentWidth*hw;
            [imgV setFrame:CGRectMake(0, (kh-contentHeight)/2-5, contentWidth, contentHeight+10)];
        }
        
        CGFloat biggerTime = image.size.width/kw;
        if (image.size.height/kh > biggerTime) {
            biggerTime = image.size.height/kh;
        }
        biggerTime += 0.8;
        if (biggerTime < 1.5) {
            biggerTime = 1.5;
        }
        scrollView.maximumZoomScale = biggerTime;
        scrollView.userInteractionEnabled = YES;
    }];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)sender {
    return [scrollView viewWithTag:63];
}

- (void)scrollViewDidZoom:(UIScrollView*)sender {
    if (sender.zoomScale > 1) {
        if (![UIApplication sharedApplication].statusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
    } else {
        if ([UIApplication sharedApplication].statusBarHidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
    }
    
    UIImageView * imgView = (UIImageView*)[scrollView viewWithTag:63];
    CGRect frame = imgView.frame;
    
    if (hw > std_hw) {
        frame.origin.x = (screenFrame.size.width-frame.size.width)/2;
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        }
    } else if (hw < std_hw) {
        frame.origin.y = (screenFrame.size.height-frame.size.height)/2;
        if (frame.origin.y < 0) {
            frame.origin.y = 0;
        }
    }
    
    [imgView setFrame:frame];
}

#pragma mark - requset
- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
    }
    return YES;
}
@end
