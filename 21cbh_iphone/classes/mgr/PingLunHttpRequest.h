//
//  PingLunHttpRequest.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PingLunHttpResponse.h"

@class NewsCommentViewController;
@class NewsSpecialViewController;
@class HeadSettingViewController;
@class CommentViewController;
@class VersionCheckViewController;
@class FeedBackViewController;
@class MoreAppViewController;


@interface PingLunHttpRequest : NSObject


@property(strong,nonatomic)PingLunHttpResponse *PLResponse;

//查询专题信息
-(void)querySepcialNSP:(NewsSpecialViewController *)VC andProgramID:(int)nProgramID andSepcial:(int)nSepcialID;

//查询回复评论信息
-(void)queryCommentNCM:(NewsCommentViewController *)VC andProgramId:(NSInteger )nProgramID andFollowListID:(NSInteger )nFollow andCursor:(NSInteger )nCursor andCount:(NSInteger)nCount;
//评论点赞
-(void)sendCommenDingtNCM:(NewsCommentViewController *)VC andProgarmID:(int)nProgarm andArticleID:(int)nArticle andPicsID:(int)nPic andFollowID:(int)nFollow;
////评论回复
//-(void)sendCommenFollowNCM:(NewsCommentViewController *)VC andProgarm:(int)nProgarmID andArticleOrPicsID:(int)nArticle andFollowID:(int)nFollowID andContent:(NSString *)content;
//图片上传
-(void)updateUserFigrueWith:(HeadSettingViewController *)VC andFigurePath:(NSString *)file;
//评论回复
-(void)sendCommenFollowCMV:(CommentViewController *)VC andProgarm:(int)nProgarmID andArticleID:(int)nArticle andPicsID:(int)picID andFollowID:(int)nFollowID andContent:(NSString *)content;
//获取最新版本
-(void)getAppleID:(VersionCheckViewController *)VC;
//发送反馈信息
-(void)sendUserFeedBack:(FeedBackViewController *)VC andContent:(NSString *)info;
//查询更多应用信息
-(void)queryMoreApp:(MoreAppViewController *)VC andPage:(NSString *)page;

@end
