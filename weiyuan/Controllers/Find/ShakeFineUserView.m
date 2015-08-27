//
//  ShakeFineUserView.m
//  reSearchDemo
//
//  Created by helfy  on 15-4-18.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "ShakeFineUserView.h"
#import "UIImageView+WebCache.h"
#import "Globals.h"
@implementation ShakeFineUserView
{
    NSDictionary *userDic;
    
    UIImageView *headImageView;
    UILabel *nickName;
    UIImageView *sexImageView;
    UILabel *distanceLabel;
}
-(id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
      userDic = dic;
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
        [self setupView];
    }
    return self;
}


-(void)setupView
{
    headImageView = [[UIImageView alloc] init];
    [self addSubview:headImageView];
    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(10);
        make.width.height.equalTo(50);
        make.top.equalTo(5);
    }];
    
    nickName = [[UILabel alloc] init];
    nickName.backgroundColor = [UIColor clearColor];
    distanceLabel.font = [UIFont systemFontOfSize:16];
    
    [self addSubview:nickName];
    [nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headImageView.mas_right).offset(10);
        make.right.equalTo(-10);
        make.top.equalTo(5);
        make.height.equalTo(20);
    }];
    
    
    sexImageView = [[UIImageView alloc] init];
    [self addSubview:sexImageView];
    [sexImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headImageView.mas_right).offset(10);
        make.top.equalTo(nickName.mas_bottom);
        make.height.width.equalTo(15);
    }];
    
    
    distanceLabel = [[UILabel alloc] init];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:distanceLabel];
    [distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headImageView.mas_right).offset(10);
        make.right.equalTo(-10);
        make.top.equalTo(sexImageView.mas_bottom);
        make.height.equalTo(20);
    }];
    
    
    
//    
//    data = @"{
//    "headsmall": "http:\/\/123.56.101.233:8082\/weiyuan\/Uploads\/Picture\/avatar\/45\/s_8d3639ab7fa64a946d0bcc3518beaee1.jpg",    //头像
//    "nickname": "\u6d4b\u8bd5\u8ba2\u9605\u53f7",  //昵称
//    "gender": "0",  //性别： 0-男 1-女 2-未填写
//    "uid": "45",    //用户ID: 满足摇一摇条件的另外那一人的
//    "distance": "445278.1726126045"  //距离，单位：米
//}"
    
    [headImageView sd_setImageWithURL:[NSURL URLWithString:userDic[@"headsmall"]] placeholderImage:[Globals getImageUserHeadDefault]];
    nickName.text =userDic[@"nickname"];
    
    if ([userDic[@"gender"] isEqualToString:@"1"]) {
        sexImageView.image = LOADIMAGE(@"woman");
    } else {
        sexImageView.image = LOADIMAGE(@"man");
    }
    
    distanceLabel.text = [NSString stringWithFormat:@"%.2f米",[userDic[@"distance"] floatValue]];
}
@end
