//
//  AppDelegate.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-30.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "MainViewController.h"
#import "MLNavigationController.h"
#import "FileOperation.h"
#import "XinWenHttpMgr.h"
#import "NewsDetailViewController.h"
#import "KLineViewController.h"
#import "CommonOperation.h"
#import "kNewsDetailViewController.h"
#import "selfMarketMessageDB.h"
#import "ASIHTTPRequest.h"
#import <StoreKit/StoreKit.h>
#import "FileOperation.h"
#import "MainEngine.h"
#import "ChatLogIn.h"
#import "PlayManager.h"
#import "DownLoadManager.h"

#import <AVFoundation/AVFoundation.h>


#define HEIGHT1 1136
#define HEIGHT2 960
#define HEIGHT3 480
#define KVersionCheckTime 24*60*60*7
#define KBaiduAPP_KEY @"Dm6ROayIcwn48FmWo840OhoV"
#define KBaiduREPORT_ID @"d37ddaf8ab"


@interface AppDelegate()<SKStoreProductViewControllerDelegate>{
    UIImageView *_splashView;
    NSDictionary *_user;//苹果的推送信息
    MainEngine* _engine;
    NSDictionary* _launchOptions;
    Reachability *_reachability;//用来监听网络的对象
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _launchOptions=launchOptions;
    //app刚启动接受苹果推送的处理
    [self finishLaunchingPushHandle:launchOptions];
    //集成baidu统计
    [self addBaiduStatistics];
    //初始化变量
    [self initParams];
    //提交推送状态
    [self postIsPush];
    //加载本地资源
    [self loadLocalsouce];
    //初始化shareSDK
    [self initializePlat];
    //初始化视图
    [self initViews];
    //获取启动页广告数据
    [self getLaunch];
    //设置广告页的淡入动画
    [self setAdIn];
    //注册苹果推送服务
    [self registerApplePush];
    //启动网络监听
    //[self openListenNetStatus];
    //自动登陆openFire
    //[[ChatLogIn getId] autoLogin];
    //初始化DownLoadManager
    [DownLoadManager getId];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    isActive=YES;
    NSLog(@"isActive:%i",isActive);
    //清除通知栏的通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // 通知App已激活，该继续的继续
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotifcationKeyForActive
                                                       object:nil
                                                     userInfo:nil];
    
    //检测是否清楚用户的缓存数据
    [[CommonOperation getId] automaticClearCach];
}

- (void)applicationWillResignActive:(UIApplication *)application{
    
}
-(void)applicationWillEnterForeground:(UIApplication *)application{
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    isActive=NO;
    playerState=[[PlayManager sharedPlayManager] getStatus];
    // 通知App将要进入后台，该保存的赶紧保存
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotifcationKeyForEnterGround
                                                       object:nil
                                                     userInfo:nil];
}
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    PlayManager *play=[PlayManager sharedPlayManager];
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:{// 远程切换播放、暂停按钮
                playerState=CBPMoviePlaybackStateStopped;}
                switch ([[PlayManager sharedPlayManager]getStatus]) {
                    case CBPMoviePlaybackStatePlaying:{
                        playerState=CBPMoviePlaybackStatePaused;
                        [play pausePlay];
                    }break;
                    case CBPMoviePlaybackStatePaused:{
                        playerState=CBPMoviePlaybackStatePlaying;
                        [play startPlay];
                    }break;
                    default:
                        break;
                }
                break;
            case UIEventSubtypeRemoteControlPause:{
                NSLog(@"UIEventSubtypeRemoteControlPause"); // 切换播放、暂停按钮
                playerState=CBPMoviePlaybackStatePaused;
                [play pausePlay];
            }break;
            case UIEventSubtypeRemoteControlPlay:{
                NSLog(@"UIEventSubtypeRemoteControlPlay");
                playerState=CBPMoviePlaybackStatePlaying;
                [play startPlay];
            }break;
            case UIEventSubtypeRemoteControlPreviousTrack:{
                [play previous];
                [play startPlay];
                playerState=CBPMoviePlaybackStatePlaying;
                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack"); // 播放上一曲按钮
            }break;
            case UIEventSubtypeRemoteControlNextTrack:{
                [play next];
                [play startPlay];
                playerState=CBPMoviePlaybackStatePlaying;
                // 播放下一曲按钮
                NSLog(@"UIEventSubtypeRemoteControlNextTrack");
            }break;
            default:
                break;
        }
    }
}

