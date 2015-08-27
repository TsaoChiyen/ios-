//
//  SessionActionBar.m
//
//  AppDelegate.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "SessionActionBar.h"
#import "EmotionInputView.h"
#import "UIColor+FlatUI.h"
@import QuartzCore.QuartzCore;

@implementation SessionActionBar {
    UIButton * btnKeyboard;
    UIButton * btnKeyboardTalk;
    UIButton * btnMore;
    UIButton * btnTalk;
    UIButton * btnEmo;
    EmotionInputView    * emojiView;
    BOOL hasMenu;
    BOOL showingInputBar;
    
    UIView *barView;
    UIView *menuView;
    UIView *actionPop;
    UIButton *hideListBtn;
    
    NSArray *curListMenu;
}

@synthesize textView;
@synthesize talkingState;
@synthesize state;
@synthesize talkState;
@synthesize sessionDelegate;
@synthesize inputView;

- (id)initWithOrigin:(CGPoint)origin withMenu:(BOOL)menu{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, Main_Screen_Width, 44)];
    if (self) {
        self.clipsToBounds = YES;
        
        hasMenu = menu;
        // Initialization code
        CGFloat originX = hasMenu?42:6.f;
        CGFloat originY = 7;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.65)];
        line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        [self addSubview:line];
        
        
        barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        barView.backgroundColor = [UIColor clearColor];
        barView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:barView];
        
        if (hasMenu) {
            barView.frame = CGRectMake(0, self.height, self.width, self.height);
            
            menuView = [[UIView alloc] initWithFrame:self.bounds];
            menuView.backgroundColor = [UIColor clearColor];
            menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [self addSubview:menuView];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(6, originY, 30, 30);
            btn.backgroundColor = [UIColor clearColor];
            btn.tag = 10000;
            [btn setImage:LOADIMAGE(@"keyboard_u_n") forState:UIControlStateNormal];
            [btn setImage:LOADIMAGE(@"keyboard_u_d") forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(changeToMenu:) forControlEvents:UIControlEventTouchUpInside];
            [menuView addSubview:btn];
            btn = nil;
            
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(6, originY, 30, 30);
            btn.backgroundColor = [UIColor clearColor];
            [btn setImage:LOADIMAGE(@"keyboard_n") forState:UIControlStateNormal];
            [btn setImage:LOADIMAGE(@"keyboard_d") forState:UIControlStateHighlighted];
            btn.tag=1;
            [btn addTarget:self action:@selector(changeToMenu:) forControlEvents:UIControlEventTouchUpInside];
            [barView addSubview:btn];
            btn = nil;
            
            actionPop = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, self.height)];
            actionPop.backgroundColor = [UIColor clearColor];
            UIImageView *popBg = [[UIImageView alloc] initWithFrame:actionPop.bounds];
            popBg.image = [LOADIMAGE(@"white_pop_bg") resizableImageWithCapInsets:UIEdgeInsetsMake(6, 3, 10, 16)];
            popBg.tag = 10000;
