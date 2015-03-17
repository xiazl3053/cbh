//
//  EFriends.m
//  DFMMessage
//
//  Created by 21tech on 14-5-27.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "EFriends.h"
#import "XMPPServer.h"


@implementation EFriends

-(id)initWithNSDictionary:(NSDictionary *)dic{

    if (self=[super init]) {
        self.location=[dic objectForKey:@"Location"];
        if (!self.location) {
            self.location=@"";
        }
        self.nickName=[dic objectForKey:@"nickName"];
        if (!self.nickName) {
            self.nickName=@"";
        }
        self.note=[dic objectForKey:@"signature"];
        if (!self.note) {
            self.note=@"";
        }
        self.telephone=[dic objectForKey:@"telephone"];
        if (!self.telephone) {
            self.telephone=@"";
        }
        self.jid=[dic objectForKey:@"userJid"];
        if (!self.jid) {
            self.jid=@"";
        }
        self.userName=[dic objectForKey:@"userName"];
        if (!self.userName) {
            self.userName=@"";
        }
        self.UUID=[dic objectForKey:@"uuid"];
        if (!self.UUID) {
            self.UUID=@"";
        }
        self.iconUrl=[dic objectForKey:@"picUrl"];
        if (!self.iconUrl) {
            self.iconUrl=[NSString stringWithFormat:@"%@&uuid=%@&size=%d",kURL(@"avatar"),self.UUID,135];
        }
        self.isShield=NO;
        self.myJID=KUserJID;
    }
    
    return self;
}

@end
