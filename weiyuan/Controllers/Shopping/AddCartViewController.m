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

@interface AddCartViewController () {
    IBOutlet KTextField * addressLabel;
    IBOutlet KTextField * personLabel;
    IBOutlet KTextField * phoneLabel;
    IBOutlet KTextView  * noticeView;
    IBOutlet UIButton   * button;
}

@end

@implementation AddCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"提交订单";
    [self setEdgesNone];
    
    [addressLabel enableBorder];
    [personLabel enableBorder];
    [phoneLabel enableBorder];
    [noticeView enableBorder];
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

- (IBAction)applyShop {
    if (!addressLabel.text.hasValue) {
        [self showText:@"请选择地址"];
    } else if (!personLabel.text.hasValue) {
        [self showText:@"请输入联系人"];
    } else if (!phoneLabel.text.hasValue) {
        [self showText:@"请输入联系电话"];
    } else {
        [super startRequest];
        // 商品格式：商品id1*count1, id2*count2
        NSArray * arr = [ShoppingCart goodsFromshopid:_shop.id];
        NSMutableString * str = [[NSMutableString alloc] init];
        
        [arr enumerateObjectsUsingBlock:^(ShoppingCart * obj, NSUInteger idx, BOOL *stop) {
            if (str.hasValue) {
                [str appendString:@","];
            }
            [str appendFormat:@"%@*%d", obj.goodid, (int)obj.goodCount];
        }];
        [client submitOrder:str
                       type:@"1"
                     shopid:_shop.id
                   username:personLabel.text
                      phone:phoneLabel.text
                    address:addressLabel.text
                    content:noticeView.text];
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        [self.shop.goods removeAllObjects];
        NSArray * arr = [ShoppingCart goodsFromshopid:_shop.id];
        [arr enumerateObjectsUsingBlock:^(ShoppingCart * obj, NSUInteger idx, BOOL *stop) {
            [obj deleteFromDB];
        }];
        [self popViewController];
    }
    return YES;
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
    currentInputView = sender;
    return YES;
}


@end
