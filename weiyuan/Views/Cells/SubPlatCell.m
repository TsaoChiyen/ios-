//
//  SubPlatCell.m
//  reSearchDemo
//
//  Created by Jinjin on 15/4/16.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "SubPlatCell.h"
#import "SubPlat.h"

@implementation SubPlatCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setCornerRadius:self.imageView.height/2];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initialiseCell {
    [super initialiseCell];
    
}

- (void)setWithItem:(id)wItem{
    if (wItem != nil && [wItem isKindOfClass:[SubPlat class]]) {
        SubPlat* item = wItem;
        self.textLabel.text = item.name;
        self.detailTextLabel.text = item.info;
    }
}

@end
