//
//  Constant.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-30.
//  Copyright (c) 2013年 ZX. All rights reserved.
//
#import "ZXConstant.h"
#import "DFMConstant.h"
#import "NCMConstant.h"
#import "CWPConstant.h"


//接口地址
//#define kBaseURL @"http://api.21cbh.com/api.php?m="//线上发布服务器的总地址
#define kBaseURL @"http://test.api.21cbh.com/api.php?m="//线上测试服务器的总地址
//#define kBaseURL @"http://192.168.16.18/apitest/api.php?m="//线下测试服务器的总地址
#define kURL(...) [kBaseURL stringByAppendingFormat:[__VA_ARGS__ stringByAppendingFormat:[@"/" stringByAppendingFormat:[__VA_ARGS__ stringByAppendingFormat:@".smpauth"]]]]

//颜色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define kImageCachePath @"21cbh/html/images/imgCache"

//字体名称
#define kFontName @"FZLanTingHei-L-GBK-M"


//通知名称
#define kNotifcationKeyForLogin @"kNotifcationKeyForLogin"//登陆后发的通知
#define kNotifcationKeyForLogout @"kNotifcationKeyForLogout"//注销后发的通知
#define kNotifcationKeyForBindingPhone @"kNotifcationKeyForBindingPhone"//绑定手机的通知
#define kNotifcationKeyForDownloadComplete @"kNotifcationKeyForDownloadComplete"//下载完成通知


#define KSkey @"q@#$%13qwrc*^dfl;^*(23dd" //3des密钥
#define KAppKey @"21app"  //应用加密密钥


