//
//  stocksDetailsListModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface stocksDetailsListModel : NSObject
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
@property (nonatomic,retain) NSDictionary *dic;
-(id)initWithDic:(NSDictionary *)dic;
#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end
