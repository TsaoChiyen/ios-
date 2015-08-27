//
//  FinancingProductDetailViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-23.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "FinancingProductDetailViewController.h"
#import "Globals.h"
#import "FinancGoods.h"
#import "Financ.h"
#import "TextInput.h"

@interface FinancingProductDetailViewController () <  UINavigationControllerDelegate, UITextFieldDelegate >
{
    IBOutlet KTextField *product;
    IBOutlet KTextField *model;
    IBOutlet KTextField *feature;
    IBOutlet KTextField *material;
    
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIView *chargeView;
    IBOutlet UIView *sortView;
    IBOutlet UIView *advView;
    
    IBOutlet KTextField *restCoins;
    IBOutlet KTextField *sortPrice;
    IBOutlet KTextField *advPrice;

    IBOutlet UILabel *exchangePrompt;
    IBOutlet UILabel *advPrompt;
    
    IBOutlet UIButton *applyBtn;
    IBOutlet UIButton *chargeBtn;
    IBOutlet UIButton *sortBtn;
    IBOutlet UIButton *advBtn;
}

@end

@implementation FinancingProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
    [product enableBorder];
    [model enableBorder];
    [feature enableBorder];
    [material enableBorder];

    [restCoins enableBorder];
    [sortPrice enableBorder];
    [advPrice enableBorder];
    
    [applyBtn commonStyle];
    [chargeBtn borderStyle];
    [sortBtn borderStyle];
    [advBtn borderStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (isFirstAppear) {
        if (_goods) {
            self.navigationItem.title = @"融资贷款服务产品管理";
            sortBtn.hidden = NO;
            advBtn.hidden = NO;
            [scrollView setContentSize:CGSizeMake(0, advView.bottom + 10)];
            [applyBtn setTitle:@"确定修改" forState:UIControlStateNormal];
            [self reloadData];
        } else {
            self.navigationItem.title = @"添加融资贷款服务产品";
            [scrollView setContentSize:CGSizeMake(0, applyBtn.bottom + 10)];
            [applyBtn setTitle:@"添加" forState:UIControlStateNormal];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __block BaseViewController *blockSelf = self;
    
    [blockSelf.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening) {
            if (currentInputView.tag > 3) {
                // 有必要的时候 适应键盘
                CGFloat oy = keyboardFrameInView.origin.y;
                CGFloat dy = currentInputView.bottom - scrollView.contentOffset.y;
                if (dy > oy) {
                    scrollView.top = oy - dy - 20;
                }
            }
        }
        if (closing) {
            scrollView.top = 0;
        }
    }];
}

- (void)reloadData {
    if (_goods) {
        product.text = _goods.name;
        model.text = _goods.type;
        feature.text = _goods.features;
        material.text = _goods.material;
        sortPrice.text = _goods.bidding;
        advPrice.text = _goods.adPrice;
    }
}

- (IBAction)btnDidTouchUp:(UIButton *)sender {
    int tag = sender.tag;
    
    switch (tag) {
        case 0:         // apply
            [self apply];
            break;
            
        case 1:         // charge
            [self showAlert:@"测试期间，暂不提供充值服务" isNeedCancel:NO];
            break;
            
        case 2:         // sort
            [self showAlert:@"测试期间，暂不提供竞价排名服务" isNeedCancel:NO];
            break;

        case 3:         // adv
            [self showAlert:@"测试期间，暂不提供竞价排名服务" isNeedCancel:NO];
            break;
            
        default:
            break;
    }
}

- (void)apply {
    if (!product.text.hasValue) {
        [self showText:@"请输入产品名称"];
    } else if (!model.text.hasValue) {
        [self showText:@"请输入产品类型"];
    } else if (!feature.text.hasValue) {
        [self showText:@"请输入产品特征"];
    } else if (!material.text.hasValue) {
        [self showText:@"请输入所需材料"];
    } else {
        [super startRequest];
        
        if (_goods) {
            [client editGoodsForFinacialShopWithId:_goods.id
                                           andName:product.text
                                              type:model.text
                                          features:feature.text
                                          material:material.text
                                           bidding:sortPrice.text
                                           adPrice:advPrice.text];
        } else {
            [client addGoodsForFinacialShopWithName:product.text
                                            andType:model.text
                                           features:feature.text
                                           material:material.text
                                            bidding:sortPrice.text
                                            adPrice:advPrice.text];
        }
    }
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        
    }
    
    if (!sender.hasError) {
        [self popViewController];
    }

    return YES;
}

#pragma mark - View Touched

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignAllKeyboard:self.view];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)sender {
    currentInputView = sender;
    return YES;
}

@end
