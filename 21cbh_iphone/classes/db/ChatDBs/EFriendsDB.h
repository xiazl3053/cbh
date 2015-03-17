//
//  EFriendsDB.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EFriends;

@interface EFriendsDB : NSObject

+(EFriendsDB *)sharedEFriends;

#pragma mark -插入好友信息
-(void)insertWithFriend:(EFriends *)friend;
#pragma mark 删除数据
-(void)deleteWithFriend:(EFriends *)friend;
#pragma mark 更新数据
-(void)updateWithFriend:(EFriends *)friend;
#pragma mark -查询好友列表
-(NSMutableArray *)getFriendsWithMyJID:(NSString*)myJID;
#pragma mark -查询好友信息
-(EFriends *)getFriendsWithJID:(NSString*)JID;
#pragma mark -好友是否存在
-(BOOL)isExistFriends:(EFriends *)friend;

@end
