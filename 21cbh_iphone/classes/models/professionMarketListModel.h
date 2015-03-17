//
//  professionMarketListModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface professionMarketListModel : NSObject

@property (nonatomic,retain) NSString *marketName;
@property (nonatomic,retain) NSString *marketId;
@property (nonatomic,retain) NSString *changeRate;
@property (nonatomic,retain) NSString *threeChangeRate;
@property (nonatomic,retain) NSString *topStockName;
@property (nonatomic,retain) NSString *volume;
@property (nonatomic,retain) NSString *totalTurnover;
@property (nonatomic,retain) NSString *newestValue;
@property (nonatomic,retain) NSString *turnoverRate;
@property (nonatomic,retain) NSString *threeTurnoverRate;
@property (nonatomic,retain) NSString *totalValue;
@property (nonatomic,retain) NSString *circulatedStockValue;
@property (nonatomic,retain) NSString *isChangeColor;

-(id)initWithDic:(NSDictionary *)dic;

@end