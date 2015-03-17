//
//  marketIndexModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface marketIndexModel : NSObject

@property (nonatomic,retain) NSString *marketId; // 大盘指数ID
@property (nonatomic,retain) NSString *marketName; // 大盘名称
@property (nonatomic,retain) NSString *totalValue; // 总值
@property (nonatomic,retain) NSString *changeValue; // 涨跌额
@property (nonatomic,retain) NSString *changeRate; // 涨跌幅

// 返回模型
-(id)initWithDic:(NSDictionary*)dic;
#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end
