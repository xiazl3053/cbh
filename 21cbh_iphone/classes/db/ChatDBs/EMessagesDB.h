//
//  EMessagesDB.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EMessages;

@interface EMessagesDB : NSObject

+(EMessagesDB *)instanceWithFriendJID:(NSString*)friend_jid;
#pragma mark 打开数据库
-(BOOL)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 查询数据
-(NSMutableArray *)selectMessageWithPage:(int)page;
#pragma mark 获取最后一条消息
-(EMessages*)getLastMessage;
#pragma mark 更新数据默认通知
-(void)updateWithMessage:(EMessages *)message;
#pragma mark 更新数据是否通知
-(void)updateWithMessage:(EMessages *)message isNotifaction:(BOOL)flag;
#pragma mark 插入数据
-(BOOL)insertWithMessage:(EMessages *)message;
#pragma mark 插入数据是否通知
-(BOOL)insertWithMessage:(EMessages *)message isNotifaction:(BOOL)flag;
#pragma mark 删除数据
-(BOOL)deleteMessage:(NSString*)guid;
#pragma mark 删除全部数据
-(void)deleteAllMessage;
#pragma mark 设置信息为已读或者未读
-(void)setMessageStateWithIsRead:(BOOL)isRead;
#pragma mark 获取未读总数
-(int)getUnReadCountWithJID:(NSString *)myJID;
#pragma mark 获取未发送消息
-(NSArray *)getUnSendedMessages;
#pragma mark 获取图片标识的消息
-(NSArray *)getImageTypeMessages;

@end
