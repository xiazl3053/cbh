//
//  MessageInputBar.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MessageInputBar.h"

@implementation MessageInputBar

@synthesize currentState=currentState_;

- (id)initWithFrame:(CGRect)frame superView:(const UIView*)view
{
    self = [super initWithFrame:frame];
    if (self) {
        currentState_=ViewStateShowNone;
//        isVoiceModel=NO;
        superView=view;
    
        self.backgroundColor=UIColorFromRGB(0xe1e1e1);
        
        //可以自适应高度的文本输入框
        textView_ = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 8, 230, 30)];
        textView_.isScrollable = NO;
        textView_.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        textView_.minNumberOfLines = 1;
        textView_.maxNumberOfLines = 4;
        // textView.maxHeight = 200.0f; // 设置最大高度
        //textView_.returnKeyType = UIReturnKeyGo;
        textView_.font = [UIFont systemFontOfSize:15.0f];
        textView_.delegate = self;
        textView_.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView_.backgroundColor = [UIColor whiteColor];
        textView_.placeholder = @"请输入消息";
        textView_.returnKeyType = UIReturnKeySend;
        textView_.layer.cornerRadius=5;
        [self addSubview:textView_];
        
//        recordBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
//        [recordBtn_ setFrame:CGRectMake(45, 9.5, 185, 40)];
//        [recordBtn_ setImage:[UIImage imageNamed:@"speak_normal.png"] forState:UIControlStateNormal];
//        [recordBtn_ setImage:[UIImage imageNamed:@"speak_press.png"] forState:UIControlStateSelected];
//        [recordBtn_ setTitle:@"按住说话" forState:UIControlStateNormal];
//        [recordBtn_ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [recordBtn_ addTarget:self action:@selector(onStartRecord) forControlEvents:UIControlEventTouchDown];
//        [recordBtn_ addTarget:self action:@selector(onEndRecord) forControlEvents:UIControlEventTouchUpInside];
//        [recordBtn_ addTarget:self action:@selector(onStopRecord) forControlEvents:UIControlEventTouchUpOutside]; //添加按下后向上滑动取消语音操作
//        [recordBtn_ setHidden:YES];
//        [self addSubview:recordBtn_];
        
        //音频按钮
//        voiceBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
//        voiceBtn_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
//        [voiceBtn_ setBackgroundImage:[UIImage imageNamed:@"voice_icon.png"] forState:UIControlStateNormal];
//        [voiceBtn_ addTarget:self action:@selector(onVoiceBtnClick) forControlEvents:UIControlEventTouchUpInside];
//        voiceBtn_.frame = CGRectMake(0,4.5,40,40);
//        [self addSubview:voiceBtn_];
        
        //表情按钮
        faceBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
        faceBtn_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [faceBtn_ setImage:[UIImage imageNamed:@"face_icon.png"] forState:UIControlStateNormal];
        [faceBtn_ addTarget:self action:@selector(onFaceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        faceBtn_.frame = CGRectMake(245,4.5,40,40);
        [self addSubview:faceBtn_];
        
        //更多按钮
        moreBtn_=[UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [moreBtn_ setImage:[UIImage imageNamed:@"more_icon.png"] forState:UIControlStateNormal];
        [moreBtn_ addTarget:self action:@selector(onMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        moreBtn_.frame = CGRectMake(280,4.5,40,40);
        [self addSubview:moreBtn_];
        
        CGRect faceRect = CGRectMake(0, CGRectGetMaxY(self.frame),kScreenWidth,keyboardHeight);
        [[MessageInputManager sharedInstance] initFaceWithFrame:faceRect superView:superView delegate:self];
        
        CGRect moreRect = CGRectMake(0, CGRectGetMaxY(self.frame),kScreenWidth,MoreMenuHeight);
        [[MessageInputManager sharedInstance] initMoreMenuWithFrame:moreRect superView:superView delegate:self];
        
//        if (faceView_ == nil) {
//            //创建表情面板
//            CGRect rect = CGRectMake(0, frame.origin.y-kTabHeight-kNavHeight-kStatusHeight-frame.size.height-5,kScreenWidth,keyboardHeight);
//            faceView_ = [[FaceSendView alloc] initWithFrame:rect delegate:self];
//            faceView_.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
//            [superView addSubview:faceView_]; //注意:初始化的时候将表情视图设置到可视窗口外面去,起到隐藏作用
//        }
//        [faceView_ setShow:NO];
        
        //给键盘注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(inputKeyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(inputKeyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

-(void)cleanData
{
    superView=nil;
    self.delegate=nil;
    [[MessageInputManager sharedInstance] clearDelegate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc
{
    [self cleanData];
}

#pragma mark 填充初始文字
- (void)fitTextView:(NSString *)text
{
    textView_.text = text;
}

- (void)addToTextView:(NSString *)aText
{
    NSMutableString* string=[NSMutableString stringWithString:textView_.text];
    NSRange rang=textView_.selectedRange;
    [string insertString:aText atIndex:rang.location];
    textView_.text=string;
    rang.location+=aText.length;
    textView_.selectedRange=rang;
    [textView_ setNeedsDisplay];
}

#pragma mark 点击发送
- (void)sendAction
{
    if (textView_.text.length>0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendTextAction:)])
        {
            [self.delegate sendTextAction:textView_.text];
        }
        textView_.text = @"";
    }
}

#pragma mark 隐藏键盘
-(void)hideKeyBoard
{
    if(currentState_!=ViewStateShowNone)
    {
        [UIView animateWithDuration:Time animations:^{
            CGRect frame=self.frame;
            if (self.frame.size.height>kTabHeight) {
                frame.origin.y=superView.frame.size.height-self.frame.size.height;
            } else {
                frame.origin.y=superView.frame.size.height-kTabHeight;
            }
            self.frame = frame;
            [[MessageInputManager sharedInstance] updateFaceViewFrame:CGRectMake(0, CGRectGetMaxY(self.frame),kScreenWidth,keyboardHeight)];
            [[MessageInputManager sharedInstance] updateMoreMenuViewFrame:CGRectMake(0, CGRectGetMaxY(self.frame),kScreenWidth,MoreMenuHeight)];
        } completion:^(BOOL finished) {
        }];
        [self resetFaceBtn:YES];
        [textView_ resignFirstResponder];
        currentState_=ViewStateShowNone;
        [self callbackAction];
    }
}

#pragma mark 键盘高度回调事件
-(void)callbackAction
{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(keyboardAction:)])
    {
        [self.delegate keyboardAction:self.frame.origin.y];
    }
}

#pragma mark 弹出键盘事件
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSLog(@"键盘即将出现：%@", NSStringFromCGRect(keyBoardFrame));
//        if (self.frame.size.height>kTabHeight) {
            self.frame = CGRectMake(0, keyBoardFrame.origin.y-self.frame.size.height,kScreenWidth,self.frame.size.height);
//        } else {
//            self.frame = CGRectMake(0, keyBoardFrame.origin.y-kNavHeight-kStatusHeight-kTabHeight,kScreenWidth,kTabHeight);
//        }
    } completion:^(BOOL finished) {
    }];
    currentState_=ViewStateShowNormal;
    [textView_ becomeFirstResponder];
    //回调
    [self callbackAction];
}

