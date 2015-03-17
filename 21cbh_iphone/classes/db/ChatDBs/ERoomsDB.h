//
//  ERoomsDB.h
//  21cbh_iphone
//
//  Created by qinghua on 14-8-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ERoom;

@interface ERoomsDB : NSObject

+(ERoomsDB *)sharedInstance;


@property (nonatomic,assign) BOOL isShield;

#pragma mark -插入好友信息
-(void)insertWithRoom:(ERoom *)room;
#pragma mark 删除数据
-(void)deleteWithRoom:(ERoom *)room;
#pragma mark 更新数据
-(void)updateWithRoom:(ERoom *)room;
#pragma mark -查询好友列表
-(NSMutableArray *)getRoomsWithMyJID:(NSString*)myJID;
#pragma mark -查询好友信息
-(ERoom *)getRoomWithJID:(NSString*)roomJid;
#pragma mark -好友是否存在
-(BOOL)isExistRoom:(ERoom *)room;

@end
