//
//  UserinfoAndSettingViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-8-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, UserInfomationOpenType) {
    UserInfomationOpen_TYPE_Contact=1,
    UserInfomationOpen_TYPE_AddFriend,
    UserInfomationOpen_TYPE_ChatSet,
    UserInfomationOpen_TYPE_ChatDetail,
    UserInfomationOpen_TYPE_LocalContact,

};

@class EFriends;
@interface UserinfoViewController : BaseViewController

-(id)initWithEFriends:(EFriends *)info andType:(UserInfomationOpenType)type;//type 1,contact 2,friendadd,3,chatset 4.chatdetial
-(id)initWithJid:(NSString *)jid andType:(UserInfomationOpenType )type;

@property (nonatomic,assign) BOOL isFriend;

@end
