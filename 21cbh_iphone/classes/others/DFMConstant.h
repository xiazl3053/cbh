//
//  DFMConstant.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

//接口地址
#define kMarketIndexList @"marketIndexList" // DFM行情页大盘指数接口
#define kPopularProfessionList @"popularProfessionList" // DFM行情页大盘指数接口
#define kChangeList @"changeList" // DFM 涨跌榜接口
#define kFiveMinuteChangeIndex @"fiveMinuteChangeIndex" // DFM 综合页五分钟涨跌榜接口
#define kFiveMinuteChangeList @"fiveMinuteChangeList" // DFM 列表页五分钟涨跌榜接口
#define kKlineIndex @"kLineIndex" // DFM K线图接口
#define kTimeShareChart @"timeShareChart" // DFM 分时图接口
#define kDapanList @"marketAndHongKongList" // DFM 大盘列表接口
#define kGangguList @"marketAndHongKongList" // DFM 港股列表接口
#define kGlobalMarketList @"globalMarketList" // DFM 全球列表接口
#define kProfessionMarketList @"professionMarketList" // DFM 行业板块行情列表接口
#define kVolDetailList @"volDetailList" // DFM 成交量明细接口
#define kStocksDetailsList @"stocksDetailsList" // DFM 个股列表接口
#define kStockListRefresh @"stockListRefresh" // DFM 个股列表刷新接口
#define kStockBets @"stockBets" // DFM 盘口接口
#define kKChartNewsList @"kChartNewsList" // DFM k线图资讯接口
#define kAnalystList @"analystList" // DFM 分析师接口
#define kSelfMarketIndexList @"selfMarketIndexList" // 自选股接口
#define kFiveAndDetail @"fiveAndDetail" // 五档明细接口
#define kSelfStockRemind @"selfStockRemind" // 自选股提醒更新接口
#define kSelfStockBatchManage @"selfStockBatchManage" // 自选股批量更新接口
#define kSelfStockManage @"selfStockManage" // 自选股单个管理接口
#define kHushenStocksIndex @"hushenStocksindex" // 沪深股接口
//颜色
#define ClearColor [UIColor clearColor] // DFM清除颜色
#define kRedColor UIColorFromRGB(0xE8322B) // DFM红色
#define kGreenColor UIColorFromRGB(0x47a316) // DFM绿色
#define kBlueColor UIColorFromRGB(0x3f99e9) // DFM蓝色
#define kBrownColor UIColorFromRGB(0xe86e25) // DFM棕色
#define kYellowColor UIColorFromRGB(0xeffff00) // DFM黄色
#define kMarketBackground UIColorFromRGB(0xf0f0f0) // DFM背景颜色
// 字体
#define kDefaultFont [UIFont fontWithName:kFontName size:16] // DFM字体

//自定义宏
#define KPlistKey2 @"hqTitles"  // DFM行情分类标题
#define KPlistKey3 @"bkTitles"  // DFM板块分类标题
#define KPlistKey4 @"ggTitles"  // DFM个股分类标题


// IOS版本
#define kDeviceVersion [[[UIDevice currentDevice] systemVersion]floatValue]  // DFM 版本判断

// 表格一些尺寸
#define kTableViewCellRowWidth 80  // 表格每列的宽度
#define kSectionHeight 40.0f
#define kMarketScreenFrame [UIScreen mainScreen].bounds // 用于行情界面全屏分辨率
#define kMarketTabButtonViewHeight kMarketScreenFrame.size.height - 20 - 44 - 35 - 61 - 40; // 当前高度为 屏幕分辨率 - 状态了高度 - 导航栏高度 - 底部广告栏高度 - 底部导航栏高度

#define kselfMarketDBName @"selfMarket.db"// 自选股数据库名字
#define ksearchStockDBName @"searchStock.db"// 搜索数据库名字

#define kSelfMarketOperationType @"selfMarketOperationType" // 自选股注销登陆操作类型 UserDefault字段名称
#define kSelfMarketIsSubmitThanUpdate @"selfMarketIsSubmitThanUpdate" // 自选股中心 是否先提交后更新

// 缓存文件夹
#define kLineCacheFolder @"kLineCache"
#define kMarketCacheFolder @"marketCache"

// 通知键名
#define kNotifcationKeyForActive @"kNotifcationKeyForActive"
#define kNotifcationKeyForEnterGround @"kNotifcationKeyForEnterGround"
