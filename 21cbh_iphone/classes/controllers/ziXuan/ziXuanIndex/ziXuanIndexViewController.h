//
//  ziXuanIndexViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hqBaseViewController.h"
#import "mainTableView.h"
@class ziXuanManageViewController;
@class OptionalViewController;
@interface ziXuanIndexViewController : hqBaseViewController<UITableViewDataSource,UITableViewDelegate,mainTableViewDelegate>
@property (nonatomic,weak) OptionalViewController *Parent;
@property (nonatomic,retain) mainTableView *mainTableView;
@property (nonatomic,retain) NSMutableArray *leftData;
@property (nonatomic,assign) CGFloat changeHeight; // 视图动态改变高度
@property (nonatomic,retain) ziXuanManageViewController *ziXuanManage;
@property (nonatomic,assign) BOOL isSubmitThanUpdate ;// 是否是先提交后更新
@property (nonatomic,assign) BOOL userState;// 用户之前的状态
@property (nonatomic,assign) BOOL isShowHuShenZhi;//显示沪深指
+(ziXuanIndexViewController*)instance;
-(void)pushKlineController;
#pragma mark 大盘列表接口返回数据
-(void)getSelfMarketListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount;
#pragma mark 请求批量管理接口
-(void)getSelfStockBatchManage;
#pragma mark 批量管理接口是否成功
-(void)getSelfStockBatchManageBundle:(int)isSuccess;
#pragma mark 行情/管理视图切换
-(void)moveViews:(BOOL)isChange;
#pragma mark 更新视图
-(void)updateViews;
#pragma mark 保存
-(void)saveLocalDatas;
#pragma mark 加载数据
-(void)loadLocalDatas;
#pragma mark 删除百度云分组数据
-(void)deleteBaiduTags;
@end
