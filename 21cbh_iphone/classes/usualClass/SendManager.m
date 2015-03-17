//
//  MessageFactory.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-1.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "SendManager.h"
#import "CommonOperation.h"
#import "UIImage+Custom.h"
#import "XMPPServer.h"
#import "ESessions.h"
#import "ESessionsDB.h"
#import "EMessagesDB.h"
#import "UserModel.h"

@implementation SendManager

static SendManager* singleton=nil;

+(SendManager *)sharedManager{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[self alloc] init];
        }
    }
    return singleton;
    
}

+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

-(XMPPMessage *)sendMessageCreater:(EMessages *)msg roomJID:(NSString *)roomJID
{
    XMPPMessage *message;
    if(!roomJID){
        message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:msg.friends_jid resource:KXMPPResource]];
    }else{
        msg.isGroup=YES;
        //NSString* roomJid = [NSString stringWithFormat:@"%@@conference.%@",roomName,KXMPPDomain];
        message=[XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomJID]];
    }
    
    //[message addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",msg.myJID]];
    [message addAttributeWithName:@"id" stringValue:msg.guid];
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
    [dic setValue:msg.userName forKeyPath:@"invite"];
    [dic setValue:msg.content forKey:@"content"];
    [dic setValue:[NSString stringWithFormat:@"%d",msg.messageType] forKey:@"messageType"];
    
    switch (msg.messageType) {
        case 0://普通文字
            break;
        case 1://图片
        {
            if(msg.picUrls&&msg.picUrls.count>0){
                NSMutableDictionary* newdic=[NSMutableDictionary dictionaryWithDictionary:msg.picUrls];
                [newdic removeObjectForKey:DSelfUpLoadImg];
                NSString* newjson=[newdic JSONRepresentation];
                [dic setValue:newjson forKey:@"picUrls"];
            }
        }
            break;
        case 2://语音
            break;
        case 3://股票
        {
            [dic setValue:msg.KId forKey:@"KId"];
            [dic setValue:msg.KType forKey:@"KType"];
        }
            break;
        case 4://新闻资讯
        case 5://专题
        case 6://图集
        {
            [dic setValue:msg.programId forKey:@"programId"];
            [dic setValue:msg.articleId forKey:@"articleId"];
            if(msg.picUrls){
                NSArray* array=[msg.picUrls objectForKey:DNewsLogoImg];
                if(array&&array.count>0){
                    [dic setValue:[array objectAtIndex:0] forKey:@"picUrl"];
                }
            }
            [dic setValue:msg.msgDesc forKey:@"description"];
        }
            break;
        default:
            break;
    }
    NSString* json=[dic JSONRepresentation];
    [message addBody:json];
    return message;
}

-(EMessages *)textMessageCreater:(NSString *)text toJID:(NSString *)toJID
{
    EMessages* message=[[EMessages alloc]init];
    message.content = text;
    message.messageType=0;
    [self messageInfo:message toJID:toJID];
    return message;
}

-(EMessages *)newsMessageCreater:(NewListModel*)model toJID:(NSString *)toJID
{
    EMessages* message=[[EMessages alloc]init];
    message.programId=model.programId;
    int type=[model.type integerValue];
    switch (type) {
        default:
        case 0:
        case 1:
        case 5:
        {
            message.articleId=model.articleId;
            message.messageType=4;
        }
            break;
        case 2:
        {
            message.articleId=model.specialId;
            message.messageType=5;
        }
            break;
        case 3:
        {
            message.articleId=model.picsId;
            message.messageType=6;
        }
            break;
    }
    
    message.content=model.title;
    message.msgDesc=model.desc;
    if(model.picUrls&&model.picUrls.count>0)
    {
        message.picUrls=[NSDictionary dictionaryWithObject:model.picUrls forKey:DNewsLogoImg];
    }
    [self messageInfo:message toJID:toJID];
    return message;
}

