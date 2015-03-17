//
//  PingLunHttpResponse.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-8.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIFormDataRequest;
@class NewsCommentViewController;
@class NewsSpecialViewController;
@class HeadSettingViewController;
@class CommentViewController;
@class VersionCheckViewController;
@class FeedBackViewController;
@class MoreAppViewController;


@interface PingLunHttpResponse : NSObject

//专题返回
-(void)specialInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success error:(NSDictionary *)dic;

// 评论信息返回
-(void)commentListInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
//点赞返回
-(void)commentDingInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
//评论回复接口
-(void)commentFollowInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
//图像上传返回
-(void)settingHeadInfoBackWithData:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
//获取版本后返回
-(void)versionInfoBackData:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
//反馈意见回调
-(void)feedBackInfoBackData:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
//更多应用回调
-(void)moreAppInfoBackData:(ASIFormDataRequest *)request isSuccess:(BOOL)success;
//用户信息返回
-(void)userinfoBackData:(ASIFormDataRequest *)request isSuccess:(BOOL)success;


@property(nonatomic,weak) NewsCommentViewController *nc;
@property(nonatomic,weak) NewsSpecialViewController *np;
@property(nonatomic,weak) HeadSettingViewController *hs;
@property(nonatomic,weak) CommentViewController *cv;
@property(nonatomic,weak) VersionCheckViewController *vc;
@property(nonatomic,weak) FeedBackViewController *fb;
@property(nonatomic,weak) MoreAppViewController *ma;
@end
