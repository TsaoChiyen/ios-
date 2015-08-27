//
//  BSEngine.m
//  Binfen
//
//  Created by NigasMone on 14-12-1.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "BSEngine.h"
#import "Globals.h"
#import "NSStringAdditions.h"
#import "Shop.h"

static BSEngine * _currentBSEngine;

@interface BSEngine () {
    
}

@end

@implementation BSEngine

@synthesize user;
@synthesize passWord;
@synthesize deviceIDAPNS;

#pragma mark - BSEngine Life Circle
+ (BSEngine *) currentEngine
{
    @synchronized (self)
    {    if (_currentBSEngine == nil) {
        _currentBSEngine = [[BSEngine alloc] init];
    }
    }
	return _currentBSEngine;
}

+ (User *) currentUser {
    return self.currentEngine.user;
}

+ (NSString *) currentUserId {
    return self.currentEngine.user.uid;
}

- (id)init {
    if (self = [super init]) {
        [self readAuthorizeData];
    }
    return self;
}

- (void)dealloc
{
    self.passWord = nil;
    self.deviceIDAPNS = nil;
    self.user = nil;
}

#pragma mark - BSEngine Private Methods

- (void)saveAuthorizeData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:user];

    if (data && passWord) {
        [defaults setObject:data forKey:KBSCurrentUserInfo];
        [defaults setObject:passWord forKey:KBSCurrentPassword];
        NSData * datashop = [NSKeyedArchiver archivedDataWithRootObject:user.shop];
        [defaults setObject:datashop forKey:KBSCurrentShop];
        NSData * datafinanc = [NSKeyedArchiver archivedDataWithRootObject:user.financ];
        [defaults setObject:datafinanc forKey:KBSCurrentFinanc];
    }
    
	[defaults synchronize];
}

- (void)readAuthorizeData {
    self.user = nil;
    self.passWord = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData* data = [defaults objectForKey:KBSCurrentUserInfo];
    NSString* pwd = [defaults objectForKey:KBSCurrentPassword];
    if (data && pwd) {
        self.user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSData * datashop = [defaults objectForKey:KBSCurrentShop];

        if (datashop) {
            self.user.shop = [NSKeyedUnarchiver unarchiveObjectWithData:datashop];
            self.user.shop.user = self.user;
        }

        NSData * datafinanc = [defaults objectForKey:KBSCurrentFinanc];
        
        if (datafinanc) {
            self.user.financ = [NSKeyedUnarchiver unarchiveObjectWithData:datafinanc];
        }

        self.passWord = pwd;
    }
}

- (void)deleteAuthorizeData {
    self.user = nil;
    self.passWord = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:KBSCurrentUserInfo];
    [defaults removeObjectForKey:KBSCurrentPassword];
    
	[defaults synchronize];
}

- (void)setCurrentUser:(User*)item password:(NSString*)pwd {
    self.user = item;
    self.passWord = pwd;
    [self saveAuthorizeData];
}

#pragma mark - BSEngine Public Methods

- (void)signOut {
    [self deleteAuthorizeData];
}

#pragma mark Authorization

- (BOOL)isLoggedIn
{
    return self.user && self.passWord;
}
@end
