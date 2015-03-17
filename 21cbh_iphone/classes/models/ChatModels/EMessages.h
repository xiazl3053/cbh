//
//  EMessages.h
//  DFMMessage
//
//  Created by 21tech on 14-5-27.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DNewsLogoImg @"newLogoImg"
#define DSelfUpLoadImg @"selfUpLoadImg"
#define DSamllPic @"pictue_small"
#define DLargePic @"pictue_large"

@interface EMessages : NSObject

@property (nonatomic, retain) NSString* myJID;
@property (nonatomic, retain) NSString* friends_jid;
@property (nonatomic, retain) NSString* userName;       //用户昵称
@property (nonatomic, retain) NSString* content;
@property (nonatomic, assign) double time;
@property (nonatomic, assign) NSInteger messageType;    // 0普通消息  1图片 2语音 3股票 4新闻资讯 5专题 6图集 99邀请消息
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) double wavSecond;         // 录音的时间长度
@property (nonatomic, assign) BOOL isRead;              // 是否已读 1=已读
@property (nonatomic, assign) BOOL isSend;              // 发送是否成功
@property (nonatomic, assign) BOOL isGroup;             // 是否群聊
@property (nonatomic, assign) BOOL isSys;               // 是否系统消息
@property (nonatomic, retain) NSString *guid;           // GUID
@property (nonatomic, retain) NSDictionary* picUrls;         //保存图片地址
@property (nonatomic, retain) NSString* msgDesc;    //描述信息,图片的Size

@property (nonatomic, retain) NSString* programId;      //栏目ID
@property (nonatomic, retain) NSString* articleId;      //文章ID
@property (nonatomic, retain) NSString* KId;            //股票ID
@property (nonatomic, retain) NSString* KType;          //股票Type
@property (nonatomic, retain) NSString* KName;          //股票名称
@property (nonatomic, retain) NSString* resource;       //消息来源

@property (nonatomic, retain) NSDictionary* otherData;

@end
