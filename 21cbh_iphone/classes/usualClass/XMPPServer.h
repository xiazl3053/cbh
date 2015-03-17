//
//  XMPPServer.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#define KUserJID [XMPPServer sharedServer].myJID.bare
#define KUserName [XMPPServer sharedServer].myJID.user

@protocol XMPPServerDelegate <NSObject>
-(void)setupStream;
-(void)getOnline;
-(void)getOffline;
@end

typedef void(^XMPPCompletedBlock)(NSDictionary* dictionary, BOOL finished);

@interface XMPPServer : NSObject<XMPPServerDelegate,XMPPRosterDelegate,XMPPvCardTempModuleDelegate>{
    XMPPStream *xmppStream;
    NSString *password;
}

@property(assign,nonatomic,readonly)BOOL isOpen;//判断socket是否连接
@property(assign,nonatomic,readonly)BOOL isAuthorized;//判断账号socket是否授权成功
@property(assign,nonatomic)BOOL isManual;//是否是手动登陆
@property (assign, nonatomic) NSTimeInterval xmppTimeout;

+(XMPPServer *)sharedServer;

-(BOOL)connect;

-(void)disconnect;

-(void)sendElement:(NSXMLElement *)element;
-(void)sendElement:(NSXMLElement *)element completed:(XMPPCompletedBlock)completedBlock;

-(void)sendElement:(NSXMLElement *)element andGetReceipt:(XMPPElementReceipt **)receiptPtr;
-(void)sendElement:(NSXMLElement *)element andGetReceipt:(XMPPElementReceipt **)receiptPtr completed:(XMPPCompletedBlock)completedBlock;

-(XMPPJID*)myJID;
@end
