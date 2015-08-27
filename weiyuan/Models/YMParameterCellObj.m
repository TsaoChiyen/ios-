//
//  YMTableCellObj.m
//  reSearchDemo
//
//  Created by helfy  on 15-4-15.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "YMParameterCellObj.h"
#import "MTextField.h"
#import "YMTextView.h"
@implementation YMParameterCellObj

@synthesize value = _value;
@synthesize canModify = _canModify;
@synthesize title = _title;
-(id)init{
    self = [super init];
    if(self)
    {
        [self setDefaults];
    }
    return self;
}

-(id)initWithObjType:(YMParameterCellObjType )type
{
    self = [super init];
    if(self)
    {
        [self setDefaults];
        self.objType = type;
        self.rigthPadding = 30;
        switch (self.objType) {
            case YMParameterCellObjTypeLabel:
            {
                self.accessoryView = [UILabel new];
                ((UILabel *)self.accessoryView).adjustsFontSizeToFitWidth = YES;
                self.accessoryView.backgroundColor = [UIColor whiteColor];
                ((UILabel *)self.accessoryView).textAlignment = NSTextAlignmentRight;
                
            }
                break;
            case YMParameterCellObjTypeButton:
            {
                self.accessoryView = [UIButton new];
                self.accessoryView.backgroundColor = [UIColor whiteColor];
                self.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            case YMParameterCellObjTypeSwitch:
            {
                self.accessoryView = [UISwitch new];
                ((UISwitch *)self.accessoryView).contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
                self.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            case YMParameterCellObjTypeTextView:
            {
                self.accessoryView = [YMTextView new];
                self.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                
                break;
            case YMParameterCellObjTypeTextField:
            {
                self.accessoryView = [MTextField new];
                self.accessoryView.backgroundColor = [UIColor whiteColor];
                self.selectionStyle = UITableViewCellSelectionStyleNone;
                ((UITextField *)self.accessoryView).placeholder = @"请输入";
            }
                break;
            case YMParameterCellObjTypeNone:
            {
                self.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            default:
                break;
        }
        
        
    }
    return self;
}
-(void)setDefaults
{
    self.objType = YMParameterCellObjTypeNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.cellHeigth = 44;
    self.canModify = YES;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    if(self.name ==nil)
    {
        self.name = title;
    }
}

-(NSString *)value
{
    if(self.objType == YMParameterCellObjTypeTextField || self.objType == YMParameterCellObjTypeTextView)
    {
        UITextField *inputView = (UITextField *)self.accessoryView;
        NSString *value =inputView.text;
        return value;
    }
    else if(self.objType == YMParameterCellObjTypeSwitch)
    {
        UISwitch *switchView = (UISwitch *)self.accessoryView;
        return [NSString stringWithFormat:@"%i",switchView.on];
    }
    
    return _value;
}
-(void)setValue:(NSString *)value
{
    _value = value;
    if(self.objType == YMParameterCellObjTypeTextField || self.objType == YMParameterCellObjTypeTextView)
    {
        UITextField *inputView = (UITextField *)self.accessoryView;
        inputView.text =value;
        
    }
    else if(self.objType == YMParameterCellObjTypeSwitch)
    {
        UISwitch *switchView = (UISwitch *)self.accessoryView;
        switchView.on =[value boolValue];
    }
    else if(self.objType == YMParameterCellObjTypeLabel)
    {
        UILabel *label = (UILabel *)self.accessoryView;
        
        if(_value.length > 0)
        {
            label.textColor = [UIColor grayColor];
            label.text =value;
        }
        else{
            label.textColor = [UIColor grayColor];
            label.text =@"请选择";
        }
        
        
    }
}

-(void)setCanModify:(BOOL)canModify
{
    _canModify = canModify;
    UIView *inputView = (UIView *)self.accessoryView;
    inputView.userInteractionEnabled = canModify;
}

-(NSString *)check
{
    
    NSString *returnStr = nil;
    if(self.isRequired)
    {
        if(self.objType == YMParameterCellObjTypeTextField || self.objType == YMParameterCellObjTypeTextView)
        {
            if(self.value==nil || self.value.length<1)
            {
                returnStr = [NSString stringWithFormat:@"请输入%@",self.name];
            }
            else
            {
                if(self.regex)
                {
                    NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.regex];
                    if(![regexPredicate evaluateWithObject:self.value])
                    {
                        returnStr = [NSString stringWithFormat:@"请输入正确的%@",self.name];
                    }
                }
            }
        }
        else {
            if(self.value==nil || self.value.length<1)
            {
                returnStr = [NSString stringWithFormat:@"请选择%@",self.name];
            }
        }
        
        
        
    }
    else{
        
        if(self.regex && (self.value!=nil && self.value.length>0))
        {
            NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.regex];
            if(![regexPredicate evaluateWithObject:self.value])
            {
                returnStr = [NSString stringWithFormat:@"请输入正确的%@",self.name];
            }
        }
        
    }
    return returnStr;
}
@end