#pragma mark - ----------------------推送-----------------------------------------
#pragma mark 收到苹果官方的deviceToken
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [[PushNotificationHandler instance]registerPushNotificationSuccessWithDeviceToken:deviceToken];
}

#pragma mark 注册失败苹果官方返回的信息
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"推送失败信息:%@",error);
}

#pragma mark 处理服务器的推送信息
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //苹果推送信息处理
    [[PushNotificationHandler instance]applicationRecievePushNotification:userInfo];
}

#pragma mark app刚启动接受苹果推送的处理
-(void)finishLaunchingPushHandle:(NSDictionary *)launchOptions{
    NSDictionary* userInfo=nil;
    if (launchOptions) {//点击通知栏进来的
        userInfo= [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //苹果推送信息处理
        [[PushNotificationHandler instance]applicationRecievePushNotification:userInfo];
    }
}

#pragma mark 注册苹果推送服务
-(void)registerApplePush
{
    _engine=[[MainEngine alloc]initWithMain:_main];
    [[PushNotificationHandler instance] registerPushNotificationAndLaunchingWithOptions:_launchOptions];
    [PushNotificationHandler instance].delegate=_engine;
}



#pragma mark - ----------------以下为自定义方法----------------
#pragma mark 初始化变量
-(void)initParams{

}


#pragma mark 初始化视图
-(void)initViews{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    MainViewController *main = [[MainViewController alloc] init];
    // 包装控制器
    MLNavigationController *mlnv = [[MLNavigationController alloc] initWithRootViewController:main];
    self.window.rootViewController = mlnv;
    [self.window makeKeyAndVisible];
    _main=main;
}

#pragma mark 设置广告页的淡入动画
-(void)setAdIn{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *picUrl=[defaults objectForKey:@"picUrl"];
    UIImage *image=[[FileOperation getId] getLocalPicWithURL:picUrl FileDirName:kAdFileDir];
    NSLog(@"setAdIn image:%@",image);
    if (!image) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        return;
    }
    
    UIImageView *splashView = [[UIImageView alloc] initWithFrame:self.window.bounds];
    _splashView=splashView;
    //获取屏幕分辨率高度
    CGFloat height=[[CommonOperation getId] getScreenHeight];
    if (height==HEIGHT1) {//iphone5
        splashView.image = [UIImage imageNamed:@"Default-568h"];
    }else if(height==HEIGHT2){//iphone4的retina
        splashView.image = [UIImage imageNamed:@"Default"];
    }else if (height==HEIGHT3){//非retina的
        splashView.image = [UIImage imageNamed:@"Default"];
    }
    [self.window addSubview:splashView];
    //显示于当前页面
    [self.window bringSubviewToFront:splashView];
    
    
    CGFloat width=self.window.frame.size.width;
    height=width*(image.size.height/image.size.width);
    //下面的为广告页加载
    UIImageView *adView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    adView.contentMode=UIViewContentModeScaleToFill;
    [adView setImage:image];
    adView.alpha=0.0;
    [splashView addSubview:adView];
    
    [UIView beginAnimations:@"in" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:1.0];
    
    adView.alpha=1.0;
    [UIView commitAnimations];
}
#pragma mark 设置广告页的淡出动画
-(void)setAdOut{
    //这个时间是给用户看广告的
    sleep(3);
    
    [UIView beginAnimations:@"out" context:nil];
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:1.0];
    
    _splashView.alpha=0.0;
    [UIView commitAnimations];
}

