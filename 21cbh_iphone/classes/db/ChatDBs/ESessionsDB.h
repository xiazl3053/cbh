//
//  ESessionsDB.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESessions;

@interface ESessionsDB : NSObject

+(ESessionsDB *)instance;
#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 查询数据
-(NSMutableArray *)selectSessions;
#pragma mark 查询某个会话
-(NSMutableArray *)selectSessionsWithFriendJid:(NSString *)friends_jid;
#pragma mark 更新数据
-(void)updateWithSession:(ESessions *)session;
#pragma mark 插入数据
-(int)insertWithSession:(ESessions *)session;
#pragma mark 删除数据
-(void)deleteSession:(NSString *)jid;
#pragma mark -数据是否存在
-(BOOL)isExistFriends:(ESessions *)session;
#pragma mark 查询某个会话
-(ESessions *)getSessionWithJid:(NSString *)jid;

@end
