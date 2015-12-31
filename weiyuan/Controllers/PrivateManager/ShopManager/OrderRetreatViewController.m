//
//  OrderRetreatViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderRetreatViewController.h"
#import "TextInput.h"
#import "Order.h"

@interface OrderRetreatViewController () <UITextViewDelegate>
{
    IBOutlet KTextView *txtInfo;
    IBOutlet UIImageView *imgTextBackground;
}

@end

@implementation OrderRetreatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];

    [self setRightBarButton:@"确定" selector:@selector(comfirmRetreat:)];
    self.navigationItem.title = @"退单";
    _shopType = 0;
    
    UIImage * tfImg = [[UIImage imageNamed:@"bkg_bb_textField"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    imgTextBackground.image = tfImg;

    txtInfo.placeholder = @"请填写退单理由";
    txtInfo.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [txtInfo becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)comfirmRetreat:(id)sender {
    [txtInfo resignFirstResponder];
    [self sendRequest];
}

- (BOOL)sendRequest {
    if (!([txtInfo.text isKindOfClass:[NSString class]] && txtInfo.text.length > 0)) {
        [self showAlert:@"真的不想说点什么吗？" isNeedCancel:NO];
        return NO;
    }

    [self popViewController];
    
    if ([super startRequest]) {
        [client retreatOrderWithShopType:_shopType
                                 orderId:_order.id
                              withReason:txtInfo.text];
    }
    return YES;
}


- (BOOL)requestDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        [self popViewController];
    }
    return YES;
}

@end
