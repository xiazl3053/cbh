//
//  ChatDetailViewController.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"
#import "EFriends.h"
@class NewListModel;

typedef void(^clearNewListModel)(void);

@interface ChatDetailViewController : BaseViewController
<UITableViewDataSource,UITableViewDelegate>
{
    EFriends* chatFriend_;
    NSString* roomName_;
    NSString* roomJID_;
}

@property (nonatomic,retain) NewListModel* currentModel;
@property (nonatomic,copy) clearNewListModel clearModelBlock;

#pragma 单聊的跳转
-(id)initWithFriend:(EFriends*)tofriend;
#pragma 群聊的跳转
-(id)initWithRoomWithJID:(NSString*)roomJID roomName:(NSString*)roomName;

@end
