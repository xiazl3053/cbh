//
//  MessageInputBar.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "MessageInputManager.h"

#define Time  0.2
#define keyboardHeight 216
#define MoreMenuHeight 100
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height

static const float kScreenWidth=320.0;
static const float kNavHeight=44.0;
static const float kTabHeight=49.0;
static const float kStatusHeight=20.0;

@class MessageInputBar;

@protocol MessageInputBarDelegate <NSObject>
@optional
#pragma 键盘高度变化代理
- (void)keyboardAction:(CGFloat)height;
#pragma 发送文字代理
- (void)sendTextAction:(NSString*)text;
#pragma 录音备用
- (void)startRecording:(MessageInputBar*)toolbar;
- (void)endRecording:(MessageInputBar*)toolbar isSend:(BOOL)isSend;
#pragma 选择图片代理
- (void)pickPhoto:(MessageInputBar*)toolbar;
#pragma 打开摄影机代理
- (void)openCamera:(MessageInputBar*)toolbar;
#pragma 发送股票代理
- (void)sendGupiao:(MessageInputBar*)toolbar;
#pragma 发送新闻代理
- (void)sendNewsAction:(MessageInputBar*)toolbar;

@end

@interface MessageInputBar : UIView<HPGrowingTextViewDelegate,FaceViewDelegate,MoreMenuViewDelegate>
{
    HPGrowingTextView* textView_;
    UIButton *faceBtn_;
    //UIButton *voiceBtn_;
    //UIButton *recordBtn_;
    UIButton *moreBtn_;
    
    const UIView* superView;
    UIImageView* backgroundImage_;
    MesssageBarState currentState_;
    //BOOL isVoiceModel;
}

@property (nonatomic,assign) MesssageBarState currentState;
@property (nonatomic,assign) id<MessageInputBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame superView:(const UIView*)view;
#pragma 隐藏键盘
- (void)hideKeyBoard;
#pragma 填充文字数据
- (void)fitTextView:(NSString*)text;
- (void)cleanData;

@end
