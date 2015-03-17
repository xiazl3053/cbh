//
//  kChartTimeShareView.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class timeShareChartModel;
@class kChartTimeShareView;
@class kChartTimeParamModel;

typedef enum : NSUInteger {
    chartTimeStateBegin,
    chartTimeStateRuning,
    chartTimeStateEnd,
} chartTimeState;

typedef void(^updateBlock)(id);
typedef void (^pressDownBlock)(timeShareChartModel *timeModel); // 手指按下触发Block
typedef void (^pressUpBlock)(timeShareChartModel *timeModel); // 手指移开触发Block
typedef void (^finishedBlocks)(kChartTimeShareView *kChartTimeView); // 处理完成
typedef void (^chartTapBlocks)(kChartTimeShareView *kChartTimeView); // 点击手势处理

@interface kChartTimeShareView : UIView

@property (nonatomic,retain) NSMutableArray *data;
@property (nonatomic,assign) CGFloat xWidth; // x轴宽度
@property (nonatomic,assign) CGFloat yHeight; // y轴高度
@property (nonatomic,assign) CGFloat bottomBoxHeight; // y轴高度
@property (nonatomic,assign) CGFloat kLineWidth; // k线的宽度 用来计算可存放K线实体的个数，也可以由此计算出起始日期和结束日期的时间段
@property (nonatomic,assign) CGFloat kLinePadding;
@property (nonatomic,assign) int kCount; // k线中实体的总数 通过 xWidth / kLineWidth 计算而来
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,copy) updateBlock finishUpdateBlock; // 定义一个block回调 更新界面
@property (nonatomic,assign) CGFloat height; // 视图的高度
@property (nonatomic,assign) CGFloat closePrice;// 昨日收盘价
@property (nonatomic,assign) CGFloat heightPrice;// 及时成交价最高值（第一次返回昨天最高价）
@property (nonatomic,copy) pressDownBlock pressDownBlock; // 手指按下调用块
@property (nonatomic,copy) pressUpBlock pressUpBlock; // 手指移开调用块
@property (nonatomic,copy) finishedBlocks finishBlock; // 完成调用
@property (nonatomic,copy) chartTapBlocks chartTapBlocks; // 点击手势处理
@property (nonatomic,assign) int days;// 分时图天数 1=分时图 5=五日分时图
@property (nonatomic,retain) NSString *timeFrame;// 时间段
@property (nonatomic,retain) NSMutableArray *pankou;// 盘口数据
@property (nonatomic,retain) NSMutableArray *dishs;// 内外盘 0=内盘 1=外盘
@property (nonatomic,assign) chartTimeState chartState;// 运行状态

-(void)startWith:(kChartTimeParamModel*)model;
-(void)updateWith:(kChartTimeParamModel*)model;
-(void)free;

@end


@interface kChartTimeParamModel : NSObject
// start option
@property (nonatomic,assign) CGFloat width; // x轴宽度
@property (nonatomic,assign) CGFloat height; // y轴高度
@property (nonatomic,assign) CGFloat kLineWidth; // k线的宽度 用来计算可存放K线实体的个数，也可以由此计算出起始日期和结束日期的时间段
@property (nonatomic,assign) CGFloat padding;
@property (nonatomic,assign) int count; // k线中实体的总数 通过 xWidth / kLineWidth 计算而来
@property (nonatomic,assign) int days;// 分时图天数 1=分时图 5=五日分时图
// update option
@property (nonatomic,assign) NSMutableArray *data;
@property (nonatomic,assign) CGFloat closePrice;// 昨日收盘价
@property (nonatomic,assign) CGFloat heightPrice;// 及时成交价最高值（第一次返回昨天最高价）
@property (nonatomic,retain) NSString *timeFrame;// 时间段

@end