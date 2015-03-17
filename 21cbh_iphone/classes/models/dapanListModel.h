//
//  dapanListModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dapanListModel : NSObject

@property (nonatomic,retain) NSString *marketName;
@property (nonatomic,retain) NSString *marketId;
@property (nonatomic,retain) NSString *newestValue;
@property (nonatomic,retain) NSString *changeRate;
@property (nonatomic,retain) NSString *changeValue;
@property (nonatomic,retain) NSString *total;
@property (nonatomic,retain) NSString *amount;
@property (nonatomic,retain) NSString *highest;
@property (nonatomic,retain) NSString *lowest;
@property (nonatomic,retain) NSString *handoff;
@property (nonatomic,retain) NSString *priceEarning;
@property (nonatomic,retain) NSString *totalValue;
@property (nonatomic,retain) NSString *circulatedStockValue;
@property (nonatomic,retain) NSString *isChangeColor;
@property (nonatomic,retain) NSString *timestamp;
@property (nonatomic,retain) NSString *type;
// 用于自选股
@property (nonatomic,retain) NSString *heightPrice; // 股价涨到
@property (nonatomic,retain) NSString *lowPrice; // 股价跌到
@property (nonatomic,retain) NSString *todayChangeRate; // 日涨跌幅超
@property (nonatomic,retain) NSString *isNotice; // 公告提醒
@property (nonatomic,retain) NSString *isNews; // 资讯提醒

-(id)initWithDic:(NSDictionary *)dic;

#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;

@end