#pragma mark 隐藏键盘事件
-(void)inputKeyboardWillHide:(NSNotification *)notification
{
}

//- (void)onStartRecord
//{
//    NSLog(@"onStartRecord");
//    //60秒后,自动执行结束录音操作
//    //[self performSelector:@selector(noticeEndRecord:) withObject:nil afterDelay:60];
//}
//
//- (void)noticeEndRecord:(id)sender
//{
//    //向按钮录音按钮发送抬起消息
//    [recordBtn_ sendActionsForControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)onEndRecord
//{
//    NSLog(@"onEndRecord");
//    //[NSObject cancelPreviousPerformRequestsWithTarget:self];
//}
//
//- (void)onStopRecord
//{
//    NSLog(@"onStopRecord");
//    //[NSObject cancelPreviousPerformRequestsWithTarget:self];
//}

//- (void)onVoiceBtnClick
//{
//    isVoiceModel=!isVoiceModel;
//    [self hideKeyBoard];
//    [voiceBtn_ setBackgroundImage:[UIImage imageNamed:isVoiceModel?@"keyboard_icon.png":@"voice_icon.png"] forState:UIControlStateNormal];
//    [recordBtn_ setHidden:!isVoiceModel];
//    [textView_ setHidden:isVoiceModel];
//    //
//    if ([textView_ isHidden] == NO) {
//        [textView_ becomeFirstResponder];
//    } else {
//        [faceBtn_ setBackgroundImage:[UIImage imageNamed:@"face_icon.png"] forState:UIControlStateNormal];
//    }
//}

- (void)hideFaceView:(BOOL)hidden
{
    CGRect frame=CGRectMake(0, hidden?SCREENHEIGHT:CGRectGetMaxY(self.frame),kScreenWidth,keyboardHeight);
    [[MessageInputManager sharedInstance] updateFaceViewFrame:frame];
}

- (void)hideMoreMenuView:(BOOL)hidden
{
    CGRect frame=CGRectMake(0, hidden?SCREENHEIGHT:CGRectGetMaxY(self.frame),kScreenWidth,MoreMenuHeight);
    [[MessageInputManager sharedInstance] updateMoreMenuViewFrame:frame];
}

-(void)resetFaceBtn:(BOOL)flag
{
    if(faceBtn_){
        [faceBtn_ setImage:[UIImage imageNamed:flag?@"face_icon.png":@"keyboard_icon.png"] forState:UIControlStateNormal];
    }
}

