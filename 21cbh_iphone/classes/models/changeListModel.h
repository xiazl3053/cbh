//
//  changeListModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface changeListModel : NSObject
@property (nonatomic,retain) NSString *marketName; // 股票名称
@property (nonatomic,retain) NSString *marketId; // 股票ID
@property (nonatomic,retain) NSString *newestValue; // 最近的值
@property (nonatomic,retain) NSString *changeRate; // 涨跌幅
@property (nonatomic,retain) NSString *changeValue; // 涨跌额
// 返回模型
-(id)initWithDic:(NSDictionary*)dic;
#pragma mark 对象归档
-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end
