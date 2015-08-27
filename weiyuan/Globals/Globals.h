//
//  Globals.h
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBConnection.h"

static __strong id preSendMsg;
// net work
#define ShouldLogPreRequest     1
#define ShouldLogAfterRequest   1
#define ShouldLogJsonUrlString  1
#define ShouldLogXMPPDebugInfo  1

#define DB_Version @"0.1.4"
#define defaultSizeInt 20

#define KBSSDKErrorDomain           @"BaseSDKErrorDomain"
#define KBSSDKErrorCodeKey          @"BaseSDKErrorCodeKey"
typedef enum
{
	KBSErrorCodeInterface	= 100,
	KBSErrorCodeSDK         = 101,
}KBSErrorCode;

typedef enum
{
	KBSSDKErrorCodeParseError       = 200,
	KBSSDKErrorCodeRequestError     = 201,
	KBSSDKErrorCodeAccessError      = 202,
	KBSSDKErrorCodeAuthorizeError	= 203,
}KBSSDKErrorCode;

typedef void (^Img_Block)(UIImage *img);
// data
#define NUMBERS @"0123456789\n"
#define LETTERS @"abcdefghijklmnopqrstuvwxvz\n"
#define SIZE_FONT16 16
#define SIZE_FONT15 15
#define SIZE_FONT14 14
#define SIZE_FONT13 13
#define SIZE_FONT12 12
#define SIZE_FONT10 10
#define kCornerRadiusNormal     5.0
#define kCornerRadiusSmall      4.0
#define bkgNameOfView           @"bkg_view"
#define bkgNameOfInputView      @"bkg_input"

extern CGFloat getDeviceStatusHeight();

@class BaseViewController, User;

@interface Globals : NSObject

+ (void)createTableIfNotExists;
+ (void)initializeGlobals;

+ (UIColor*)getColorViewBkg;
+ (UIColor*)getColorGrayLine;
+ (UIImage*)getImageInputViewBkg;
+ (UIImage*)getImageDefault;
+ (UIImage*)getImageRoomHeadDefault;
+ (UIImage*)getImageUserHeadDefault;
+ (UIImage*)getImageGoodHeadDefault;
+ (UIImage*)getImageGray;
+ (UIImage *)getImageWithColor:(UIColor*)color;

+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSString*)convertDateFromString:(NSString*)uiDate timeType:(int)timeType;
+ (NSDate *)convertStringtoDate:(NSString*)strDate timeType:(int)timeType;
+ (NSString*)timeStringForListWith:(NSTimeInterval)timestamp;
+ (NSString*)getBaiduAdrPic:(CGFloat)lat lng:(CGFloat)lng;
+ (NSString*)getBaiduAdrPicForTalk:(CGFloat)lat lng:(CGFloat)lng;
+ (void)removeAllItemsInFolder:(NSString*)path;
+ (NSTimeInterval)fileCreateDate:(NSString*)filePath;
+ (NSString*)timeString;
+ (void)imageDownload:(Img_Block)block url:(NSString*)url;

+ (NSString*)sendTimeString:(double)sendTime;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (NSString *)generateUUID;


+ (NSString *)getTime:(NSTimeInterval)createtime;

+ (void)callAction:(NSString *)phone parentView:(UIView*)view;
+ (void)smsAction:(NSString *)phone parentView:(BaseViewController*)controller;

+ (BOOL)isNotify;
+ (void)setIsNotify:(BOOL)value;

+ (void)setPreSendMsg:(id)it;
+ (id)preSendMsg;

+ (void)talkToUser:(User *)user
            andUid:(NSString *)uid
    withController:(BaseViewController *)controller;

@end
