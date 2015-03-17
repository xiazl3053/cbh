//
//  EFriendsAndRoomsOpration.m
//  21cbh_iphone
//
//  Created by qinghua on 14-8-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "EFriendsAndRoomsOpration.h"
#import "EFriendsDB.h"
#import "EFriends.h"
#import "ERoomsDB.h"
#import "ERoom.h"
#import "XMPPServer.h"

@interface EFriendsAndRoomsOpration()
{
    BOOL isGetRooms;
    BOOL isGetFriends;
    NSMutableArray* roomsArray_;
    NSMutableArray* friendsArray_;
}

@end

static EFriendsAndRoomsOpration* singleton=nil;

@implementation EFriendsAndRoomsOpration

+(EFriendsAndRoomsOpration *)instance{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[EFriendsAndRoomsOpration alloc] init];
        }
    }
    return singleton;
    
}

+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

-(id)init
{
    if(self=[super init])
    {
        roomsArray_=[NSMutableArray array];
        friendsArray_=[NSMutableArray array];
    }
    return self;
}

#pragma mark - 好友
#pragma mark -获取好友列表
-(NSArray *)FriendsArray{
    if(!isGetFriends)
    {
        //isGetFriends=YES;
        friendsArray_=[[EFriendsDB sharedEFriends]getFriendsWithMyJID:KUserJID];
    }
    return friendsArray_;
}

#pragma mark -获取好友信息
-(EFriends *)getFriendWithJid:(NSString *)jid{
    for (EFriends *obj in friendsArray_) {
        if ([obj.jid isEqual:jid]) {
            return obj;
        }
    }
    return nil;
}

#pragma mark -删除好友
-(void)delFriendWithJid:(NSString *)jid{
    for (int i=0; i<friendsArray_.count; i++) {
        EFriends *friend=friendsArray_[i];
        if ([friend.jid isEqual:jid]) {
            [friendsArray_ removeObject:friend];
            [[EFriendsDB sharedEFriends]deleteWithFriend:friend];
            [self sendNotication:friend];
        }
    }
}

#pragma mark -插入好友
-(void)insertFriendWithFriend:(EFriends *)friend{
    [friendsArray_ addObject:friend];
    [[EFriendsDB sharedEFriends] insertWithFriend:friend];
    [self sendNotication:friend];
}

#pragma mark -更新好友
-(void)updateFriendWithFriend:(EFriends *)friend{
    for (int i=0; i<friendsArray_.count; i++) {
        EFriends *ef=friendsArray_[i];
        if ([ef.jid isEqual:friend.jid]) {
            [friendsArray_ removeObject:ef];
            [friendsArray_ addObject:friend];
            [[EFriendsDB sharedEFriends]updateWithFriend:ef];
            [self sendNotication:ef];
        }
    }
}

#pragma mark -更改好友状态
-(void)setFriendShield:(NSString *)jid{
    for (int i=0; i<friendsArray_.count; i++) {
        EFriends *ef=friendsArray_[i];
        if ([ef.jid isEqual:jid]) {
            ef.isShield=!ef.isShield;
            [[EFriendsDB sharedEFriends]updateWithFriend:ef];
            [self sendNotication:ef];
        }
    }
}

#pragma mark -是否是好友
-(BOOL)isFriend:(NSString *)jid{
    EFriends *ef= [self getFriendWithJid:jid];
    return ef.isFriend?YES:NO;
}

#pragma mark -是否是好友
-(BOOL)isExist:(EFriends *)friend{
    EFriends *ef= [self getFriendWithJid:friend.jid];
    return ef?YES:NO;
}

#pragma mark -房间
#pragma mark - 获取房间列表
-(NSArray *)RoomsArray{
    if(!isGetRooms)
    {
        isGetRooms=YES;
        roomsArray_=[[ERoomsDB sharedInstance]getRoomsWithMyJID:KUserJID];
    }
    return roomsArray_;
}

#pragma mark -获取房间信息
-(ERoom *)getRoomWithJid:(NSString *)jid{
    for (ERoom *obj in roomsArray_) {
        if ([obj.jid isEqual:jid]) {
            return obj;
        }
    }
    return nil;
}

#pragma mark -插入房间
-(void)insertRoomWithRoom:(ERoom *)room{
    [roomsArray_ addObject:room];
    [[ERoomsDB sharedInstance] insertWithRoom:room];
}

#pragma mark -更新房间
-(void)updateRoomWithRoom:(ERoom *)room{
    for (int i=0; i<roomsArray_.count; i++) {
        ERoom *temp=roomsArray_[i];
        if ([temp.jid isEqual:room.jid]) {
            [roomsArray_ removeObject:temp];
            [roomsArray_ addObject:room];
            [[ERoomsDB sharedInstance]updateWithRoom:room];
        }
    }
}


#pragma mark -删除好友
-(void)delRoomWithJid:(NSString *)jid{
    for (int i=0; i<roomsArray_.count; i++) {
        ERoom *room=roomsArray_[i];
        if ([room.jid isEqual:jid]) {
            [friendsArray_ removeObject:room];
            [[ERoomsDB sharedInstance]deleteWithRoom:room];
           // [self sendNotication:room];
        }
    }
}


#pragma mark -更改群状态
-(void)setRoomShield:(NSString *)jid{
    for (int i=0; i<roomsArray_.count; i++) {
        ERoom *room=roomsArray_[i];
        if ([room.jid isEqual:jid]) {
            room.isShield=!room.isShield;
            [[ERoomsDB sharedInstance]updateWithRoom:room];
            //[self sendNotication:room];
        }
    }
}

#pragma mark -发送通知刷新
-(void)sendNotication:(EFriends *)friend{
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPFriendsChangeNotifaction
                                                       object:nil
                                                     userInfo:[NSDictionary dictionaryWithObject:friend forKey:@"friends"]];
}

@end