-(EMessages *)imageMessageCreater:(UIImage*)image toJID:(NSString *)toJID isPng:(BOOL)isPng isScale:(BOOL)isScale
{
    CGSize size=[UIImage fitSize:image.size inSize:CGSizeMake(100, 100)];
    EMessages* message=[[EMessages alloc]init];
    message.content=@"[图片]";
    message.messageType=1;
    [self messageInfo:message toJID:toJID];
    NSString* pictureUrl=[self saveUpLoadPicWithPath:message.guid image:image isPng:isPng isScale:isScale];
    if(pictureUrl)
    {
        NSMutableDictionary* picDic=[NSMutableDictionary dictionary];
        [picDic setObject:[NSString stringWithFormat:@"%f",size.width] forKey:@"width"];
        [picDic setObject:[NSString stringWithFormat:@"%f",size.height] forKey:@"height"];
        [picDic setObject:pictureUrl forKey:@"url"];
        
        message.picUrls=[NSDictionary dictionaryWithObject:picDic forKey:DSelfUpLoadImg];
    }
    
    return message;
}

-(EMessages *)HQMessageCreater:(NSString *)kId kType:(NSString *)kType kName:(NSString*)kName toJID:(NSString *)toJID
{
    EMessages* message=[[EMessages alloc]init];
    message.content = @"[股票行情]";
    message.messageType=3;
    message.KId=kId;
    message.KType=kType;
    message.KName=kName;
    [self messageInfo:message toJID:toJID];
    return message;
}

-(void)messageInfo:(EMessages*)message toJID:(NSString *)toJID
{
    message.guid=[CommonOperation stringWithGUID];
    message.time = [[NSDate date] timeIntervalSince1970];
    message.isSelf = YES;
    message.isRead=YES;
    message.friends_jid=toJID;
    message.myJID=KUserJID;
    message.userName=[UserModel um].nickName!=nil?[UserModel um].nickName:[UserModel um].userName;
}

-(NSString*)saveUpLoadPicWithPath:(NSString*)key image:(UIImage*)image isPng:(BOOL)isPng isScale:(BOOL)isScale
{
    NSData* data;
    if(isPng){
        data=UIImagePNGRepresentation(image);
    }else{
        data=UIImageJPEGRepresentation(image, isScale?0.5:0.8);
    }
    NSString* path=[KDataCacheDocument stringByAppendingPathComponent:@"upload"];
    if (data) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        NSString* fileName=[[path stringByAppendingPathComponent:key] stringByAppendingPathExtension:isPng?@"png":@"jpg"];
        [fileManager createFileAtPath:fileName contents:data attributes:nil];
        return fileName;
    }
    return nil;
}

-(void)sendMessageWithMessage:(EMessages *)msg roomJID:(NSString*)roomJID
{
    XMPPMessage *message=[self sendMessageCreater:msg roomJID:roomJID];
    
    if (!msg.myJID) {
        msg.myJID = KUserJID;
    }
    
    // 插入数据库
    [[EMessagesDB instanceWithFriendJID:msg.friends_jid] insertWithMessage:msg];
    
    [self startSendMessage:message eMessage:msg];
}

-(void)sendMessageWithImage:(EMessages *)msg
{
    if (!msg.myJID) {
        msg.myJID = KUserJID;
    }
    
    // 插入数据库
    [[EMessagesDB instanceWithFriendJID:msg.friends_jid] insertWithMessage:msg];
}

-(void)sendUploadCompleteMessage:(EMessages *)msg roomJID:(NSString*)roomJID
{
    XMPPMessage *message=[self sendMessageCreater:msg roomJID:roomJID];

    [self startSendMessage:message eMessage:msg];
}

-(void)startSendMessage:(XMPPMessage *)message eMessage:(EMessages *)msg
{
//    [[XMPPServer sharedServer] sendElement:message completed:^(NSDictionary *dictionary, BOOL finished)
//    {
//        msg.isSend=finished;
//        if(finished)
//        {
//            [[EMessagesDB instanceWithFriendJID:msg.friends_jid] updateWithMessage:msg];
//        }
//    }];
    
    XMPPElementReceipt* recript;
    [[XMPPServer sharedServer] sendElement:message andGetReceipt:&recript completed:^(NSDictionary *dictionary, BOOL finished)
    {
        
    }];
    
    if([recript wait:-1])
    {
        NSLog(@"发送成功");
        msg.isSend=YES;
        [[EMessagesDB instanceWithFriendJID:msg.friends_jid] updateWithMessage:msg];
    }
    else
    {
        NSLog(@"发送失败");
    }
}

@end
