//
//  BankEditViewController.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseViewController.h"

@protocol BankEditViewDelegate <NSObject>

- (void)editDidFinishedWithBank:(NSString *)bank user:(NSString *)user account:(NSString *)account;

@end

@interface BankEditViewController : BaseViewController

@property(nonatomic, weak)id<BankEditViewDelegate> delegate;

@end
