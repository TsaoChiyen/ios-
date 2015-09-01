//
//  AddRepaymentBillViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "AddRepaymentBillViewController.h"
#import "KPickerView.h"
#import "TPickerView.h"
#import "Globals.h"
#import "Bill.h"
#import "TextInput.h"
#import "ImageTouchView.h"

@interface AddRepaymentBillViewController () <UITextFieldDelegate>
{
    IBOutlet KTextField *txtName;
    IBOutlet KTextField *txtMechanism;
    IBOutlet KTextField *txtDateOfMonth;
    IBOutlet KTextField *txtPrice;
    IBOutlet KTextField *txtNumber;
    
    IBOutlet KTextField *txtCard;
    IBOutlet KTextField *txtBank;
    IBOutlet KTextField *txtLastDate;
    IBOutlet KTextField *txtEmail;
    IBOutlet KTextField *txtEmailPass;
    IBOutlet KTextField *txtEmailLogin;
    IBOutlet KTextField *txtEmailServer;

    IBOutlet UIButton   *btnEmailAgree;
    IBOutlet UIButton   *btnEmailProtocol;
    
    IBOutlet UIView *view1;
    IBOutlet UIView *view2;
    
    NSString *dateValue;
    
    NSArray *arrayBank;
    NSArray *arrayDate;
}

@end

@implementation AddRepaymentBillViewController

@synthesize billType = _billType;

