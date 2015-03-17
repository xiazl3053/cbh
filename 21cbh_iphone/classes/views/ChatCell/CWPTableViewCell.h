//
//  CWPTableViewCell.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageItemAdaptor.h"

#define KTopMargin 30

@interface CWPTableViewCell : UITableViewCell
{
    UILabel* timeLabel_;
    MessageItemAdaptor* adaptor_;
}

#pragma 计算Cell的高度
+(int)currentCellHeight:(MessageItemAdaptor*)adaptor;
#pragma 填充数据
-(void)fillWithData:(MessageItemAdaptor*)adaptor;
#pragma 清空数据
-(void)cleanData;

@end
