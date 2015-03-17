//
//  selfMaketMessageDB.h
//  21cbh_iphone
//
//  Created by Franky on 14-4-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "selfMarketMessageModel.h"

@interface selfMarketMessageDB : NSObject

+(selfMarketMessageDB*)instance;

#pragma mark 如果不存在就插入数据
-(void)insertIfNotExist:(selfMarketMessageModel*)model andUserId:(NSString*)userId;
#pragma mark 如果不存在就插入数据
-(void)insertIfNotExistWithDic:(NSDictionary*)dic isRead:(BOOL)flag andUserId:(NSString*)userId;
#pragma mark 插入数据
-(void)insertMessage:(selfMarketMessageModel *)model andUserId:(NSString*)userId;
#pragma mark 更新数据
-(void)readMessage:(selfMarketMessageModel *)model andUserId:(NSString*)userId;
#pragma mark 删除数据
-(void)deleteMessage:(selfMarketMessageModel*)model andUserId:(NSString*)userId;
#pragma mark 查询数据是否存在
-(BOOL)isExistMessage:(selfMarketMessageModel*)model andUserId:(NSString*)userId;
#pragma mark 查询数据是否已读
-(BOOL)isReadMessage:(selfMarketMessageModel*)model andUserId:(NSString*)userId;
#pragma mark 查询未读数量
-(int)getUnReadofMessageWithUserId:(NSString*)userId;
#pragma mark 清空所有未读数量
-(void)cleanAllUnReadMessageWithUserId:(NSString*)userId;

@end
