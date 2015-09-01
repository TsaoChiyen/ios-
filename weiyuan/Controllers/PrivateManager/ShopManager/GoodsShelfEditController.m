//
//  GoodsShelfEditController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-19.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "GoodsShelfEditController.h"
#import "Good.h"
#import "TextInput.h"
#import "ImageTouchView.h"
#import "UIImageView+WebCache.h"
#import "Globals.h"

@interface GoodsShelfEditController () <UITextFieldDelegate>
{
    
    IBOutlet ImageTouchView *logo;
    IBOutlet UILabel *labelName;
    IBOutlet KTextField *textPrice;
    IBOutlet KTextField *textNumber;
}

@end

@implementation GoodsShelfEditController

@synthesize goods = _goods;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setEdgesNone];
    self.navigationItem.title = @"上架商品信息";
    [self setRightBarButtonImage:LOADIMAGE(@"OK") highlightedImage:nil selector:@selector(btnOK)];
    
    [textPrice infoStyle];
    [textNumber infoStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    labelName.text = _goods.name;
    textPrice.text = _goods.price;
    textNumber.text = _goods.number;
    
    [logo sd_setImageWithUrlString:_goods.logo placeholderImage:[Globals getImageGoodHeadDefault]];
    
    [textPrice becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    currentInputView = sender;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        _goods.price = textField.text;
        [textNumber becomeFirstResponder];
    } else if (textField.tag == 2) {
        _goods.number = textField.text;
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)btnOK
{
    [self editDidFinished];
}

- (void)editDidFinished
{
    _goods.number = textNumber.text;
    _goods.price = textPrice.text;
    
    if (!client) {
        client = [[BSClient alloc] initWithDelegate:self action:@selector(requestDidFinish:obj:)];
        
        [client editShopGoodsWithId:_goods.id price:_goods.price number:_goods.number];
    }
}

- (BOOL)requestDidFinish:(id)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        if ([self.delegate respondsToSelector:@selector(view:didEditFinishWithGoods:)]) {
            [self.delegate performSelector:@selector(view:didEditFinishWithGoods:) withObject:self withObject:_goods];
        }
        
        [self popViewController];
    }
    
    return YES;
}

@end
