//
//  ESessions.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ESession_TYPE){
    EsesionPrivateChat=0,
    EsesionPublicGroup=1,
    

};

@interface ESessions : NSObject

@property (nonatomic, retain) NSString * jid;           // 用户JID
@property (nonatomic, retain) NSString * myJID;         // 本地登陆用户的JID
@property (nonatomic, retain) NSString * content;       // 内容
@property (nonatomic, retain) NSString *sessionName;    // 会话名称
@property (nonatomic, assign) double time;              // 会话生成时间
@property (nonatomic, assign) BOOL isShiled;            // 是否屏蔽
@property (nonatomic, retain) NSString *nickName;       // 最后消息昵称
@property (nonatomic, retain) NSString *message_time;   // 消息时间
@property (nonatomic, assign) ESession_TYPE session_type;
@property (nonatomic, assign) BOOL isTop;               // 是否置顶
@property (nonatomic, assign) int unReadCount;              // 未读数

@end
