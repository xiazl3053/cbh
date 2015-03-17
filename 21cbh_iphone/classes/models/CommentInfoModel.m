//
//  CommentInfoModel.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentInfoModel.h"

#define KCommentDataJsonKeyTitle @"newsTitle"
#define KCommentDataJsonKeyUrl @"newsUrl"
#define KCommentDataJsonKeyFollowId @"followId"
#define KCommentDataJsonKeyUserHeadPic @"userHeadPic"
#define KCommentDataJsonKeyUserNickName @"userNickName"
#define KCommentDataJsonKeyUserLocation @"userLocation"
#define KCommentDataJsonKeyTopNum @"topNum"
#define KCommentDataJsonKeyTime @"addtime"
#define KCommentDataJsonKeyContent @"content"
#define KCommnetDataJsonKeyFollowers @"followers"

@implementation CommentInfoModel


-(id)initWithNSDictionary:(NSDictionary *)dic{

    self=[super init];
    
    NSLog(@"self==%@",self);
    
    if (self) {
        
        self.commentTitle=[dic objectForKey:KCommentDataJsonKeyTitle];
        if (!self.commentTitle||![self.commentTitle isKindOfClass:[NSString class]]) {
            self.commentTitle=@"";
        }
        self.commentUrl=[dic objectForKey:KCommentDataJsonKeyUrl];
        if (!self.commentUrl||![self.commentUrl isKindOfClass:[NSString class]]) {
            self.commentUrl=@"";
        }
        self.commentID=[dic objectForKey:KCommentDataJsonKeyFollowId];
        if (!self.commentID||![self.commentID isKindOfClass:[NSString class]]) {
            self.commentID=@"";
        }
        self.commentUserHeadUrl=[dic objectForKey:KCommentDataJsonKeyUserHeadPic];
        if (!self.commentUserHeadUrl||![self.commentUserHeadUrl isKindOfClass:[NSString class]]) {
            self.commentUserHeadUrl=@"";
        }
        self.commentUserNickName=[dic objectForKey:KCommentDataJsonKeyUserNickName];
        if (!self.commentUserNickName||![self.commentUserNickName isKindOfClass:[NSString class]]) {
            self.commentUserNickName=@"";
        }
        self.commentUserLocation=[dic objectForKey:KCommentDataJsonKeyUserLocation];
        if (!self.commentUserLocation||![self.commentUserLocation isKindOfClass:[NSString class]]) {
            self.commentUserLocation=@"";
        }
        self.commentTopNum=[dic objectForKey:KCommentDataJsonKeyTopNum];
        if (!self.commentTopNum||![self.commentTopNum isKindOfClass:[NSString class]]) {
            self.commentTopNum=@"";
        }
        self.commentTime=[dic objectForKey:KCommentDataJsonKeyTime];
        if (!self.commentTime||![self.commentTime isKindOfClass:[NSString class]]) {
            self.commentTime=@"";
        }
        self.commentContent=[dic objectForKey:KCommentDataJsonKeyContent];
        if (!self.commentContent||![self.commentContent isKindOfClass:[NSString class]]) {
            self.commentContent=@"";
        }
        self.commentFollows=[self WithNSArray:[dic objectForKey:KCommnetDataJsonKeyFollowers]];
        self.isOpenComment=NO;
    }

    return self;

}

-(NSMutableArray * )WithNSArray:(NSArray *)arr{
    NSMutableArray *data=[NSMutableArray array];
    for (int nIndex=0; nIndex<arr.count; nIndex++) {
        NSDictionary *dic=[arr objectAtIndex:nIndex];
            CommentInfoModel *model=[[CommentInfoModel alloc]init];
            model.commentID=[dic objectForKey:KCommentDataJsonKeyFollowId];
            model.commentUserHeadUrl=[dic objectForKey:KCommentDataJsonKeyUserHeadPic];
            model.commentUserNickName=[dic objectForKey:KCommentDataJsonKeyUserNickName];
            model.commentUserLocation=[dic objectForKey:KCommentDataJsonKeyUserLocation];
            model.commentTopNum=[dic objectForKey:KCommentDataJsonKeyTopNum];
            if (!model.commentTopNum) {
            model.commentTopNum=@"0";
            }
            model.commentTime=[dic objectForKey:KCommentDataJsonKeyTime];
            if (!model.commentTime) {
                model.commentTime=@"0";
            }
            model.commentContent=[dic objectForKey:KCommentDataJsonKeyContent];
            model.number=nIndex;
            //插入到第一个
            [data insertObject:model atIndex:0];
    }
    return data;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    NSLog(@"------深复制-------");
    CommentInfoModel *info=[[CommentInfoModel allocWithZone:zone]init];
    info.commentID=[_commentID copy];
    info.commentUserHeadUrl=[_commentUserHeadUrl copy];
    info.commentUserNickName=[_commentUserNickName copy];
    info.commentUserLocation=[_commentUserLocation copy];
    info.commentTopNum=[_commentTopNum copy];
    info.commentTime=[_commentTime copy];
    info.commentContent=[_commentContent copy];
    return info;
}

@end
