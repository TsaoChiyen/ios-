//
//  OrderCustomerCell.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-20.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderCustomerCell.h"
#import "ImageTouchView.h"

@interface OrderCustomerCell () < ImageTouchViewDelegate >
{
    NSInteger allowType;
}
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;
@property (strong, nonatomic) IBOutlet UIView *viewConnect;
@property (strong, nonatomic) IBOutlet UIView *viewDelete;
@property (strong, nonatomic) IBOutlet ImageTouchView *imgCall;
@property (strong, nonatomic) IBOutlet ImageTouchView *imgSMS;
@property (strong, nonatomic) IBOutlet ImageTouchView *imgDel;

@end


@implementation OrderCustomerCell

- (void)setData:(NSString *)it
{
    _data = it;
    
    if (_data) {
        NSArray *arr = [_data componentsSeparatedByString:@"^"];
        
        if (arr && arr.count) {
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *str = obj;
                
                if (idx == 0) {
                    self.labelTitle.text = str;
                } else if (idx == 1) {
                    self.labelContent.text = str;
                }
            }];
        }
    }
}

- (void)setTextFont:(UIFont *)textFont {
    self.labelTitle.font = textFont;
    self.labelContent.font = textFont;
}

- (void)setTextHeight:(CGFloat)textHeight {
    self.labelTitle.height = textHeight;
    self.labelContent.height = textHeight;
}

- (void)addConnectButton {
    self.imgCall.tag = @"imgCall";
    self.imgCall.delegate = self;
    
    self.imgSMS.tag = @"imgSMS";
    self.imgSMS.delegate = self;
    
    allowType = 0;
    self.viewConnect.hidden = NO;
}

- (void)addDeleteButton {
    self.imgDel.tag = @"imgDel";
    self.imgDel.delegate = self;

    allowType = 0;
    self.viewDelete.hidden = NO;
}

- (void)autoShowButton:(NSInteger)index {
    allowType = index;
}

- (void)imageTouchViewDidSelected:(id)sender
{
    ImageTouchView *btn = sender;
    
    if ([btn.tag isEqual:@"imgCall"]) {
        if ([self.delegate respondsToSelector:@selector(cell:willCallPhone:)]) {
            [self.delegate performSelector:@selector(cell:willCallPhone:) withObject:self withObject:self.labelContent.text];
        }
    } else if ([btn.tag isEqual:@"imgSMS"]) {
        if ([self.delegate respondsToSelector:@selector(cell:willTalkWithUserID:)]) {
            [self.delegate performSelector:@selector(cell:willTalkWithUserID:) withObject:self withObject:self.uid];
        }
    } else if ([btn.tag isEqual:@"imgDel"]) {
        if ([self.delegate respondsToSelector:@selector(cell:willSendDeleteAtIndexPath:)]) {
            [self.delegate performSelector:@selector(cell:willSendDeleteAtIndexPath:) withObject:self withObject:self.indexPath];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        if (allowType == 2) {
            self.viewDelete.hidden = NO;
        } else if (allowType ==1) {
            self.viewConnect.hidden = NO;
        }
    } else {
        if (allowType == 2) {
            self.viewDelete.hidden = YES;
        } else if (allowType ==1) {
            self.viewConnect.hidden = YES;
        }
    }
}

@end
