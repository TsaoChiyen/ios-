//
//  AddServiceViewController.h
//  chengxin
//
//  Created by Tsao Chiyen on 15-8-21.
//  Copyright (c) 2015年 dreamisland. All rights reserved.
//

#import "BaseViewController.h"

@protocol ServiceViewDelegate <NSObject>

- (void)editDidFinishedWithName:(NSString *)name account:(NSString *)account;

@end

@interface AddServiceViewController : BaseViewController

@property(nonatomic, weak)id<ServiceViewDelegate> delegate;

@end
