//
//  Instance.h
//  21cbh_iphone
//
//  Created by Franky on 14-8-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ESessions;
@class EFriends;

#define INSTANCE [SessionInstance instance]

static const NSString* kSessionChangeType=@"SessionChangeType";

typedef enum 
{
    kSessionNewMsg=0,
    kSessionUpdate=1,
    kSessionDelete=2,
    kSessionUnRead=3,
}SessionChangeType;

//获取、保存本地数据逻辑实体单例
@interface SessionInstance : NSObject

@property (nonatomic,retain,readonly) NSArray* ContactArrays;//执行getAddressBook方法后这里返回本地通讯录地址
@property (nonatomic,retain,readonly) NSArray* SessionArray;
@property (nonatomic,retain) NSString* currentJID;

+(SessionInstance*)instance;

#pragma 获取未读消息总数
-(int)totalUnReadCount;
#pragma 获取本地通讯录地址列表方法（耗时）
-(void)getAddressBook;

#pragma 更新会话未读数
-(void)updateUnReadCount:(ESessions*)session count:(int)count;
#pragma 通过JID查找Session
-(ESessions*)getSession:(NSString*)friends_jid;
#pragma 更新Session使用到的好友信息
-(void)updateSessionWithFriend:(EFriends*)efriends;
#pragma 更新Session置顶和消息提醒的属性 YES取反，NO不变
-(void)updateSession:(NSString*)friends_jid myJID:(NSString*)myJID isShield:(BOOL)isShield isTop:(BOOL)isTop;
#pragma 清空Session最后消息内容
-(void)cleanSessionLast:(NSString*)friends_jid;
#pragma 删除Session
-(void)deleteSession:(ESessions*)session;

@end
