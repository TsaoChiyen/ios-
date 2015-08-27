//
//  DemandPublishViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-16.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "DemandPublishViewController.h"
#import "TextInput.h"
#import "LocationManager.h"

@interface DemandPublishViewController () <UITextViewDelegate>
{
    IBOutlet KTextView *txtInfo;
    IBOutlet UIImageView *imgTextBackground;
    IBOutlet UILabel *lblStatus;
}

@end

@implementation DemandPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesNone];
    
    [self setRightBarButton:@"发布" selector:@selector(comfirmRetreat:)];
    self.navigationItem.title = @"发布需求";
    
    
    UIImage * tfImg = [[UIImage imageNamed:@"bkg_bb_textField"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    imgTextBackground.image = tfImg;
    
    txtInfo.placeholder = @"请简要写出你的需求，内容不超过40字";
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

- (void)comfirmRetreat:(id)sender {
    [txtInfo resignFirstResponder];
    [self sendRequest];
}

- (BOOL)sendRequest {
    if (!([txtInfo.text isKindOfClass:[NSString class]] && txtInfo.text.length > 0)) {
        [self showAlert:@"请输入文字后再发布" isNeedCancel:NO];
        return NO;
    }
    
    [self popViewController];
    if ([super startRequest]) {
        Location loc = [[LocationManager sharedManager] coordinate];
        
        [client addDemandWithContent:txtInfo.text
                                 lat:@(loc.lat).stringValue
                                 lng:@(loc.lng).stringValue];
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

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger number = [textView.text length];

    if (number > 40) {
        textView.text = [textView.text substringToIndex:40];
        number = 40;
    }

    lblStatus.text = [NSString stringWithFormat:@"%d/40",number];
}

@end
