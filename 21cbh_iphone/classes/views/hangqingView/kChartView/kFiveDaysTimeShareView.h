//
//  kFiveDaysTimeShareView.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class timeShareChartModel;
typedef void(^updateBlock)(id);
typedef void (^pressDownBlock)(timeShareChartModel *timeModel); // 手指按下触发Block
typedef void (^pressUpBlock)(timeShareChartModel *timeModel); // 手指移开触发Block
@interface kFiveDaysTimeShareView : UIView

@property (nonatomic,copy) NSMutableArray *data;
@property (nonatomic,retain) NSMutableArray *category;
@property (nonatomic,retain) NSString *startDate;
@property (nonatomic,retain) NSString *endDate;
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
-(void)start;
-(void)update;


@end
