//
//  GoodsCollectionViewCell.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-22.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * priceLabel;
@property (nonatomic, strong) UILabel * shopLabel;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UICollectionView * superCollectionView;
@property (nonatomic, assign, readonly) NSIndexPath * indexPath;

@property (nonatomic, assign) UIImage   * image;
@property (nonatomic, assign) NSString  * name;
@property (nonatomic, assign) NSString  * price;
@property (nonatomic, assign) NSString  * shop;


@end
