//
//  MessageFactory.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-1.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMessages.h"
#import "NewListModel.h"

@interface SendManager : NSObject

+(SendManager *)sharedManager;

#pragma mark 生成发送纯文字消息
-(EMessages *)textMessageCreater:(NSString *)text toJID:(NSString *)toJID;
#pragma mark 生成发送新闻消息
-(EMessages *)newsMessageCreater:(NewListModel*)model toJID:(NSString *)toJID;
#pragma mark 生成发送图片消息
-(EMessages *)imageMessageCreater:(UIImage*)image toJID:(NSString *)toJID isPng:(BOOL)isPng isScale:(BOOL)isScale;
#pragma mark 生成发送股票消息
-(EMessages *)HQMessageCreater:(NSString *)kId kType:(NSString *)kType kName:(NSString*)kName toJID:(NSString *)toJID;
#pragma mark 生成基本的消息属性
-(void)messageInfo:(EMessages*)message toJID:(NSString *)toJID;

#pragma mark 发送Message消息
-(void)sendMessageWithMessage:(EMessages *)msg roomJID:(NSString*)roomJID;
#pragma mark 发送待上传的图片消息
-(void)sendMessageWithImage:(EMessages *)msg;
#pragma mark 发送已上传的图片消息
-(void)sendUploadCompleteMessage:(EMessages *)msg roomJID:(NSString*)roomJID;

@end
