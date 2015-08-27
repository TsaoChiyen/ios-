//
//  YMTableCellObj.h
//  reSearchDemo
//
//  Created by helfy  on 15-4-15.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    YMParameterCellObjTypeNone =0,
    YMParameterCellObjTypeLabel,
    YMParameterCellObjTypeTextField ,
    YMParameterCellObjTypeTextView ,
    YMParameterCellObjTypeButton ,
    YMParameterCellObjTypeSwitch,
    
    //Labe TextField TextView Button 初始化的时候自动创建，以下不创建
    YMParameterCellObjTypeCustomView ,
}YMParameterCellObjType;
typedef enum
{
    YMParameterCellArrangementTypeHorizontal =0,
    YMParameterCellArrangementTypeVertical,
}YMParameterCellArrangementType;


@interface YMParameterCellObj : NSObject
-(id)initWithObjType:(YMParameterCellObjType )type;


@property (nonatomic,assign) NSInteger cellHeigth;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *subTitle;


@property (nonatomic,strong) UIImage *headImage;
@property (nonatomic,assign) CGSize imageSize;

@property (nonatomic,strong) UIView *accessoryView;
@property (nonatomic,assign) YMParameterCellObjType objType;

@property (nonatomic,assign) NSInteger accessoryViewWidth; // 默认0，与title等宽

@property (nonatomic,assign)   UITableViewCellSelectionStyle   selectionStyle;
@property (nonatomic,assign)   UITableViewCellAccessoryType    accessoryType;
@property (nonatomic,assign) SEL cellAction;
@property (nonatomic,assign) Class pushToClass;
@property (nonatomic,assign) YMParameterCellArrangementType arrangementType;

@property (nonatomic,assign) NSInteger rigthPadding; //






//提交表单使用
@property (nonatomic,assign) BOOL isRequired;  //必填项

@property (nonatomic,strong) NSString *key;
@property (nonatomic,strong) NSString *value;
@property (nonatomic,strong) NSString *regex;   //判断值正则。。不设置之判断是否为空

@property (nonatomic,assign) BOOL canModify;   //defaule yes


@property (nonatomic,assign) id userInfo;


-(NSString *)check;
@end