//            popBg.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [actionPop addSubview:popBg];
            
            hideListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            hideListBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [hideListBtn addTarget:self action:@selector(hideListMenu) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(originX, originY, 30, 30);
        [btn setImage:LOADIMAGE(@"talk_btn_key_s") forState:UIControlStateNormal];
        [btn setImage:LOADIMAGE(@"talk_btn_key_d") forState:UIControlStateHighlighted];
        [btn setImage:LOADIMAGE(@"talk_btn_keyboard") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnKeyboardPress:) forControlEvents:UIControlEventTouchUpInside];
        [barView addSubview:btn];
        btnKeyboard = btn;
        btn = nil;
        
        originX += 35.f;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(originX, originY, 30, 30);
        [btn setImage:LOADIMAGE(@"talk_btn_key_more") forState:UIControlStateNormal];
        [btn setImage:LOADIMAGE(@"talk_btn_key_minus") forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnMoreViewPress:) forControlEvents:UIControlEventTouchUpInside];
        [barView addSubview:btn];
        btnMore = btn;
        btn = nil;
        
        originX += 35.f;
        UITextView * kTextView = [[UITextView alloc] initWithFrame:CGRectMake(originX,
                                                                              originY,
                                                                              Main_Screen_Width -  (originX + 60),
                                                                              30)];
        kTextView.returnKeyType = UIReturnKeyDone;
        kTextView.font = [UIFont systemFontOfSize:14];
        kTextView.layer.cornerRadius = 4;
        kTextView.layer.borderWidth = 1;
        kTextView.layer.borderColor = RGBCOLOR(206, 206, 206).CGColor;
        [barView addSubview:kTextView];
        self.textView = kTextView;
        originX += kTextView.width + 5;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn navBlackStyle];
        btn.frame = CGRectMake(originX, originY, 47, 29);
        [btn setTitle:@"发送" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        [barView addSubview:btn];

        self.backgroundColor = RGBCOLOR(243, 243, 243);
        
        // keyboardInputView
        self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 150)];
        
        CGFloat itemOffset = (SCREEN_WIDTH-(45*4))/5;
        originY = 20;
        originX = itemOffset;
        
        for (int i=0; i<6;i++) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(originX, originY, 45, 45);
            btn.tag = i;
            NSString *str = [NSString stringWithFormat:@"SessionBarIcon%d",i];
            [btn setImage:LOADIMAGE(str) forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnItemPressed:) forControlEvents:UIControlEventTouchUpInside];
            [inputView addSubview:btn];
            btn = nil;
            if (i == 3) {
                originY += 65;
                originX = itemOffset;
            } else {
                originX += 45+itemOffset;
            }
        }
        self.inputView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) dealloc {
    [actionPop removeFromSuperview];
    actionPop = nil;
    self.textView = nil;
    self.sessionDelegate = nil;
    self.inputView = nil;
    Release(btnKeyboard);
    Release(btnMore);
    Release(btnKeyboardTalk);
    Release(btnTalk);
    Release(emojiView);
}

- (void)setMenuData:(NSArray *)menuData{
    
    _menuData = menuData;
    
    for (UIView *view in menuView.subviews) {
        if (view.tag != 10000) {
            [view removeFromSuperview];
        }
    }
    
    if (menuData.count) {
        CGFloat xOffset = 42;
        CGFloat itemWidth = (menuView.width-xOffset)/menuData.count;
        for (NSDictionary *menu in menuData) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, 0.65, menuView.height)];
            line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
            [menuView addSubview:line];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitle:menu[@"name"] forState:UIControlStateNormal];
            btn.tag = [menuData indexOfObject:menu];
            [btn addTarget:self action:@selector(menuDidTap:) forControlEvents:UIControlEventTouchUpInside];
            [menuView addSubview:btn];
            
            btn.frame = CGRectMake(xOffset, 0, itemWidth, menuView.height);
            xOffset += itemWidth;
        }
    }
}

- (void)menuDidTap:(UIButton *)btn{
    
    NSDictionary *menu = self.menuData[btn.tag];
    NSInteger type = [menu[@"type"] integerValue];
    if (type==MenuTypeOpenLink && self.sessionDelegate && [self.sessionDelegate respondsToSelector:@selector(actionBarMenuDidTap:)]) {
        [self.sessionDelegate actionBarMenuDidTap:menu];
    }
    if (type==MenuTypeOpenList) {
        NSArray *list = menu[@"list"];
        actionPop.frame = CGRectMake(btn.left, btn.bottom, btn.width, btn.height);
        [self showSubMenuList:list];
    }
}

- (void)hideListMenu{
    
    [UIView animateWithDuration:0.3 animations:^{
        actionPop.frame = CGRectMake(actionPop.left, SCREEN_HEIGHT, actionPop.width, actionPop.height);
        actionPop.alpha = 0;
    } completion:^(BOOL finished) {
        [hideListBtn removeFromSuperview];
        [actionPop removeFromSuperview];
    }];
}

