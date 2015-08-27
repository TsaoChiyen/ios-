//
//  OrderDeliveryViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "OrderDeliveryViewController.h"
#import "QRcodeReaderViewController.h"
#import "TextInput.h"
#import "Order.h"

@interface OrderDeliveryViewController () <UITextFieldDelegate, QRcodeReaderViewDelegate>
{
    IBOutlet KTextField *txtCompany;
    IBOutlet KTextField *txtOrderCode;
}

- (IBAction)scanForOrderCode:(UIButton *)sender;

@end

@implementation OrderDeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
    [self setRightBarButton:@"确定" selector:@selector(comfirmDelivery:)];
    self.navigationItem.title = @"发货";
    
    [txtCompany enableBorder];
    [txtOrderCode enableBorder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [txtCompany becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanForOrderCode:(UIButton *)sender {
    QRcodeReaderViewController *tmpCon = [[QRcodeReaderViewController alloc] init];
    
    if ([tmpCon isKindOfClass:[UIViewController class]]) {
        tmpCon.delegate = self;
        UIViewController* con = (UIViewController*)tmpCon;
        [self presentModalController:con animated:YES];
    }
}

- (void)comfirmDelivery:(UIButton *)sender {
    [txtCompany resignFirstResponder];
    [self sendRequest];
}

- (BOOL)sendRequest {
    if (!([txtCompany.text isKindOfClass:[NSString class]] && txtCompany.text.length > 0 && [txtOrderCode.text isKindOfClass:[NSString class]] && txtOrderCode.text.length > 0)) {
        [self showAlert:@"请填写所有信息！" isNeedCancel:NO];
        return NO;
    }
    
    [self popViewController];
        if ([super startRequest]) {
            [client deliveryOrder:_order.id
                    withLogistics:txtCompany.text
                       adnWaybill:txtOrderCode.text];
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

- (void)QRcodeReaderDidFinish:(UIView *)sender data:(NSString *)data {
    if (data) {
        txtOrderCode.text = data;
    }
}

@end
