//
//  AbnormalAppealViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-15.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "AbnormalAppealViewController.h"
#import "TextInput.h"

@interface AbnormalAppealViewController () <UITextViewDelegate>
{
    IBOutlet KTextView *txtInfo;
    IBOutlet UIImageView *imgTextBackground;
}

@end

@implementation AbnormalAppealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
    [self setRightBarButton:@"申诉" selector:@selector(comfirmRetreat:)];
    self.navigationItem.title = @"异常申诉";
    
    
    UIImage * tfImg = [[UIImage imageNamed:@"bkg_bb_textField"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    imgTextBackground.image = tfImg;
    
    txtInfo.placeholder = @"请填写申诉原因";
    txtInfo.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [txtInfo becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)comfirmRetreat:(UIButton *)sender {
    [txtInfo resignFirstResponder];
    [self sendRequest];
}

- (BOOL)sendRequest {
    if (!([txtInfo.text isKindOfClass:[NSString class]] && txtInfo.text.length > 0)) {
        [self showAlert:@"真的不想说出申诉原因吗？" isNeedCancel:NO];
        return NO;
    }
    
    if ([super startRequest]) {
        [client abnormalAppealWithContent:txtInfo.text];
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
