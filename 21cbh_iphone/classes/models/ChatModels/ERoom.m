//
//  GroupModel.m
//  21cbh_iphone
//
//  Created by qinghua on 14-7-30.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ERoom.h"
#import "XMPPServer.h"

@implementation ERoom

-(id)initWithNSDictionary:(NSDictionary *)dic{
    if (self=[super init]) {
        self.desc=[dic objectForKey:@"roomDesc"];
        self.jid=[dic objectForKey:@"roomJid"];
        self.name=[dic objectForKey:@"roomName"];
        self.myJID=KUserJID;
    }
    return self;
}

@end
