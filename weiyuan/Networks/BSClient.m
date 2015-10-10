//
//  BSClient.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BSClient.h"
#import "BSEngine.h"
#import "StRequest.h"
#import "Message.h"
#import "KAlertView.h"
#import "Good.h"
#import "Room.h"

@interface BSClient () <StRequestDelegate> {
    BOOL    needUID;
    BOOL    cancelled;
    BOOL    isGet;
}

@property (nonatomic, assign) id          delegate;
@property (nonatomic, assign) SEL         action;
@property (nonatomic, strong) StRequest * bsRequest;
@property (nonatomic, weak)   BSEngine  * engine;

@end

@implementation BSClient

@synthesize action;
@synthesize bsRequest;
@synthesize engine;
@synthesize errorMessage;
@synthesize errorCode;
@synthesize hasError;
@synthesize indexPath;
@synthesize tag;
@synthesize delegate;

- (id)initWithDelegate:(id)del action:(SEL)act {
    self = [super init];
    if (self) {
        self.delegate = del;
        self.action = act;
        
        needUID = YES;
        self.hasError = YES;
        self.engine = [BSEngine currentEngine];
    }
    return self;
}

- (void)dealloc {
    Release(tag);
    Release(indexPath);
    Release(errorMessage);
    Release(action);
    Release(bsRequest);
    Release(engine);
    self.delegate = nil;
}

- (void)cancel {
    if (!cancelled) {
        [bsRequest disconnect];
        self.bsRequest = nil;
        cancelled = YES;
        self.action = nil;
        self.delegate = nil;
    }
}

- (void)showAlert {
    NSString* alertMsg = nil;
    if ([errorMessage isKindOfClass:[NSString class]] && errorMessage.length > 0) {
        alertMsg = errorMessage;
    } else {
        alertMsg = @"服务器出去晃悠了，等它一下吧！";
    }
    NSLog(@"error is %@",alertMsg);

        [KAlertView showType:KAlertTypeError text:alertMsg for:0.8 animated:YES];
    
}

- (void)loadRequestWithDoMain:(BOOL)isDoMain
                   methodName:(NSString *)methodName
                       params:(NSMutableDictionary *)params
                 postDataType:(StRequestPostDataType)postDataType {
    [bsRequest disconnect];
    
    NSMutableDictionary* mutParams = [NSMutableDictionary dictionaryWithDictionary:params];

//    [mutParams setObject:APPKEY forKey:@"appkey"];

    if (needUID && [engine isLoggedIn]) {
        [mutParams setObject:engine.user.uid forKey:@"uid"];
    }
    
    self.bsRequest = [StRequest requestWithURL:[NSString stringWithFormat:@"%@%@", KBSSDKAPIDomain, methodName]
                                  httpMethod:@"POST"
                                      params:mutParams
                                postDataType:postDataType
                            httpHeaderFields:nil
                                    delegate:self];
    
	[bsRequest connect];
}

#pragma mark - StRequestDelegate Methods

- (void)request:(StRequest*)sender didFailWithError:(NSError *)error {
    if (cancelled) {
        return;
    }
    
    NSString * errorStr = [[error userInfo] objectForKey:@"error"];
    if (errorStr == nil || errorStr.length <= 0) {
        errorStr = [NSString stringWithFormat:@"%@", [error localizedDescription]];
    } else {
        errorStr = [NSString stringWithFormat:@"%@", [[error userInfo] objectForKey:@"error"]];
    }
    if ([errorStr hasPrefix:@"The operation couldn’t"]) {
        errorStr = @"服务器换班去啦，客官就请歇息下吧!";
    }
    self.errorMessage = errorStr;
    
    if ([delegate respondsToSelector:action]) {
        IMP imp = [delegate methodForSelector:action];
        void (*func)(id, SEL, id, id) = (void *)imp;
        func(delegate, action, self, error);
    }
    
    self.bsRequest = nil;
}

- (void)request:(StRequest*)sender didFinishLoadingWithResult:(NSDictionary*)result {
    if (cancelled) {
        return;
    }
    
    int stateCode = -1;
    if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
        NSDictionary* state = [result objectForKey:@"state"];
        if (state != nil && [state isKindOfClass:[NSDictionary class]]) {
            stateCode = [state getIntValueForKey:@"code" defaultValue:stateCode];
            self.errorCode = stateCode;
            self.hasError = (stateCode != 0);
            self.errorMessage = [state getStringValueForKey:@"msg" defaultValue:nil];
        }
    }
    
    if (stateCode != 0 && self.errorMessage == nil) {
        self.errorMessage = @"让网络飞一会再说吧..";
    }
    
    self.bsRequest = nil;
    if (cancelled) {
        return;
    }
    if ([delegate respondsToSelector:action]) {
        IMP imp = [delegate methodForSelector:action];
        void (*func)(id, SEL, id, id) = (void *)imp;
        func(delegate, action, self, result);
    }
}

#pragma mark - Method

/**
 *  Copyright © 2015 tcy@dreamisland. All rights reserved.
 *  用户注册协议(user/apiother/regist)
 *  @return     html
 */
- (NSURLRequest *)getProtocol {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/apiother/regist", KBSSDKAPIDomain]];
    return [NSURLRequest requestWithURL:url];
}

/**
 *  Copyright © 2015 tcy@dreamisland. All rights reserved.
 *  帮助中心(user/apiother/help)
 *  @return     html
 */
- (NSURLRequest *)getHelp {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/apiother/help", KBSSDKAPIDomain]];
    return [NSURLRequest requestWithURL:url];
}

/**
 *  Copyright © 2015 tcy@dreamisland. All rights reserved.
 *  获取验证码(user/apiother/getCode)
 *  @param phone    手机号码
 */
