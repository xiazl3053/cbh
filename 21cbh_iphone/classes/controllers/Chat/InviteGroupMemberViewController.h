//
//  InviteGroupMemberViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-8-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ContactBaseViewController.h"

typedef NS_ENUM(NSInteger, InviteTYPE) {
    InviteTYPE_CHAT,
    InviteTYPE_ROOM
};

typedef void(^InviteGroupMemberBlock)(NSString *status);

@interface InviteGroupMemberViewController : ContactBaseViewController

-(id)initWithJid:(NSString *)jid andType:(InviteTYPE )type;

@property (nonatomic,strong) UINavigationController *nav;

@property (nonatomic,copy)  InviteGroupMemberBlock completionBlock;


@end
