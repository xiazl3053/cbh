//
//  zhongheViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hqBaseViewController.h"
#import "MarketViewController.h"
@interface zhongheViewController : hqBaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) NSString *kId;
@property (nonatomic,retain) NSMutableArray *cellDatas; // 报错分页数据

-(void)pushKlineController;
-(void)getMarketIndexBundle:(NSMutableArray*)data isUpdate:(BOOL)update; // 返回大盘数据处理
-(void)getPopularProfessionListBundle:(NSMutableArray *)data isUpdate:(BOOL)update; // 返回热门行业数据处理
-(void)getChangeListBundle:(NSMutableArray *)data isDown:(BOOL)down isUpdate:(BOOL)update; // 返回涨跌幅数据处理
-(void)getFiveMinuteIndexBundle:(NSMutableArray *)data isDown:(BOOL)down isUpdate:(BOOL)update; // 返回五分钟涨跌幅数据处理
@end
