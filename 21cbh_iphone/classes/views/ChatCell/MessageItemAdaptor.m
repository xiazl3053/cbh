//
//  MessageItemAdaptor.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MessageItemAdaptor.h"
#import "NSDate+Custom.h"
#import "NSAttributedString+Attributes.h"
#import "RegexKitLite.h"
#import "MessageInputManager.h"
#import "MarkupParser.h"
#import "UIImage+Custom.h"
#import "XMPPJID.h"

@interface MessageItemAdaptor()
{
    EMessages* messgae_;
    NSString* msgContent_;
    NSString* timeSpan_;
    CGSize contentSize_;
    int height_;
    NSMutableAttributedString* contentAttributedString_;
    NSMutableArray* emjios_;
    NSDate* timeInterval_;
    NSString* description_;
    NSString* headUrl_;
}

@end

@implementation MessageItemAdaptor

@synthesize msgContent=msgContent_;
@synthesize currentContentAttributedString=contentAttributedString_;
@synthesize timeSpan=timeSpan_;
@synthesize contentSize=contentSize_;
@synthesize height=height_;
@synthesize emjios=emjios_;
@synthesize timeInterval=timeInterval_;
@synthesize description=description_;
@synthesize headUrl=headUrl_;
@synthesize guId,userName,fromJID,picUrls;

-(id)initWithMessage:(EMessages*)message
{
    if(self=[super init]){
        messgae_=message;
        contentSize_=CGSizeZero;
        height_=0;
        emjios_=[NSMutableArray array];
        self.width=messgae_.isSelf?240:210;
        self.font=[UIFont systemFontOfSize:16.0];
    }
    return self;
}

-(int)width
{
    switch (self.msgType)
    {
        case TextMessage:
        case VoiceMessage:
        default:
            return messgae_.isSelf?240:210;
        case ImageMessgae:
            return 120;
        case HQMessage:
        case NewsMessage:
        case SpecialMessage:
        case PicsMessage:
            return self.contentSize.width+20;
    }
}

-(int)height
{
    if(height_==0)
    {
        if(self.isSys)
        {
            height_=self.contentSize.height+20;
        }
        else
        {
            switch (self.msgType)
            {
                case TextMessage:
                    height_=self.contentSize.height+40;
                    break;
                case VoiceMessage:
                    height_=30;
                    break;
                case ImageMessgae:
                    height_=self.contentSize.height+20;
                    break;
                case HQMessage:
                case NewsMessage:
                case SpecialMessage:
                case PicsMessage:
                    height_=self.contentSize.height+20;
                    break;
            }
            if(!self.isSelf&&self.isGroup)
            {
                height_+=20;
            }
        }
    }
    return height_;
}

-(NSString *)msgContent
{
    if(!msgContent_){
        msgContent_=messgae_.content;
    }
    return msgContent_;
}

-(CGSize)contentSize
{
    if(CGSizeEqualToSize(contentSize_, CGSizeZero))
    {
        contentSize_=[self calculateContentSize];
    }
    return contentSize_;
}

-(NSString *)timeSpan
{
    if(!timeSpan_||timeSpan_.length==0)
    {
        NSDate* date=[NSDate dateWithTimeIntervalSince1970:messgae_.time];
        timeSpan_=[date dateStringForShow];
    }
    return timeSpan_;
}

-(NSString *)description
{
    if(!description_)
    {
        description_=messgae_.msgDesc;
    }
    return description_;
}

-(NSDate *)timeInterval
{
    if(!timeInterval_)
    {
        timeInterval_=[NSDate dateWithTimeIntervalSince1970:messgae_.time];
    }
    return timeInterval_;
}

-(NSMutableAttributedString*)currentContentAttributedString
{
    if(!messgae_) return nil;
    if(!contentAttributedString_)
    {
        if(self.msgType==TextMessage)
        {
            NSString* text=[self transformString:messgae_.content];
            MarkupParser* parser=[[MarkupParser alloc]init];
            contentAttributedString_ = [parser attrStringFromMarkup:text images:emjios_];
            [contentAttributedString_ modifyParagraphStylesWithBlock:^(OHParagraphStyle *paragraphStyle) {
                paragraphStyle.textAlignment = kCTTextAlignmentLeft;
                paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
                paragraphStyle.paragraphSpacing = 8.f;
                paragraphStyle.lineSpacing = 3.f;
            }];
            [contentAttributedString_ setFont:self.font];
            [contentAttributedString_ setTextColor:[UIColor blackColor]];
        }
    }
    return contentAttributedString_;
}

-(BOOL)isSelf
{
    return messgae_.isSelf;
}

-(BOOL)isSend
{
    return messgae_.isSend;
}

-(BOOL)isSys
{
    return messgae_.isSys;
}

-(BOOL)isGroup
{
    return messgae_.isGroup;
}

-(NSString *)guId
{
    return messgae_.guid;
}

-(NSString *)userName
{
    return messgae_.userName;
}

-(NSString *)fromJID
{
    if(messgae_.isGroup){
        return messgae_.resource;
    }
    return messgae_.friends_jid;
}

-(NSDictionary *)picUrls
{
    return messgae_.picUrls;
}

