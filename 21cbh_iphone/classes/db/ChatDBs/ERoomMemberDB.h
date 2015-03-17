//
//  EGroupsDB.h
//  21cbh_iphone
//
//  Created by qinghua on 14-8-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ERoomMemberModel;
@class EFriends;
@interface ERoomMemberDB : NSObject

+(ERoomMemberDB *)sharedInstance;

#pragma mark -插入群成员
-(void)insertWithMember:(ERoomMemberModel *)member;
#pragma mark -插入群成员
-(void)insertWithMemberList:(NSArray *)memberList;
#pragma mark -获取群成员
-(NSMutableArray *)getGroupMemberWithRoomJid:(NSString*)jid;
#pragma mark -判断群成员
-(BOOL)isExistMember:(EFriends *)friends andRoomJid:(NSString *)roomJid;
#pragma mark 更新数据
-(void)updateWithFriend:(ERoomMemberModel *)group;
@end
