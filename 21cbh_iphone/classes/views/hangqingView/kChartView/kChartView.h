//
//  kChartView.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class kLineModel;
@class kChartView;
@class kChartParamModel;

typedef void(^updateBlock)(id);
typedef void (^pressDownKLineBlock)(kLineModel *timeModel); // 手指按下触发Block
typedef void (^pressUpKLineBlock)(kLineModel *timeModel); // 手指移开触发Block
typedef void (^finishedBlock)(kChartView *kChartView); // k线处理完成调用
typedef void (^chartTapBlock)(kChartView *kChartView); // 点击手势处理

@interface kChartView : UIView
@property (nonatomic,retain) id parent;// 父控制器
@property (nonatomic,copy) NSMutableArray *data;
@property (nonatomic,retain) NSMutableArray *category;
@property (nonatomic,retain) NSDate *startDate;
@property (nonatomic,retain) NSDate *endDate;
@property (nonatomic,assign) CGFloat xWidth; // x轴宽度
@property (nonatomic,assign) CGFloat yHeight; // y轴高度
@property (nonatomic,assign) CGFloat bottomBoxHeight; // y轴高度
@property (nonatomic,assign) CGFloat kLineWidth; // k线的宽度 用来计算可存放K线实体的个数，也可以由此计算出起始日期和结束日期的时间段
@property (nonatomic,assign) CGFloat kLinePadding;
@property (nonatomic,assign) int kCount; // k线中实体的总数 通过 xWidth / kLineWidth 计算而来
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,copy) updateBlock finishUpdateBlock; // 定义一个block回调 更新界面
@property (nonatomic,assign) CGFloat height; // 视图的高度
@property (nonatomic,copy) pressDownKLineBlock pressDownBlock; // 手指按下调用块
@property (nonatomic,copy) pressUpKLineBlock pressUpBlock; // 手指移开调用块
@property (nonatomic,copy) finishedBlock finishedBlock; // k线处理完成调用
@property (nonatomic,copy) chartTapBlock chartTapBlock; // 点击手势处理

-(void)startWith:(kChartParamModel*)model;
-(void)updateWith:(kChartParamModel*)model;
-(void)free;
@end


@interface kChartParamModel : NSObject

@property (nonatomic,assign) NSMutableArray *data;
@property (nonatomic,assign) CGFloat width; // x轴宽度
@property (nonatomic,assign) CGFloat height; // y轴高度
@property (nonatomic,assign) CGFloat kLineWidth; // k线的宽度 用来计算可存放K线实体的个数，也可以由此计算出起始日期和结束日期的时间段
@property (nonatomic,assign) CGFloat padding;
@property (nonatomic,assign) int count; // k线中实体的总数 通过 xWidth / kLineWidth 计算而来
@property (nonatomic,retain) id parent;// 父控制器
@end