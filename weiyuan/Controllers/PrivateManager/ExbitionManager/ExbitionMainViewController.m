//
//  ExbitionMainViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-27.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "ExbitionMainViewController.h"

@interface ExbitionMainViewController ()

@end

@implementation ExbitionMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
    
    self.navigationItem.title = @"申请参加展会";
    
    [self labelInActionbar:self.view title:@"正在筹备中,敬请期待!" frame:CGRectMake(0, 100, self.view.width, 80)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (isFirstAppear) {
    }
}

- (UILabel *)labelInActionbar:(UIView*)actionbar title:(NSString *)text frame:(CGRect)frame {
    UILabel *lbl = [UILabel multLinesText:text font:[UIFont systemFontOfSize:22] wid:100];
    [lbl setTextColor:[UIColor lightGrayColor]];
    lbl.frame = frame;
    lbl.textAlignment = NSTextAlignmentCenter;
    [actionbar addSubview:lbl];
    return lbl;
}

- (BOOL)startRequest {
    return NO;
}

@end
