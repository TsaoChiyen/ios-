//
//  BSClient.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Declare.h"
#import "StRequest.h"
@class Message;

@interface BSClient : NSObject

@property (nonatomic, strong) NSString      * errorMessage;
@property (nonatomic, strong) NSIndexPath   * indexPath;
@property (nonatomic, strong) NSString      * tag;
@property (nonatomic, assign) BOOL          hasError;
@property (nonatomic, assign) int           errorCode;

#pragma mark - Init
- (id)initWithDelegate:(id)del action:(SEL)act;

- (void)showAlert;

- (void)cancel;

- (void)loadRequestWithDoMain:(BOOL)isDoMain
                   methodName:(NSString *)methodName
                       params:(NSMutableDictionary *)params
                 postDataType:(StRequestPostDataType)postDataType;

#pragma mark - Request

-(void)requestFor:(NSDictionary *)params methodName:(NSString *)methodName;

/**
 *  Copyright © 2015 tcy@dreamisland. All rights reserved.
 *  用户注册协议
 *  @interface  /user/apiother/regist
 *  @param      none
 */
- (NSURLRequest *)getProtocol;

/**
 *  Copyright © 2015 tcy@dreamisland. All rights reserved.
 *  帮助中心
 *  @interface  /user/apiother/help
 *  @param      none
 */
- (NSURLRequest *)getHelp;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *	@interface  公众号菜单
 */
- (void)getCloudMenu:(NSString *)subId;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	公众号详细信息
 *
 */
- (void)subsDetail:(NSString *)subId userId:(NSString *)userId;

//-(void)requestFor:(NSDictionary *)params methodName:(NSString *)methodName;
/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	搜索公众号
 *
 */
- (void)searchSubs:(NSString *)userId andKey:(NSString *)key;

/**
 *	Copyright © 2014 Xizue Inc. All rights reserved.
 *
 *	我关注的公众号
 *
 */
- (void)myFollowSubs:(NSString *)userId;


// ========= Login&Reg =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	账号登录
 *
 *	@param 	phone 	电话
 *	@param 	pwd 	密码
 */
- (void)loginWithUserPhone:(NSString *)phone
                  password:(NSString *)pwd;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	账号注册
 *
 *	@param 	phone 	电话
 *	@param 	pwd 	密码
 *	@param 	code 	验证码
 */
- (void)regWithPhone:(NSString *)phone
            password:(NSString *)password
                code:(NSString *)code;

/**
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *  获取地区表
 *
 */
- (void)getAreaList;

    // ======== 获取验证码 =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取验证码
 *
 *	@param 	phone 	电话
 */
- (void)getPhoneCode:(NSString*)phone;

// ========= UserInfo =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据uid获取详细资料
 *
 *	@param 	uid 	uid
 */

- (void)getUserInfoWithuid:(NSString*)uid;
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据Keyword获取资料
 *
 *	@param 	Keyword 	昵称/电话
 *  @return 返回为用户数组
 */
- (void)getUserInfoWithKeyword:(NSString*)keyword page:(int)page;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置好友的备注名
 *
 *	@param 	name 	备注名
 *	@param 	fuid 	uid
 */
- (void)setMarkName:(NSString*)name fuid:(NSString*)fuid
;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	附近的人
 *  gender: 0 男 1 女 2 未填写
 *
 */
- (void)nearbyUserWithlat:(NSString*)lat lng:(NSString*)lng gender:(NSString*)gender page:(int)page;

// ========= editInfo =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	编辑资料
 *
 *	@param 	headImg 	新的头像
 *	@param 	user        用户对象
 */
- (void)editUserInfo:(UIImage*)headImg user:(id)user;

// ========= Friend =========

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	添加好友
 *
 *	@param 	fuid 	uid
 *	@param 	content 	理由
 */
- (void)to_friend:(NSString*)fuid content:(NSString*)content;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	删除好友
 *
 *	@param 	fuid 	uid
 */
- (void)del_friend:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	同意申请加好友
 *
 *	@param 	fuid 	uid
 */
- (void)agreeAddFriend:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	好友列表
 *
 */
- (void)friendList;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	通讯录添加好友
 *  @param phones 上传格式：电话1,电话2,电话3,电话4
 *  @return type  	0-不是系统用户，可邀请的用户 1-系统用户
 isfriend  0-不是好友 可以添加 1-是好友
 */
