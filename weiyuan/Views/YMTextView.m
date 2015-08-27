//
//  YMTextView.m
//  dream
//
//  Created by helfy  on 15-3-31.
//  Copyright (c) 2015年 helfy . All rights reserved.
//

#import "YMTextView.h"

@implementation YMTextView

-(id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if([self.text length] == 0 && self.placeHolder && self.font) {
        CGRect placeHolderRect = CGRectMake(10.0f,
                                            7.0f,
                                            rect.size.width,
                                            rect.size.height);
        
        [[[UIColor grayColor] colorWithAlphaComponent:0.3] set];
        
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = self.textAlignment;
        
            [self.placeHolder drawInRect:placeHolderRect
                          withAttributes:@{ NSFontAttributeName : self.font,
                                            NSForegroundColorAttributeName : [[UIColor grayColor] colorWithAlphaComponent:0.5] ,
                                            NSParagraphStyleAttributeName : paragraphStyle}];
     
    }
}


@end
