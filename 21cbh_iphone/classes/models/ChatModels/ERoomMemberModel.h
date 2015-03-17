//
//  EGroupMember.h
//  21cbh_iphone
//
//  Created by qinghua on 14-8-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EFriends;
@interface ERoomMemberModel : NSObject
@property (nonatomic,copy) NSString *roomJid;
@property (nonatomic,strong) EFriends *member;

-(id)initWithNSDictionary:(NSDictionary *)dic;
-(id)initWithNSDictionary:(NSDictionary *)dic andRoomJID:(NSString *)roomJid;

@end
