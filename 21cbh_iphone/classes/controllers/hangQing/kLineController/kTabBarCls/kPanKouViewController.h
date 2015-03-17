//
//  kPanKouViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-1.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kBaseViewController.h"
@class stockBetsModel;
@interface kPanKouViewController : kBaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) stockBetsModel *model; // 盘口模型
// 成交量接口返回数据
-(void)getFiveAndDetailBundle:(NSMutableArray*)data;

@end