- (void)telephone:(NSString*)phones;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	通讯录添加好友
 *  @param phones 上传格式：电话1,电话2,电话3,电话4
 */
- (void)newFriends:(NSString*)phones;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *  个人相册
 *  @param fuid 不传刚获取自己的，传刚获取别人的
 */
- (void)userAlbum:(NSString*)fuid page:(int)page;

// ========= 黑名单 =========

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	添加到黑名单
 *
 *	@param 	fuid 	uid
 */
- (void)black:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	黑名单列表
 *
 */
- (void)blackList;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *  收藏列表
 *
 */
- (void)favoriteList;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *  删除收藏
 *
 */
- (void)deleteFavorite:(NSString*)fid;
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *  增加收藏
 *
 *	@param fuid 被收藏人的uid
 *	@param otherid 如果是收藏的群组的消息，就传入此id
 *	@param content 收藏的内容
 */
- (void)addfavorite:(NSString*)fuid otherid:(NSString*)otherid content:(NSString*)content;

// ========= 单聊 =========

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	发送消息
 *
 *	@param msg 消息对象
 *
 */
- (void)sendMessageWithObject:(Message*)msg;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	@param fromid false 发送者id
 *	@param fromname true 发送者name
 *	@param fromurl true 发送者头像
 *	@param toid true 接收者，可以是某人，也可以是某个群id
 *	@param toname true 接收者name
 *	@param tourl true 接收者头像
 *	@param file false 上传图片/声音
 *	@param voicetime false 声音时间长度
 *	@param lat false 纬度
 *	@param lng false 经度
 *	@param address 地址 false
 *	@param content 消息的文字内容
 *	@param typechat 100-单聊 200-群聊 300-临时会话 默认为100
 *	@param typefile 1-文字 2-图片 3-声音 4-位置
 *	@param tag 标识符
 *	@param time 发送消息的时间,毫秒（服务器生成）
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
                    tag:(NSString*)tag
                   time:(NSString*)time;
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置是否接收另一用户的消息
 *
 *	@param fuid 用户id
 *
 */
- (void)setGetmsg:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置星标朋友
 *
 *	@param fuid 用户id
 *
 */
- (void)setStar:(NSString*)fuid;
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

- (void)createGroupAndInviteUsers:(NSArray*)inviteduids groupname:(NSString*)groupname;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	删除群组
 *
 *	@param 	groupid 	群组id 
 */
- (void)delGroup:(NSString*)groupid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	查找群
 *
 *	@param 	keyword 	可以是群昵称或群id
 */
- (void)groupSearch:(NSString*)keyword page:(int)page;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据群id获取群信息
 *
 *	@param 	groupid 	群组id 
 */
- (void)groupDetail:(NSString*)groupid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	根据群id加入群
 *
 *	@param 	groupid 	群组id
 */
- (void)addtogroup:(NSString*)groupid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	添加用户到群组
 *
 *	@param 	groupid 	群组id 
 *	@param 	inviteduids 	参数格式: uid1,uid2,uid3
 */
- (void)inviteUser:(NSString*)groupid inviteduids:(NSArray*)inviteduids;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取可邀请的成员
 *
 *	@param 	groupid 	群组id 
 */
- (void)inviteMember:(NSString*)groupid page:(int)page;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	把用户从某个群踢出
 *
 *	@param 	groupid 	群组id 
 *	@param 	fuid 	被踢者
 */
- (void)delUserFromGroup:(NSString*)groupid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取群详细
 *
 *	@param 	groupid 	群组id
 */
- (void)getGroupdetail:(NSString*)groupid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取群用户列表
 *
 *	@param 	groupid 	群组id 
 */

- (void)getGroupUserList:(NSString*)groupid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	获取自己所在的群
 *	@param 	page 	页码
 *
 */
- (void)getMyGroupWithPage:(int)page;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	退出群
 *
 *	@param 	groupid 	群组id
 */
- (void)exitGroup:(NSString*)groupid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置是否接受群消息
 *
 *	@param 	groupid 	群组id
 *	@param 	getmsg      是否接受
 */
- (void)groupMsgSetting:(NSString*)groupid getmsg:(BOOL)getmsg;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置是否接受群消息
 *
 *	@param 	groupid 	群组id
 *	@param 	name      会话名称
 */
