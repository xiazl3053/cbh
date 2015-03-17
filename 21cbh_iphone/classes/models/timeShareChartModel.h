//
//  timeShareChartModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface timeShareChartModel : NSObject
@property (nonatomic,retain) NSString *transationPrice;
@property (nonatomic,retain) NSString *MAn;
@property (nonatomic,retain) NSString *changeValue;
@property (nonatomic,retain) NSString *changeRate;
@property (nonatomic,retain) NSString *volume;
@property (nonatomic,retain) NSString *volumePrice;
@property (nonatomic,retain) NSString *heightPrice;
@property (nonatomic,retain) NSString *closePrice;
@property (nonatomic,retain) NSString *seonds;
@property (nonatomic,retain) NSString *time;
@property (nonatomic,retain) NSString *turnoverRate;
@property (nonatomic,retain) NSString *priceType;
@property (nonatomic,retain) NSString *timeFrame;
@property (nonatomic,retain) NSString *betsType;

-(id)initWithDic:(NSDictionary *)dic;
@end
