//
//  HelpViewController.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()
@end

@implementation HelpViewController
@synthesize type;

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
        type = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (type == 0) {
        self.navigationItem.title = @"帮助中心";
    } else {
        self.navigationItem.title = @"注册协议";
    }
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];

    NSURLRequest *request = nil;

    client = [[BSClient alloc] init];
    
    if (type == 0) {
        request = [client getHelp];
    } else {
        request = [client getProtocol];
    }

    if (request) {
        [webView loadRequest:request];
    }
}

@end