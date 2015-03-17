//
//  XMPPRoomModel.h
//  21cbh_iphone
//
//  Created by qinghua on 14-6-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPRoom.h"
@class EFriends;


typedef void(^CreateRoomBlock)(NSDictionary *roomModel,BOOL isSucess);
typedef void(^CreateRoomJoinRoomBlock)(NSDictionary *status,BOOL isSucess);
typedef void(^QueryFriendInfomationBlock)(NSDictionary *model,BOOL isSucess);
typedef void(^QueryUserJoinRoomsListBlock)(NSDictionary *model,BOOL isSucess);
typedef void(^QueryRoomUserlistBolock)(NSDictionary *list,BOOL isSucess);
typedef void(^QueryGroupListBlock)(NSArray *model,NSInteger error);
typedef void(^ExitRoomBlock)(NSDictionary *staus,BOOL isSuccess);
typedef void(^SetPushBlock)(NSDictionary *staus,BOOL isSuccess);


typedef void(^operationBackBlock)(NSDictionary *data,BOOL isSucess);

@interface XMPPRoomManager : NSObject<XMPPRoomDelegate,XMPPRoomStorage>{

}


+(XMPPRoomManager *)instance;

#pragma  mark -创建Room
-(void)createRoom:(NSString *)roomName andUserNickName:(NSString *)nickName;
#pragma mark -requestRoomConfiguration
-(void)requestReserveRoomConfiguration:(NSString *)roomJID;
#pragma mark -配置RoomProperty
-(void)configurationRoomPreperty:(NSString *)roomJID;
#pragma mark -进入房间
-(void)intoRoom:(NSString *)roomJID;
#pragma  mark -退出房间
-(void)exitRoom:(NSString *)roomJID;
#pragma mark -邀请好友
-(void)invitedFriends:(NSString *)friendJID andRoomJID:(NSString *)roomJID;
#pragma mark -getGroupList
-(void)getGroupList:(NSString *)roomDomain;
#pragma mark -获取房间信息
-(void)getRoomInfomation:(NSString *)roomJID;
#pragma mark -getOnlyRoomID
-(void)getOnlyRoomID:(NSString *)roomDomain;
#pragma mark -TEST
-(void)getUserinfomation:(NSString *)userID;
#pragma mark -创建房间
-(void)createRoom;
#pragma mark -房间加入好友
-(void)addRoomUser:(NSArray *)userJids andRoomJid:(NSString *)roomJid;
#pragma mark -查询用户加入群列表
-(void)getUserJoinRoomsListWithUserName:(NSString *)userName;
#pragma mark -查询群列表
-(void)getRoomUsersListWithRoomJid:(NSString *)roomJid;
#pragma mark -查找好友
-(void)getFriendInfomationWithIdentifer:(NSString *)identifier;
#pragma mark -进入房间
-(void)joinRoomJid:(NSString *)roomJid;

#pragma mark -设置用户昵称
-(void)setUserNickName:(NSString *)nickName toUser:(NSString *)jid;
#pragma mark -删除好友
-(void)delUserName:(NSString *)jid;
#pragma mark -添加好友请求
- (void)addFriendSubscribe:(NSString *)jid;
#pragma mark -响应好友请求
-(void)acceptPresenceSubscriptionRequestFrom:(NSString *)name andAccept:(BOOL)b;


#pragma mark - 回调方法
#pragma mark -createRoom
-(void)createRoomUser:(NSArray *)userJids Completion:(CreateRoomBlock)createRoomBlock;
#pragma mark -addRoomuser
-(void)addRoomUser:(NSArray *)userJids andRoomJid:(NSString *)roomJid completion:(CreateRoomJoinRoomBlock)joinRoomBlock;
#pragma mark -getFriend
-(void)getFriendInfomationWithIdentifer:(NSString *)identifier completion:(QueryFriendInfomationBlock)queryFriendInfomationBlock;
#pragma mark -getUserJoinRoomsList
-(void)getUserJoinRoomsListWithUserName:(NSString *)userName completion:(QueryUserJoinRoomsListBlock)joinRoomsList;
#pragma mark -getRoomUsersListWithRoomJid
-(void)getRoomUsersListWithRoomJid:(NSString *)roomJid completion:(QueryRoomUserlistBolock)userlistBlock;
#pragma mark -退出房间
-(void)exitRoomWithjid:(NSString *)jid completion:(ExitRoomBlock )exitRoomBlock;
#pragma mark -获取好友列表
-(void)getFriendsList:(NSString *)uuid completion:(operationBackBlock)backBlock;
#pragma mark -添加好友
-(void)addFriend:(NSString *)uuid completion:(operationBackBlock)backBlock;
#pragma mark -删除好友
-(void)delFriend:(NSString *)uuid completion:(operationBackBlock)backBlock;
#pragma mark -设置用户昵称
-(void)setFriendNickName:(NSString *)nickName toFrienduuid:(NSString *)uuid completion:(operationBackBlock)backBlock;
#pragma mark -设置推送
-(void)setUserPushWithJid:(NSString *)jid type:(NSInteger )type isShield:(BOOL)b completion:(SetPushBlock)pushBlock;
#pragma mark -获取设置列表
-(void)getPushList:(NSString *)uuid completion:(operationBackBlock)backBlock;


@end
