//
//  popularProfessionModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface popularProfessionModel : NSObject

@property (nonatomic,retain) NSString *professionId; // 行业ID
@property (nonatomic,retain) NSString *professionName; // 行业名称
@property (nonatomic,retain) NSString *professionChangeRate; // 行业涨跌幅
@property (nonatomic,retain) NSString *stockName; // 行业中排行第一的股票名称
@property (nonatomic,retain) NSString *stockChangeRate; // 行业中排行第一的股票涨跌幅

// 返回模型
-(id)initWithDic:(NSDictionary*)dic;

@end
