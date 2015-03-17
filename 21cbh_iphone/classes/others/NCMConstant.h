//
//  NCMConstant.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

//接口定义

#define KfollowList @"followList" // 评论信息读取接口
#define Ksepcial @"special" //专题接口
#define Kding @"ding" //点赞接口
#define Kfollow @"follow" //评论回复接口
#define Kfigure @"figure" //图像上传
#define kfeedBack @"feedback" //用户反馈
#define kmoreApp @"moreApps" //更多应用
#define Kuserinfo @"userinfo" //用户信息接口


//风格
typedef NS_ENUM(NSInteger, APPSTYLE_TYPE) {
    APPSTYLE_TYPE_WHITE,
    APPSTYLE_TYPE_BLACK,
};


// IOS版本
#define kDeviceVersion [[[UIDevice currentDevice] systemVersion]floatValue]  // DFM 版本判断

//应用URL
#define KAppstorePrefix @"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?mt=8&id="//appstore前缀
#define KApple_ID @"635791212" //应用ID
#define KAppstoreUrlString [KAppstorePrefix stringByAppendingString:KApple_ID] //应用appstore地址
#define kAppCurVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]//版本获取
#define KAppStorePath @"https://itunes.apple.com/cn/app/21shi-ji-wang-yuan-chuang/id635791212?mt=8"
#define KAppAboutUrl @"http://3g.21cbh.com/app3/app-about-w.html"//关于页面白色版
#define KAppAboutUrl1 @"http://3g.21cbh.com/app3/app-about-b.html"//关于页面黑色版

#define KSharePrefixTitle @"【分享自21世纪网新闻客户端】"


//company
#define KCompanyName @"21世纪网"
#define KCompanyUrl @"http://www.21chb.com"


/*****Tool********/
#define KSpecialTopDefaultImageName @"top_default.png"


//comment
#define kBgcolor UIColorFromRGB(0x000000)
#define KBgWitheColor UIColorFromRGB(0Xf0f0f0)
#define KCommentContentFontSize 14.0
#define KCommentContentColor UIColorFromRGB(0x808080)
#define KCommentNameFontSize 12
#define KCommentNameColor UIColorFromRGB(0xe86e25)
#define KCommentContentBGColor UIColorFromRGB(0x262626)
#define KCommentViewBGColor UIColorFromRGB(0Xf0f0f0)
#define KCommentTableSeparatorColor UIColorFromRGB(0Xe1e1e1)
#define KCommentMaxWidth 280
#define KCommentContentCalcuMaxWidth 260
#define KCommentMaxShrink 4
#define KCommentNewNameHeight 30
#define KAlertCoordinateY 130

//comment floor
#define kMaxFloor 4
#define KCommentFloorNameColor UIColorFromRGB(0x808080)
#define KCommentFloorBorderColor UIColorFromRGB(0xe1e1e1)
#define KCommentFloorBorderWidth 1.0
#define KCommentFloorBGColor UIColorFromRGB(0xffffff)
#define KCommentFloorNumberColor  UIColorFromRGB(0x8d8d8d)
#define KCommentFloorContentColor UIColorFromRGB(0x000000)
#define KCommentFloorExpandBtnTextColor UIColorFromRGB(0xe86e25)
#define KCommentFloorNameFontSize 12
#define KCommentFloorNumberFontSize 12
#define KCommentFloorContentFontSize 14
#define KCommentFloorNameHeight 30

//commentSendView
#define KCommentSendViewTitleFontSize 16
#define KCommentSendViewTitleColor UIColorFromRGB(0xffffff)
#define KCommentSendViewContentFontSize 15
#define KCommentSendViewContentColor UIColorFromRGB(0x000000)
#define KCommentSendViewBGColor UIColorFromRGB(0x262626)


//special
#define KSpecialTopHieght 159
#define KSpecialTopShowTitleBGColor UIColorFromRGB(0X000000)
#define KSpecialSectionViewBGColor UIColorFromRGB(0X262626)
#define KSpecialSectionViewTitleFontSize [UIFont systemFontOfSize:15.0]
#define KSpecialSectionViewTitleFontColor UIColorFromRGB(0Xffffff)


//feedback
#define KFeedbackPlaceholderLabelFontSize 14
#define KFeedBackTextViewTextFontSize 16


//moreapp
#define KMoreAppCellTitleFontSize 17
#define KMoreAppCellDescFontSize  14

//notice
#define KNoticeErrorTitle @"网络不给力"
#define KNoticeErrotImage @"error.png"

#define KNoticeNoMoreDataTitle @"已无更多记录"
#define KNoticeNoMoreDataIcon @"alert_tanhao.png"
#define KNoticeNetWorkErrorTitle @"网络不给力"
#define KNoticeNetWorkErrorIcon @"alert_tanhao.png"
#define KNoticeLoadMoreAppFailTitle @"获取更多应用失败"
#define KNoticeLoadMoreAppFailIcon @"error.png"
#define KNoticeLoadVersionFailTitle @"获取版本失败"
#define KNoticeLoadVersionFailIcon @"error.png"
#define KNoticeLoadCommentFailTitle @"获取评论失败"
#define KNoticeLoadCommentFailIcon @"error.png"
#define KNoticeLoadAboutFailTitle @"获取关于失败"
#define KNoticeLoadAboutFailIcon @"error.png"
#define KNoticeFeedbackFailTitle @"反馈失败"
#define KNoticeFeedbackFailIcon @"error.png"
#define KNoticeFeedbackSuccessTitle @"反馈成功"
#define KNoticeFeedBackSuccessIcon @"NewsComment_CopySuccee.png"

#define KNoticeSendCommentSuccessTitle @"发送成功"
#define KNoticeSendCommentSuccessIcon @"NewsComment_CopySuccee.png"
#define KNoticeSendCommentFailTitle @"发送失败"
#define KNoticeSendCommentFailIcon @"error.png"
#define KNoticeSendCommentBeingTitle @"发送中"
#define KNoticeSendCommentBeingIcon @"D_Refresh.png"
#define KNoticeContentLengthFailTitle @"多说两句吧"
#define KNoticeContentLengthFailIcon @"error.png"


//系统
#define KDataCacheDocument [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define KSystemVersion [[UIDevice currentDevice] systemVersion]
#define KScreenSize [UIScreen mainScreen].bounds.size


//按钮高亮
#define KBtnHighlightStateColor UIColorFromRGB(0xe86e25)
#define KBtnFontSize 14
#define KAppStyle APPSTYLE_TYPE_WHITE

#define KServerBackDataKey @"data"
#define KServerBackMsgKey @"Msg"
#define KServerBackErrorKey @"errno"
#define KServerBackNetWorkDisconnectMsg @"网络不给力"
#define KServerBackNetWorkFialMsg @"请求失败"

