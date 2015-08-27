//
//  SMSViewController.m
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-20.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "SMSViewController.h"
#import "TextInput.h"
#import "Globals.h"
#import <MessageUI/MessageUI.h>

@interface SMSViewController () <UITextViewDelegate, MFMessageComposeViewControllerDelegate>
{
    IBOutlet KTextView *txtInfo;
    IBOutlet UIImageView *imgTextBackground;
    IBOutlet UILabel *labelPhone;
    IBOutlet UIButton       * buttonSend;
}

@end

@implementation SMSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [buttonSend navStyle];
    [self setEdgesNone];
    
    self.navigationItem.title = @"短信联系客户";
    
    
    UIImage * tfImg = [[UIImage imageNamed:@"bkg_bb_textField"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    imgTextBackground.image = tfImg;
    
    txtInfo.placeholder = @"请填写短信内容";
    txtInfo.delegate = self;
    
    labelPhone.text = [NSString stringWithFormat:@"客户手机: %@", _phone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [txtInfo becomeFirstResponder];
}

- (IBAction)sendSMS:(id)sender
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController * MsgController = [[MFMessageComposeViewController alloc] init];
        MsgController.recipients = [NSArray arrayWithObject:_phone];
        MsgController.body = txtInfo.text;
        MsgController.messageComposeDelegate = self;
        [self presentModalController:MsgController animated:YES];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self popViewController];
    if (result == MessageComposeResultCancelled)
        DLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        DLog(@"Message sent");
    else
        DLog(@"Message failed");
}

@end
