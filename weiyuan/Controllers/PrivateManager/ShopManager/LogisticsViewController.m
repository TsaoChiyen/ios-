//
//  LogisticsViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "LogisticsViewController.h"

@interface LogisticsViewController ()
{
    IBOutlet UITextView *txtInfo;
    
}


@end

@implementation LogisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"物流信息";
    txtInfo.text = @"这里显示通过快递单号查出来的物流信息。这里显示通过快递单号查出来的物流信息。";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
