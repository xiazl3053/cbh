//
//  KLineViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hqBaseViewController.h"
#import "MJRefresh.h"
@class KLineViewController;
@class kTabbarController;
@class kChartViewController;
@class stockBetsModel;
typedef void (^headerUpdateBlock)(KLineViewController*kLineView); // 声明更新块
typedef void (^footerMoreLoadBlock)(KLineViewController*kLineView); // 声明更多加载块
typedef void (^scrollBlock)(KLineViewController*kLineView); // 主视图滚动块

@interface KLineViewController : hqBaseViewController<MJRefreshBaseViewDelegate,UIScrollViewDelegate>
@property (nonatomic,retain) NSString *kId;
@property (nonatomic,retain) NSString *kName;
@property (nonatomic,retain) NSString *yesterdayPrice;// 共享昨日收盘价
@property (nonatomic,retain) NSString *newsPrice;// 共享最新价
@property (nonatomic,retain) NSString *changeRate;// 共享涨跌幅
@property (nonatomic,retain) UILabel *kNameLabel;// 标题栏
@property (nonatomic,retain) UILabel *kIdLabel;// 标题栏
@property (nonatomic,retain) UIView *kTopView; // 顶部参数显示视图
@property (nonatomic,retain) UIScrollView *mainView; // 主视图
@property (nonatomic,retain) UIScrollView *mainScrollView; // 主视图
@property (nonatomic,copy) headerUpdateBlock kUpdateBlock; // 更新块
@property (nonatomic,copy) footerMoreLoadBlock kMoreLoadBlock; // 加载更多块
@property (nonatomic,copy) scrollBlock scrollBlock; // 主视图滚动块
@property (nonatomic,retain) MJRefreshHeaderView *header; // 下拉刷新
@property (nonatomic,retain) MJRefreshFooterView *footer;// 上啦加载
@property (nonatomic,retain) kTabbarController *bottomController; // 底部切换控制器
@property (nonatomic,retain) kChartViewController *kChartController ;// k线图控制器
@property (nonatomic,assign) BOOL isFix;// 是否固定底部视图切换栏
@property (nonatomic,retain) stockBetsModel *pDatas;// 共享盘口数据
@property (nonatomic,assign) BOOL isStop;// 共享停止标签
@property (nonatomic,assign) BOOL isHorizontal;// 是否横屏
@property (nonatomic,assign) CGRect screenFrame;// 共享屏幕分辨率
@property (nonatomic,assign) BOOL isFirst;//是否第一次
@property (nonatomic,assign) int currentButtonIndex;//当前点击的视图索引
@property (nonatomic,assign) int currentPage;// 当前页码
@property (nonatomic,copy) NSMutableArray *pageArray;// 上下页数据
@property (nonatomic,assign) BOOL isBack;// 是否返回
@property (nonatomic,retain) UIView *titleView;// 标题视图 横屏的时候用到
@property (nonatomic,retain) hqBaseViewController *backController;// 返回控制器
@property (nonatomic,assign) BOOL isStopStock;// 是否停牌
@property (nonatomic,retain) UIView *preAndNextView; // 上一页下一页视图
@property (nonatomic,assign) BOOL isMovePage;// 是否是滑动翻页
@property (nonatomic,assign) BOOL isClickTransformButton;// 是否点击切换横屏按钮
@property (nonatomic,retain) MJRefreshBaseView *refreshView; // 上啦下拉刷新视图

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

#pragma mark 设置标题
-(void)setKTitle:(NSString*)title;
#pragma mark 更新主视图高度
-(void)updateMainViewHeight:(CGFloat)height;
#pragma mark 初始化K线图
-(id)initWithIsBack:(BOOL)isBack KId:(NSString*)kId KType:(int)kType KName:(NSString*)kName;
#pragma mark 初始化K线图 用于二级个股列表界面
-(id)initWithBackController:(id)controller kId:(NSString*)kId KType:(int)kType KName:(NSString*)kName andPageArray:(NSMutableArray*)pageArray andPage:(int)page;
#pragma mark 从推送中心push过来
-(id)initWithPush:(NSString*)kId KType:(int)kType KName:(NSString*)kName RemindType:(NSString*)remindType;
#pragma mark 为上下页服务
-(id)initWithMovePage:(NSString*)kId KType:(int)kType KName:(NSString*)kName;
#pragma mark 加载完运行
-(void)whenLoadOverAction;
-(void)jumpIntoPage;
@end
