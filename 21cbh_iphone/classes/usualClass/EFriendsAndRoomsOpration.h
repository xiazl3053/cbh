//
//  EFriendsAndRoomsOpration.h
//  21cbh_iphone
//
//  Created by qinghua on 14-8-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EFriends;
@class ERoom;

@interface EFriendsAndRoomsOpration : NSObject

@property (nonatomic,retain) NSArray *FriendsArray;//好友列表
@property (nonatomic,retain) NSArray *RoomsArray;//群列表


+(EFriendsAndRoomsOpration *)instance;
#pragma mark -获取好友列表
-(NSArray *)FriendsArray;
#pragma mark -获取好友信息
-(EFriends *)getFriendWithJid:(NSString *)jid;
#pragma mark -插入好友
-(void)insertFriendWithFriend:(EFriends *)friend;
#pragma mark -删除好友
-(void)delFriendWithJid:(NSString *)jid;
#pragma mark -更新好友
-(void)updateFriendWithFriend:(EFriends *)friend;
#pragma mark -是否是好友
-(BOOL)isFriend:(NSString *)jid;
#pragma mark -是否是好友
-(BOOL)isExist:(EFriends *)friend;
#pragma mark -更改好友状态
-(void)setFriendShield:(NSString *)jid;

-(ERoom *)getRoomWithJid:(NSString *)jid;
#pragma mark -插入房间
-(void)insertRoomWithRoom:(ERoom *)room;
#pragma mark -更新房间
-(void)updateRoomWithRoom:(ERoom *)room;
#pragma mark -更改群状态
-(void)setRoomShield:(NSString *)jid;
#pragma mark -删除房间
-(void)delRoomWithJid:(NSString *)jid;

@end
