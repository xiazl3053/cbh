//
//  ZXConstant.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

//接口地址
#define kLaunch @"launch"//启动页接口
#define kAdBar @"adBar"//广告栏接口
#define kHead @"head"//头图接口
#define kNewsList @"newsList"//新闻列表接口
#define kNewsList2 @"newsList2"//新闻列表接口2
#define kLogin  @"login"//普通登陆接口
#define kLoginSSO  @"loginSSO"//第三方授权登陆接口
#define kRegister @"register"//注册接口
#define kLoginOut @"loginOut"//注销登录
#define kNewsDetail @"newsDetail" //新闻详情接口
#define kPicsList @"picsList" //图集列表接口
#define kPicsDetail @"picsDetail" //图集详细接口
#define kNewsFlash @"newsFlash" //新闻快讯接口
#define kPushNewList @"pushNewList" //推送新闻列表接口
#define kPostIsPush @"postIsPush" //是否推送状态接口
#define kLiveBroadcast @"liveBroadcast" //直播列表接口
#define kAdDetail @"adDetail" //广告详情接口
#define kCheckToken @"checkToken" //验证token接口
#define kPhoneAuthCode @"phoneAuthCode" //获取手机验证码接口
#define kBindPhonel @"bindPhone" //绑定手机接口


#define kPostDeviceInfo @"postDeviceInfo" //IOS提交设备信息接口(正式)
//#define kPostDeviceInfo @"postDeviceInfo_test"//IOS提交设备信息接口(测试)

//颜色
#define kBackgroundcolor [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1]
#define K808080 UIColorFromRGB(0x808080)
#define kffffff UIColorFromRGB(0xffffff)
#define k000000 UIColorFromRGB(0x000000)
#define k262626 UIColorFromRGB(0x262626)

//shareSDK的宏
#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define BUNDLE_NAME @"Resource"
#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"
#define CONTENT @"分享"
#define SHARE_URL @"http://www.sharesdk.cn"


//自定义宏
#define kFontSize @"fontSize" //设置字体大小标示符
#define kAnimateTime 0.5//动画渐现时间
#define kNDmodel @"model"//日间模式和夜间模式(0:日间; 1:夜间)
#define KPlistDirName @"plist"//本地存储的plist文件夹名字
#define KPlistName @"programa.plist"//本地存储plist文件名
#define KPlistKey0 @"programa"//新闻栏目名称数组
#define KPlistKey1 @"Type"//新闻栏目的id数组
#define KPlistKey11 @"topType"//新闻头图栏目的id数组
#define kClientType 1//1为iphone客户端
#define kAdFileDir @"adImages"//存启动页广告图片的文件夹
#define KImageDirName @"image"//存头图和列表图片的文件夹
#define kUserDir @"user"//用户的账户信息文件夹目录名
#define kUserFile @"user.db"//用户的账户信息文件
#define kdbName @"21cbhDB.db"//总数据库名字
#define kIsPush @"isPush" //存储本地的是否推送关键字
#define kProgramTitles @[@"头条",@"推荐",@"财经",@"金融",@"机构",@"政经",@"科技"]
#define kLocalSource @[@"article.css",@"article_b.css",@"article_s.css",@"article1.css",@"article_b1.css",@"article_s1.css",@"mobile web reset.css",@"webctrl.js",@"jquery.js",@"21cbh.png",@"21logo.png",@"art.png",@"n-r.png",@"qq.png",@"vote.png",@"dp_up.png",@"dp_down.png",@"art_night.png",@"vote_night.png",@"dp_up1.png",@"dp_down1.png",@"n-r2.png",@"avatar.png",@"fangzheng.TTF"]


//cell的各种标签
#define kNewCell1 @"newCell1"
#define kNewCell2 @"newCell2"
#define kNewCell3 @"newCell3"
#define kPicCell1 @"picCell1"
#define kPicCell2 @"picCell2"
#define kPicCell3 @"picCell3"
#define kliveBroadcastCell @"liveBroadcastCell"
#define kDownLoadCell @"DownLoadCell"