-(void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context{
    if ([animationID isEqualToString:@"in"]) {
        //设置广告页的淡出动画
        [self setAdOut];
    }else if([animationID isEqualToString:@"out"]){
        [_splashView removeFromSuperview];//移除视图
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
         [self versionCheck];
    }

}

#pragma mark 初始化shareSDK
- (void)initializePlat
{
    /**
     注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
     此方法必须在启动时调用，否则会限制SDK的使用。
     **/
    [ShareSDK registerApp:@"178f642f1425"];
    
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:@"2567592961"
                               appSecret:@"5201b9c4cc03e40372679b3405333530"
                             redirectUri:@"http://www.21cbh.com/apps/download2/"];
    /**
     连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    [ShareSDK connectTencentWeiboWithAppKey:@"801498290"
                                  appSecret:@"65b8f60588818baeeaa86f4a2374afd3"
                                redirectUri:@"http://www.21cbh.com/"
                                   wbApiCls:[WeiboApi class]];

    /**
     连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
     http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
     **/
    [ShareSDK connectQZoneWithAppKey:@"101049358"
                           appSecret:@"7955a140ff924fdd17f2f4e353e1cadf"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wxc567639bc54320a7" wechatCls:[WXApi class]];
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
    
    [ShareSDK connectQQWithQZoneAppKey:@"101049358"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    /**
     连接印象笔记应用以使用相关功能，此应用需要引用EverNoteConnection.framework
     http://dev.yinxiang.com上注册应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectEvernoteWithType:SSEverNoteTypeSandbox
                          consumerKey:@"21shijiwang"
                       consumerSecret:@"7755d0590a786150"];
    
    //连接邮件
    [ShareSDK connectMail];
    
    //连接短信分享
    [ShareSDK connectSMS];
    
    
    //连接打印
    //  [ShareSDK connectAirPrint];
    
    //连接拷贝
    //  [ShareSDK connectCopy];
    
    
    /**
     连接Facebook应用以使用相关功能，此应用需要引用FacebookConnection.framework
     https://developers.facebook.com上注册应用，并将相关信息填写到以下字段
     **/
//    [ShareSDK connectFacebookWithAppKey:@"107704292745179"
//                              appSecret:@"38053202e1a5fe26c80c753071f0b573"];
    
    /**
     连接Twitter应用以使用相关功能，此应用需要引用TwitterConnection.framework
     https://dev.twitter.com上注册应用，并将相关信息填写到以下字段
     **/
//    [ShareSDK connectTwitterWithConsumerKey:@"mnTGqtXk0TYMXYTN7qUxg"
//                             consumerSecret:@"ROkFqr8c3m1HXqS3rm3TJ0WkAJuwBOSaWhPbZ9Ojuc"
//                                redirectUri:@"http://www.sharesdk.cn"];
    
    /**
     连接Google+应用以使用相关功能，此应用需要引用GooglePlusConnection.framework、GooglePlus.framework和GoogleOpenSource.framework库
     https://code.google.com/apis/console上注册应用，并将相关信息填写到以下字段
     **/
//    [ShareSDK connectGooglePlusWithClientId:@"232554794995.apps.googleusercontent.com"
//                               clientSecret:@"PEdFgtrMw97aCvf0joQj7EMk"
//                                redirectUri:@"http://localhost"
//                                  signInCls:[GPPSignIn class]
//                                   shareCls:[GPPShare class]];
    
    /**
     连接人人网应用以使用相关功能，此应用需要引用RenRenConnection.framework
     http://dev.renren.com上注册人人网开放平台应用，并将相关信息填写到以下字段
     **/
//    [ShareSDK connectRenRenWithAppId:@"266518"
//                              appKey:@"666fc066ff95484bb3f6b2f526778cd3"
//                           appSecret:@"e220156f78d940f5b3cf70b1ab453c4c"
//                   renrenClientClass:[RennClient class]];
//    
//    [ShareSDK connectRenRenWithAppId:@"266807"
//                              appKey:@"bfee009e55e341199af918c48a8ada6e"
//                           appSecret:@"2b0cc10c603e4697a31db858503a632a"
//                   renrenClientClass:[RennClient class]];
    

    
    /**
     连接开心网应用以使用相关功能，此应用需要引用KaiXinConnection.framework
     http://open.kaixin001.com上注册开心网开放平台应用，并将相关信息填写到以下字段
     **/
//    [ShareSDK connectKaiXinWithAppKey:@"3918859447363746cfef27faffc0d618"
//                            appSecret:@"ec5682b9de04157762c22c4cd1733371"
//                          redirectUri:@"http://www.21cbh.com/apps/21cbh/"];
//    
//    /**
//     连接易信应用以使用相关功能，此应用需要引用YiXinConnection.framework
//     http://open.yixin.im/上注册易信开放平台应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectYiXinWithAppId:@"yx95afdb08c72b47c69f2f6e9dc614f47e"
//                           yixinCls:[YXApi class]];
    

    
//    /**
//     连接搜狐微博应用以使用相关功能，此应用需要引用SohuWeiboConnection.framework
//     http://open.t.sohu.com上注册搜狐微博开放平台应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectSohuWeiboWithConsumerKey:@"32sMA4HWDffpjvnwa9oA"
//                               consumerSecret:@"jbU=z9NyQyHkHFlIH6*gQHFrhslkeFI!Y^Ajxcwi"
//                                  redirectUri:@"http://www.21cbh.com/"];
    
    /**
     连接网易微博应用以使用相关功能，此应用需要引用T163WeiboConnection.framework
     http://open.t.163.com上注册网易微博开放平台应用，并将相关信息填写到以下字段
     **/
//    [ShareSDK connect163WeiboWithAppKey:@"m6mIxpZV1FuWBMDm"
//                              appSecret:@"dPAoupSyLcAAPaVEinBK0qCBfqooxJjb"
//                            redirectUri:@"http://www.21cbh.com/"];
//    
//    
//    /**
//     连接豆瓣应用以使用相关功能，此应用需要引用DouBanConnection.framework
//     http://developers.douban.com上注册豆瓣社区应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectDoubanWithAppKey:@"0d3d01e41bc7390527b705ac5355ab0f"
//                            appSecret:@"8a76b1902a4a933b"
//                          redirectUri:@"http://www.21cbh.com/"];
    

    
//    /**
//     连接LinkedIn应用以使用相关功能，此应用需要引用LinkedInConnection.framework库
//     https://www.linkedin.com/secure/developer上注册应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectLinkedInWithApiKey:@"21shijiwang-4340"
//                              secretKey:@"56cbb9fddb011239"
//                            redirectUri:@"http://www.21cbh.com/"];
//    
//    /**
//     连接Pinterest应用以使用相关功能，此应用需要引用Pinterest.framework库
//     http://developers.pinterest.com/上注册应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectPinterestWithClientId:@"1432928"
//                              pinterestCls:[Pinterest class]];
//    
//    /**
//     连接Pocket应用以使用相关功能，此应用需要引用PocketConnection.framework
//     http://getpocket.com/developer/上注册应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectPocketWithConsumerKey:@"11496-de7c8c5eb25b2c9fcdc2b627"
//                               redirectUri:@"pocketapp1234"];
//    
//    /**
//     连接Instapaper应用以使用相关功能，此应用需要引用InstapaperConnection.framework
//     http://www.instapaper.com/main/request_oauth_consumer_token上注册Instapaper应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectInstapaperWithAppKey:@"4rDJORmcOcSAZL1YpqGHRI605xUvrLbOhkJ07yO0wWrYrc61FA"
//                                appSecret:@"GNr1GespOQbrm8nvd7rlUsyRQsIo3boIbMguAl9gfpdL0aKZWe"];
//    /**
//     连接有道云笔记应用以使用相关功能，此应用需要引用YouDaoNoteConnection.framework
//     http://note.youdao.com/open/developguide.html#app上注册应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectYouDaoNoteWithConsumerKey:@"dcde25dca105bcc36884ed4534dab940"
//                                consumerSecret:@"d98217b4020e7f1874263795f44838fe"
//                                   redirectUri:@"http://www.sharesdk.cn/"];
//    
//    /**
//     连接搜狐随身看应用以使用相关功能，此应用需要引用SohuConnection.framework
//     https://open.sohu.com上注册应用，并将相关信息填写到以下字段
//     **/
//    [ShareSDK connectSohuKanWithAppKey:@"e16680a815134504b746c86e08a19db0"
//                             appSecret:@"b8eec53707c3976efc91614dd16ef81c"
//                           redirectUri:@"http://sharesdk.cn"];
//    
//    
//    /**
//     链接Flickr,此平台需要引用FlickrConnection.framework框架。
//     http://www.flickr.com/services/apps/create/上注册应用，并将相关信息填写以下字段。
//     **/
//    [ShareSDK connectFlickrWithApiKey:@"33d833ee6b6fca49943363282dd313dd"
//                            apiSecret:@"3a2c5b42a8fbb8bb"];
//    
//    /**
//     链接Tumblr,此平台需要引用TumblrConnection.framework框架
//     http://www.tumblr.com/oauth/apps上注册应用，并将相关信息填写以下字段。
//     **/
//    [ShareSDK connectTumblrWithConsumerKey:@"2QUXqO9fcgGdtGG1FcvML6ZunIQzAEL8xY6hIaxdJnDti2DYwM"
//                            consumerSecret:@"3Rt0sPFj7u2g39mEVB3IBpOzKnM3JnTtxX2bao2JKk4VV1gtNo"
//                               callbackUrl:@"http://sharesdk.cn"];
//    
//    /**
//     连接Dropbox应用以使用相关功能，此应用需要引用DropboxConnection.framework库
//     https://www.dropbox.com/developers/apps上注册应用，并将相关信息填写以下字段。
//     **/
//    [ShareSDK connectDropboxWithAppKey:@"7janx53ilz11gbs"
//                             appSecret:@"c1hpx5fz6tzkm32"];
//    
//    /**
//     连接Instagram应用以使用相关功能，此应用需要引用InstagramConnection.framework库
//     http://instagram.com/developer/clients/register/上注册应用，并将相关信息填写以下字段
//     **/
//    [ShareSDK connectInstagramWithClientId:@"ff68e3216b4f4f989121aa1c2962d058"
//                              clientSecret:@"1b2e82f110264869b3505c3fe34e31a1"
//                               redirectUri:@"http://sharesdk.cn"];
//    
//    /**
//     连接VKontakte应用以使用相关功能，此应用需要引用VKontakteConnection.framework库
//     http://vk.com/editapp?act=create上注册应用，并将相关信息填写以下字段
//     **/
//    [ShareSDK connectVKontakteWithAppKey:@"3921561"
//                               secretKey:@"6Qf883ukLDyz4OBepYF1"];
    
    //导入QQ互联和QQ好友分享需要的外部库类型，如果不需要QQ空间SSO和QQ好友分享可以不调用此方法
    [ShareSDK importQQClass:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
}


#pragma mark 加载本地资源(这个是个蛋疼的方法,写资源文件是各种坑爹,少点挖坑吧)
-(void)loadLocalsouce{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version1=[[CommonOperation getId] getVersion];
    NSString *version2=[defaults objectForKey:@"version"];
    if (!version2||![version2 isEqualToString:version1]) {//不同版本的资源处理
        [defaults setObject:version1 forKey:@"version"];
        // 将数据同步到Preferences文件夹中
        [defaults synchronize];
        
        //设置token为nil
        [[CommonOperation getId] setToken:nil];
        //清除账号信息
        [CommonOperation clearUm];
        
        //栏目换名增删处理(哥想到每次启动都去资源文件目录里匹配下最新栏目的想法真是太机智了!)
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"21cbh" ofType:@"plist"];
        NSMutableArray *titles=[[[NSMutableDictionary alloc] initWithContentsOfFile:plistPath] objectForKey:KPlistKey0];
        NSMutableArray *currentTitles=[[[FileOperation getId] getLocalPlistWithFileDirName:KPlistDirName fileName:KPlistName] objectForKey:KPlistKey0];
        
        if (!currentTitles) {//如果本地栏目为空就重新写一遍
            //初始化栏目存到本地
            [self saveProgramListToDocument];
            currentTitles=[[[FileOperation getId] getLocalPlistWithFileDirName:KPlistDirName fileName:KPlistName] objectForKey:KPlistKey0];
        }
        //拷贝一份currentTitles
        NSMutableArray *currentTitles1=[NSMutableArray array];
        for (int i=0; i<currentTitles.count; i++) {
            [currentTitles1 addObject:[currentTitles objectAtIndex:i]];
        }
        
        for (int i=0; i<currentTitles.count; i++) {
            NSString *title=[currentTitles objectAtIndex:i];
            NSLog(@"titile:%@%i",title,i);
            if (![titles containsObject:title]) {
                [currentTitles1 removeObject:title];//如果最新的资源包没有该栏目了,就删除
            }
        }
        
        NSMutableDictionary *data=[[FileOperation getId] getLocalPlistWithFileDirName:KPlistDirName fileName:KPlistName];
        [data setObject:currentTitles1 forKey:KPlistKey0];
        //plist存储到本地
        [[FileOperation getId] savePlistToLocalWithNSMutableDictionary:data FileDirName:KPlistDirName fileName:KPlistName];
        
        
        //有新html资源要写进本地请在下面的代码里添加
        NSArray *array=kLocalSource;
        [self putFileToSandboxWithArray:array];
    }
    
}

#pragma mark 加载资源里的各种类型的文件进沙盒
-(void)putFileToSandboxWithArray:(NSArray *)array{
    for (int i=0; i<[array count]; i++) {
        NSString *fileName=[array objectAtIndex:i];
        NSArray *FileNameArray=[fileName componentsSeparatedByString: @"."];
        NSString *string1=[FileNameArray objectAtIndex:0];
        NSString *string2=[FileNameArray objectAtIndex:[FileNameArray count]-1];
        NSData *data=[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:string1 ofType:string2]];
        //NSLog(@"%@:%@",fileName,string);
        if ([string2 isEqualToString:@"js"]) {
            [[FileOperation getId] saveHtmlWithData:data FileDirName:@"html/js" fileName:fileName];
        }else if([string2 isEqualToString:@"css"]){
            [[FileOperation getId] saveHtmlWithData:data FileDirName:@"html/css" fileName:fileName];
        }else if([string2 isEqualToString:@"png"]||[string2 isEqualToString:@"jpg"]){
            UIImage *image=[UIImage imageNamed:fileName];
            [[FileOperation getId] savePicToLocalWithUIImage:image picUrl:fileName FileDirName:@"html/images" isPng:YES];
        }else if ([string2 isEqualToString:@"TTF"]){
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[FileOperation getId] saveHtmlWithData:data FileDirName:@"html/fonts" fileName:fileName];
            });
        }
    }
}

