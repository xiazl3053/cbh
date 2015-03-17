//
//  StockIndexOperation.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockIndexOperation : NSObject

#pragma mark 计算MACD值
+(NSMutableDictionary*)getMACD:(NSArray*)list andDays:(int)day DhortPeriod:(int)shortPeriod LongPeriod:(int)longPeriod MidPeriod:(int)midPeriod;
#pragma mark 计算KDJ值
+(NSMutableDictionary*)getKDJMap:(NSArray*)m_kData;
#pragma mark 计算MA均线值
+(void)CalculateMA:(NSArray*)data;
@end
