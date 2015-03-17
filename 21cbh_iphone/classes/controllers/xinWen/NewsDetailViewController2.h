//
//  NewsDetailViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NewsDetailModel.h"
#import "AdBarView.h"
#import "AdBarModel.h"
#import "PlayerTool2.h"

@interface NewsDetailViewController2 : BaseViewController<UIWebViewDelegate,AdBarViewDelegate,PlayerTool2Protocol,UIGestureRecognizerDelegate>

@property(copy,nonatomic)NSString *articleId;//文章id
@property(copy,nonatomic)NSString *programId;//栏目id
@property(assign,nonatomic)NSInteger currentIndex;//当前图片标签
@property(assign,nonatomic)BOOL isVertical;//是否是水平切换
@property(strong,nonatomic)NewsDetailModel *ndm;
@property(assign,nonatomic)BOOL isReturn;//根据它来判断打开聊天界面还是返回聊天界面

-(id)initWithProgramId:(NSString *)programId articleId:(NSString *)articleId main:(UIViewController *)main;
-(id)initWithProgramId:(NSString *)programId articleId:(NSString *)articleId main:(UIViewController *)main isReturn:(BOOL)isReturn;

#pragma mark 检测该广告栏广告是否是用户点击过的
-(void)checkAdBar:(AdBarModel *)abm;
#pragma mark 获取广告栏数据后的处理
-(void)getAdBarHandle:(AdBarModel *)adBarModel;
#pragma mark 获取文章详情页数据后的处理
-(void)getNewsDetailHandle:(NewsDetailModel *)ndm;
#pragma mark 发表评论接口
-(void)getComment:(NSString *)commentString;

@end