- (void)getPhoneCode:(NSString*)phone {
    needUID = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/apiother/getCode"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *  验证验证码(/user/apiother/checkCode)
 *  @param phone	true	string	手机号
 *  @param code     true	string	验证码
 */
- (void)checkVerCodeWithPhone:(NSString *)phone andCode:(NSString *)code {
    needUID = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:code  forKey:@"code"];
    [params setObject:phone forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/apiother/getCode"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *  更新用户的Gps user/api/upateGps
 *  @param uid false string 登录用户id
 *  @param lat true string 纬度
 *  @param lng true string 经度
 *  @throws WeiYuanException
 */
- (void)updataGpsWithLat:(NSString *)lat andLng:(NSString *)lng {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:lat forKey:@"lat"];
    [params setObject:lng forKey:@"lng"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/upateGps"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	登录
 *	@param 	Phone 	手机号
 *	@param 	pwd 	密码
 */
- (void)loginWithUserPhone:(NSString *)phone password:(NSString *)pwd {
    needUID = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [params setObject:pwd forKey:@"password"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/login"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *  Copyright © 2015 tcy@dreamisland. All rights reserved.
 *  获取地区表
 */
- (void)getAreaList {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/apiother/areaList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

- (void)regWithPhone:(NSString *)phone
            password:(NSString *)password
                code:(NSString *)code
{
    needUID = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [params setObject:password forKey:@"password"];
    if (code && code.length > 0) {
        [params setObject:code forKey:@"code"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/regist"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据uid获取详细资料
 *
 *	@param 	fuid 	fuid
 */

- (void)getUserInfoWithuid:(NSString*)uid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据Keyword获取资料
 *
 *	@param 	Keyword 	昵称/电话
 */

- (void)getUserInfoWithKeyword:(NSString*)keyword page:(int)page {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:keyword forKey:@"search"];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/search"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

- (void)setMarkName:(NSString*)name fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:name forKey:@"remark"];
    [params setObject:fuid forKey:@"fuid"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/remark"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	附近的人
 *  gender: 0 男 1 女 2 未填写
 *
 */
- (void)nearbyUserWithlat:(NSString*)lat lng:(NSString*)lng gender:(NSString*)gender page:(int)page {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (lat) {
        [params setObject:lat forKey:@"lat"];
        [params setObject:lng forKey:@"lng"];
    }
    if (gender) {
        [params setObject:gender forKey:@"gender"];
    }

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/nearbyUser"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= editInfo =========
// 编辑资料
- (void)editUserInfo:(UIImage*)headImg user:(NSMutableDictionary *)user {
    StRequestPostDataType dataType = KSTRequestPostDataTypeNormal;
    if (headImg) {
        [user setObject:headImg forKey:@"picture"];
        dataType= KSTRequestPostDataTypeMultipart;
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/edit"
                         params:user
                   postDataType:dataType];
}

// ========= Friend =========

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	添加好友
 *
 *	@param 	fuid 	uid
 *	@param 	content 	理由
 */
- (void)to_friend:(NSString*)fuid content:(NSString*)content {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    if (content&&content.length>0) {
        [params setObject:content forKey:@"content"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/applyAddFriend"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	 删除好友
 *
 *	@param 	fuid 	uid
 */
- (void)del_friend:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/deleteFriend"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	同意申请加好友
 *
 *	@param 	fuid 	uid
 */
- (void)agreeAddFriend:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/agreeAddFriend"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	好友列表
 *
 */
- (void)friendList;
 {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/friendList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	通讯录添加好友
 *  @param phones 上传格式：电话1,电话2,电话3,电话4
 *  @return type  	0-不是系统用户，可邀请的用户 1-系统用户
            isfriend  0-不是好友 可以添加 1-是好友
 */
- (void)telephone:(NSString*)phones {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phones forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/importContact"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	新的朋友
 *  @param phones 上传格式：电话1,电话2,电话3,电话4
 */
- (void)newFriends:(NSString*)phones {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phones forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/newFriend"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *  个人相册
 *  @param fuid 不传刚获取自己的，传刚获取别人的
 */
- (void)userAlbum:(NSString*)fuid page:(int)page {
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }
    
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/userAlbum"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}
// ========= 黑名单 =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	添加到黑名单
 *
 *	@param 	fuid 	uid
 */
- (void)black:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/black"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	黑名单列表
 *
 */
- (void)blackList {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/blackList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 * 收藏列表
 *
 */
- (void)favoriteList {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/favoriteList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 * 删除收藏
 *
 */
- (void)deleteFavorite:(NSString*)fid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fid forKey:@"favoriteid"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/deleteFavorite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 * 增加收藏
 *
 *	@param fuid 被收藏人的uid
 *	@param otherid 如果是收藏的群组的消息，就传入此id
 *	@param content 收藏的内容
 */
- (void)addfavorite:(NSString*)fuid otherid:(NSString*)otherid content:(NSString*)content {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    if (otherid) {
        [params setObject:otherid forKey:@"otherid"];
    }
    [params setObject:content forKey:@"content"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/favorite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 聊天消息 =========

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	发送消息
 *
 *	@param msg 消息对象
 *
 */
- (void)sendMessageWithObject:(Message*)msg {
    [self sendMessageToid:msg.toId
                   toname:msg.toname
                    tourl:msg.tohead
                     file:msg.value
                 typefile:msg.typefile
                 typechat:[NSString stringWithFormat:@"%d", msg.typechat]
                voicetime:msg.voiceTime
                      lat:[NSString stringWithFormat:@"%f", msg.address.lat]
                      lng:[NSString stringWithFormat:@"%f", msg.address.lng]
                  address:msg.address.address
                  content:msg.content
                      tag:msg.tag
                     time:msg.sendTime];
}
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	发送消息
 *
 *	@param fromid       false   发送者id
 *	@param fromname     true    发送者name
 *	@param fromurl      true    发送者头像
 *	@param toid         true    接收者，可以是某人，也可以是某个群id
 *	@param toname       true    接收者name
 *	@param file         false   上传图片/声音
 *	@param voicetime    false   声音时间长度
 *	@param address      false   地址
 *	@param content      false   消息的文字内容
 *	@param typechat     false   100-单聊 200-群聊 300-临时会话 默认为100
 *	@param typefile     false   1-文字 2-图片 3-声音 4-位置 默认为1
 *	@param tag          true    标识符
 *	@param time         true    发送消息的时间,毫秒（服务器生成）
 *
 */
- (void)sendMessageToid:(NSString*)toid
                 toname:(NSString*)toname
                  tourl:(NSString*)tourl
                   file:(id)file
               typefile:(int)typefile
               typechat:(NSString*)typechat
              voicetime:(NSString*)voicetime
                    lat:(NSString*)lat
                    lng:(NSString*)lng
                address:(NSString*)address
                content:(NSString*)content
                    tag:(NSString*)_tag
                   time:(NSString*)time {
    
    StRequestPostDataType dType = KSTRequestPostDataTypeNormal;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[BSEngine currentUserId] forKey:@"fromid"];
    if (typechat.intValue == 300) {
        Room * room = [Room roomForUid:toid];
        if (room) {
            [params setObject:room.mynickname forKey:@"fromname"];
        } else {
            [params setObject:[[BSEngine currentUser] nickname] forKey:@"fromname"];
        }
    } else {
        [params setObject:[[BSEngine currentUser] nickname] forKey:@"fromname"];
    }
    
    [params setObject:[[BSEngine currentUser] headsmall] forKey:@"fromurl"];
    [params setObject:toid forKey:@"toid"];
    [params setObject:toname forKey:@"toname"];
    if (tourl) {
        [params setObject:tourl forKey:@"tourl"];
    }
    if (file) {
        if (![file isKindOfClass:[NSString class]]) {
            // 只有非转发的消息才会上传媒体数据
            dType = KSTRequestPostDataTypeMultipart;
        }
        [params setObject:file forKey:@"image"];
    }
    if (voicetime) {
        [params setObject:voicetime forKey:@"voicetime"];
    }
    if (lat) {
        [params setObject:lat forKey:@"lat"];
    }
    if (lng) {
        [params setObject:lng forKey:@"lng"];
    }
    if (address) {
        [params setObject:address forKey:@"address"];
    }
    if (typechat) {
        [params setObject:typechat forKey:@"typechat"];
    }
    if (typefile) {
        [params setObject:[NSString stringWithFormat:@"%d", typefile] forKey:@"typefile"];
    }
    if (content) {
        [params setObject:content forKey:@"content"];
    }
    [params setObject:_tag forKey:@"tag"];
    [params setObject:time forKey:@"time"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/sendMessage"
                         params:params
                   postDataType:dType];
    
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置是否接收另一用户的消息
 *
 *	@param fuid 用户id
 *
 */
- (void)setGetmsg:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/setGetmsg"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置星标朋友
 *
 *	@param fuid 用户id
 *
 */
- (void)setStar:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/setStar"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 群聊 =========
// /api/group/
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	创建群组
 *
 *	@param 	inviteduids 	参数格式: uid1,uid2,uid3
 *	@param 	groupname 	聊天群的名称
 */
- (void)createGroupAndInviteUsers:(NSArray*)inviteduids groupname:(NSString*)groupname
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSMutableArray * idArr = [NSMutableArray array];
    if (!groupname) {
        NSMutableArray* nameArr = [NSMutableArray array];
        [nameArr addObject:[BSEngine currentUser].nickname];
        for (User * user in inviteduids) {
            if (nameArr.count < 4) {
                [nameArr addObject:user.nickname];
            }
            
            [idArr addObject:user.uid];
        }
        groupname = [nameArr componentsJoinedByString:@","];
    }
    [params setObject: [idArr componentsJoinedByString:@","] forKey:@"uids"];
    [params setObject:groupname forKey:@"name"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/add"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	删除群组
 *
 *	@param 	groupid 	群组id
 */
- (void)delGroup:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/delete"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	查找群
 *
 *	@param 	keyword 	可以是群昵称或群id
 */
- (void)groupSearch:(NSString*)keyword page:(int)page {
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    [params setObject:keyword forKey:@"keyword"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/search"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据群id获取群信息
 *
 *	@param 	groupid 	群组id
 */
- (void)groupDetail:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据群id加入群
 *
 *	@param 	groupid 	群组id
 */
- (void)addtogroup:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/join"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	添加用户到群组
 *
 *	@param 	groupid 	群组id
 *	@param 	inviteduids 	参数格式: uid1,uid2,uid3
 */
- (void)inviteUser:(NSString*)groupid inviteduids:(NSArray*)inviteduids {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:[inviteduids componentsJoinedByString:@","] forKey:@"uids"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/addUserToSession"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取可邀请的成员
 *
 *	@param 	groupid 	群组id
 */
- (void)inviteMember:(NSString*)groupid page:(int)page {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/contactList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	把用户从某个群踢出
 *
 *	@param 	groupid 	群组id
 *	@param 	fuid 	被踢者
 */
- (void)delUserFromGroup:(NSString*)groupid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/remove"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取群详细
 *
 *	@param 	groupid 	群组id
 */
- (void)getGroupdetail:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取群用户列表
 *
 *	@param 	groupid 	群组id 
 */
- (void)getGroupUserList:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"Group/getGroupUserList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取自己所在的群
 *
 */
- (void)getMyGroupWithPage:(int)page {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/userSessionList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	退出群
 *
 *	@param 	groupid 	群组id
 */
- (void)exitGroup:(NSString*)groupid {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:groupid forKey:@"sessionid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/quit"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置是否接受群消息
 *
 *	@param 	groupid 	群组id
 *	@param 	getmsg      是否接受
 */
- (void)groupMsgSetting:(NSString*)groupid getmsg:(BOOL)getmsg {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:[NSString stringWithFormat:@"%d", getmsg] forKey:@"getmsg"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/getmsg"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置是否接受群消息
 *
 *	@param 	groupid 	群组id
 *	@param 	name      会话名称
 */
- (void)editGroupname:(NSString*)groupid name:(NSString*)name{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:name forKey:@"name"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/edit"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	修改我的群昵称
 *
 *	@param 	groupid 	群组id
 *	@param 	name      会话名称
 */
- (void)setNickname:(NSString*)groupid name:(NSString*)name {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:groupid forKey:@"sessionid"];
    [params setObject:name forKey:@"mynickname"];
    [self loadRequestWithDoMain:YES
                     methodName:@"session/api/setNickname"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置APNS
 */
- (void)setupAPNSDevice {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([[BSEngine currentEngine] deviceIDAPNS]) {
        [params setObject:[[BSEngine currentEngine] deviceIDAPNS] forKey:@"udid"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/addNoticeHostForIphone"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	取消APNS
 */
- (void)cancelAPNSDevice {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([[BSEngine currentEngine] deviceIDAPNS]) {
        [params setObject:[[BSEngine currentEngine] deviceIDAPNS] forKey:@"udid"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/removeNoticeHostForIphone"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置用户设备是否通知
 */
- (void)setNoticeForIphone:(BOOL)isNotice {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%d", isNotice] forKey:@"neednotice"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/removeNoticeHostForIphone"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 聊吧 meeting =========
// meeting/api
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	创建聊吧 - add
 *
 *	@param 	picture 上传头像
 *	@param 	name 聊吧标题
 *	@param 	content 聊吧主题
 *	@param  start 开始时间戳
 *	@param  end 结束时间戳
 */
- (void)addMeetingWithName:(NSString*)name content:(NSString*)content start:(NSString*)start end:(NSString*)end picture:(UIImage*)picture {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) [params setObject:name forKey:@"name"];
    if (content) [params setObject:content forKey:@"content"];
    if (start) [params setObject:start forKey:@"start"];
    if (end) [params setObject:end forKey:@"end"];
    StRequestPostDataType ty = KSTRequestPostDataTypeNormal;
    if (picture) {
        [params setObject:picture forKey:@"picture"];
        ty = KSTRequestPostDataTypeMultipart;
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/add"
                         params:params
                   postDataType:ty];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	聊吧详细 - detail
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingWithMid:(NSString*)mid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	用户活跃度排行 - huoyue
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingActiveWithMid:(NSString*)mid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/huoyue"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	移除用户 - remove
 *
 *	@param 	fuid 	要移除的用户
 *	@param 	meetingid 	聊吧id
 */
- (void)removefromMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/remove"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	聊吧列表 - meetingList
 *
 *	@param 	type 1-正在进行中 2-往期 3-我的
 */
- (void)meetingListWithType:(int)mType page:(int)page {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%d", mType] forKey:@"type"];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/meetingList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	申请加入聊吧 - apply
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)applyMeeting:(NSString*)mid content:(NSString*)content {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:content forKey:@"content"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/apply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	聊吧的用户申请列表 - meetingApplyList
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingApplyList:(NSString*)mid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/meetingApplyList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	同意申请加入聊吧 - agreeApply
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)agreeApplyMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/agreeApply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	不同意申请加入聊吧 - disagreeApply
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)disagreeApplyMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/disagreeApply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	邀请加入聊吧 - invite
 *
 *	@param 	fuid 	被邀请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)inviteMeeting:(NSString*)mid uids:(NSString*)uids {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:uids forKey:@"uids"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/invite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	同意邀请加入聊吧 - agreeInvite
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)agreeInviteMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/agreeInvite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	不同意邀请加入聊吧 - disagreeInvite
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)disagreeInviteMeeting:(NSString*)mid fuid:(NSString*)fuid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:mid forKey:@"meetingid"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"meeting/api/disagreeInviteMeeting"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= setting =========
// 设置密码
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置密码
 *
 *	@param 	oldpass 	旧密码
 *	@param 	newpass 	新密码
 */
- (void)changePassword:(NSString*)oldpass new:(NSString*)newpass
 {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:oldpass forKey:@"oldpassword"];
    [params setObject:newpass forKey:@"newpassword"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/editPassword"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	找回密码
 *
 *	@param 	phone 	电话
 */

- (void)findPassword:(NSString*)phone {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/findPass"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置加我为好友是否需要验证
 *
 */
- (void)setVerify {
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/setVerify"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 意见与反馈 =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	反馈
 *
 *	@param 	content 	内容
 */
- (void)feedback:(NSString*)content {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    if (content) {
        [params setObject:content forKey:@"content"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/feedback"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	协议
 *
 *	@param 	aType 	0 userprotocol 用户协议 1 registprotocol 注册协议
 */
- (void)userAgreement:(int)aType
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    if (aType == 0) {
        [params setObject:@"userprotocol" forKey:@"propkey"];
    } else {
        [params setObject:@"registprotocol" forKey:@"propkey"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"User/keyvalue"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	举报
 *
 *	@param 	content 	内容
 *	@param 	fuid        uid
 */
- (void)jubao:(NSString*)content fuid:(NSString*)fuid
 {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:content forKey:@"content"];
    [params setObject:fuid forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"User/jubao"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

// ========= 朋友圈 =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈列表
 *
 */
- (void)shareList:(int)page {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/shareList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 根据id获取分享详情
 *
 *	@param 	sid        分享id
 */
- (void)getShareDetail:(NSString*)sid {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 赞
 *
 *	@param 	sid        分享id
 */
- (void)addZan:(NSString*)sid {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/sharePraise"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 删除自己的分享
 *
 *	@param 	sid        分享id
 */
- (void)deleteShare:(NSString*)sid {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/delete"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 回复
 *
 *	@param 	sid         分享id
 *	@param 	fuid        回复哪个人
 *	@param 	content     内容
 */
- (void)shareReply:(NSString*)sid fuid:(NSString*)fuid content:(NSString*)content {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [params setObject:fuid forKey:@"fuid"];
    [params setObject:content forKey:@"content"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/shareReply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 删除回复
 *
 *	@param 	sid        分享id
 */
- (void)deleteReply:(NSString*)sid {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"fsid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/deleteReply"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 删除回复
 *
 *	@param 	fuid uid
 *	@param 	type 1. 不看他（她）的朋友圈 2.不让他（她）看我的朋友圈
 */
- (void)setFriendCircleAuth:(NSString*)fuid type:(int)type {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:fuid forKey:@"fuid"];
    [params setObject:[NSString stringWithFormat:@"%d", type] forKey:@"type"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/setFriendCircleAuth"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 设置相册封面
 *
 *	@param 	image 封面
 */
- (void)setCover:(UIImage*)image {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:image forKey:@"picture"];
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/setCover"
                         params:params
                   postDataType:KSTRequestPostDataTypeMultipart];
    
}
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	发布分享
 *
 *	@param 	picdata     最多上传6张,命名picture1,picture2,..
 *	@param 	content     分享文字内容
 *	@param 	lng         经度
 *	@param 	lat         纬度
 *	@param 	address     经纬度所在的地址
 *	@param 	visible     不传表示是公开的，传入格式：id1,id2,id3
 */
- (void)addNewshare:(NSArray*)picdata content:(NSString*)content lng:(double)lng lat:(double)lat address:(NSString*)address visible:(NSArray*)visible {
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    StRequestPostDataType StRequestPostDataType;
    if (picdata && picdata.count > 0) {
        StRequestPostDataType = KSTRequestPostDataTypeMultipart;
        [picdata enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [params setObject:obj forKey:[NSString stringWithFormat:@"picture%d", (int)idx + 1]];
        }];
    } else {
        StRequestPostDataType = KSTRequestPostDataTypeNormal;
    }
    if (content) {
        [params setObject:content forKey:@"content"];
    }
    if (address) {
        [params setObject:[NSString stringWithFormat:@"%f", lng] forKey:@"lng"];
        [params setObject:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
        [params setObject:address forKey:@"address"];
    }
    if (visible && visible.count > 0) {
        [params setObject:[visible componentsJoinedByString:@","] forKey:@"visible"];
    }
    [self loadRequestWithDoMain:YES
                     methodName:@"friend/api/add"
                         params:params
                   postDataType:StRequestPostDataType];
}

// ========= 商户 =========

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	申请成为商家
 *
 *	@param name         商户名称
 *	@param address      商户地址
 *	@param username     联系人
 *	@param phone        联系电话
 *	@param address      联系地址
 *	@param lat          经度
 *	@param lng          纬度
 *	@param city         城市ID
 *	@param logo         商户图标
 *	@param shop_paper   营业执照
 *	@param auth_paper   授权证书
 *	@param bank         银行名称
 *	@param bank_name    银行用户名
 *	@param bank_card    银行账号
 *	@param content      备注信息
 */
- (void)applyShop:(NSString *)name
          address:(NSString *)address
         username:(NSString *)username
            phone:(NSString *)phone
      useraddress:(NSString *)useraddress
              lat:(NSString *)lat
              lng:(NSString *)lng
             city:(NSString *)city
             logo:(UIImage *)logo
        shoppaper:(UIImage *)shoppaper
        authpaper:(UIImage *)authpaper
             bank:(NSString *)bank
         bankuser:(NSString *)bankuser
          account:(NSString *)account
          content:(NSString *)content
{
    StRequestPostDataType requestPostDataType = KSTRequestPostDataTypeNormal;
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    [params setObject:name          forKey:@"name"];
    [params setObject:username      forKey:@"username"];
    [params setObject:phone         forKey:@"phone"];
    [params setObject:address       forKey:@"address"];
    [params setObject:useraddress   forKey:@"useraddress"];

    if (city)   [params setObject:city  forKey:@"city"];
    if (lat)    [params setObject:lat   forKey:@"lat"];
    if (lng)    [params setObject:lng   forKey:@"lng"];
    
    if (logo) {
        requestPostDataType = KSTRequestPostDataTypeMultipart;
        [params setObject:logo forKey:@"logo"];
    }

    if (shoppaper) {
        requestPostDataType = KSTRequestPostDataTypeMultipart;
        [params setObject:shoppaper forKey:@"shopPaper"];
    }

    if (authpaper) {
        requestPostDataType = KSTRequestPostDataTypeMultipart;
        [params setObject:authpaper forKey:@"authPaper"];
    }
    
    if (bank)       [params setObject:bank      forKey:@"bank"];
    if (bankuser)   [params setObject:bankuser  forKey:@"bankName"];
    if (account)    [params setObject:account   forKey:@"bankCard"];
    if (content)    [params setObject:content   forKey:@"content"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/apply"
                         params:params
                   postDataType:requestPostDataType];
}

/**
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	设置银行信息
 *
 *	@param  bank    开户行
 *	@param  user    开户名
 *	@param  account 账号
 *
 */
- (void)updateBank:(NSString *)bank
              user:(NSString *)user
           account:(NSString *)account
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    [params setObject:bank forKey:@"bank"];
    [params setObject:user forKey:@"bankName"];
    [params setObject:account forKey:@"bankCard"];

    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/editBank"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	提交订单
 *	goods 商品格式：商品id1*count1,id2*count2
 *	usrename 联系人
 *	phone 电话
 *	address 地址
 *	content 备注
 */
- (void)submitOrder:(NSString *)goods
               type:(NSString *)type
             shopid:(NSString *)shopid
           username:(NSString *)username
              phone:(NSString *)phone
            address:(NSString *)address
            content:(NSString *)content
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];

    [params setObject:type forKey:@"type"];
    [params setObject:goods forKey:@"goods"];
    [params setObject:shopid forKey:@"shopid"];
    [params setObject:username forKey:@"username"];
    [params setObject:phone forKey:@"phone"];
    [params setObject:address forKey:@"address"];
    
    if (content) {
        [params setObject:content forKey:@"content"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/submitOrder"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商户类别
 *
 */
- (void)getShopCategoryList {
    needUID = NO;

    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/categroyList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商区列表
 *
 */
- (void)getShopAreaList
{
    needUID = NO;
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/areaList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	商家列表
 *
 */
- (void)getShopListWithPage:(int)page
                 categoryid:(NSString *)categoryid
                        lat:(NSString *)lat
                        lng:(NSString *)lng
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:categoryid forKey:@"categoryid"];
    
    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

//    if (lat) {
//        [params setObject:lat forKey:@"lat"];
//        [params setObject:lng forKey:@"lng"];
//    }
    
    [params setObject:[[[BSEngine currentEngine] user] uid] forKey:@"uid"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/shopList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商家列表
 *
 *  @param categoryid   商品分类id
 *  @param areaId       商品区域id
 */
- (void)getShopListWithPage:(NSInteger)page
                 categoryid:(NSString *)categoryid
                        lat:(NSString *)lat
                        lng:(NSString *)lng
                       city:(NSString *)city
{
//    if (!categoryid && !areaId) {
//        return;
//    }
//    
  
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    if (lat)
        [params setObject:lat forKey:@"lat"];
    else
        [params setObject:@"0.0001" forKey:@"lat"];

    if (lng)
        [params setObject:lng forKey:@"lng"];
    else
        [params setObject:@"0.0001" forKey:@"lng"];
    

    if (categoryid) [params setObject:categoryid    forKey:@"categoryid"];
    if (city)       [params setObject:city          forKey:@"city"];
    
    [params setObject:[[[BSEngine currentEngine] user] uid] forKey:@"uid"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/shopList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品详细
 *
 *  @param shopid   商家 ID
 *
 */
- (void)getShopByShopId:(NSString *)shopid {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:shopid forKey:@"shopid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/shopDetail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品详细
 *
 *  @param goodsid   商品 ID
 *
 */
- (void)getShopDetail:(NSString *)goodsid{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:goodsid forKey:@"goodid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/detail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品列表
 *
 *  @param shopid       商户id
 *  @param categoryid   商品分类id
 *  @param areaid       商品地区id
 *  @param sort         价格排序 1：升序，2：降序
 *  @param page
 *
 */
- (void)getGoodsListWithShopId:(NSString *)shopid
                    categoryId:(NSString *)categoryid
                          city:(NSString *)city
                          sort:(NSString *)sort
                          page:(NSInteger)page
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    // status=>2; 是上架的产品，只有上架的产品才能成为商品
    [params setObject:@"2"          forKey:@"status"];

    if (page > 1)   [params setObject:@(page).stringValue forKey:@"page"];
    if (shopid)     [params setObject:shopid        forKey:@"shopid"];
    if (categoryid) [params setObject:categoryid    forKey:@"categoryid"];
    if (sort)       [params setObject:sort          forKey:@"sort"];
    if (city > 0)   [params setObject:city          forKey:@"city"];

    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/goodsList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	商品详细
 *	action 0-取消收藏 1-收藏
 *
 */
- (void)favorite:(NSString *)goods_id action:(NSString*)act {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:goods_id forKey:@"goods_id"];
    [params setObject:act forKey:@"action"];
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/favorite"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	添加评论
 *
 */
- (void)addComment:(NSString *)goods_id star:(NSString *)star content:(NSString *)content {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:goods_id forKey:@"goods_id"];
    [params setObject:star forKey:@"star"];
    [params setObject:content forKey:@"content"];
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/addComment"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	评论列表
 *
 */
- (void)commentList:(NSString *)goods_id page:(int)page {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:goods_id forKey:@"goods_id"];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/commentList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	购物车商品信息获取 ／／ {"1":"1,2,3,4","2":"5,6,7"}
 *
 */
- (void)cartGoodsList:(NSString*)goods_id {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:goods_id forKey:@"goods_id"];
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/cartGoodsList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	添加商品
 *
 *  @param categoryid    商品分类   (必填)
 *  @param name          商品名称   (必填)
 *  @param price         商品价格   (必填)
 *  @param picture       图片(数组)
 *  @param content       备注
 *  @param parameter     规格参数
 *  @param logo          商品图标   (必填)
 *  @param barcode       商品条码
 *
 */
- (void)addGoods:(NSString*)categoryid
            name:(NSString*)name
           price:(NSString*)price
         picture:(NSArray*)picture
         content:(NSString*)content
       parameter:(NSString*)parameter
            logo:(UIImage*)logo
         barcode:(NSString *)barcode
{
    if (!(categoryid && name && price && logo)) {
        self.errorMessage = @"商品分类，商品名称，价格及商品图标是必需的商品信处，请逐一全部填写！";
        [self showAlert];
        return;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    [params setObject:categoryid    forKey:@"categoryid"];
    [params setObject:name          forKey:@"name"];
    [params setObject:logo          forKey:@"logo"];
    [params setObject:price         forKey:@"price"];

    if (picture && picture.count > 0) {
        [picture enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [params setObject:obj forKey:[NSString stringWithFormat:@"picture%d", (int)idx + 1]];
        }];
    }

    if (content)    [params setObject:content   forKey:@"content"];
    if (parameter)  [params setObject:parameter forKey:@"parameter"];
    if (barcode)    [params setObject:content   forKey:@"barcode"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/addGoods"
                         params:params
                   postDataType:KSTRequestPostDataTypeMultipart];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	修改商品库
 *
 *  @param categoryid    商品分类   (必填)
 *  @param name          商品名称   (必填)
 *  @param price         商品价格   (必填)
 *  @param picture       图片(数组)
 *  @param content       备注
 *  @param parameter     规格参数
 *  @param logo          商品图标   (必填)
 *  @param barcode       商品条码
 *
 */
- (void)editGoodsWithId:(NSString *)goodsId
             categoryId:(NSString*)categoryId
                   name:(NSString*)name
                  price:(NSString*)price
                picture:(NSArray*)picture
                content:(NSString*)content
              parameter:(NSString*)parameter
                   logo:(UIImage*)logo
                barcode:(NSString *)barcode
{
    if (!goodsId) {
        return;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    StRequestPostDataType requestType = KSTRequestPostDataTypeNormal;

    if (categoryId) [params setObject:categoryId    forKey:@"categoryid"];
    if (name)       [params setObject:name          forKey:@"name"];

    if (logo) {
        requestType = KSTRequestPostDataTypeMultipart;
        [params setObject:logo forKey:@"logo"];
    }
    
    if (price)      [params setObject:price         forKey:@"price"];
    
    if (picture && picture.count > 0) {
        requestType = KSTRequestPostDataTypeMultipart;
        [picture enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [params setObject:obj forKey:[NSString stringWithFormat:@"picture%d", (int)idx + 1]];
        }];
    }
    
    if (content)    [params setObject:content       forKey:@"content"];
    if (parameter)  [params setObject:parameter     forKey:@"parameter"];
    
    if (params.count > 0) {
        [params setObject:goodsId forKey:@"id"];
        [self loadRequestWithDoMain:YES
                         methodName:@"shop/api/editGoods"
                             params:params
                       postDataType:requestType];
    }
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	修改商品库
 *
 *  @param price         商品价格   (必填)
 *  @param number        商品库存量
 *      data:     数据格式:1,200,50 <=>商品 ID,价格,库存
 *                  这里的 data 应该是ShlefGoods数组
 */
- (void)editShopGoodsWithId:(NSString *)goodsId
                      price:(NSString *)price
                     number:(NSString *)number
{
    if (!goodsId) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *data = [NSString stringWithFormat:@"%@,%@,%@", goodsId, price, number];
    [params setObject:data forKey:@"data"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/goodStatus"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	删除产品库
 *
 *  @param goodsIds   产品 ID,多个用“,”逗号隔开
 *
 */
- (void)deleteGoodsWithIds:(NSArray *)goodsIds
{
    if (!goodsIds) {
        return;
    }
    
    if (goodsIds.count == 0) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[goodsIds componentsJoinedByString:@","] forKey:@"id"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/delGoods"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品上下架
 *
 *  @param status:   枚举值:1 下架 2 上架
 *  @param data:     数据格式:1,200,50 <=>商品 ID,价格,库存
 *                  这里的 data 应该是ShlefGoods数组
 *
 */
- (void)shelfGoodsWithStatus:(NSInteger)status
                        data:(NSArray *)data
{
    if (!data) {
        return;
    }
    
    if (status < 1 || status > 2) {
        return;
    }

    if (data.count == 0) {
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    
    if (data && data.count > 0) {
        [data enumerateObjectsUsingBlock:^(Good *obj, NSUInteger idx, BOOL *stop) {
                [arr addObject:[obj getShelfString]];
        }];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[arr componentsJoinedByString:@";"] forKey:@"data"];
    [params setObject:@(status).stringValue forKey:@"status"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/goodStatus"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

-(void)requestFor:(NSDictionary *)params methodName:(NSString *)methodName
{
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];

    [self loadRequestWithDoMain:YES
                     methodName:methodName
                         params:paramsDic
                   postDataType:KSTRequestPostDataTypeNormal];
    
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	公众号菜单
 *
 */
- (void)getCloudMenu:(NSString *)subId{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (subId)  [params setObject:subId forKey:@"fuid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/api/userMenu"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	公众号详细信息
 *
 */
- (void)subsDetail:(NSString *)subId userId:(NSString *)userId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userId)  [params setObject:userId forKey:@"uid"];
    if (subId)  [params setObject:subId forKey:@"fid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/Api/subsDetail"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	搜索公众号
 *
 */
- (void)searchSubs:(NSString *)userId andKey:(NSString *)key
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userId)  [params setObject:userId forKey:@"uid"];
    if (key)  [params setObject:key forKey:@"keyword"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/Api/findSubs"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}


/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	我关注的公众号
 *
 */
- (void)myFollowSubs:(NSString *)userId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (userId)  [params setObject:userId forKey:@"uid"];
    [self loadRequestWithDoMain:YES
                     methodName:@"user/Api/myFollowSubs"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}
-(void)followSub:(NSString *)userId
{}


#pragma mark Shop Demand

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	添加需求
 *	@param content  需求内容
 *	@param lat      当前纬度
 *	@param lng      当前经度
 *
 */
-(void)addDemandWithContent:(NSString *)content
                        lat:(NSString *)lat
                        lng:(NSString *)lng
{
    if (content == nil) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:content forKey:@"content"];

    if (lat && lng) {
        [params setObject:lat forKey:@"lat"];
        [params setObject:lng forKey:@"lng"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/addDemand"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	需求列表
 *	@param key      搜索关键字，匹配content字段
 *	@param lat      当前纬度
 *	@param lng      当前经度
 *
 */
-(void)getDemandWithPage:(NSInteger)page
                  andKey:(NSString *)key
                     lat:(NSString *)lat
                     lng:(NSString *)lng
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (key)  [params setObject:key forKey:@"keywords"];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    if (lat && lng) {
        [params setObject:lat forKey:@"lat"];
        [params setObject:lng forKey:@"lng"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/demandList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

#pragma mark - Finacce Relative

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	添加账单
 *	@param type         账单类型: 1=>贷款，2=>信用卡
 *	@param repayment    还款提醒日期
 *
 *  ==== 以下是信用卡类参数 ====
 *
 *	@param card         信用卡卡号
 *	@param bank         贷款银行
 *
 *  ==== 以下是贷款类参数 ====
 *
 *	@param name         账单名称
 *	@param price        还款金额
 *	@param number       剩余期数
 *	@param mechanism    还款机构
 *
 */
-(void)addBillWithType:(NSString *)type
             repayment:(NSString *)repayment
                  name:(NSString *)name
                 price:(NSString *)price
                number:(NSString *)number
             mechanism:(NSString *)mechanism
                  card:(NSString *)card
                  bank:(NSString *)bank
{
    if (type == nil) {
        return;
    }
    
    if (!([type isEqualToString:@"1"] || [type isEqualToString:@"2"])) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:type forKey:@"type"];
    [params setObject:repayment forKey:@"repayment"];
    
    if ([type isEqualToString:@"1"]) {
        [params setObject:name forKey:@"name"];
        [params setObject:price forKey:@"price"];
        [params setObject:number forKey:@"number"];
        [params setObject:mechanism forKey:@"mechanism"];
    } else {
        [params setObject:card forKey:@"card"];
        [params setObject:bank forKey:@"bank"];
    }

    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/addBill"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	编辑账单
 *
 *	@param billId       账单id
 *	@param type         账单类型: 1=>贷款，2=>信用卡
 *	@param repayment    还款提醒日期
 *
 *  ==== 以下是信用卡类参数 ====
 *
 *	@param card         信用卡卡号
 *	@param bank         贷款银行
 *
 *  ==== 以下是贷款类参数 ====
 *
 *	@param name         账单名称
 *	@param price        还款金额
 *	@param number       剩余期数
 *	@param mechanism    还款机构
 *
 */
-(void)editBillWithId:(NSString *)billId
              andType:(NSString *)type
            repayment:(NSString *)repayment
                 name:(NSString *)name
                price:(NSString *)price
               number:(NSString *)number
            mechanism:(NSString *)mechanism
                 card:(NSString *)card
                 bank:(NSString *)bank
{
    if (billId == nil) {
        return;
    }
    
    if (!([type isEqualToString:@"1"] || [type isEqualToString:@"2"])) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:billId    forKey:@"id"];
    [params setObject:type      forKey:@"type"];
    [params setObject:repayment forKey:@"repayment"];
    
    if ([type isEqualToString:@"1"]) {
        [params setObject:name forKey:@"name"];
        [params setObject:price forKey:@"price"];
        [params setObject:number forKey:@"number"];
        [params setObject:mechanism forKey:@"mechanism"];
    } else {
        [params setObject:card forKey:@"card"];
        [params setObject:bank forKey:@"bank"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/editBill"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	删除账单
 *
 *	@param billId       账单id
 *
 */
-(void)deleteBillWithId:(NSString *)billId
{
    if (billId == nil) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:billId    forKey:@"id"];
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/delBill"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	账单列表
 *
 */
-(void)getBillListWithPage:(NSInteger)page
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/billList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

#pragma mark - Order Relative

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	订单列表
 *
 *  @param status           订单状态
 *  @param type             用户角色 1： 商家，2： 买家
 *
 */
-(void)getOrderListWithPage:(NSInteger)page
                  andStatus:(NSInteger)status
                    andType:(NSInteger)type
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:@(type).stringValue forKey:@"type"];

    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }
    
    if (status > 0) {
        [params setObject:@(status).stringValue forKey:@"status"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/orderList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	订单状态更新
 *
 *  @param id        订单 ID
 *  @param status    1:等待发货
 *                  2:已发货
 *                  3:未付款
 *                  4:退货中
 *                  5:已退单
 *                  6:已完成
 *                  7:已退货
 *                  8:结款中
 *                  9:已结款
 *
 */
-(void)updateOrder:(NSString *)orderId
        withStatus:(NSString *)status
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:orderId forKey:@"id"];
    [params setObject:status forKey:@"status"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/orderStatus"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	订单退单处理
 *
 *  @param id        订单 ID
 *  @param reason    退单理由
 *  @note status     5:已退单
 *
 */
-(void)retreatOrder:(NSString *)orderId
        withReason:(NSString *)reason
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:orderId forKey:@"id"];
    [params setObject:@"5" forKey:@"status"];
    [params setObject:reason forKey:@"content"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/orderStatus"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	订单发货处理
 *
 *  @param id           订单 ID
 *  @param logistics    物流公司
 *  @param logistics    运单号
 *  @note status        2:已发货
 *
 */
-(void)deliveryOrder:(NSString *)orderId
         withLogistics:(NSString *)logistics
          adnWaybill:(NSString *)waybill
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:orderId forKey:@"id"];
    [params setObject:@"1" forKey:@"type"];
    [params setObject:@"2" forKey:@"status"];
    [params setObject:logistics forKey:@"logcompany"];
    [params setObject:waybill forKey:@"lognumber"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/orderStatus"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	订单收货处理
 *
 *  @param id           订单 ID
 *  @note status        10:已收货
 *
 */
-(void)recieveGoodsByOrderId:(NSString *)orderId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:orderId forKey:@"id"];
    [params setObject:@"2" forKey:@"type"];
    [params setObject:@"6" forKey:@"status"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/orderStatus"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

#pragma mark - Seller Relative

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	编辑商家信息(由于商家信息不可随意修改，这个接口基本没用)
 *
 *  @param  name:        商户名称
 *  @param  contact:     联系人
 *  @param  phone:       联系电话
 *  @param  address:     联系地址
 *  @param  content:     备注信息
 *  @param  lat:         经度
 *  @param  lng:         纬度
 *  @param  city:        城市名称
 *  @param  license:     营业执照
 *  @param  certificate: 授权证书
 *  @param  bank:        银行名称
 *  @param  bankUser:    银行用户名
 *  @param  bankAccount: 银行账号
 *
 */
-(void)editShopWithName:(NSString *) name
                contact:(NSString *) contact
                  phone:(NSString *) phone
                address:(NSString *) address
                content:(NSString *) content
                    lat:(NSString *) lat
                    lng:(NSString *) lng
                   city:(NSString *) city
                license:(UIImage *) license
            certificate:(UIImage *) certificate
                   bank:(NSString *) bank
               bankUser:(NSString *) bankUser
            bankAccount:(NSString *) bankAccount
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    StRequestPostDataType requestType = KSTRequestPostDataTypeNormal;

    if (name)           [params setObject:name          forKey:@"name"];
    if (contact)        [params setObject:contact       forKey:@"username"];
    if (phone)          [params setObject:phone         forKey:@"phone"];
    if (address)        [params setObject:address       forKey:@"address"];
    if (contact)        [params setObject:contact       forKey:@"content"];
    if (lat)            [params setObject:lat           forKey:@"lat"];
    if (lng)            [params setObject:lng           forKey:@"lng"];
    if (city)           [params setObject:city          forKey:@"city"];
    
    if (license)        {
        requestType = KSTRequestPostDataTypeMultipart;
        [params setObject:license       forKey:@"shopPaper"];
    }
    
    if (certificate)    {
        requestType = KSTRequestPostDataTypeMultipart;
        [params setObject:certificate   forKey:@"authPaper"];
    }
    
    if (bank)           [params setObject:bank          forKey:@"bank"];
    if (bankUser)       [params setObject:bankUser      forKey:@"bankName"];
    if (bankAccount)    [params setObject:bankAccount   forKey:@"bankCard"];
    
    if (params.count > 0) {
        [self loadRequestWithDoMain:YES
                         methodName:@"shop/Api/editShop"
                             params:params
                       postDataType:requestType];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品库列表
 *
 *  @param  categoryid:  分类 ID
 *  @param  status:      状态 1: 未上架； 2: 已上架
 *
 */
-(void)getProductListWithCategoryid:(NSInteger)categoryid
                             andStatus:(NSInteger)status
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (categoryid > 0) [params setObject:@(categoryid).stringValue forKey:@"categoryid"];
    if (status > 0)     [params setObject:@(status).stringValue     forKey:@"status"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/productList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	编辑收货地址
 *
 *  @param  address:  收货地址
 *
 */
-(void)editShippingAddress:(NSString *)address
                andOrderId:(NSString *)orderId
{
    if (address && orderId) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:address          forKey:@"address"];
        [params setObject:orderId          forKey:@"id"];
        
        [self loadRequestWithDoMain:YES
                         methodName:@"shop/Api/editAddress"
                             params:params
                       postDataType:KSTRequestPostDataTypeNormal];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	申请结款
 *
 */
-(void)applyAccountSettleWithIds:(NSArray *)orderIds
{
    if (!orderIds) {
        return;
    }
    
    if (orderIds.count == 0) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[orderIds componentsJoinedByString:@","] forKey:@"id"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/api/applyPayment"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	可结款列表
 *
 */
-(void)accountSettleable
{
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/paymentList"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	历史结款列表
 *
 */
-(void)accountHistory
{
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/paymentHis"
                         params:nil
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	异常款项申诉
 *
 *  @param  content: 申诉内容
 *
 */
-(void)abnormalAppealWithContent:(NSString *)content
{
    if (content) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:content          forKey:@"content"];
        
        [self loadRequestWithDoMain:YES
                         methodName:@"shop/Api/addAppeal"
                             params:params
                       postDataType:KSTRequestPostDataTypeNormal];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	添加客服
 *
 *  @param  name:           客服名称
 *  @param  serviceName:    客服账户
 *
 */
-(void)addServiceOfShopWithName:(NSString *)name
                 andServiceName:(NSString *)serviceName
{
    if (name && serviceName) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:name          forKey:@"name"];
        [params setObject:serviceName   forKey:@"username"];
        
        [self loadRequestWithDoMain:YES
                         methodName:@"shop/Api/addService"
                             params:params
                       postDataType:KSTRequestPostDataTypeNormal];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	删除客服
 *
 *  @param  serviceId:  客服id
 *
 */
-(void)delServiceOfShopById:(NSString *)serviceId
{
    if (serviceId) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:serviceId          forKey:@"id"];
        
        [self loadRequestWithDoMain:YES
                         methodName:@"shop/Api/delService"
                             params:params
                       postDataType:KSTRequestPostDataTypeNormal];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	客服列表
 *
 *  @param  shopid: 商家 ID
 *
 */
-(void)serviceListWithShopId:(NSString *)shopid
{
    if (shopid) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:shopid    forKey:@"shopid"];
        
        [self loadRequestWithDoMain:YES
                         methodName:@"shop/Api/serviceList"
                             params:params
                       postDataType:KSTRequestPostDataTypeNormal];
    }
}

#pragma mark - Finacing Relative

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	入驻商户申请
 *
 *  @param  company:        公司名称
 *  @param  workPaper:      工作证明图
 *  @param  idcard:         身份证图
 *  @param  certificate:    从业资格图
 *  @param  city:           城市 ID
 *  @param  lat:            经度
 *  @param  lng:            纬度
 *  @param  address:        办公地址
 *
 */
-(void)applyFinacialShop:(NSString *)company
                 address:(NSString *)address
                    city:(NSString *)city
                     lat:(NSString *)lat
                     lng:(NSString *)lng
              workPermit:(UIImage *)workPermit
                  idCard:(UIImage *)idCard
             certificate:(UIImage *)certificate
{
    if (company) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        StRequestPostDataType requestType = KSTRequestPostDataTypeNormal;
        
        [params setObject:company    forKey:@"company"];
        
        if (city)       [params setObject:city      forKey:@"city"];
        if (address)    [params setObject:address   forKey:@"address"];
        if (lat)        [params setObject:lat       forKey:@"lat"];
        if (lng)        [params setObject:lng       forKey:@"lng"];
        
        if (workPermit) {
            requestType = KSTRequestPostDataTypeMultipart;
            [params setObject:workPermit forKey:@"workPaper"];
        }
        
        if (idCard) {
            requestType = KSTRequestPostDataTypeMultipart;
            [params setObject:idCard forKey:@"idCard"];
        }

        if (certificate) {
            requestType = KSTRequestPostDataTypeMultipart;
            [params setObject:certificate forKey:@"certificate"];
        }
        
        [self loadRequestWithDoMain:YES
                         methodName:@"financ/Api/apply"
                             params:params
                       postDataType:requestType];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	入驻商户申请
 *
 *  @param  id:             融资商户 ID
 *  @param  company:        公司名称
 *  @param  workPaper:      工作证明图
 *  @param  idcard:         身份证图
 *  @param  certificate:    从业资格图
 *  @param  city:           城市 ID
 *  @param  lat:            经度
 *  @param  lng:            纬度
 *  @param  address:        办公地址
 *
 */
-(void)editFinacialShopWithId:(NSString *)shopid
                   andCompany:(NSString *)company
                      address:(NSString *)address
                         city:(NSString *)city
                          lat:(NSString *)lat
                          lng:(NSString *)lng
                   workPermit:(UIImage *)workPermit
                       idCard:(UIImage *)idCard
                  certificate:(UIImage *)certificate
{
    if (shopid) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        StRequestPostDataType requestType = KSTRequestPostDataTypeNormal;
        
        [params setObject:shopid   forKey:@"id"];
        
        if (company)    [params setObject:company   forKey:@"company"];
        if (city)       [params setObject:city      forKey:@"city"];
        if (address)    [params setObject:address   forKey:@"address"];
        if (lat)        [params setObject:lat       forKey:@"lat"];
        if (lng)        [params setObject:lng       forKey:@"lng"];
        
        if (workPermit) {
            requestType = KSTRequestPostDataTypeMultipart;
            [params setObject:workPermit forKey:@"workPaper"];
        }
        
        if (idCard) {
            requestType = KSTRequestPostDataTypeMultipart;
            [params setObject:idCard forKey:@"idcard"];
        }
        
        if (certificate) {
            requestType = KSTRequestPostDataTypeMultipart;
            [params setObject:certificate forKey:@"certificate"];
        }
        
        [self loadRequestWithDoMain:YES
                         methodName:@"financ/Api/edit"
                             params:params
                       postDataType:requestType];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	添加商品
 *
 *  @param  name:       商品名称
 *  @param  type:       商品类型
 *  @param  features:   特征信息
 *  @param  material:   所需材料
 *  @param  bidding:    竞价排名价格
 *  @param  adPrice:    广告位价格
 *
 */
-(void)addGoodsForFinacialShopWithName:(NSString *)name
                               andType:(NSString *)type
                              features:(NSString *)features
                              material:(NSString *)material
                               bidding:(NSString *)bidding
                               adPrice:(NSString *)adPrice
{
    if (name) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        StRequestPostDataType requestType = KSTRequestPostDataTypeNormal;
        
        [params setObject:name   forKey:@"name"];
        
        if (type)       [params setObject:type      forKey:@"type"];
        if (features)   [params setObject:features  forKey:@"features"];
        if (material)   [params setObject:material  forKey:@"material"];
        if (bidding)    [params setObject:bidding   forKey:@"bidding"];
        if (adPrice)    [params setObject:adPrice   forKey:@"adPrice"];
        
        [self loadRequestWithDoMain:YES
                         methodName:@"financ/Api/addGoods"
                             params:params
                       postDataType:requestType];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	编辑商品
 *
 *  @param  id:         商品 ID
 *  @param  name:       商品名称
 *  @param  type:       商品类型
 *  @param  features:   特征信息
 *  @param  material:   所需材料
 *  @param  bidding:    竞价排名价格
 *  @param  adPrice:    广告位价格
 *
 */
-(void)editGoodsForFinacialShopWithId:(NSString *)goodsId
                              andName:(NSString *)name
                                 type:(NSString *)type
                             features:(NSString *)features
                             material:(NSString *)material
                              bidding:(NSString *)bidding
                              adPrice:(NSString *)adPrice
{
    if (goodsId) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        StRequestPostDataType requestType = KSTRequestPostDataTypeNormal;
        
        [params setObject:goodsId   forKey:@"id"];
        
        if (name)       [params setObject:name      forKey:@"name"];
        if (type)       [params setObject:type      forKey:@"type"];
        if (features)   [params setObject:features  forKey:@"features"];
        if (material)   [params setObject:material  forKey:@"material"];
        if (bidding)    [params setObject:bidding   forKey:@"bidding"];
        if (adPrice)    [params setObject:adPrice   forKey:@"adPrice"];
        
        [self loadRequestWithDoMain:YES
                         methodName:@"financ/Api/editGoods"
                             params:params
                       postDataType:requestType];
    }
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品列表
 *
 *  @param  city:   城市 ID
 *  @param  lat:    GPS定位坐标:纬度
 *  @param  lng:    GPS定位坐标:经度
 *
 */
-(void)listGoodsOfFinacialShopWithPage:(int)page
                                cityId:(NSString *)city
                                   lat:(NSString *)lat
                                   lng:(NSString *)lng
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (page > 1) {
        [params setObject:@(page).stringValue forKey:@"page"];
    }

    if (city) {
        [params setObject:city  forKey:@"city"];
    }

    if (lat && lng) {
        [params setObject:lat  forKey:@"lat"];
        [params setObject:lng  forKey:@"lng"];
    }
    
    [self loadRequestWithDoMain:YES
                     methodName:@"financ/Api/goodList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品列表
 *
 *  @param  shopid:   融资商ID
 *
 */
-(void)listGoodsOfFinacialWithShopId:(NSString *)shopid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:shopid  forKey:@"shopid"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"financ/Api/goodList"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	删除商品
 *
 *  @param  goodid:   商品ID
 *
 */
-(void)deleteGoodsOfFinacialWithGoodsId:(NSString *)goodsid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:goodsid  forKey:@"goodid"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"financ/Api/deleteGood/"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

#pragma mark - 商户独立密码

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商户独立密码设置、修改
 *
 *  @param  password:   商户独立密码
 *
 */
- (void)setShopPassword:(NSString *)password {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:password  forKey:@"password"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/setPassword/"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商户独立密码验证
 *
 *  @param  password:   商户独立密码
 *
 */
- (void)verifyShopPassword:(NSString *)password {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:password  forKey:@"password"];
    
    [self loadRequestWithDoMain:YES
                     methodName:@"shop/Api/verify/"
                         params:params
                   postDataType:KSTRequestPostDataTypeNormal];
}

@end
