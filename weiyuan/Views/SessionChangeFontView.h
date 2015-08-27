//
//  SessionChangeFontView.h
//  reSearchDemo
//
//  Created by helfy  on 15-4-21.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEFilterControl.h"

@interface SessionChangeFontView : UIView
-(void)showInView:(UIView *)targetView;

@property (nonatomic,strong)SEFilterControl *filterControl;

@end
