//
//  BaseCollectionViewCell.m
//  huazhuangpin
//
//  Created by Kiwaro on 14-11-19.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import "BaseCollectionViewCell.h"
#import "Globals.h"

@interface BaseCollectionViewCell ()<UIGestureRecognizerDelegate, ImageTouchViewDelegate>{
    UILongPressGestureRecognizer *longPress;
}

@end

@implementation BaseCollectionViewCell
@dynamic indexPath;

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)setSelected:(BOOL)sel {
    [super setSelected:sel];
    _nameLabel.highlighted = sel;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, self.width, 20)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.highlightedTextColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UIImageView*)imageView {
    if (!_imageView) {
        _imageView = [[ImageTouchView alloc] initWithFrame:CGRectMake(10, 0, 45, 45)];
        _imageView.delegate = self;
        _imageView.image = [Globals getImageDefault];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 2;
        [self.contentView insertSubview:_imageView belowSubview:_nameLabel];
    }
    return _imageView;
}

- (void)enableLongPress {
    if (!longPress) {
        longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longPressed:)];
        longPress.delegate = self;
        longPress.minimumPressDuration = 0.5f;
        [self.contentView addGestureRecognizer:longPress];
    }
}

- (UIImageView*)imageViewDelete {
    if (!_imageViewDelete) {
        _imageViewDelete = [[UIImageView alloc] initWithImage:LOADIMAGE(@"icon_delete")];
        _imageViewDelete.size = CGSizeMake(20, 20);
        [self.contentView addSubview:_imageViewDelete];
    }
    _imageViewDelete.origin = CGPointMake(_imageView.right - _imageViewDelete.width/2 - 4, _imageView.top - _imageViewDelete.width/2 + 4);
    return _imageViewDelete;
}

#pragma mark - set Methods
- (void)setEdit:(BOOL)et {
    _edit = et;
    self.imageViewDelete.hidden = !et;
    if (et) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        // 动画选项设定
        animation.duration = 0.3; // 动画持续时间
        animation.repeatCount = INT_MAX; // 重复次数
        animation.autoreverses = YES; // 动画结束时执行逆动画
        
        // 缩放倍数
        animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
        animation.toValue = [NSNumber numberWithFloat:1.5]; // 结束时的倍率
        
        [_imageViewDelete.layer addAnimation:animation forKey:@"keyFrameAnimation"];
    } else {
        [_imageViewDelete.layer removeAllAnimations];
    }
}

- (void)setTitle:(NSString *)t {
    self.nameLabel.text = t;
}

- (void)setImage:(UIImage *)ima {
    self.imageView.image = ima;
}

#pragma mark - UITapGestureDelegate
- (void)imageTouchViewDidSelected:(id)sender {
    if ([_superCollectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [_superCollectionView.delegate performSelector:@selector(collectionView:didSelectItemAtIndexPath:) withObject:self.superCollectionView withObject:self.indexPath];
    }
}

- (void)longPressed:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        if ([_superCollectionView.delegate respondsToSelector:@selector(handleTableviewCellLongPressed:)]) {
            [_superCollectionView.delegate performSelector:@selector(handleTableviewCellLongPressed:) withObject:self.indexPath];
        }
    }
}

- (NSIndexPath*)indexPath {
    return [self.superCollectionView indexPathForCell:self];
}

@end