#pragma mark 将栏目plist文件写进本地沙盒
-(void)saveProgramListToDocument{
    //plist资源
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    //新闻栏目资料
    NSMutableArray *programPlist=[NSMutableArray array];
    //预设新闻栏目,老板说以后默认全部加
    NSArray *presupposeArray=kProgramTitles;
    for (int i=0; i<presupposeArray.count; i++) {//添加新闻栏目
        
        [programPlist addObject:[presupposeArray objectAtIndex:i]];
    }
    
    [data setObject:programPlist forKey:KPlistKey0];
    //plist存储到本地
    [[FileOperation getId] savePlistToLocalWithNSMutableDictionary:data FileDirName:KPlistDirName fileName:KPlistName];
}


#pragma mark 获取启动页广告数据
-(void)getLaunch{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    [hmgr launch];
}

#pragma mark 提交推送状态
-(void)postIsPush{
    NSString *isPush=nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool noFirst=[defaults boolForKey:@"noFirst"];
    if (!noFirst) {
        isPush=@"1";
        [defaults setValue:isPush forKey:kIsPush];
        [defaults synchronize];
    }
    
    isPush=[defaults objectForKey:kIsPush];
    
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    [hmgr postIsPushWithIsPush:isPush];
}


#pragma mark -appStore版本获取
-(void)versionCheck{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"curSecond=%f,lastSecond=%f",[[NSDate date]timeIntervalSince1970],[[defaults objectForKey:@"updataTime"]floatValue]);
    
    if ([[defaults objectForKey:@"updataTime"]floatValue]>[[NSDate date]timeIntervalSince1970]) {
        return;
    }
    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup"]];
    ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:url];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];//默认编码为utf-8
    [request setRequestMethod:@"POST"];
    [request setPostValue:KApple_ID forKey:@"id"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block ASIFormDataRequest* blockRequest=request;
        //请求成功
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *str=[blockRequest responseString];
                    NSLog(@"str=%@",str);
                    NSDictionary *dic=[str JSONValue];
                    [self versionComPare:dic];
                });
            });
        }];
        //请求失败
        [request setFailedBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"---------获取版本失败-----------");
            });
        }];
        //发送请求
        [request startAsynchronous];
        
    });
}


