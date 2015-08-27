//
//  DGRParametersTableViewCell.h
//  DGRouter
//
//  Created by helfy  on 14-12-9.
//  Copyright (c) 2014年 helfy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMParameterCellObj.h"
@interface YMParametersTableViewCell : UITableViewCell

@property (nonatomic,readonly)YMParameterCellObj *cellObj;
-(void)setupViewFor:(YMParameterCellObj *)cellObj;
-(UILabel *)titleLabel;

@end