- (void)showSubMenuList:(NSArray *)menuList{
    
    curListMenu = menuList;
    UIView *imgView = nil;
    for (UIView *view in actionPop.subviews) {
        if (view.tag!=10000) {
            [view removeFromSuperview];
        }else{
            imgView = view;
        }
    }
    
    CGFloat yOffset = 0;
    CGFloat offset = 5;
    CGFloat itemHeight = 34;
    for (NSDictionary *menu in menuList) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:menu[@"name"] forState:UIControlStateNormal];
        btn.tag = [menuList indexOfObject:menu];
        btn.frame = CGRectMake(offset, yOffset, actionPop.width-(offset*2), itemHeight);
        [btn addTarget:self action:@selector(listMenuDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [actionPop addSubview:btn];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, btn.bottom, actionPop.width, 0.65)];
        line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        [actionPop addSubview:line];
        
        yOffset += itemHeight;
    }
    actionPop.frame = CGRectMake(actionPop.left, SCREEN_HEIGHT, actionPop.width, yOffset+5.5);
    actionPop.alpha = 0;
    imgView.frame = actionPop.bounds;
    [[[UIApplication sharedApplication] keyWindow] addSubview:hideListBtn];
    [[[UIApplication sharedApplication] keyWindow] addSubview:actionPop];
    
    [UIView animateWithDuration:0.3 animations:^{
        actionPop.frame = CGRectMake(actionPop.left,SCREEN_HEIGHT-self.height-actionPop.height-5, actionPop.width, actionPop.height);
        actionPop.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)listMenuDidTap:(UIButton *)btn{

    [self hideListMenu];
    NSDictionary *menu = curListMenu[btn.tag];
    NSInteger type = [menu[@"type"] integerValue];
    if (type==MenuTypeOpenLink && self.sessionDelegate && [self.sessionDelegate respondsToSelector:@selector(actionBarMenuDidTap:)]) {
        [self.sessionDelegate actionBarMenuDidTap:menu];
    }
}

- (void)changeToMenu:(UIButton *)btn{
    
    showingInputBar = btn.tag==10000;
    [self bringSubviewToFront:showingInputBar?barView:menuView];
    if (!showingInputBar) {
        [self.textView resignFirstResponder];
    }
    [UIView animateWithDuration:0.2 animations:^{
        barView.frame = CGRectMake(0, showingInputBar?0:self.height, self.width, self.height);
        menuView.frame = CGRectMake(0, showingInputBar?self.height:0, self.width, self.height);
    }];
}

- (void)sendMessage {
    if (textView.text.length > 0) {
//        [self setClose:YES];
        if ([sessionDelegate respondsToSelector:@selector(actionBarSendMessage:)]) {
            [sessionDelegate actionBarSendMessage:textView.text];
        }
    }
}

- (void)setText:(NSString*)t {
    if (textView.text && textView.text.length > 0) {
        textView.text = [NSString stringWithFormat:@"%@%@", textView.text, t];
    } else {
        textView.text = t;
    }
}

- (void)setTalkingState:(BOOL)sts {
    if (talkingState != sts) {
        talkingState = sts;
        btnKeyboardTalk.hidden = sts;
    }
}

- (void)setTalkState:(TalkState)ts {
    talkState = ts;
    if (ts == TalkStateNone) {
        [self setClose:YES];
    }
}

- (void)setState:(ActionBarState)sts {
    if (state != sts) {
        state = sts;
    }
    if (sts == ActionBarStateReInsert) {
        self.textView.inputView = nil;
        [self.textView resignFirstResponder];
    } else if (sts == ActionBarStateInsert){
        self.textView.inputView = self.inputView;
        [self.textView becomeFirstResponder];
    } else if (sts == ActionBarStateEmotion){
        if (emojiView == nil) {
            emojiView = [[EmotionInputView alloc] initWithOrigin:CGPointMake(0, 44) del:self];
        }
        self.textView.inputView = emojiView;
        [self.textView becomeFirstResponder];
    }
}

- (void)btnMoreViewPress:(UIButton*)sender {
    btnMore.selected = !btnMore.selected;
    self.talkingState = NO;
    textView.hidden = talkingState;
    btnTalk.hidden = !talkingState;
    btnKeyboard.selected = NO;
    
    [self.textView resignFirstResponder];
    self.state = btnMore.selected?ActionBarStateInsert:ActionBarStateReInsert;
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
}

- (void)btnItemPressed:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.textView resignFirstResponder];
        btnMore.selected = YES;
        self.state = ActionBarStateEmotion;
    } else if (sender.tag == 1) {
        state = ActionBarStateCamera;
        [self.textView resignFirstResponder];
    } else if (sender.tag == 2) {
        state = ActionBarStatePhoto;
        [self.textView resignFirstResponder];
    } else if (sender.tag == 3) {
        state = ActionBarStateMap;
        [self.textView resignFirstResponder];
    } else if (sender.tag == 4) {
        [self.textView resignFirstResponder];
        state = ActionBarStateNameCard;
    } else if (sender.tag == 5) {
        [self.textView resignFirstResponder];
        state = ActionBarStateMyFav;
    }
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
}