- (void)editGroupname:(NSString*)groupid name:(NSString*)name;
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	修改我的群昵称
 *
 *	@param 	groupid 	群组id
 *	@param 	name      会话名称
 */
- (void)setNickname:(NSString*)groupid name:(NSString*)name;
// ========= APNS =========
// 添加APNS
- (void)setupAPNSDevice;
// 取消APNS
- (void)cancelAPNSDevice;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置用户设备是否通知
 */
- (void)setNoticeForIphone:(BOOL)isNotice;

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
- (void)addMeetingWithName:(NSString*)name
                   content:(NSString*)content
                     start:(NSString*)start
                       end:(NSString*)end
                   picture:(UIImage*)picture;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	聊吧详细 - detail
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingWithMid:(NSString*)mid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	用户活跃度排行 - huoyue
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingActiveWithMid:(NSString*)mid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	移除用户 - remove
 *
 *	@param 	fuid 	要移除的用户
 *	@param 	meetingid 	聊吧id
 */
- (void)removefromMeeting:(NSString*)mid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	聊吧列表 - meetingList
  *
 *	@param 	type 0-正在进行中 1-往期 2-我的
 */

- (void)meetingListWithType:(int)mType page:(int)page;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	申请加入聊吧 - apply
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)applyMeeting:(NSString*)mid content:(NSString*)content;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	聊吧的用户申请列表 - meetingApplyList
 *
 *	@param 	meetingid 	聊吧id
 */
- (void)getMeetingApplyList:(NSString*)mid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	同意申请加入聊吧 - agreeApply
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)agreeApplyMeeting:(NSString*)mid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	不同意申请加入聊吧 - disagreeApply
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)disagreeApplyMeeting:(NSString*)mid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	邀请加入聊吧 - invite
 *
 *	@param 	uids        用户id 格式 id1,id2,id3
 *	@param 	meetingid 	聊吧id
 */
- (void)inviteMeeting:(NSString*)mid uids:(NSString*)uids;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	同意邀请加入聊吧 - agreeInvite
 *
 *	@param 	fuid        申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)agreeInviteMeeting:(NSString*)mid fuid:(NSString*)fuid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	不同意邀请加入聊吧 - disagreeInvite
 *
 *	@param 	fuid 	申请用户id
 *	@param 	meetingid 	聊吧id
 */
- (void)disagreeInviteMeeting:(NSString*)mid fuid:(NSString*)fuid;

// ========= setting =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置密码
 *
 *	@param 	oldpass 	旧密码
 *	@param 	newpass 	新密码
 */
- (void)changePassword:(NSString*)oldpass new:(NSString*)newpass;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	找回密码
 *
 *	@param 	phone 	电话
 */

- (void)findPassword:(NSString*)phone;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	设置加我为好友是否需要验证
 *
 */
- (void)setVerify;


// ========= 意见与反馈 =========
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	反馈
 *
 *	@param 	content 	内容
 */
- (void)feedback:(NSString*)content;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	协议
 *
 *	@param 	aType 	0 userprotocol 用户协议 1 registprotocol 注册协议
 */
- (void)userAgreement:(int)aType;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	举报
 *
 *	@param 	content 	内容
 *	@param 	fuid        uid
 */
- (void)jubao:(NSString*)content fuid:(NSString*)fuid;

// ========= 朋友圈 =========

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈列表
 *
 */
- (void)shareList:(int)page;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 根据id获取分享详情
 *
 *	@param 	sid        分享id
 */
- (void)getShareDetail:(NSString*)sid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 赞
 *
 *	@param 	sid        分享id
 */
- (void)addZan:(NSString*)sid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 删除自己的分享
 *
 *	@param 	sid        分享id
 */
- (void)deleteShare:(NSString*)sid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 回复
 *
 *	@param 	sid         分享id
 *	@param 	fuid        回复哪个人
 *	@param 	content     内容
 */
- (void)shareReply:(NSString*)sid fuid:(NSString*)fuid content:(NSString*)content;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 删除回复
 *
 *	@param 	sid        分享id
 */
- (void)deleteReply:(NSString*)sid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 删除回复
 *
 *	@param 	fuid uid
 *	@param 	type 1. 不看他（她）的朋友圈 2.不让他（她）看我的朋友圈
 */