#pragma mark -版本匹配
-(void)versionComPare:(NSDictionary *)desc{
    NSArray *infoArray = [desc objectForKey:@"results"];
    if ([infoArray count]) {
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        NSString *lastVersion = [releaseInfo objectForKey:@"version"];
        NSLog(@"curr.version=%@,last.version=%@",kAppCurVersion,lastVersion);
        NSComparisonResult result = [lastVersion compare:kAppCurVersion options:NSLiteralSearch];
        if (result==NSOrderedDescending) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
            alert.tag = 88888;
            [alert show];
        }else{
            NSLog(@"此版本为最新版本");
        }
    }else{
        return ;
    }
    
    NSTimeInterval secondsPerDay = KVersionCheckTime;
    NSDate *tomorrow = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
    NSTimeInterval interval=[tomorrow timeIntervalSince1970];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithLong:interval] forKey:@"updataTime"];
    [defaults synchronize];

}


#pragma mark -集成Baidu统计
-(void)addBaiduStatistics{
    [Frontia initWithApiKey:KBaiduAPP_KEY];
    
    FrontiaStatistics* statTracker = [Frontia getStatistics];
    statTracker.enableExceptionLog = YES; // 是否允许截获并发送崩溃信息，请设置YES或者NO
    statTracker.channelId = @"AppStore";//设置您的app的发布渠道
    statTracker.logStrategy = FrontiaStatLogStrategyCustom;//根据开发者设定的时间间隔接口发送 也可以使用启动时发送策略
    statTracker.logSendInterval = 1;  //为1时表示发送日志的时间间隔为1小时
    //statTracker.logSendWifiOnly = YES; //是否仅在WIfi情况下发送日志数据
    statTracker.sessionResumeInterval = 60;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
    statTracker.shortAppVersion  = kAppCurVersion; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    [statTracker startWithReportId:KBaiduREPORT_ID];//设置您在mtj网站上添加的app的appkey
    
}

#pragma mark 启动网络监听
-(void)openListenNetStatus{
    _reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [_reachability startNotifier];
}


#pragma mark - ---------------UIAlertView代理方法----------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //前往appStore更新应用
    if (alertView.tag==88888) {
        if (buttonIndex==1) {
//            SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
//            NSDictionary *dict = [NSDictionary dictionaryWithObject:KApple_ID forKey:SKStoreProductParameterITunesItemIdentifier];
//            [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
//                if (result) {
//                    
//                }
//            }];
//            storeProductVC.delegate=self;
//            UIViewController *nav= [[CommonOperation getId]getCurrectNavigationController];
//            [nav presentViewController:storeProductVC animated:YES completion:nil];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:KAppStorePath]];
        }
    }
    
}

#pragma mark ---------------SKStoreProductViewController代理方法----------------------------
#pragma mark -退出appStore窗口
-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    UIViewController *nav= [[CommonOperation getId]getCurrectNavigationController];
    [nav dismissViewControllerAnimated:YES completion:nil];
}



@end
