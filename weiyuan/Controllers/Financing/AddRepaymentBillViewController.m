//
//  AddRepaymentBillViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "AddRepaymentBillViewController.h"
#import "KPickerView.h"
#import "Globals.h"
#import "Bill.h"
#import "TextInput.h"
#import "ImageTouchView.h"

@interface AddRepaymentBillViewController () <UITextFieldDelegate>
{
    IBOutlet KTextField *txtNameOrCard;
    IBOutlet KTextField *txtBankOrMechanism;
    IBOutlet KTextField *txtDate;
    IBOutlet KTextField *txtPrice;
    IBOutlet KTextField *txtNumber;
    
    NSString *dateValue;
}

@end

@implementation AddRepaymentBillViewController

@synthesize billType = _billType;

- (id)init {
    if ((self = [super init])) {
        _billType = 1;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
    [txtNameOrCard enableBorder];
    [txtBankOrMechanism enableBorder];
    [txtDate enableBorder];
    [txtPrice enableBorder];
    [txtNumber enableBorder];

    txtDate.placeholder = @"还款日期";
    txtPrice.placeholder = @"还款金额";
    txtNumber.placeholder = @"剩余期数";

    [self setRightBarButtonImage:LOADIMAGE(@"OK") highlightedImage:nil selector:@selector(btnOK)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_bill) {
        _billType = _bill.type.integerValue;

        dateValue = _bill.repayment;
        txtDate.text = [Globals convertDateFromString:dateValue timeType:4];
        
        if (_bill.type.integerValue == 2) {
            self.navigationItem.title = @"信用卡账单编辑";
            txtNameOrCard.placeholder = @"信用卡号";
            txtBankOrMechanism.placeholder = @"选择银行";

            txtNameOrCard.text = _bill.card;
            txtBankOrMechanism.text = _bill.bank;
            txtPrice.hidden = YES;
            txtNumber.hidden = YES;
        } else if (_bill.type.integerValue == 1) {
            self.navigationItem.title = @"贷款账单编辑";
            txtNameOrCard.placeholder = @"还款名称";
            txtBankOrMechanism.placeholder = @"还款机构";

            txtNameOrCard.text = _bill.name;
            txtBankOrMechanism.text = _bill.mechanism;
            txtPrice.text = _bill.price;
            txtNumber.text = _bill.number;
        }
    } else {
        if (_billType == 2) {
            self.navigationItem.title = @"信用卡还款";
            txtNameOrCard.placeholder = @"信用卡号";
            txtBankOrMechanism.placeholder = @"选择银行";
            txtPrice.hidden = YES;
            txtNumber.hidden = YES;
        } else if (_billType == 1) {
            self.navigationItem.title = @"贷款还款";
            txtNameOrCard.placeholder = @"还款名称";
            txtBankOrMechanism.placeholder = @"还款机构";
            txtPrice.hidden = NO;
            txtNumber.hidden = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [txtNameOrCard becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    if (sender == txtDate) {
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
    
        txtDate.text = tmpTime;
        dateValue = tmpTimeInterval;
}

- (void)btnOK {
    if (!txtNameOrCard.text.hasValue) {
        if (self.billType == 1) {
            [self showText:@"请输入还款名称"];
        } else {
            [self showText:@"请输入信用卡号"];
        }
    } else if (!txtBankOrMechanism.text.hasValue) {
        if (self.billType == 1) {
            [self showText:@"请输入还款机构"];
        } else {
            [self showText:@"请输入还款银行"];
        }
    } else if (!txtDate.text.hasValue) {
        [self showText:@"请输入还款日期"];
    } else if (!txtPrice.text.hasValue && self.billType == 1) {
        [self showText:@"请输入还款金额"];
    } else if (!txtNumber.text.hasValue && self.billType == 1) {
        [self showText:@"请输入剩余期数"];
    } else {
        [txtNameOrCard resignFirstResponder];
        [self sendRequest];
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
                                  card:txtNameOrCard.text
                                  bank:txtBankOrMechanism.text];
            } else {
                [client editBillWithId:_bill.id
                               andType:@(self.billType).stringValue
                             repayment:dateValue
                                  name:txtNameOrCard.text
                                 price:txtPrice.text
                                number:txtNumber.text
                             mechanism:txtBankOrMechanism.text
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
                                   card:txtNameOrCard.text
                                   bank:txtBankOrMechanism.text];
            } else {
                [client addBillWithType:@(self.billType).stringValue
                              repayment:dateValue
                                   name:txtNameOrCard.text
                                  price:txtPrice.text
                                 number:txtNumber.text
                              mechanism:txtBankOrMechanism.text
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
