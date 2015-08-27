//
//  Star.m
//  NewZhiyou
//
//  Created by user on 11-8-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Star.h"
#import "ColorHelper.h"

#define kColorStarEmpty kColorGray
#define kColorStarFull  kColorRed

@interface Star (){
    UIImageView * sStarsView;
    CGFloat showWidth;
    NSInteger pre_star;
    CGFloat height;
}

@end

@implementation Star
@synthesize max_star, show_star;
@synthesize isSelect;

static UIImage * nStars;
static UIImage * sStars;

static UIImageView * nStarsView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    max_star = 5;
    show_star = 0;
    isSelect = NO;
    nStarsView = [[UIImageView alloc] initWithFrame:self.bounds];
    nStars= LOADIMAGECACHES(@"b27_icon_star_gray");
    sStars= LOADIMAGECACHES(@"b27_icon_star_yellow");
    CGFloat px = 0;
    height = self.height;
    if (height < nStars.size.height) {
        height = self.height - 8;
    } else {
        height = sStars.size.height;
    }
    for (int i = 0; i<max_star; i++) {
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(px,(self.height - height)/2, height, height)];
        image.image = LOADIMAGECACHES(@"b27_icon_star_gray");
        [nStarsView addSubview:image];
        px += height;
    }
    [self addSubview:nStarsView];
    
    sStarsView = [[UIImageView alloc] initWithFrame:self.bounds];
    px = 0;
    for (int i = 0; i<max_star; i++) {
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(px,(self.height - height)/2, height, height)];
        image.image = LOADIMAGECACHES(@"b27_icon_star_yellow");
        image.tag = i+10;
        [sStarsView addSubview:image];
        px += height;
    }
    sStarsView.width = px;
    nStarsView.left = 
    sStarsView.left = 5;
    sStarsView.clipsToBounds = YES;
    [self addSubview:sStarsView];
    
    showWidth = sStarsView.width;
    sStarsView.width = 0;
//    self.backgroundColor = [UIColor clearColor];
}

- (void)setIsSelect:(BOOL)isS {
    isSelect = isS;
    if (isSelect) {
        
        nStarsView.left =
        sStarsView.left = 0;
    }
}

- (void)setMax_star:(NSInteger)maxCount {
    max_star = maxCount;
}

- (void)setShow_star:(NSInteger)showCount {
    show_star = showCount;
    CGFloat offset = show_star * height;
    UIView * view = VIEWWITHTAG(sStarsView, 10+show_star-1);
    [UIView animateWithDuration:show_star*0.1 animations:^{
        sStarsView.width = offset;
        view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isSelect) {
        CGPoint pt = [[touches anyObject] locationInView:self];
        if (pt.x > nStarsView.width + 5) {
            return;
        }
        CGFloat animatetime;
        NSInteger next_star = (NSInteger)(max_star * (pt.x + (showWidth/max_star)) / showWidth);
        pre_star = show_star;
        NSInteger tag_star = next_star - 1;
        if (next_star == show_star) {
            animatetime = abs((int)(next_star - show_star))*0.1;
            show_star = next_star;
        } else {
            animatetime = abs((int)(next_star - show_star))*0.1;
            show_star = next_star;
        }
        if (show_star > max_star) {
            show_star = max_star;
        }
        if (show_star < 0) {
            show_star = 0;
        }
        UIView * view = VIEWWITHTAG(sStarsView, 10+tag_star);
        CGFloat offset = show_star * height;
        [UIView animateWithDuration:animatetime animations:^{
            sStarsView.width = offset;
            view.transform = CGAffineTransformMakeScale(1.25, 1.25);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                view.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (isSelect) {
        CGPoint pt = [[touches anyObject] locationInView:self];
        if (pt.x > nStarsView.width + 5) {
            return;
        }
        
        show_star = (NSInteger)(max_star * (pt.x + (showWidth/max_star)) / showWidth);
        if (show_star > max_star) {
            show_star = max_star;
        }
        if (show_star < 0) {
            show_star = 0;
        }
        UIView * view = VIEWWITHTAG(sStarsView, 10+show_star-1);
        [UIView animateWithDuration:show_star*.1 animations:^{
            sStarsView.width = show_star * sStars.size.width;
            if (pre_star != show_star) {
                view.transform = CGAffineTransformMakeScale(1.25, 1.25);
            }
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                view.transform = CGAffineTransformIdentity;
            }];
            pre_star = show_star;
        }];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (isSelect) {
        CGPoint pt = [[touches anyObject] locationInView:self];
        if (pt.x > nStarsView.width + 5) {
            return;
        }
        
        UIView * view = VIEWWITHTAG(sStarsView, 10+show_star-1);
        [UIView animateWithDuration:.25 animations:^{
            if (pre_star == 1 && show_star == 1) {
                sStarsView.width = 0;
                show_star = pre_star = 0;
            }
            view.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                view.transform = CGAffineTransformIdentity;
            }];
            pre_star = show_star;
        }];
    }
}

@end
