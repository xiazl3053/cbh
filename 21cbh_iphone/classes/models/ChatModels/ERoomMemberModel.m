//
//  EGroupMember.m
//  21cbh_iphone
//
//  Created by qinghua on 14-8-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ERoomMemberModel.h"
#import "EFriends.h"
#import "XMPPServer.h"

@implementation ERoomMemberModel

-(id)initWithNSDictionary:(NSDictionary *)dic{
    if (self=[super init]) {
        self.roomJid=[dic objectForKey:@"roomJid"];
        if (self.roomJid==nil) {
            self.roomJid=@"";
        }
        self.member=[[EFriends alloc]init];
        self.member.myJID=KUserJID;
        self.member.nickName=[dic objectForKey:@"nickName"];
        if (self.member.nickName==nil) {
            self.member.nickName=@"";
        }
        self.member.jid=[dic objectForKey:@"userJid"];
        if (self.member.jid==nil) {
            self.member.jid=@"";
        }
        self.member.userName=[dic objectForKey:@"userName"];
        if (self.member.userName==nil) {
            self.member.userName=@"";
        }
        self.member.UUID=[dic objectForKey:@"uuid"];
        if (self.member.UUID==nil) {
            self.member.UUID=@"";
        }
        
        self.member.iconUrl=[NSString stringWithFormat:@"%@&uuid=%@&size=%d",kURL(@"avatar"),self.member.UUID,135];
//        self.member.iconUrl=[dic objectForKey:@"picUrl"];
//        if (self.member.iconUrl==nil) {
//            
//        }
        
    }
    return self;
}

-(id)initWithNSDictionary:(NSDictionary *)dic andRoomJID:(NSString *)roomJid{

    if (self=[super init]) {
        
        self.roomJid=roomJid;
        
        self.member=[[EFriends alloc]init];
        self.member.myJID=KUserJID;
        
        self.member.nickName=[dic objectForKey:@"nickName"];
        if (self.member.nickName==nil) {
            self.member.nickName=@"";
        }
        self.member.jid=[dic objectForKey:@"jid"];
        if (self.member.jid==nil) {
            self.member.jid=@"";
        }
        self.member.userName=[dic objectForKey:@"nickName"];
        if (self.member.userName==nil) {
            self.member.userName=@"";
        }
        
        self.member.UUID=[[self.member.jid componentsSeparatedByString:@"@"]objectAtIndex:0];
        if (self.member.UUID==nil) {
            self.member.UUID=@"";
        }
        
        self.member.iconUrl=[NSString stringWithFormat:@"%@&uuid=%@&size=%d",kURL(@"avatar"),self.member.UUID,135];
        
    }
    return self;

}

@end
