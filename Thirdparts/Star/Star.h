//
//  Star.h
//  NewZhiyou
//
//  Created by user on 11-8-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Star : UIView 
{
    NSInteger max_star;                 /* 默认为5 */
    NSInteger show_star;
    BOOL isSelect;                      /* 是否支持选择星数 */
    UIColor *empty_color;
    UIColor *full_color;
}

//+ (void)drawInRect:(CGRect)frame stars:(CGFloat)count;

@property (nonatomic, assign) NSInteger max_star;
@property (nonatomic, assign) NSInteger show_star;
@property (nonatomic, assign) BOOL isSelect;

@end
