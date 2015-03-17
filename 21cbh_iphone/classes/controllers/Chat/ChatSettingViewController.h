//
//  ChatSettingViewController.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"
#import "EFriends.h"

@protocol ChatSettingDelegate <NSObject>

-(void)cleanAllMessage;

@end

@interface ChatSettingViewController : BaseViewController

@property (nonatomic,assign) id<ChatSettingDelegate> delegate;

-(id)initWithEFriend:(EFriends*)efriend;
-(id)initWithRoom:(NSString*)roomName;

@end
