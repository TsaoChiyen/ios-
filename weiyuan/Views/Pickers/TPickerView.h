//
//  TPickerView.h
//  SpartaEducation
//
//  Created by kiwaro on 14-3-5.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KLocation;

@interface TPickerView : UIActionSheet

@property (nonatomic, strong) NSString *selected;

- (id)initWithTitle:(NSString *)title data:(NSArray *)data delegate:(id)delegate;
- (void)showInView:(UIView *)view;

@end
