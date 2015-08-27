//
//  MTextField.m
//  MikeCrm
//
//  Created by helfy on 14/12/3.
//  Copyright (c) 2014年 helfy. All rights reserved.
//

#import "MTextField.h"

@implementation MTextField

-(id)init
{
    self =[super init];
    if(self)
    {
        self.textOffset =5;
        self.font = [UIFont systemFontOfSize:16];
    }
     return self;
}
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
     CGRect rect= [super placeholderRectForBounds:bounds];
    return CGRectInset(rect, self.textOffset, 0);
 
}
-(CGRect)textRectForBounds:(CGRect)bounds
{
  CGRect rect= [super textRectForBounds:bounds];
        return CGRectInset(rect, self.textOffset, 0);
}
-(CGRect)editingRectForBounds:(CGRect)bounds
{
         CGRect rect= [super editingRectForBounds:bounds];
        return CGRectInset(rect, self.textOffset, 0);
}


//控制placeHolder的颜色、字体
//- (void)drawPlaceholderInRect:(CGRect)rect
//{
//
//}
@end
