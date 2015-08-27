//
//  AddCommentViewController.m
//  weiyuan
//
//  Created by Kiwaro on 15-2-8.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "AddCommentViewController.h"
#import "Star.h"
#import "TextInput.h"
#import "Good.h"
#import "Comment.h"

@interface AddCommentViewController ()<UITextViewDelegate> {
    IBOutlet Star * star;
    IBOutlet UIButton * button;
    IBOutlet KTextView * textView;
}

@end

@implementation AddCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"发布评论";
    star.isSelect = YES;
    star.backgroundColor = [UIColor clearColor];
    [textView enableBorder];
    textView.placeholder = @"评论内容";
    [button commonStyle];
    [self setEdgesNone];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __block BaseViewController *blockSelf = self;
    [blockSelf.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening) {
            // 有必要的时候 适应键盘
            CGFloat oy = keyboardFrameInView.origin.y;
            if (currentInputView.bottom>oy) {
                self.view.top -= 50;
            }
        }
        if (closing) {
            self.view.top = 64;
        }
    }];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)sender {
    currentInputView = sender;
    return YES;
}

- (IBAction)buttonPressed:(id)sender {
    if (!textView.text.hasValue) {
        [self showText:@"请输入评论内容"];
    } else {
        [super startRequest];
        [client addComment:_goods.id star:@(star.show_star).stringValue content:textView.text];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [textView resignFirstResponder];
}

- (BOOL)requestDidFinish:(BSClient*)sender obj:(NSDictionary *)obj {
    if ([super requestDidFinish:sender obj:obj]) {
        [self showText:sender.errorMessage];
        if ([_delegate respondsToSelector:@selector(AddCommentAction:newComment:star:)]) {
            NSDictionary * dic = [obj getDictionaryForKey:@"data"];
            NSString * newCount = [dic getStringValueForKey:@"commentcount" defaultValue:@"0"];
            NSString * newStar = [dic getStringValueForKey:@"star" defaultValue:@"0"];
            Comment * it = [Comment objWithJsonDic:[dic getDictionaryForKey:@"comment"]];
            [_delegate AddCommentAction:newCount newComment:it star:newStar];
        }
        [self popViewController];
    }
    return YES;
}

@end
