//
//  dapanViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hqBaseViewController.h"
#import "mainTableView.h"
@interface dapanViewController : hqBaseViewController<UITableViewDataSource,UITableViewDelegate,mainTableViewDelegate>

-(void)pushKlineController;
// 大盘列表接口返回数据
-(void)getDapanListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount;
// 个股详情列表接口返回数据
-(void)getStocksDetailsListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount;
@end
