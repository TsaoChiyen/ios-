//
//  ShopPasswordViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-27.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "ShopPasswordViewController.h"
#import "TextInput.h"

@interface ShopPasswordViewController ()
{
    IBOutlet UIView *oldView;
    IBOutlet UIView *newView;

    IBOutlet KTextField *oldPass;
    IBOutlet KTextField *newPass;
    IBOutlet KTextField *confirPass;
}

@end

@implementation ShopPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
    if (_password.hasValue) {
        self.navigationItem.title = @"修改商城独立密码";
    } else {
        self.navigationItem.title = @"设置商城独立密码";
        
        oldView.hidden = YES;
    }
    
    [oldPass infoStyle];
    [newPass infoStyle];
    [confirPass infoStyle];
    
    [self setRightBarButtonImage:LOADIMAGE(@"OK") highlightedImage:nil selector:@selector(btnOK)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) btnOK {
    if (_password) {
        if (!oldPass.hasText) {
            [self showAlert:@"请输入当前密码" isNeedCancel:NO];
            [oldPass becomeFirstResponder];
            return;
        }
    }
    
    if (!newPass.hasText) {
        [self showAlert:@"请输入新密码" isNeedCancel:NO];
        [newPass becomeFirstResponder];
        return;
    }
    if (!confirPass.hasText) {
        [self showAlert:@"请输入确认密码" isNeedCancel:NO];
        [confirPass becomeFirstResponder];
        return;
    }
    if (![newPass.text isEqualToString:confirPass.text]) {
        [self showAlert:@"新密码确认不正确" isNeedCancel:NO];
        [newPass becomeFirstResponder];
        return;
    }
    
    if (_password) {
        [self verifyPassword:oldPass.text];
    } else {
        [self registryNewPassword:newPass.text];
    }
}

- (void)verifyPassword:(NSString *)password {
    BSClient *verify = [[BSClient alloc] initWithDelegate:self action:@selector(verifyDidFinish:obj:)];
    
    [verify verifyShopPassword:password];
}

- (void)registryNewPassword:(NSString *)password {
    BSClient *registry = [[BSClient alloc] initWithDelegate:self action:@selector(registryDidFinish:obj:)];
    
    [registry setShopPassword:password];
}

- (BOOL)verifyDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if (sender.hasError) {
            [self showAlert:sender.errorMessage isNeedCancel:NO];
        } else {
            [self registryNewPassword:newPass.text];
        }
    }
    return YES;
}

- (BOOL)registryDidFinish:(BSClient *)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        if (!sender.hasError) {
            [self refreshCurrentUser];
        }
    }
    [self popViewController];
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    if (sender == oldPass) {
        [newPass becomeFirstResponder];
    } else if (sender == newPass) {
        [confirPass becomeFirstResponder];
    } else if (sender == confirPass) {
        [confirPass resignFirstResponder];
    }
    
    return YES;
}

@end
