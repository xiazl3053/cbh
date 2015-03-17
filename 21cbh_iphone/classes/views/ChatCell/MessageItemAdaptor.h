//
//  MessageItemAdaptor.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMessages.h"
#import "EFriends.h"

static const NSString* mProgramId=@"programId";
static const NSString* mArticleId=@"articleId";

typedef enum{
    TextMessage=0,//文字
    ImageMessgae=1,//图片
    VoiceMessage=2,//语音
    HQMessage=3,//股票
    NewsMessage=4,//新闻消息
    SpecialMessage=5,//专题消息
    PicsMessage=6,//图集消息
}MessageType;

@interface MessageItemAdaptor : NSObject

@property (nonatomic,retain,readonly) NSString* guId;
@property (nonatomic,assign) BOOL isSelf;
@property (nonatomic,assign) BOOL isSend;
@property (nonatomic,assign,readonly) BOOL isSys;
@property (nonatomic,assign) BOOL isGroup;
@property (nonatomic,assign) MessageType msgType;
@property (nonatomic,retain) NSString* msgContent;
@property (nonatomic,retain) NSMutableAttributedString* currentContentAttributedString;
@property (nonatomic,retain) NSString* userName;
@property (nonatomic,retain) NSString* fromJID;
@property (nonatomic,retain) NSString* timeSpan;
@property (nonatomic,retain) NSString* description;
@property (nonatomic,retain) NSDate* timeInterval;
@property (nonatomic,retain) UIFont* font;
@property (nonatomic,copy) NSMutableArray* emjios;
@property (nonatomic,strong) NSDictionary* picUrls;
@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) CGSize contentSize;//文本文字整体Size
@property (nonatomic) BOOL isHideTime;//列表中是否隐藏时间
@property (nonatomic,retain) NSString* headUrl;

-(id)initWithMessage:(EMessages*)message;
#pragma 更新已经上传好的图片消息
-(void)updateMessageWithUploadImg:(NSDictionary*)dic finished:(void(^)(EMessages* msg))block;
#pragma 更新已经下载好行情信息数据消息
-(void)updateMEssageWithHQValue:(NSDictionary*)dic finished:(void(^)(EMessages* msg))block;
#pragma 获取当前所需的数据字典
-(NSDictionary*)getCurrentIdDic;
#pragma 判断消息是否已经发送失败
-(BOOL)isTimeOut;

-(EMessages*)newMessage;//用户重发消息

@end
