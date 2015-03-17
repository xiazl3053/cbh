//
//  HttpMgr.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "XinWenHttpMgrHandle.h"

@interface XinWenHttpMgr : NSObject

@property(strong,nonatomic)XinWenHttpMgrHandle *hh;

#pragma mark 普通登陆接口
-(void)loginWithUserName:(NSString *)userName passWord:(NSString *)passWord;
#pragma mark 第三方授权登陆接口
-(void)loginSSOwithPlatformId:(NSString *)platformId platformUserId:(NSString *)platformUserId platformNickName:(NSString *)platformNickName platformPicUrl:(NSString *)platformPicUrl;
#pragma mark 注册接口
-(void)registerWithUserName:(NSString *)userName nickName:(NSString *)nickName email:(NSString *)email passWord:(NSString *)passWord platformId:(NSString *)platformId platformUserId:(NSString *)platformUserId;
#pragma mark 注销登陆接口
-(void)loginOut;
#pragma mark 是否推送状态接口
-(void)postIsPushWithIsPush:(NSString *)isPush;
#pragma mark 新闻快讯接口
-(void)newsFlash;
#pragma mark 启动页接口
-(void)launch;
#pragma mark 广告栏接口
-(void)adBarWithProgramId:(NSString *)programId isProgram:(NSString *)isProgram;
#pragma mark 头图接口
-(void)headWithProgramId:(NSString *)programId;
#pragma mark 新闻列表接口
-(void)newsListWithProgramId:(NSString *)programId type:(NSString *)type id:(NSString *)newListId order:(NSString *)order addtime:(NSString *)addtime isUp:(BOOL)isUp;
#pragma mark 新闻列表接口2
-(void)newsList2WithProgramId:(NSString *)programId type:(NSString *)type id:(NSString *)newListId order:(NSString *)order addtime:(NSString *)addtime page:(NSString *)page pageNum:(NSString *)pageNum isUp:(BOOL)isUp;
#pragma mark 新闻详情接口
-(void)newsDetailWithArticleId:(NSString *)articleId programId:(NSString *)programId isLocalExist:(BOOL)isLocalExist;
#pragma mark 图集列表接口
-(void)picsListWithProgramId:(NSString *)programId id:(NSString *)picsId order:(NSString *)order addtime:(NSString *)addtime isUp:(BOOL)isUp;
#pragma mark 图集详细接口
-(void)picsDetailWithPicsId:(NSString *)picsId programId:(NSString *)programId;
#pragma mark 推送新闻列表接口
-(void)pushNewListWithPushId:(NSString *)pushId order:(NSString *)order addtime:(NSString *)addtime isUp:(BOOL)isUp;
#pragma mark 直播列表接口
-(void)liveBroadcastWithAddtime:(NSString *)addtime isUp:(BOOL)isUp;
#pragma mark 广告详情接口
-(void)adDetailWithAdId:(NSString *)adId type:(NSString *)type;
#pragma mark 验证token接口
-(void)checkToken;
#pragma mark 获取手机验证码接口
-(void)phoneAuthCodeWithPhoneNum:(NSString *)phoneNum;
#pragma mark 绑定手机号码
-(void)bindPhoneWithPhoneNum:(NSString *)phoneNum authCode:(NSString *)authCode;
@end
