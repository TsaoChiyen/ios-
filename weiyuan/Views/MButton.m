//
//  MButton.m
//  Medical
//
//  Created by helfy on 14-10-9.
//  Copyright (c) 2014年 charles. All rights reserved.
//

#import "MButton.h"
//#import "CGRectUtils.h"
//#import "UIView+CGRectUtils.h"
@implementation MButton
{
    CGSize imageShowSize;
    BOOL isSetShowSize;
    CGPoint titileOffset;
    CGFloat spacing;
    
    
    UIColor *normallColor;
    UIColor *selectColor;
}
- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment=NSTextAlignmentCenter;
        self.titleLabel.font=[UIFont systemFontOfSize:16.0];
        self.arrangement= MButtonContentArrangementOverlap;
        
        float min = MIN(frame.size.width, frame.size.height);
        imageShowSize = CGSizeMake(min, min);
        spacing = 5;
    }
    
    return self;
    
}
-(void)setImageShowSize:(CGSize)size
{
    imageShowSize = size;
    isSetShowSize=YES;
}
-(void)setTitileOffset:(CGPoint)offset
{
    titileOffset = offset;
}
-(void)setNormalColor:(UIColor *)newNormalColor SelectColor:(UIColor *)newSelectColor
{
    self.backgroundColor = newNormalColor;
    normallColor = newNormalColor;
    selectColor = newSelectColor;
}
-(void)setImageAndTitleSpacing:(CGFloat)newSpacing
{
    spacing =newSpacing;
}
#pragma mark 重写父类UIButton的方法
//TODO
//根据button的rect设定并返回文本label的rect
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    switch (self.arrangement) {
        case MButtonContentArrangementOverlap:
        {
            contentRect =  CGRectOffset(contentRect, titileOffset.x, titileOffset.y);
           
        }
            break;
        case MButtonContentArrangementHorizontal:
        {
            contentRect.size.width = contentRect.size.width - imageShowSize.width;
            
            NSString *titleStr = [self titleForState:self.state];
            CGSize textSize = [titleStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [UIFont systemFontOfSize:16.0], NSFontAttributeName,
                                                            nil]];
          
            textSize.width =MIN(contentRect.size.width-imageShowSize.width, textSize.width);
            contentRect.size = textSize;
            if(self.imageAtEnd)
            {
              contentRect.origin.x= (self.width-(textSize.width+imageShowSize.width + spacing))/2.0;
            }
            else{
                contentRect.origin.x= spacing + (self.width-(textSize.width+imageShowSize.width + spacing))/2.0+ imageShowSize.width;
            }
            contentRect.origin.y =(self.height-textSize.height)/2.0;
            
            if(UIControlContentHorizontalAlignmentLeft == self.contentHorizontalAlignment)contentRect.origin.x =spacing +
                imageShowSize.width;
            
        }
            break;
        case MButtonContentArrangementVertical:
        {
            contentRect.size.width = contentRect.size.width;
            
            NSString *titleStr = [self titleForState:self.state];
            CGSize textSize = [titleStr sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [UIFont systemFontOfSize:16.0], NSFontAttributeName,
                                                            nil]];
            textSize.width =MIN(contentRect.size.width, textSize.width);
            contentRect.size = textSize;
            contentRect.origin.x= (self.width-textSize.width)/2.0;
            contentRect.origin.y =spacing + (self.height-(textSize.height+ imageShowSize.height+spacing))/2.0+ imageShowSize.height;
        }
            break;
        default:
            break;
    }
   
    return contentRect;
}

//根据根据button的rect设定并返回UIImageView的rect
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{

  switch (self.arrangement) {
        case MButtonContentArrangementOverlap:
      {
          contentRect.origin.x = (int)(contentRect.size.width -imageShowSize.width )/2;
          contentRect.origin.y = (int)(contentRect.size.height -imageShowSize.height )/2;
          contentRect.size.width =  imageShowSize.width;
          contentRect.size.height =  imageShowSize.height;
      }
            break;
      case MButtonContentArrangementHorizontal:
      {
          CGFloat imageW = imageShowSize.width;
          
          CGFloat imageH = imageShowSize.height;
          
          CGFloat imageX =0;
          if(self.imageAtEnd)
          {
              imageX = self.titleLabel.frame.origin.x+self.titleLabel.width+spacing;
         }
          else{
            imageX = (self.width-(self.titleLabel.width+imageShowSize.width+spacing))/2.0;
              
          }
          if(UIControlContentHorizontalAlignmentLeft == self.contentHorizontalAlignment)imageX=0;
          CGFloat imageY = (self.height-imageShowSize.height )/2.0;
   
          contentRect = (CGRect){{imageX,imageY},{imageW,imageH}};
      }
          break;
      case MButtonContentArrangementVertical:
      {
          CGFloat imageW = imageShowSize.width;
          
          CGFloat imageH = imageShowSize.height;
          
          CGFloat imageX = (self.width-imageShowSize.width)/2.0;
          
          CGFloat imageY = (self.height-(self.titleLabel.height+ imageShowSize.height +spacing))/2.0;
          
          contentRect = (CGRect){{imageX,imageY},{imageW,imageH}};
      }
          break;
        default:
            break;
    }
    return contentRect;
}

-(void)setCustomHighligth:(BOOL)highlight
{
    if(!(selectColor && normallColor))return;
    if(highlight)
    {
        self.backgroundColor = selectColor;
    }
    else{
        self.backgroundColor = normallColor;
    }
}


-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setCustomHighligth:highlighted];
}

//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    [super beginTrackingWithTouch:touch withEvent:event];
//
//    return YES;
//}
//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    [super continueTrackingWithTouch:touch withEvent:event];
//    CGPoint touchPoint  =[touch locationInView:self];
//    float w = 70;
//    CGRect rect = CGRectMake(-w,-w, self.frameWidth+w*2, self.frameHeight+w*2);
//    
//    if(!CGRectContainsPoint(rect, touchPoint))
//    {
//    }
//    else{
//    }
//    return YES;
//}
//- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    [super endTrackingWithTouch:touch withEvent:event];
//}
//- (void)cancelTrackingWithEvent:(UIEvent *)event{
//    [super cancelTrackingWithEvent:event];
//
//}
@end
