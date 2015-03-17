//
//  globalMarketList.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface globalMarketList : NSObject
@property (nonatomic,retain) NSString *marketName;
@property (nonatomic,retain) NSString *marketId;
@property (nonatomic,retain) NSString *newestValue;
@property (nonatomic,retain) NSString *changeRate;
@property (nonatomic,retain) NSString *state;
@property (nonatomic,retain) NSString *isChangeColor;

-(id)initWithDic:(NSDictionary *)dic;

@end

