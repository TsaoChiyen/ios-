//
//  TPickerView.m
//  SpartaEducation
//
//  Created by kiwaro on 14-3-5.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "TPickerView.h"

@interface TPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray	*arrData;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIPickerView *picker;
    UIView * blankView;
}

@end

@implementation TPickerView

- (id)initWithTitle:(NSString *)title data:(NSArray *)data delegate:(id)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TPickerView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        arrData = data;
        self.delegate = delegate;
        titleLabel.text = title;
        picker.dataSource = self;
        picker.delegate = self;
        picker.backgroundColor = RGBCOLOR(245, 241, 247);
        [self loadData];
    }
    return self;
}

- (void)loadData {
    //加载数据
    self.selected = [arrData objectAtIndex:0];
    self.selectedID = 0;
}
- (void)dealloc
{
    self.selected = nil;
}

- (void)showInView:(UIView *)view
{
    blankView = [[UIView alloc] initWithFrame:view.bounds];
    blankView.backgroundColor = [UIColor blackColor];
    blankView.alpha = 0;
    [view addSubview:blankView];
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self setAlpha:1.0f];
    [self.layer addAnimation:animation forKey:@"ShowPickView"];
    
    self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    blankView.alpha = 0.3;
    [view addSubview:self];
    [UIView commitAnimations];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)sender
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)sender numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [arrData count];
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)sender titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [arrData objectAtIndex:row];
            break;

        default:
            return nil;
            break;
    }
}

- (void)pickerView:(UIPickerView *)sender didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
        self.selected = [arrData objectAtIndex:row];
        self.selectedID = row;
        break;
        
        default:
        break;
    }
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    blankView.alpha = 0;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TPickerView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:0];
    }
}

- (IBAction)done:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    blankView.alpha = 0;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TPickerView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3];
    if(self.delegate) {
        [self.delegate actionSheet:self clickedButtonAtIndex:1];
    }
    
}

@end
