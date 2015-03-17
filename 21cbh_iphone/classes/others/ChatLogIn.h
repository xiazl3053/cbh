//
//  ChatLogIn.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-7-23.
//  Copyright (c) 2014年 ZX. All rights reserved.
//  该类主要做聊天的自动登陆和手动登陆
//

#import <Foundation/Foundation.h>
#import "NewListModel.h"

typedef void (^ChatLoginBlock) (BOOL isvalid);

@interface ChatLogIn : NSObject

@property(copy,nonatomic)ChatLoginBlock chatLoginBlock;

+(ChatLogIn *)getId;


#pragma mark 自动登陆
-(void)autoLogin;

#pragma mark 手动登陆
-(void)manualLoginWithModel:(NewListModel *)nlm;




@end
