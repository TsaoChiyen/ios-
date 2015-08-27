//
//  SessionNewsDetailViewController.h
//  reSearchDemo
//
//  Created by helfy  on 15-4-17.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseTableViewController.h"
@interface SessionNewsDetailViewController : BaseViewController


-(void)setTitle:(NSString *)title filePath:(NSString *)filePath;

-(void)setTitle:(NSString *)title url:(NSURL *)urlPath;

-(void)setNewsDic:(NSDictionary *)newsDic;
@end
