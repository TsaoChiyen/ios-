//
//  NewsView.m
//  reSearchDemo
//
//  Created by Jinjin on 15/4/17.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "NewsView.h"
#import "UIImageView+WebCache.h"
#import "Message.h"
#import "JSON.h"

@interface NewsView()
@property (nonatomic,strong) NSArray *newsList;
@end


@implementation NewsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (CGFloat)heightForMessage:(Message*)item{

    CGFloat heigth = 60;
    if (!item.value) {
        item.value = [JSON objectFromJSONString:item.content];
    }
    NSArray *list = item.value[@"list"];
    if ([list isKindOfClass:[NSArray class]]) {
        //多新闻
        heigth = 8 + 140 + 8 + (([list count]-1) * (50+(8*2)));
    }else{
        heigth = 8 + 140 + 8 ;
    }
    return heigth + 10;
}


- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
        self.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.layer.borderWidth = 0.68;
    }
    return self;
}

- (void)loadNewsWithNews:(id)dataDict{
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        
        
        NSArray *list = dataDict[@"list"];
        self.newsList = @[dataDict];
        if ([list isKindOfClass:[NSArray class]]) {
            //多新闻
            self.newsList = list;
        }
        
        UIImage *tapImage = [self createImageWithColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3]];
        
        CGFloat offset = 8;
        CGFloat yOffset = offset;
        CGFloat smallImgHeight = 50;
        CGRect btnFrame = CGRectZero;
        //开始绘制
        for (NSDictionary *news in self.newsList) {
            NSString *imgurl = news[@"imgurl"];
            NSString *title = news[@"title"];
            
            NSInteger index = [self.newsList indexOfObject:news];
            if (index==0) {//大新闻
                UIImageView *bigImage = [[UIImageView alloc] initWithFrame:CGRectMake(offset, yOffset, self.width-(offset*2), 140)];
                bigImage.clipsToBounds = YES;
                bigImage.backgroundColor = [UIColor lightGrayColor];
                bigImage.contentMode = UIViewContentModeScaleAspectFill;
                [bigImage sd_setImageWithURL:[NSURL URLWithString:imgurl]];
                [self addSubview:bigImage];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 140-30, bigImage.width, 30)];
                label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont systemFontOfSize:16];
                label.text = [NSString stringWithFormat:@" %@ ",title];
                [bigImage addSubview:label];
                btnFrame = CGRectMake(0, 0, self.width, 140+offset+offset);
                
                yOffset += 140+offset;
            }else{//小新闻
                
                //小新闻顶部横线
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, self.width, 0.68)];
                line.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
                [self addSubview:line];
            
                UIImageView *smallImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-offset-smallImgHeight, yOffset+offset, smallImgHeight, smallImgHeight)];
                smallImage.clipsToBounds = YES;
                smallImage.backgroundColor = [UIColor lightGrayColor];
                smallImage.contentMode = UIViewContentModeScaleAspectFill;
                [smallImage sd_setImageWithURL:[NSURL URLWithString:imgurl]];
                [self addSubview:smallImage];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(offset, yOffset, self.width-offset-smallImgHeight-offset, smallImgHeight+(offset*2))];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:15];
                label.numberOfLines = 2;
                label.text = title;
                [self addSubview:label];
                
                btnFrame = CGRectMake(0, yOffset, self.width, (smallImgHeight+(offset*2)));
            
                yOffset +=(smallImgHeight+(offset*2));
            }
            
            UIButton *btn = [[UIButton alloc] initWithFrame:btnFrame];
            [btn setBackgroundImage:tapImage forState:UIControlStateHighlighted];
            btn.tag = index;
            [btn addTarget:self action:@selector(newsDidTap:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        
        self.height = yOffset;
    }else {
        self.height = 60;
    }
}

- (void)newsDidTap:(UIButton *)btn{

    NSInteger index = btn.tag;
    NSDictionary *news = self.newsList[index];
    if (self.newsDidTap) {
        self.newsDidTap(news);
    }
}

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
