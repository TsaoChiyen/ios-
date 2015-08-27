//
//  BankEditViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BankEditViewController.h"
#import "TextInput.h"

@interface BankEditViewController () < UITextFieldDelegate >
{
    IBOutlet KTextField *txtAccount;
    IBOutlet KTextField *txtBank;
    IBOutlet KTextField *txtUser;
    
    NSString *strBank;
    NSString *strBankUser;
    NSString *strBankCard;
}

@end

@implementation BankEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"设置银行信息";
    [self setEdgesNone];

    [txtBank enableBorder];
    [txtUser enableBorder];
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
    [txtBank becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    currentInputView = sender;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
    if (sender.tag == 1) {
        [txtUser becomeFirstResponder];
    } else if (sender.tag == 2) {
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
    
    strBank = txtBank.text;
    strBankUser = txtUser.text;
    strBankCard = txtAccount.text;

    if (strBank && strBankCard && strBankUser &&
        strBank.length > 4 && strBankCard.length > 4 && strBankUser.length > 2) {
        [client updateBank:strBank
                      user:strBankUser
                   account:strBankCard];
    } else if (strBank || strBankCard || strBankUser) {
        [self showText:@"请输入完整的银行信息再提交更新！"];
        return NO;
    }

    if ([self.delegate respondsToSelector:@selector(editDidFinishedWithBank:user:account:)]) {
        [self.delegate editDidFinishedWithBank:txtBank.text
                                          user:txtUser.text
                                       account:txtAccount.text];
    }
    
    return YES;
}

@end
