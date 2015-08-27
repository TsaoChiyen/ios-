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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (isFirstAppear) {
        self.loading = YES;
        [self startRequest];
    }
}

- (BOOL)startRequest {
    [self showAlert:@"展会正在筹建中，敬请期待！" isNeedCancel:NO];
    self.loading = NO;
    return NO;
}

@end
