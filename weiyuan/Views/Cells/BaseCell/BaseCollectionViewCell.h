//
//  BaseCollectionViewCell.h
//  huazhuangpin
//
//  Created by Kiwaro on 14-11-19.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageTouchView.h"
@protocol BaseCollectionViewCellDelegate <NSObject>
- (void)handleTableviewCellLongPressed:(NSIndexPath*)indexPath;
@end

@interface BaseCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) ImageTouchView  * imageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView   * imageViewDelete;
@property (nonatomic, assign) UIImage   * image;
@property (nonatomic, assign) NSString  * title;
@property (nonatomic, assign, readonly) NSIndexPath * indexPath;
@property (nonatomic, strong) UICollectionView * superCollectionView;
@property (nonatomic, assign) BOOL edit;
- (void)enableLongPress;

@end
