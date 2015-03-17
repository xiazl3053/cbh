//
//  liveBroadcastViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-5-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface liveBroadcastViewController : BaseViewController<MainDelegate,UITableViewDelegate,UITableViewDataSource>

@property(weak,nonatomic)MainViewController *main;

#pragma mark 获取新闻列表数据后的处理
-(void)LiveBroadcastHandle:(NSMutableArray *)lbms isUp:(BOOL)isUp;

@end