- (void)setFriendCircleAuth:(NSString*)fuid type:(int)type;
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	朋友圈 设置相册封面
 *
 *	@param 	image 封面
 */
- (void)setCover:(UIImage*)image;
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
- (void)addNewshare:(NSArray*)picdata content:(NSString*)content lng:(double)lng lat:(double)lat address:(NSString*)address visible:(NSArray*)visible;


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
          content:(NSString *)content;

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
           account:(NSString *)account;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © tcy@dreamisland. All rights reserved.
 *
 *	提交订单
 *	goods 商品格式：商品id1*count1,id2*count2
 *	usrename 联系人
 *	phone 电话
 *	address 地址
 *	content 备注
 */
- (void)submitOrderWithShopType:(int)shopType
                          goods:(NSString *)goods
                           type:(NSString *)type
                         shopid:(NSString *)shopid
                       username:(NSString *)username
                          phone:(NSString *)phone
                        address:(NSString *)address
                        content:(NSString *)content;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	订单付款
 *	orderid 订单ID
 */
- (void)payOrderWithShopType:(NSInteger)shopType
                     orderId:(NSString *)orderid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	商户类别
 *
 */
- (void)getShopCategoryListWithShopType:(int)shopType;

/**
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商区列表
 *
 */
- (void)getShopAreaListWithShopType:(int)shopType;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	商家列表
 *
 */
- (void)getShopListWithShopType:(int)shopType
                           page:(int)page
                     categoryid:(NSString *)categoryid
                            lat:(NSString *)lat
                            lng:(NSString *)lng;


/**
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商家列表
 *
 *  @param categoryid   商品分类id
 *  @param city         商品区域
 */
- (void)getShopListWithShopType:(int)shopType
                           page:(NSInteger)page
                     categoryid:(NSString *)categoryid
                            lat:(NSString *)lat
                            lng:(NSString *)lng
                           city:(NSString *)city;

/**
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品详细
 *
 *  @param shopid   商家 ID
 *
 */
- (void)getShopWithShopType:(int)shopType shopId:(NSString *)shopid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	商品详细
 *
 */
- (void)getShopDetailWithShopType:(int)shopType goodsId:(NSString *)goodsid;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品列表
 *
 *  @param shopid       商户id
 *  @param categoryid   商品分类id
 *  @param city         商品地区
 *  @param page
 *
 */
- (void)getGoodsListWithShopType:(int)shopType
                          shopId:(NSString *)shopid
                      categoryId:(NSString *)categoryid
                            city:(NSString *)city
                            sort:(NSString *)sort
                            page:(NSInteger)page;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	商品详细
 *	action 0-取消收藏 1-收藏
 *
 */
- (void)favorite:(NSString *)goods_id action:(NSString*)action;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	添加评论
 *
 */
- (void)addComment:(NSString *)goods_id star:(NSString *)star content:(NSString *)content;
/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	评论列表
 *
 */
- (void)commentList:(NSString *)goods_id page:(int)page;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *
 *	购物车商品信息获取 ／／ {"1":"1,2,3,4","2":"5,6,7"}
 *
 */
- (void)cartGoodsList:(NSString*)goods_id;

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
         barcode:(NSString *)barcode;

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
                barcode:(NSString *)barcode;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	修改商品库
 *
 *  @param price         商品价格   (必填)
 *  @param number        商品数量
 *      data:     数据格式:1,200,50 <=>商品 ID,价格,库存
 *                  这里的 data 应该是ShlefGoods数组
 */
- (void)editShopGoodsWithId:(NSString *)goodsId
                      price:(NSString *)price
                     number:(NSString *)number;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	删除产品库
 *
 *  @param goodsIds   产品 ID,多个用“,”逗号隔开
 *
 */
- (void)deleteGoodsWithIds:(NSArray *)goodsIds;

/**
 *	Copyright © 2014 sam Inc. All rights reserved.
 *	Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品上下架
 *
 *  @param status:   枚举值:1 上架 2 下架
 *  @param data:     数据格式:1,200,50 <=>商品 ID,价格,库存
 *                  这里的 data 应该是ShlefGoods数组
 *
 */
- (void)shelfGoodsWithStatus:(NSInteger)status
                        data:(NSArray *)data;

#pragma mark - Shop Demand

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	添加需求
 *
 *	@param content  需求内容
 *	@param lat      当前纬度
 *	@param lng      当前经度
 *
 */
