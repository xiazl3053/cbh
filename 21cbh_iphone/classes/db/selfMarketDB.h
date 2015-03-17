//
//  selfMarketDB.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "selfMarketModel.h"
@interface selfMarketDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertWithSelfMarket:(selfMarketModel *)selfMarket;
#pragma mark 更新自选股
-(void)updateRemindWithSelfMarket:(selfMarketModel *)selfMarket;
#pragma mark 删除数据
-(void)deleteSelfMarket:(selfMarketModel *)selfMarket;
#pragma mark 删除所有数据
-(void)deleteAllSelfMarket;
#pragma mark 查看自选股是否存在
-(BOOL)isExistSelfMarket:(selfMarketModel *)selfMarket;
#pragma mark 查询自选股列表数据
-(NSMutableArray *)getSelfMarketList;
#pragma mark 查询自选股单例数据
-(selfMarketModel *)getSelfMarketModelWithMarketId:(NSString*)marketId andMarketType:(NSString*)marketType;
@end
