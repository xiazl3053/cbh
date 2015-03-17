//
//  kLineModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface kLineModel : NSObject<NSCoding>

@property (nonatomic,retain) NSString *openPrice;
@property (nonatomic,retain) NSString *closePrice;
@property (nonatomic,retain) NSString *heightPrice;
@property (nonatomic,retain) NSString *lowPrice;
@property (nonatomic,retain) NSString *volume;
@property (nonatomic,retain) NSString *volumePrice;
@property (nonatomic,retain) NSString *turnoverRate;
@property (nonatomic,retain) NSString *changeValue;
@property (nonatomic,retain) NSString *changeRate;
@property (nonatomic,retain) NSString *MA5;
@property (nonatomic,retain) NSString *MA10;
@property (nonatomic,retain) NSString *MA20;
@property (nonatomic,retain) NSString *volMA5;
@property (nonatomic,retain) NSString *volMA10;
@property (nonatomic,retain) NSString *time;
@property (nonatomic,retain) NSString *MACD_DIF;
@property (nonatomic,retain) NSString *MACD_DEA;
@property (nonatomic,retain) NSString *MACD_M;
@property (nonatomic,retain) NSString *MACD_12EMA;
@property (nonatomic,retain) NSString *MACD_26EMA;
@property (nonatomic,retain) NSString *KDJ_K;
@property (nonatomic,retain) NSString *KDJ_D;
@property (nonatomic,retain) NSString *KDJ_J;

-(id)initWithDic:(NSDictionary *)dic;

#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end
