//
//  zRemindViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hqBaseViewController.h"

@interface zRemindViewController : hqBaseViewController
@property (nonatomic,retain) NSString *marketName;
@property (nonatomic,retain) NSString *marketId;
@property (nonatomic,retain) NSString *marketType; // 股票类型 0=大盘 1=沪股 2=深股 3=沪深股
@property (nonatomic,retain) NSString *newsValue;
@property (nonatomic,retain) NSString *changeRate;

#pragma mark 接口返回
-(void)getSelfMarketRemindBundle:(BOOL)isSuccess;
#pragma mark 单个管理接口返回
-(void)getSelfStockManageBundle:(int)isSuccess;
#pragma mark 出错提示
-(void)limitMoreTenRemind:(NSString*)message;
@end
