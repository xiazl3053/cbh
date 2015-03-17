//
//  kLine.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface kLine : UIView
@property (nonatomic,assign) CGPoint startPoint; // 线条起点
@property (nonatomic,assign) CGPoint endPoint; // 线条终点
@property (nonatomic,retain) NSMutableArray *points; // 多点连线数组
@property (nonatomic,retain) UIColor *color; // 线条颜色
@property (nonatomic,assign) CGFloat lineWidth; // 线条宽度
@property (nonatomic,assign) BOOL isK;// 是否是实体K线 默认是连接线
@property (nonatomic,assign) BOOL isVol;// 是否是画成交量的实体
@property (nonatomic,assign) BOOL isTimeShare;// 是否是画成交量的实体
@property (nonatomic,assign) BOOL isDash;// 是否虚线
@property (nonatomic,assign) BOOL isMACDM;// MACD的M线  
@end
