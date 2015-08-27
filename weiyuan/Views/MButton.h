//
//  MButton.h
//  Medical
//
//  Created by helfy on 14-10-9.
//  Copyright (c) 2014年 charles. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    MButtonContentArrangementOverlap=0,  //defalut
    MButtonContentArrangementHorizontal,
    MButtonContentArrangementVertical,
}
MButtonContentArrangement;

@interface MButton : UIButton
@property (nonatomic,assign) MButtonContentArrangement arrangement;
@property (nonatomic,assign) id userInfo;

@property (nonatomic,assign) BOOL imageAtEnd;


-(void)setImageShowSize:(CGSize)size;
-(void)setTitileOffset:(CGPoint)offset;

-(void)setImageAndTitleSpacing:(CGFloat)spacing;
-(void)setNormalColor:(UIColor *)newNormalColor SelectColor:(UIColor *)newSelectColor;
@end
