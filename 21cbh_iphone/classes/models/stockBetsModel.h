//
//  stockBetsModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface stockBetsModel : NSObject

@property (nonatomic,retain) NSString *newsValue;
@property (nonatomic,retain) NSString *openPrice;
@property (nonatomic,retain) NSString *changeValue;
@property (nonatomic,retain) NSString *heightPrice;
@property (nonatomic,retain) NSString *volume;
@property (nonatomic,retain) NSString *upStop;
@property (nonatomic,retain) NSString *outerDish;
@property (nonatomic,retain) NSString *quantityRatio;
@property (nonatomic,retain) NSString *peRatioA;
@property (nonatomic,retain) NSString *netAsset;
@property (nonatomic,retain) NSString *totalStock;
@property (nonatomic,retain) NSString *flowOfEquity;
@property (nonatomic,retain) NSString *changeRate;
@property (nonatomic,retain) NSString *turnoverRate;
@property (nonatomic,retain) NSString *lowPrice;
@property (nonatomic,retain) NSString *volumePrice;
@property (nonatomic,retain) NSString *downStop;
@property (nonatomic,retain) NSString *innerDish;
@property (nonatomic,retain) NSString *earningsThree;
@property (nonatomic,retain) NSString *peRatioB;
@property (nonatomic,retain) NSString *pbRatio;
@property (nonatomic,retain) NSString *totalPrice;
@property (nonatomic,retain) NSString *flowPrice;
@property (nonatomic,retain) NSString *mainIn;
@property (nonatomic,retain) NSString *mainOut;
@property (nonatomic,retain) NSString *mainNetIn;
@property (nonatomic,retain) NSString *hugeOrder;
@property (nonatomic,retain) NSString *bigOrder;
@property (nonatomic,retain) NSString *middleOrder;
@property (nonatomic,retain) NSString *smallOrder;
@property (nonatomic,retain) NSString *todayPrice;
@property (nonatomic,retain) NSString *yesterdayPrice;
@property (nonatomic,retain) NSString *changeUpValue;
@property (nonatomic,retain) NSString *changeDownValue;
@property (nonatomic,retain) NSString *sameDish;
@property (nonatomic,retain) NSString *stockName;
@property (nonatomic,retain) NSMutableDictionary *dic;
-(id)initWithDic:(NSDictionary *)dic;

@end
