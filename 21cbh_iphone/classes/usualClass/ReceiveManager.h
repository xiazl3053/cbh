//
//  ReceiveManager.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPServer.h"

@interface ReceiveManager : NSObject

+(ReceiveManager *)sharedManager;

-(void)setupRoster:(XMPPStream*)xmppStream deleagte:(id)delegate;
-(void)releaseRoster;

#pragma mark - 接收Message包处理方法
-(void)receiveXmppMessage:(XMPPMessage *)message;
#pragma mark - 接收Message包处理方法并且回调
-(void)receiveXmppMessage:(XMPPMessage *)message completedBlock:(XMPPCompletedBlock)completedBlock;
#pragma mark - 接收Iq包处理方法
-(void)receiveXmppIQ:(XMPPIQ *)iq;
#pragma mark - 接收Iq包处理方法带回调方法
-(void)receiveXmppIQ:(XMPPIQ *)iq completedBlock:(XMPPCompletedBlock)completedBlock;

#pragma mark - 接收Presence包处理方法
-(void)receiveXmppPresence:(XMPPPresence *)presence;

@end