- (id)init {
    if ((self = [super init])) {
        _billType = 1;
        
        arrayBank = @[@"中国工商银行"
                      ,@"中国农业银行"
                      ,@"中国银行"
                      ,@"中国建设银行"
                      ,@"交通银行"
                      ,@"中信银行"
                      ,@"中国光大银行"
                      ,@"华夏银行"
                      ,@"中国民生银行"
                      ,@"招商银行"
                      ,@"兴业银行"
                      ,@"广发银行"
                      ,@"平安银行"
                      ,@"上海浦东发展银行"
                      ,@"恒丰银行"
                      ,@"浙商银行"
                      ,@"渤海银行"
                      ,@"中国邮政储蓄银行"];

        arrayDate = @[@"1"
                      ,@"2"
                      ,@"3"
                      ,@"4"
                      ,@"5"
                      ,@"6"
                      ,@"7"
                      ,@"8"
                      ,@"9"
                      ,@"10"
                      ,@"11"
                      ,@"12"
                      ,@"13"
                      ,@"14"
                      ,@"15"
                      ,@"16"
                      ,@"17"
                      ,@"18"
                      ,@"19"
                      ,@"20"
                      ,@"21"
                      ,@"22"
                      ,@"23"
                      ,@"24"
                      ,@"25"
                      ,@"26"
                      ,@"27"
                      ,@"28"
                      ,@"29"
                      ,@"30"
                      ,@"31"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
    [txtName enableBorder];
    [txtMechanism enableBorder];
    [txtDateOfMonth enableBorder];
    [txtPrice enableBorder];
    [txtNumber enableBorder];
    [txtCard enableBorder];
    [txtBank enableBorder];
    [txtLastDate enableBorder];
    [txtEmail enableBorder];
    [txtEmailPass enableBorder];
    [txtEmailLogin enableBorder];
    [txtEmailServer enableBorder];

    txtPrice.placeholder = @"还款金额";
    txtNumber.placeholder = @"剩余期数";

    [self setRightBarButtonImage:LOADIMAGE(@"OK") highlightedImage:nil selector:@selector(btnOK)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_bill) {
        _billType = _bill.type.integerValue;
        
        if (_billType == 2) {
            dateValue = _bill.repayment;
            txtLastDate.text = [Globals convertDateFromString:dateValue timeType:4];
            txtCard.text = _bill.card;
            txtBank.text = _bill.bank;
        } else if (_billType == 1) {
            txtDateOfMonth.text = _bill.repayment;
            txtName.text = _bill.name;
            txtMechanism.text = _bill.mechanism;
            txtPrice.text = _bill.price;
            txtNumber.text = _bill.number;
        }
    }

    if (_billType == 2) {
        self.navigationItem.title = @"信用卡还款提醒";
        view1.hidden = YES;
        view2.hidden = NO;
    } else if (_billType == 1) {
        self.navigationItem.title = @"贷款还款提醒";
        view1.hidden = NO;
        view2.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_billType == 2) {
        [txtCard becomeFirstResponder];
    } else if (_billType == 1) {
        [txtName becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)emailAgree:(UIButton *)sender {
    if (sender.tag == 0) {
        sender.selected = !sender.selected;
    } else {
        
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    if (sender == txtDateOfMonth && _billType == 1) {
            TPickerView *picker = [[TPickerView alloc] initWithTitle:@"选择还款日子" data:arrayDate delegate:self];
            picker.tag = 0;
            [picker showInView:self.view];

        if (currentInputView) {
            [currentInputView resignFirstResponder];
        }
        
        return NO;
    } else if (sender == txtLastDate && _billType == 2) {
            KPickerView * picker = [[KPickerView alloc] initWithType:forPickViewDate delegate:self];
            [picker showInView:self.view];
            picker.timeDoNotInvaild = NO;
            UIDatePicker * tmpPicker = picker.picker;
            
            // 用日历来推算日期
            unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [calendar components:units fromDate:[NSDate date]];
            
            [comps setYear:[comps year] - 2];           // 两年前
            NSDate *minDate = [calendar dateFromComponents:comps];
            
            [comps setYear:[comps year] + 10];          // 两年前的十年后，即八年后
            NSDate *maxDate = [calendar dateFromComponents:comps];
            
            tmpPicker.minimumDate = minDate;            // 最小日期
            tmpPicker.maximumDate = maxDate;            // 最大日期
            
            calendar = nil;

        if (currentInputView) {
            [currentInputView resignFirstResponder];
        }
        
        return NO;
    } else if (sender == txtBank && _billType == 2) {
        TPickerView *picker = [[TPickerView alloc] initWithTitle:@"选择信用银行" data:arrayBank delegate:self];
        picker.tag = 1;
        [picker showInView:self.view];

        if (currentInputView) {
            [currentInputView resignFirstResponder];
        }
        
        return NO;
    }
    
    currentInputView = sender;
    return YES;
}

#pragma mark - KPickerViewDelegate

- (void)kPickerViewDidDismiss:(KPickerView*)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年M月d日"];
    NSString * tmpTime = [dateFormatter stringFromDate:sender.selectedDate];
    NSString * tmpTimeInterval = [NSString stringWithFormat:@"%0.0f", [sender.selectedDate timeIntervalSince1970]];
    
    txtLastDate.text = tmpTime;
    dateValue = tmpTimeInterval;
}

- (void)actionSheet:(TPickerView *)sender clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (sender.tag == 0) {
            txtDateOfMonth.text = sender.selected;
            dateValue = sender.selected;
        } else {
            txtBank.text = sender.selected;
        }
    }
}

- (void)btnOK {
    if (_billType == 1) {
        if (!txtName.text.hasValue) {
            [self showText:@"请输入还款名称"];
        } else if (!txtMechanism.text.hasValue) {
            [self showText:@"请输入还款机构"];
        } else if (!txtDateOfMonth.text.hasValue) {
            [self showText:@"请输入每期还款日期"];
        } else if (!txtPrice.text.hasValue) {
            [self showText:@"请输入还款金额"];
        } else if (!txtNumber.text.hasValue) {
            [self showText:@"请输入剩余期数"];
        } else {
            [currentInputView resignFirstResponder];
            [self sendRequest];
        }
    } else {
        if (!txtCard.text.hasValue) {
            [self showText:@"请输入信用卡号4位尾号"];
        } else if (!txtBank.text.hasValue) {
            [self showText:@"请选择还款银行"];
        } else if (!txtLastDate.text.hasValue) {
            [self showText:@"请选择最晚还款日期"];
        } else {
            [currentInputView resignFirstResponder];
            [self sendRequest];
        }
    }
}

- (BOOL)sendRequest {
    if ([super startRequest]) {
        if (_bill) {
            if (self.billType == 2) {
                [client editBillWithId:_bill.id
                               andType:@(self.billType).stringValue
                             repayment:dateValue
                                  name:@""
                                 price:@""
                                number:@""
                             mechanism:@""
                                  card:txtCard.text
                                  bank:txtBank.text];
            } else {
                [client editBillWithId:_bill.id
                               andType:@(self.billType).stringValue
                             repayment:dateValue
                                  name:txtName.text
                                 price:txtPrice.text
                                number:txtNumber.text
                             mechanism:txtMechanism.text
                                  card:@""
                                  bank:@""];
            }
        } else {
            if (self.billType == 2) {
                [client addBillWithType:@(self.billType).stringValue
                              repayment:dateValue
                                   name:@""
                                  price:@""
                                 number:@""
                              mechanism:@""
                                   card:txtCard.text
                                   bank:txtBank.text];
            } else {
                [client addBillWithType:@(self.billType).stringValue
                              repayment:dateValue
                                   name:txtName.text
                                  price:txtPrice.text
                                 number:txtNumber.text
                              mechanism:txtMechanism.text
                                   card:@""
                                   bank:@""];
            }
        }
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
