//
//  QRcodeReaderViewController.h
//  SpartaEducation
//
//  Created by kiwi on 14-6-9.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import "BaseViewController.h"

@protocol QRcodeReaderViewDelegate <NSObject>
@optional
- (void)QRcodeReaderDidFinish:(UIView *)sender data:(NSString *)data;
@end

@interface QRcodeReaderViewController : BaseViewController
@property(nonatomic, weak)id<QRcodeReaderViewDelegate> delegate;
@end
