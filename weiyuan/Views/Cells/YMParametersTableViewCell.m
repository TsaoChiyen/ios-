//
//  YMParametersTableViewCell.m
//
//  Created by helfy  on 14-12-9.
//  Copyright (c) 2014年 helfy. All rights reserved.
//

#import "YMParametersTableViewCell.h"
#import "YMParameterCellObj.h"

@implementation YMParametersTableViewCell
{
    UILabel *titleLabel;
    UIView *customView;
    UIImageView *imageView;
    CGSize imageShowSize;
    
    //    YMParameterCellObj *cellObj;
}
@synthesize cellObj =_cellObj;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    titleLabel = [UILabel new];
    titleLabel.font =[UIFont systemFontOfSize:16];
    //    titleLabel.textColor = RGB(100, 100, 100);
    [self addSubview:titleLabel];
    
    imageView = [UIImageView new];
    [self addSubview:imageView];
    return self;
}

-(UILabel *)titleLabel
{
    return titleLabel;
}
-(void)setupViewFor:(YMParameterCellObj *)newCellObj
{
    _cellObj = newCellObj;
    if(customView.superview == self)
    {
        [customView removeFromSuperview];
    }
    titleLabel.text = newCellObj.title;
    imageView.image = newCellObj.headImage;
    imageShowSize = newCellObj.imageSize;
    self.accessoryType = newCellObj.accessoryType;
    self.selectionStyle = newCellObj.selectionStyle;
    BOOL hasImage = imageView.image?YES:NO;
    BOOL hasTitle = titleLabel.text?YES:NO;
    
    float leftPadding =15;
    float rigthPadding = -newCellObj.rigthPadding;
    //    if(newCellObj.objType != YMParameterCellObjTypeLabel)
    //    {
    //        rigthPadding = -30;
    //    }
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(leftPadding);
        make.width.equalTo(imageShowSize.width);
        make.height.equalTo(imageShowSize.height);
        make.centerY.equalTo(self);
    }];
    
    if (newCellObj.accessoryView) {
        customView = newCellObj.accessoryView;
        [self addSubview:customView];
        
        switch (newCellObj.arrangementType) {
            case YMParameterCellArrangementTypeHorizontal:
            {
                if(newCellObj.accessoryViewWidth == 0)
                {
                    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self).offset(5);
                        if(hasImage)
                        {
                            make.left.equalTo(imageView.mas_right).offset(8);
                        }
                        else{
                            make.left.equalTo(self).offset(leftPadding);
                        }
                        if(hasTitle)
                        {
                            make.width.equalTo(customView.mas_width);
                        }else{
                            make.width.equalTo(0);
                            
                        }
                        make.bottom.equalTo(self).offset(-5);
                    }];
                    
                    [customView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self).offset(5);
                        make.right.equalTo(self).offset(rigthPadding);
                        
                        if(hasTitle)
                        {
                            make.width.equalTo(titleLabel.mas_width);
                            make.left.equalTo(titleLabel.mas_right).offset(5);
                        }
                        else{
                            if(hasImage)
                            {
                                make.left.equalTo(imageView.mas_right).offset(8);
                            }
                            else{
                                make.left.equalTo(self).offset(leftPadding);
                            }
                        }
                        make.bottom.equalTo(self).offset(-5);
                    }];
                }
                else
                {
                    //                    customView.backgroundColor = [UIColor redColor];
                    
                    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self).offset(5);
                        if(hasImage)
                        {
                            make.left.equalTo(imageView.mas_right).offset(8);
                        }
                        else{
                            make.left.equalTo(self).offset(leftPadding);
                        }
                        
                        make.right.equalTo(self).offset( -(newCellObj.accessoryViewWidth+ABS(rigthPadding)+5));
                        make.bottom.equalTo(self).offset(-5);
                    }];
                    [customView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self).offset(5);
                        make.left.equalTo(titleLabel.mas_right).offset(5);
                        make.right.equalTo(self).offset(rigthPadding);
                        //                        make.width.equalTo(cellObj.accessoryViewWidth);
                        make.bottom.equalTo(self).offset(-5);
                    }];
                }
            }
                break;
            case YMParameterCellArrangementTypeVertical:
            {
                [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self).offset(5).priorityHigh();
                    if(hasImage)
                    {
                        make.left.equalTo(imageView.mas_right).offset(8).priorityHigh();
                    }
                    else{
                        make.left.equalTo(self).offset(leftPadding).priorityHigh();
                    }
                    make.right.equalTo(self).offset(rigthPadding).priorityHigh();
                    make.height.equalTo(30).priorityHigh();
                    
                }];
                [customView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(titleLabel.mas_bottom);
                    if(hasImage)
                    {
                        make.left.equalTo(imageView.mas_right).offset(8);
                    }
                    else{
                        make.left.equalTo(self).offset(leftPadding);
                    }
                    make.right.equalTo(self).offset(rigthPadding);
                    make.bottom.equalTo(self).offset(-5);
                }];
            }
                break;
            default:
                break;
        }
    }
    else{
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.right.equalTo(self).offset(rigthPadding);
            if(hasImage)
            {
                make.left.equalTo(imageView.mas_right).offset(8);
            }
            else{
                make.left.equalTo(self).offset(leftPadding);
            }
            make.bottom.equalTo(self).offset(-5);
        }];
    }
    
}

@end