-(void)addDemandWithContent:(NSString *)content
                        lat:(NSString *)lat
                        lng:(NSString *)lng;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	需求列表
 *
 *	@param key      搜索关键字，匹配content字段
 *	@param lat      当前纬度
 *	@param lng      当前经度
 *
 */
-(void)getDemandWithPage:(NSInteger)page
                  andKey:(NSString *)key
                     lat:(NSString *)lat
                     lng:(NSString *)lng;

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
                  bank:(NSString *)bank;

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
                 bank:(NSString *)bank;


/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	删除账单
 *
 *	@param billId       账单id
 *
 */
-(void)deleteBillWithId:(NSString *)billId;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	账单列表
 *
 */
-(void)getBillListWithPage:(NSInteger)page;

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
-(void)getOrderListWithShopType:(NSInteger)shopType
                           page:(NSInteger)page
                      andStatus:(NSInteger)status
                        andType:(NSInteger)type;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	订单状态更新
 *
 *  @param id        订单 ID
 *  @param status    1:未付款
 *                  2:等待发货
 *                  3:已退单/已退货
 *                  4:已发货
 *                  5:可退货
 *                  6:已完成
 *                  7:退货中
 *                  8:结款中
 *                  9:已结款
 *
 */
-(void)updateOrderWithShopType:(NSInteger)shopType
                       orderId:(NSString *)orderId
                    withStatus:(NSString *)status;


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
-(void)retreatOrderWithShopType:(NSInteger)shopType
                        orderId:(NSString *)orderId
                     withReason:(NSString *)reason;

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
-(void)deliveryOrderWithShopType:(NSInteger)shopType
                         orderId:(NSString *)orderId
                   withLogistics:(NSString *)logistics
                      adnWaybill:(NSString *)waybill;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	订单收货处理
 *
 *  @param id           订单 ID
 *  @note status        10:已收货
 *
 */
-(void)recieveGoodsWithShopType:(NSInteger)shopType
                        orderId:(NSString *)orderId;

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
            bankAccount:(NSString *) bankAccount;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品库列表
 *
 *  @param  categoryid:  分类 ID
 *  @param  status:      状态 0: 未上架； 1: 已上架
 *
 */
-(void)getProductListWithCategoryid:(NSInteger)categoryid
                          andStatus:(NSInteger)status;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	编辑收货地址
 *
 *  @param  address:  收货地址
 *
 */
-(void)editShippingAddress:(NSString *)address
                andOrderId:(NSString *)orderId;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	可结款列表
 *
 */
-(void)accountSettleable;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	历史结款列表
 *
 */
-(void)accountHistory;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	申请结款
 *
 */
-(void)applyAccountSettleWithIds:(NSArray *)orderIds;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	异常款项申诉
 *
 *  @param  content: 申诉内容
 *
 */
-(void)abnormalAppealWithContent:(NSString *)content;

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
                 andServiceName:(NSString *)serviceName;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	删除客服
 *
 *  @param  serviceId:  客服id
 *
 */
-(void)delServiceOfShopById:(NSString *)serviceId;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	客服列表
 *
 *  @param  shopid: 商家 ID
 *
 */
-(void)serviceListWithShopId:(NSString *)shopid;

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
             certificate:(UIImage *)certificate;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	编辑商户信息
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
                  certificate:(UIImage *)certificate;

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
                               adPrice:(NSString *)adPrice;

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
                              adPrice:(NSString *)adPrice;

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
                                   lng:(NSString *)lng;


/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商品列表
 *
 *  @param  shopid:   融资商ID
 *
 */
-(void)listGoodsOfFinacialWithShopId:(NSString *)shopid;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	删除商品
 *
 *  @param  goodid:   商品ID
 *
 */
-(void)deleteGoodsOfFinacialWithGoodsId:(NSString *)goodsid;

#pragma mark - 商户独立密码

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商户独立密码设置、修改
 *
 *  @param  password:   商户独立密码
 *
 */
- (void)setShopPassword:(NSString *)password;

/**
 *	@Copyright © 2015 tcy@dreamisland. All rights reserved.
 *
 *	商户独立密码验证
 *
 *  @param  password:   商户独立密码
 *
 */
- (void)verifyShopPassword:(NSString *)password;

@end
