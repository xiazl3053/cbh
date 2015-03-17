//
//  FaceManager.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceView.h"
#import "MoreMenuView.h"

typedef enum {
    ViewStateShowNone,//没显示的状态
    ViewStateShowNormal,//普通键盘状态
    ViewStateShowFace,//显示表情状态
    ViewStateShowMore,//显示更多的状态
}MesssageBarState;

@interface MessageInputManager : NSObject
{
    FaceView* faceView_;
    MoreMenuView* moreMenuView_;
}

+(MessageInputManager *) sharedInstance;
-(void)initFaceWithFrame:(CGRect)frame superView:(const UIView*)superView delegate:(id<FaceViewDelegate>)delegate;
-(void)initMoreMenuWithFrame:(CGRect)frame superView:(const UIView*)superView delegate:(id<MoreMenuViewDelegate>)delegate;
-(void)clearDelegate;
#pragma 通过key查找表情图片字符串
-(NSString*)emjioForKey:(NSString*)key;
#pragma 更新表情控件的Frame
-(void)updateFaceViewFrame:(CGRect)frame;
#pragma 更新更多栏的Frame
-(void)updateMoreMenuViewFrame:(CGRect)frame;

@end
