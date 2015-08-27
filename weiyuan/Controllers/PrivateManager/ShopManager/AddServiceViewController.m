//
//  AddServiceViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "AddServiceViewController.h"
#import "TextInput.h"

@interface AddServiceViewController () < UITextFieldDelegate >
{
    IBOutlet KTextField *txtName;
    IBOutlet KTextField *txtAccount;

    NSString *strName;
    NSString *strAccount;
}

@end

@implementation AddServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"添加客服";
    [self setEdgesNone];
    
    [txtName enableBorder];
    [txtAccount enableBorder];
    
    [self setRightBarButtonImage:LOADIMAGE(@"OK") highlightedImage:nil selector:@selector(btnOK)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [txtName becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    currentInputView = sender;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
    if (sender.tag == 1) {
        [txtAccount becomeFirstResponder];
    } else if (sender.tag == 3) {
        [sender resignFirstResponder];
    }
    
    return YES;
}

- (void)btnOK
{
    if ([self settingDidFinished]) {
        [self popViewController];
    };
}

- (BOOL)settingDidFinished {
    if (!client) {
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
    }
    
    strName = txtName.text;
    strAccount = txtAccount.text;
    
    if (strName && strAccount &&
        strName.length > 0 && strAccount.length > 0) {
        [client addServiceOfShopWithName:strName andServiceName:strAccount];
    } else if (strName || strAccount) {
        [self showText:@"请输入完整的客服信息再提交！"];
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(editDidFinishedWithName:account:)]) {
        [self.delegate editDidFinishedWithName:strName
                                       account:strAccount];
    }
    
    return YES;
}

@end
