//
//  GoodsCollectionViewCell.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-22.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "GoodsCollectionViewCell.h"

@implementation GoodsCollectionViewCell

@dynamic indexPath;

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (CGRect)getInsetRect {
    CGSize size = self.frame.size;
    size.width -= 4;
    size.height -= 4;
    CGRect rect = CGRectMake(2, 2, size.width, size.height);
    
    return rect;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        CGRect rc = [self getInsetRect];
        CGRect frame = CGRectMake(rc.origin.x, rc.origin.y + rc.size.height * 0.72, rc.size.width, rc.size.height * 0.15);

        _nameLabel = [[UILabel alloc] initWithFrame:frame];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel*)priceLabel {
    if (!_priceLabel) {
        CGRect rc = [self getInsetRect];
        CGRect frame = CGRectMake(rc.origin.x + rc.size.width * 0.5, rc.origin.y + rc.size.height * 0.90, rc.size.width * 0.5, rc.size.height * 0.08);
        
        _priceLabel = [[UILabel alloc] initWithFrame:frame];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont systemFontOfSize:11];
        _priceLabel.textColor = [UIColor darkGrayColor];
        _priceLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_priceLabel];
    }
    return _priceLabel;
}

- (UILabel*)shopLabel {
    if (!_shopLabel) {
        CGRect rc = [self getInsetRect];
        CGRect frame = CGRectMake(rc.origin.x, rc.origin.y + rc.size.height * 0.90, rc.size.width * 0.5, rc.size.height * 0.08);
        
        _shopLabel = [[UILabel alloc] initWithFrame:frame];
        _shopLabel.backgroundColor = [UIColor clearColor];
        _shopLabel.font = [UIFont systemFontOfSize:11];
        _shopLabel.textColor = [UIColor darkGrayColor];
        _shopLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_shopLabel];
    }
    return _shopLabel;
}

- (UIImageView*)imageView {
    if (!_imageView) {
        CGRect rc = [self getInsetRect];
        CGRect frame = CGRectMake(rc.origin.x, rc.origin.y, rc.size.width, rc.size.height * 0.70);

        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 2;
        [self.contentView addSubview:_imageView];
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTapped:)];
        [_imageView addGestureRecognizer:recognizer];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (void)setPrice:(NSString *)price {
    self.priceLabel.text = price;
}

- (void)setShop:(NSString *)shop {
    self.shopLabel.text = shop;
}

- (void)setImage:(UIImage *)ima {
    self.imageView.image = ima;
}

#pragma mark - UITapGestureDelegate

- (void)headTapped:(UITapGestureRecognizer*)recognizer {
    if ([_superCollectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [_superCollectionView.delegate performSelector:@selector(collectionView:didSelectItemAtIndexPath:) withObject:@"headTapped" withObject:self.indexPath];
    }
}

- (NSIndexPath*)indexPath {
    return [self.superCollectionView indexPathForCell:self];
}

@end