- (void)setClose:(BOOL)close {
    btnMore.selected = NO;
    self.state = ActionBarStateReInsert;
}

- (void)btnKeyboardPress:(UIButton*)sender {
    sender.selected = !sender.selected;
    self.talkingState = !talkingState;
    textView.hidden = talkingState;
    if (!btnTalk) {
        btnTalk = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTalk.frame = textView.frame;
        [btnTalk setTitle:@"按住说话" forState:UIControlStateNormal];
        [btnTalk commonStyle];
        [btnTalk setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [barView addSubview:btnTalk];
        [btnTalk addTarget:self action:@selector(btnRecordDragInside:) forControlEvents:UIControlEventTouchDragInside];
        [btnTalk addTarget:self action:@selector(btnRecordDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [btnTalk addTarget:self action:@selector(btnRecordTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];
        [btnTalk addTarget:self action:@selector(btnRecordTouchDown:) forControlEvents:UIControlEventTouchDown];
        [btnTalk addTarget:self action:@selector(btnRecordTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    btnTalk.hidden = !talkingState;
    self.state = (talkingState) ? 1 : 0;
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
    if (talkingState) {
        [textView resignFirstResponder];
        btnMore.selected = NO;
    }
}

- (void)btnInsertPress:(id)sender {
    self.talkingState = NO;
    textView.hidden = NO;
    btnTalk.hidden = YES;
    self.state = 2;
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
}

- (void)btnRecordTouchDown:(id)sender {
    self.talkingState = TalkStateTalking;
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkStateChanged:)]) {
        [sessionDelegate actionBarTalkStateChanged:TalkStateTalking];
    }
}
- (void)btnRecordTouchUp:(id)sender {
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkFinished)]) {
        [sessionDelegate actionBarTalkFinished];
    }
}

- (void)btnRecordTouchCancel:(id)sender {
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkStateChanged:)]) {
        [sessionDelegate actionBarTalkStateChanged:TalkStateNone];
    }
}

- (void)btnRecordDragInside:(id)sender {
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkStateChanged:)]) {
        [sessionDelegate actionBarTalkStateChanged:TalkStateTalking];
    }
}

- (void)btnRecordDragOutside:(id)sender {
    if ([sessionDelegate respondsToSelector:@selector(actionBarTalkStateChanged:)]) {
        [sessionDelegate actionBarTalkStateChanged:TalkStateCanceling];
    }
}

#pragma mark - EmotionInputViewDelegate
- (void)emotionInputView:(id)sender output:(NSString*)str {
    if ([textView.text isKindOfClass:[NSString class]] && textView.text.length > 0) {
        textView.text = [NSString stringWithFormat:@"%@%@", textView.text, [EmotionInputView emojiText4To5:str]];
    } else {
        textView.text = [EmotionInputView emojiText4To5:str];
    }
}

- (void)emotionInputView:(id)sender otherOutput:(NSString*)str {
    self.state = ActionBarStateEmotion;
    if ([sessionDelegate respondsToSelector:@selector(actionBarDidChangeState:)]) {
        [sessionDelegate actionBarDidChangeState:state];
    }
}

@end
