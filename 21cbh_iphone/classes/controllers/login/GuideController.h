//l
//  GuideController.h
//
//  Created by gzty1 on 11-11-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//  新手介绍控制类

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#define APPVERSION @"Application Version"

@class ScrollView;
@class GuideController;

@protocol GuideControllerDelegate<NSObject>
@optional
-(void)handleGuidePageChanged:(GuideController*)guideController;
-(void)handleGuideFinish:(UIButton*)sender;
-(void)handleGuideFinish2:(UIButton*)sender;
@end


@interface GuideController : NSObject <UIScrollViewDelegate,UIActionSheetDelegate,SKStoreProductViewControllerDelegate>
{
    UIView* superView_;
	ScrollView* iScrollView;
    int pageCount_;
    BOOL flag;
    SKStoreProductViewController *SKSVC_;
    MPMoviePlayerController* moviePlayerController_;
}

@property (nonatomic,assign) id<GuideControllerDelegate> delegate;

-(void)checkShowGiveScoreDialog;

+(int)startCount;//返回上次访问次数
+(int)addStartCount;//增加一次访问次数，并返回本次访问次数

//显示展示向导，带淡入效果
-(void)showGuideWithSuperView:(UIView*)superView bounds:(CGRect)bounds bgColor:(UIColor*)bgColor imageArray:(NSArray*)imageArray bgContentMode:(UIViewContentMode)bgContentMode index:(int)index delegate:(id<GuideControllerDelegate>)delegate buttonRect:(CGRect)buttonRect closeRect:(CGRect)closeRect animated:(BOOL)animated;
-(void)showGuideWithSuperView:(UIView*)superView videoFilePathName:(NSString*)videoFilePathName delegate:(id<GuideControllerDelegate>)delegate buttonRect:(CGRect)buttonRect;
-(void)showGuideWithSuperView:(UIView*)superView;

//隐藏向导，带淡出效果
-(void)hideGuideAnimated;
-(void)hideGuide;

//只隐藏，不销毁
-(void)hideFromSuper;
-(void)showInSuper;

-(int)currentIndex;
-(void)setCurrentIndex:(int)currentIndex;

-(void)showAppInApp:(NSString *)appId withParentViewController:(UIViewController*)parentViewController;
+(void)openAppStoreGiveScore;

@end
