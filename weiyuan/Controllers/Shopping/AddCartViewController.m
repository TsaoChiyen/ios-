//
//  AddCartViewController.m
//  weiyuan
//
//  Created by Kiwaro on 15/2/9.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "AddCartViewController.h"
#import "TextInput.h"
#import "ShoppingCart.h"
#import "Shop.h"
#import "Order.h"
#import "UniPay.h"
#import "TPickerView.h"
#import "UPPayPlugin.h"

@interface AddCartViewController () < UPPayPluginDelegate > {
    IBOutlet KTextField * addressLabel;
    IBOutlet KTextField * personLabel;
    IBOutlet KTextField * phoneLabel;
    IBOutlet KTextField * payTypeLabel;
    IBOutlet KTextView  * noticeView;
    IBOutlet UIButton   * button;

    NSArray *arrayPayType;
    int payMode;
}

@end

@implementation AddCartViewController

- (id)init {
    if ((self = [super init])) {
        arrayPayType = @[@"在线支付"
                         ,@"货到付款"
                         ,@"上门自提"];
        payMode = 0;
        _shopType = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"提交订单";
    [self setEdgesNone];
    
    [addressLabel enableBorder];
    [personLabel enableBorder];
    [phoneLabel enableBorder];
    [noticeView enableBorder];
    [payTypeLabel enableBorder];
    noticeView.placeholder = @"备注 选填";
    [button commonStyle];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __block BaseViewController *blockSelf = self;
    [blockSelf.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening) {
            if (currentInputView.tag > 3) {
                // 有必要的时候 适应键盘
                CGFloat oy = keyboardFrameInView.origin.y;
                if (currentInputView.bottom>oy) {
                    self.view.top -= currentInputView.height;
                }
            }
        }
        if (closing) {
            self.view.top = 64;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isFirstAppear) {
//        User *user = [[BSEngine currentEngine] user];
//        
//        personLabel.text = user.name;
//        phoneLabel.text = user.phone;
    }
    
}

- (IBAction)applyShop {
    if (!addressLabel.text.hasValue) {
        [self showText:@"请选择地址"];
    } else if (!personLabel.text.hasValue) {
        [self showText:@"请输入联系人"];
    } else if (!phoneLabel.text.hasValue) {
        [self showText:@"请输入联系电话"];
    } else if (payMode == 0) {
        [self showText:@"请选择支付方式"];
    } else {
        [super startRequest];
        // 商品格式：商品id1*count1, id2*count2
        NSArray * arr = [ShoppingCart goodsFromshopid:_shop.id];
        NSMutableString * str = [[NSMutableString alloc] init];
        
        [arr enumerateObjectsUsingBlock:^(ShoppingCart * obj, NSUInteger idx, BOOL *stop) {
            if (str.hasValue) {
                [str appendString:@","];
            }
            [str appendFormat:@"%@*%ld", obj.goodid, obj.goodCount.integerValue];
        }];
        [client submitOrderWithShopType:_shopType
                                  goods:str
                                   type:@(payMode).stringValue
                                 shopid:_shop.id
                               username:personLabel.text
                                  phone:phoneLabel.text
                                address:addressLabel.text
                                content:noticeView.text];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        Order *order = [Order objWithJsonDic:[obj objectForKey:@"data"]];
        
        if (order) {
            if (order.uniPay &&
                order.uniPay.tn &&
                order.uniPay.tn.length > 0 &&
                ![order.uniPay.tn isEqual:@"0"]) {
                [self startUPPayWithPayTN:order.uniPay.tn];
            } else {
                [self popViewController];
            }
        }
        
        [self showText:sender.errorMessage];
        [self.shop.goods removeAllObjects];
        NSArray * arr = [ShoppingCart goodsFromshopid:_shop.id];
        [arr enumerateObjectsUsingBlock:^(ShoppingCart * obj, NSUInteger idx, BOOL *stop) {
            [obj deleteFromDB];
        }];
    }
    return YES;
}

- (void)startUPPayWithPayTN:(NSString *)payTN {
    if (payTN == nil || payTN.length == 0) {
        return;
    }
    
    [UPPayPlugin startPay:payTN mode:@"01" viewController:self delegate:self];
}

-(void)UPPayPluginResult:(NSString*)result {
    NSString *msg = @"";
    
    if ([result isEqual:@"success"]) {
        msg = @"支付成功！";
    } else if ([result isEqual:@"fail"]) {
        msg = @"支付失败！";
    } else if ([result isEqual:@"cancel"]) {
        msg = @"用户取消了支付";
    }
    
    [self showText:msg];
    [self popViewController];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignAllKeyboard:self.view];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)sender {
    currentInputView = sender;
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    if (sender == payTypeLabel) {
        TPickerView *picker = [[TPickerView alloc] initWithTitle:@"选择支付方式" data:arrayPayType delegate:self];
        picker.tag = 0;
        [picker showInView:self.view];
        
        if (currentInputView) {
            [currentInputView resignFirstResponder];
        }
        
        return NO;
    }
    
    currentInputView = sender;
    return YES;
}

- (void)actionSheet:(TPickerView *)sender clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (sender.tag == 0) {
            payMode = sender.selectedID + 1;
            payTypeLabel.text = sender.selected;
        }
    }
}

@end