- (void)onMoreBtnClick
{
    if (self.frame.origin.y==superView.bounds.size.height-self.frame.size.height)
    {
        [UIView animateWithDuration:Time animations:^{
            CGRect frame=self.frame;
            frame.origin.y-=MoreMenuHeight;
            self.frame=frame;
            [self hideMoreMenuView:NO];
            [self hideFaceView:YES];
        } completion:^(BOOL finished) {
        }];
        currentState_=ViewStateShowMore;
        [self callbackAction];
        return ; //直接返回了
    }
    
    if (currentState_==ViewStateShowMore)
    {
        [self hideMoreMenuView:YES];
        [textView_ becomeFirstResponder];
    }
    else
    {
        [UIView animateWithDuration:Time animations:^{
            self.frame = CGRectMake(0,superView.frame.size.height-MoreMenuHeight-self.frame.size.height,kScreenWidth,self.frame.size.height);
            [textView_ resignFirstResponder];
            [self hideMoreMenuView:NO];
            [self hideFaceView:YES];
        } completion:^(BOOL finished) {
            [self resetFaceBtn:YES];
        }];
        currentState_=ViewStateShowMore;
    }
    [self callbackAction];
    
}

- (void)onFaceBtnClick
{
//    if (isVoiceModel) {
//        isVoiceModel = NO;
//        [voiceBtn_ setBackgroundImage:[UIImage imageNamed:isVoiceModel?@"keyboard_icon.png":@"voice_icon.png"] forState:UIControlStateNormal];
//        [recordBtn_ setHidden:!isVoiceModel];
//        [textView_ setHidden:isVoiceModel];
//    }
    if (self.frame.origin.y==superView.bounds.size.height-self.frame.size.height)
    {
        [UIView animateWithDuration:Time animations:^{
            CGRect frame=self.frame;
            frame.origin.y-=keyboardHeight;
            self.frame=frame;
            [self hideMoreMenuView:YES];
            [self hideFaceView:NO];
        } completion:^(BOOL finished) {
            
        }];
        currentState_=ViewStateShowFace;
        [self resetFaceBtn:NO];
        [self callbackAction];
        return ; //直接返回了
    }
    
    if (currentState_==ViewStateShowFace)
    {
        [self hideFaceView:YES];
        [textView_ becomeFirstResponder];
        [self resetFaceBtn:YES];
    }
    else
    {
        [UIView animateWithDuration:Time animations:^{
            self.frame = CGRectMake(0,superView.frame.size.height-keyboardHeight-self.frame.size.height,kScreenWidth,self.frame.size.height);
            [textView_ resignFirstResponder];
            [self hideMoreMenuView:YES];
            [self hideFaceView:NO];
        } completion:^(BOOL finished) {
        }];
        [self resetFaceBtn:NO];
        currentState_=ViewStateShowFace;
    }
    [self callbackAction];
}

#pragma mark - ------------FaceViewDelegate 的代理方法----------------

-(void)itemClickEvent:(NSString *)content
{
    [self addToTextView:content];
}

-(void)deleteClickEvent
{
    NSString* str=textView_.text;
    if(str.length<=0)
        return;
    int n=-1;
    if( [str characterAtIndex:str.length-1] == ']'){
        for(int i=str.length-1;i>=0;i--){
            if( [str characterAtIndex:i] == '[' ){
                n = i;
                break;
            }
        }
    }
    if(n>=0)
        textView_.text = [str substringWithRange:NSMakeRange(0,n)];
    else
        textView_.text = [str substringToIndex:str.length-1];
}

-(void)sendClickEvent
{
    [self sendAction];
}

#pragma mark - ------------MoreMenuViewDelegate 的代理方法----------------

-(void)didSelecteMenuItem:(MoreMenuItem *)shareMenuItem atIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            if(self.delegate&&[self.delegate respondsToSelector:@selector(pickPhoto:)])
            {
                [self.delegate pickPhoto:self];
            }
            break;
        case 1:
            if(self.delegate&&[self.delegate respondsToSelector:@selector(openCamera:)])
            {
                [self.delegate openCamera:self];
            }
            break;
        case 2:
            if(self.delegate&&[self.delegate respondsToSelector:@selector(sendGupiao:)])
            {
                [self.delegate sendGupiao:self];
            }
            break;
        case 3:
            if(self.delegate&&[self.delegate respondsToSelector:@selector(sendNewsAction:)])
            {
                [self.delegate sendNewsAction:self];
            }
            break;
        default:
            break;
    }
}

#pragma mark - ------------HPGrowingTextViewDelegate 的代理方法----------------

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self resetFaceBtn:YES];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = growingTextView.frame.size.height-height;
	CGRect rect = self.frame;
    rect.size.height -= diff;
    rect.origin.y += diff;
	self.frame = rect;
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self sendAction];
    return YES;
}

@end