-(MessageType)msgType
{
    switch (messgae_.messageType)
    {
        case 0:
        default:
            return TextMessage;
        case 1:
            return ImageMessgae;
        case 2:
            return VoiceMessage;
        case 3:
            return HQMessage;
        case 4:
            return NewsMessage;
        case 5:
            return SpecialMessage;
        case 6:
            return PicsMessage;
    }
}

- (CGSize)calculateContentSize
{
    CGSize size=CGSizeZero;
    if(self.isSys)
    {
        size=[self.msgContent sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByCharWrapping];
    }
    else if (self.msgType==TextMessage)
    {
        size=[self.currentContentAttributedString sizeConstrainedToSize:CGSizeMake(self.width, CGFLOAT_MAX)];
    }
    else if (self.msgType==ImageMessgae)
    {
        if(self.isSelf)
        {
            NSDictionary* dic=[self.picUrls objectForKey:DSelfUpLoadImg];
            if(dic)
            {
                float width=[[dic objectForKey:@"width"] floatValue];
                float height=[[dic objectForKey:@"height"] floatValue];
                size=CGSizeMake(100, 100);
                if(width>height&&width/height>1.25)
                {
                    size=CGSizeMake(100, 70);
                }
                else if(width<height&&height/width>1.25)
                {
                     size=CGSizeMake(70, 100);
                }
                //size=CGSizeMake(width, height);
                //size=[UIImage fitSize:size inSize:CGSizeMake(100, 100)];
            }
        }
        else
        {
            NSDictionary* dic=[self.picUrls objectForKey:DSamllPic];
            float width=[[dic objectForKey:@"width"] floatValue];
            float height=[[dic objectForKey:@"height"] floatValue];
            size=CGSizeMake(100, 100);
            if(width>height&&width/height>1.25)
            {
                size=CGSizeMake(100, 70);
            }
            else if(width<height&&height/width>1.25)
            {
                size=CGSizeMake(70, 100);
            }
//            size=CGSizeMake(width, height);
//            size=[UIImage fitSize:size inSize:CGSizeMake(100, 100)];
        }
        if(CGSizeEqualToSize(size, CGSizeZero)){
            size=CGSizeMake(100,100);
        }
    }
    else if(self.msgType==NewsMessage||self.msgType==SpecialMessage||self.msgType==PicsMessage)
    {
        size=CGSizeMake(240, 110);
    }
    else if (self.msgType==HQMessage)
    {
        size=CGSizeMake(200, 100);
    }
    
    return size;
}

- (NSString *)transformString:(NSString *)originalStr
{
    //匹配表情，将表情转化为html格式
    NSString *text = originalStr;
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = [text componentsMatchedByRegex:regex_emoji];
    if (array_emoji.count>0) {
        for (NSString *str in array_emoji) {
            NSRange range = [text rangeOfString:str];
            NSString *url =[[MessageInputManager sharedInstance] emjioForKey:str];
            if (url) {
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='28' height='28'>",url];
                text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
            }
        }
    }
    //返回转义后的字符串
    return text;
}

-(NSDictionary*)getCurrentIdDic
{
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
    if(self.msgType==NewsMessage||self.msgType==SpecialMessage||self.msgType==PicsMessage)
    {
        [dic setObject:messgae_.programId forKey:mProgramId];
        [dic setObject:messgae_.articleId forKey:mArticleId];
    }
    else if (self.msgType==HQMessage)
    {
        if(messgae_.otherData)
        {
            return messgae_.otherData;
        }
        [dic setObject:messgae_.KId forKey:@"marketId"];
        [dic setObject:messgae_.KType forKey:@"KType"];
        if(messgae_.KName)
        {
            [dic setObject:messgae_.KName forKey:@"marketName"];
        }
    }
    return dic;
}

-(void)updateMessageWithUploadImg:(NSDictionary*)dic finished:(void(^)(EMessages* msg))block
{
    NSDictionary* localDic=[self.picUrls objectForKey:DSelfUpLoadImg];
    NSMutableDictionary* newdic=[NSMutableDictionary dictionaryWithDictionary:dic];
    [newdic setObject:localDic forKey:DSelfUpLoadImg];
    messgae_.picUrls=newdic;
    if (block){
        block(messgae_);
    }
}

-(void)updateMEssageWithHQValue:(NSDictionary *)dic finished:(void(^)(EMessages* msg))block
{
    messgae_.otherData=dic;
    if (block){
        block(messgae_);
    }
}

-(BOOL)isTimeOut
{
    NSDate* now=[NSDate date];
    NSTimeInterval time=abs([self.timeInterval timeIntervalSinceDate:now]);
    return (time>=240&&!self.isSend);
}

-(NSString *)headUrl
{
    if(!headUrl_)
    {
        NSString* uuid;
        if(messgae_.isGroup){
            uuid=[XMPPJID jidWithString:messgae_.resource].user;
        }
        else{
            uuid=[XMPPJID jidWithString:messgae_.friends_jid].user;
        }
        headUrl_=[NSString stringWithFormat:@"%@&uuid=%@&size=%d",kURL(@"avatar"),uuid,135];
    }
    return headUrl_;
}

-(EMessages *)newMessage
{
    return messgae_;
}

@end
