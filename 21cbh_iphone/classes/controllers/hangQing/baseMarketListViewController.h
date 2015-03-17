//
//  baseMarketListViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hqBaseViewController.h"
#import "mainTableView.h"

@interface baseMarketListViewController : hqBaseViewController<UITableViewDataSource,UITableViewDelegate,mainTableViewDelegate>

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *subTitle;
@property (nonatomic,retain) NSMutableArray *tableTitles;
@property (nonatomic,assign) BOOL isContainSelf;// 是否显示自身标题
@property (nonatomic,assign) int orderBy; // 排序类型 0=降序 1=升序
@property (nonatomic,retain) NSString *element; // 排序字段
@property (nonatomic,assign) int listType ; // 列表类型  0=个股涨跌榜列表  1=五分钟涨跌榜列表
-(void)pushKlineController;
#pragma mark 个股详情列表接口返回数据
-(void)getStocksDetailsListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount;
@end
