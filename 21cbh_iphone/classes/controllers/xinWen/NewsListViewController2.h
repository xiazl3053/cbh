//
//  NewsListViewController2.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXCycleScrollView.h"
#import "AdBarView.h"
#import "AdBarModel.h"
#import "TopPicModel.h"
#import "NewListModel.h"
#import "NewsViewController.h"


@interface NewsListViewController2 : UIViewController<ZXCycleScrollViewDatasource,ZXCycleScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,AdBarViewDelegate>

@property(weak,nonatomic)NewsViewController *nvc;
@property(copy,nonatomic)NSString *programId;
@property(copy,nonatomic)NSString *topProgramId;
@property(copy,nonatomic)NSString *programName;
@property(weak,nonatomic)MainViewController *main;

#pragma mark 当前的子控制器为选中状态
-(void)refreshView;
#pragma mark 当前的子控制器为非选中状态
-(void)endRefreshView;
#pragma mark 设置table的高度
-(void)setTableHeight:(CGFloat)height;
#pragma mark 检测该广告栏广告是否是用户点击过的
-(void)checkAdBar:(AdBarModel *)abm;
#pragma mark 获取广告栏数据后的处理
-(void)getAdBarHandle:(AdBarModel *)adBarModel;
#pragma mark 获取头图数据后的处理
-(void)getHeadHandle:(NSMutableArray *)tpms;
#pragma mark 获取新闻列表数据后的处理
-(void)getNewsListHandle:(NSMutableArray *)nlms data:(NSDictionary *)data isUp:(BOOL)isUp;
@end
