//
//  ChatLogIn.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-7-23.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ChatLogIn.h"
#import "CommonOperation.h"
#import "XMPPServer.h"
#import "XinWenHttpMgr.h"

static ChatLogIn *_cl;

@implementation ChatLogIn

+(ChatLogIn *)getId{
    if (_cl) {
        return _cl;
    }
    _cl=[[ChatLogIn alloc] init];
    return _cl;
}


#pragma mark 自动登陆
-(void)autoLogin{
    //启动openFire
    [XMPPServer sharedServer];
    
    //是否有登陆状态
    NSString *token=[[CommonOperation getId] getToken];
    if (!token) {
        return;
    }
    
    //检查是否有绑定手机
    NSString *phoneNum=[UserModel um].phoneNum;
    if (!phoneNum||phoneNum.length<11) {//用户没绑定了手机
        return;
    }
    
    //检测token是否过期
    _chatLoginBlock=^(BOOL isvalid){
        NSLog(@"进入自动登陆的bolock--------------------------");
        
        if (isvalid) {//token有效
            [XMPPServer sharedServer].isManual=NO;
            //连接openFire
            [[XMPPServer sharedServer] connect];
        }
    };
    
    //检查token的有效性
    [self checkToken];
}



#pragma mark 手动登陆
-(void)manualLoginWithModel:(NewListModel *)nlm{
    
    //是否有登陆状态
    NSString *token=[[CommonOperation getId] getToken];
    if (!token) {//没登陆
        //跳转到登陆页
        [CommonOperation goTOLogin];
        return;
    }
    
    //检查是否有绑定手机
    NSString *phoneNum=[UserModel um].phoneNum;
    if (!phoneNum||phoneNum.length<11) {//用户没绑定了手机
        //跳转到绑定手机页
        [CommonOperation goToBindPhone];
        return;
    }
    
    [XMPPServer sharedServer].isManual=YES;
    //跳转到聊天主界面
    [CommonOperation goToChatViewWithModel:nlm];
    
}


#pragma mark 检测token的有效性
-(void)checkToken{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.cl=self;
    [hmgr checkToken];
}




@end
