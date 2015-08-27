//
//  ExibitionViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-25.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "ExibitionViewController.h"

@interface ExibitionViewController ()

@end

@implementation ExibitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setEdgesNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)startRequest {
    [self showAlert:@"展会正在筹建中，敬请等待！" isNeedCancel:NO];
    return NO;
}

@end
