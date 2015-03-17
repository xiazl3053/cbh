//
//  selfMarketModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface selfMarketModel : NSObject

@property (nonatomic,retain) NSString *marketName;
@property (nonatomic,retain) NSString *marketId;
@property (nonatomic,retain) NSString *marketType;
@property (nonatomic,retain) NSString *userId;
@property (nonatomic,retain) NSString *timestamp;
@property (nonatomic,retain) NSString *isSyn;
@property (nonatomic,retain) NSString *heightPrice;
@property (nonatomic,retain) NSString *lowPrice;
@property (nonatomic,retain) NSString *todayChangeRate;
@property (nonatomic,retain) NSString *isNotice;
@property (nonatomic,retain) NSString *isNews;
@property (nonatomic,retain) NSString *ids;
-(id)initWithDic:(NSDictionary *)dic;
@end
