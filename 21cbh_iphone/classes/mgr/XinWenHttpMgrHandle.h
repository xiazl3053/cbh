//
//  HttpMgrHandle.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "NewsListViewController.h"
#import "NewsListViewController2.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "NewsDetailViewController.h"
#import "PicListViewController.h"
#import "MJPhotoBrowser.h"
#import "ConsultPushListViewController.h"
#import "liveBroadcastViewController.h"
#import "WebViewController.h"
#import "ChatLogIn.h"
#import "BindingMobileCheckCodeViewController.h"

@interface XinWenHttpMgrHandle : NSObject

@property(weak,nonatomic)NewsListViewController *nlv;
@property(weak,nonatomic)NewsListViewController2 *nlv2;
@property(weak,nonatomic)LoginViewController *lvc;
@property(weak,nonatomic)RegisterViewController *rvc;
@property(weak,nonatomic)NewsDetailViewController *ndv;
@property(weak,nonatomic)PicListViewController *plc;
@property(weak,nonatomic)MJPhotoBrowser *mpb;
@property(weak,nonatomic)MainViewController *main;
@property(weak,nonatomic)ConsultPushListViewController *cplvc;
@property(weak,nonatomic)liveBroadcastViewController *lbvc;
@property(weak,nonatomic)WebViewController *wvc;
@property(weak,nonatomic)ChatLogIn *cl;
@property(weak,nonatomic)BindingMobileCheckCodeViewController *bmccvc;


#pragma mark 普通登陆接口处理
-(void)loginHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark  第三方授权登陆接口处理
-(void)loginSSOHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark  注册登陆接口处理
-(void)registerHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark 注销接口处理
-(void)loginOut:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark IOS提交设备信息接口处理
-(void)postDeviceInfo:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark 是否推送状态接口处理
-(void)postIsPush:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark  新闻快讯接口处理
-(void)newsFlashHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark  启动页接口处理
-(void)launchHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark  广告栏接口处理
-(void)adBarHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark  头图接口处理
-(void)headHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark 新闻列表接口处理
-(void)newsListHandle:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp;
#pragma mark 新闻列表接口处理2
-(void)newsListHandle2:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp;
#pragma mark 新闻详情接口处理
-(void)newsDetailHandle:(ASIFormDataRequest *)request success:(BOOL)b isLocalExist:(BOOL)isLocalExist;
#pragma mark 图集列表接口处理
-(void)picsListHandle:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp;
#pragma mark 图集详情接口处理
-(void)picsDetailHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark 推送新闻列表接口处理
-(void)pushNewListHandle:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp;
#pragma mark 直播列表接口处理
-(void)liveBroadcastHandle:(ASIFormDataRequest *)request success:(BOOL)b isUp:(BOOL)isUp;
#pragma mark 广告详情接口处理
-(void)adDetailHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark 验证token接口处理
-(void)checkTokenHandle:(ASIFormDataRequest *)request success:(BOOL)b;
#pragma mark 绑定手机号码接口处理
-(void)bindPhoneHandle:(ASIFormDataRequest *)request success:(BOOL)b;
@end
