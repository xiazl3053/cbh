//
//  liveBroadcastCell.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-5-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "liveBroadcastModel.h"

@interface liveBroadcastCell : UITableViewCell


#pragma mark 设置cell的数据
-(void)setCell:(liveBroadcastModel *)lbm;
#pragma mark 获取当前cell的高度
+(int)currentHight:(liveBroadcastModel*)lbm;

@end
