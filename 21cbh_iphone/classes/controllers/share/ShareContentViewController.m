//
//  ShareContentViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ShareContentViewController.h"
#import "MBProgressHUD+Add.h"
#import <ShareSDK/ShareSDK.h>
#import "AGAuthViewController.h"
#import "NoticeOperation.h"
#import "NCMConstant.h"

#define kContentViewHeight 170

@interface ShareContentViewController (){
    UIView *_contentView;
    UITextView *_textView;
    UIButton *_yes_btn;
    
    BOOL _isFirst;
    NSString *_title;
    NSString *_url;
    NSString *_shareName;
    NSInteger _shareType;
    NSString *_shareIcon;
    
    UIViewController *_controller;
    
    UIView *_alert;//提示窗口
}

@end

@implementation ShareContentViewController

-(id)initWithTitle:(NSString *)title url:(NSString *)url shareName:(NSString *)shareName shareIcon:(NSString *)shareIcon shareType:(NSInteger)shareType controller:(UIViewController *)controller{
    if (self=[super init]) {
        _title=title;
        _url=url;
        _shareName=shareName;
        _shareType=shareType;
        _controller=controller;
        _shareIcon=shareIcon;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
    
    [self initNotificationKeyBoard];
}


-(void)viewDidAppear:(BOOL)animated{
    if (_isFirst) {
//        [UIView animateWithDuration:0.35f animations:^{
//            CGRect frame=_contentView.frame;
//            frame.origin.y-=kContentViewHeight;
//            _contentView.frame=frame;
//            
//        } completion:^(BOOL finished) {
//            
//            
//        }];
        _isFirst=NO;
    }
    [_textView becomeFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // 取出set中的那个UItouch对象
    UITouch *touch = [touches anyObject];
    // 获取触摸点在_contentView上的位置
    CGPoint point = [touch locationInView:_contentView];
    CGFloat x=point.x;
    CGFloat y=point.y;
    if (0<x<_contentView.frame.size.width&&y>0) {//点击到了_contentview的区域
        NSLog(@"点击_contentView");
        return;
    }
    
    //退出设置
    [self exitComment];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 初始化变量
-(void)initParams{
    _isFirst=YES;
}
#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    
    //内容视图
//    UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height, self.view.frame.size.width, kContentViewHeight)];
    
    UIScreen *screen=[UIScreen mainScreen];
    UIView *contentView=[[UIView alloc]initWithFrame:CGRectMake(0, screen.bounds.size.height, self.view.frame.size.width, kContentViewHeight)];
    
    contentView.backgroundColor=UIColorFromRGB(0x262626);
    [self.view addSubview:contentView];
    _contentView=contentView;
    
    UIView *top=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
    [_contentView addSubview:top];
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    line.backgroundColor=UIColorFromRGB(0x808080);
    [top addSubview:line];
    
    
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake((top.frame.size.width-100)*0.5f,0, 100, 40)];
    lable.backgroundColor=[UIColor clearColor];
    lable.textAlignment=NSTextAlignmentCenter;
    lable.font=[UIFont fontWithName:kFontName size:16];
    lable.textColor=UIColorFromRGB(0xffffff);
    lable.text=_shareName;
    [top addSubview:lable];
    
    UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-290)*0.5f, 40, 290, 100)];
    textView.font=[UIFont fontWithName:kFontName size:15];
    textView.textColor=UIColorFromRGB(0x000000);
    textView.textAlignment=NSTextAlignmentLeft;
    //    textFiled.layer.borderWidth = 0.5;
    //    textFiled.layer.borderColor=[UIColorFromRGB(0x555555) CGColor];
    textView.text=[NSString stringWithFormat:@"%@ %@",_title,KSharePrefixTitle];
    //textView.text=[NSString stringWithFormat:@"%@",_title];
    textView.delegate=self;
    [top addSubview:textView];
    _textView=textView;
    [_textView becomeFirstResponder];
    _textView.selectedRange=NSMakeRange(0,0);
    
    
    UIImage *img=[UIImage imageNamed:@"comment_no"];
    UIButton *no_btn=[[UIButton alloc] initWithFrame:CGRectMake(20-img.size.width*0.5f, (40-img.size.height*2)*0.5f, img.size.width*2, img.size.height*2)];
//    [no_btn setImage:img forState:UIControlStateNormal];
//    [no_btn setImage:img forState:UIControlStateHighlighted];
    [no_btn setTitle:@"取消" forState:UIControlStateNormal];
    [no_btn.titleLabel setFont:[UIFont fontWithName:kFontName size:KBtnFontSize]];
    [no_btn addTarget:self action:@selector(exitComment) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:no_btn];
    
    
    img=[UIImage imageNamed:@"comment_yes_selected"];
    UIButton *yes_btn=[[UIButton alloc] initWithFrame:CGRectMake(top.frame.size.width-20-img.size.width*2+img.size.width*0.5f, (40-img.size.height*2)*0.5f, img.size.width*2, img.size.height*2)];
//    [yes_btn setImage:img forState:UIControlStateNormal];
//    [yes_btn setImage:img forState:UIControlStateHighlighted];
    [yes_btn setTitle:@"分享" forState:UIControlStateNormal];
    [yes_btn setTitleColor:KBtnHighlightStateColor forState:UIControlStateNormal];
    [yes_btn.titleLabel setFont:[UIFont fontWithName:kFontName size:KBtnFontSize]];
    [yes_btn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    yes_btn.userInteractionEnabled=YES;
    [top addSubview:yes_btn];
    _yes_btn=yes_btn;
    
}

#pragma mark 退出设置
-(void)exitComment{
    [_textView resignFirstResponder];
    
    [UIView animateWithDuration:0.35f animations:^{//设置面板退下
        CGRect frame=_contentView.frame;
        frame.origin.y+=kContentViewHeight;
        _contentView.frame=frame;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2f animations:^{//界面渐隐
            self.view.alpha=0;
            
        } completion:^(BOOL finished){
            
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
        }];
        
    }];
}


#pragma mark 分享
-(void)shareBtn{
    _alert=[[NoticeOperation getId] showAlertWithMsg:@"分享中..." imageName:@"D_Refresh" toView:_controller.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
    
    _yes_btn.userInteractionEnabled=NO;
    
    if (!_url||_url.length<2) {
        _url=@"http://www.21cbh.com";
    }
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@%@",_textView.text,_url]
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:_shareIcon]
                                                title:[NSString stringWithFormat:@"%@",_textView.text]
                                                  url:_url
                                          description:NSLocalizedString(@"21世纪网", @"21世纪网")
                                            mediaType:SSPublishContentMediaTypeText];
   // NSString *content=[NSString stringWithFormat:@"%@ %@",_textView.text,KSharePrefixTitle];
    
    //*****************************************定制***********************************************//
    
    
    //定制邮件信息
    [publishContent addMailUnitWithSubject:_textView.text
                                   content:[NSString stringWithFormat:@"%@ %@",_textView.text,_url]
                                    isHTML:[NSNumber numberWithBool:YES]
                               attachments:INHERIT_VALUE
                                        to:nil
                                        cc:nil
                                       bcc:nil];
    
    //定制短信信息
    [publishContent addSMSUnitWithContent:[NSString stringWithFormat:@"%@ %@",_textView.text,_url]];
    
    //定制人人网信息
    [publishContent addRenRenUnitWithName:_textView.text
                              description:INHERIT_VALUE
                                      url:_url
                                  message:INHERIT_VALUE
                                    image:[ShareSDK imageWithUrl:_shareIcon]
                                  caption:nil];
    
    //定制QQ空间信息
    [publishContent addQQSpaceUnitWithTitle:_textView.text
                                        url:_url
                                       site:_textView.text
                                    fromUrl:nil
                                    comment:INHERIT_VALUE
                                    summary:INHERIT_VALUE
                                      image:[ShareSDK imageWithUrl:_shareIcon]
                                       type:INHERIT_VALUE
                                    playUrl:nil
                                       nswb:nil];
    
    //定制QQ分享内容
    [publishContent addQQUnitWithType:[NSNumber numberWithInt:2]
                              content:_textView.text
                                title:nil
                                  url:_url
                                image:[ShareSDK imageWithUrl:_shareIcon]];
    
    
    //定制微信好友信息
    [publishContent addWeixinSessionUnitWithType:[NSNumber numberWithInt:2]
                                         content:_textView.text
                                           title:_textView.text
                                             url:_url
                                      thumbImage:[ShareSDK imageWithUrl:_shareIcon]
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];

    
    //定制微信朋友圈信息
    [publishContent addWeixinTimelineUnitWithType:[NSNumber numberWithInteger:2]
                                          content:_textView.text
                                            title:_textView.text
                                              url:_url
                                       thumbImage:[ShareSDK imageWithUrl:_shareIcon]
                                            image:INHERIT_VALUE
                                     musicFileUrl:_url
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    
    //定制QQ分享信息
    [publishContent addQQUnitWithType:[NSNumber numberWithInteger:2]
                              content:_textView.text
                                title:_textView.text
                                  url:_url
                                image:[ShareSDK imageWithUrl:_shareIcon]];
    
    
    //定制易信好友信息
    [publishContent addYiXinSessionUnitWithType:[NSNumber numberWithInteger:2]
                                        content:_textView.text
                                          title:_textView.text
                                            url:_url
                                     thumbImage:[ShareSDK imageWithUrl:_shareIcon]
                                          image:INHERIT_VALUE
                                   musicFileUrl:INHERIT_VALUE
                                        extInfo:INHERIT_VALUE
                                       fileData:INHERIT_VALUE];
    
    
    //定义易信朋友圈信息
    [publishContent addYiXinTimelineUnitWithType:[NSNumber numberWithInteger:2]
                                         content:_textView.text
                                           title:_textView.text
                                             url:_url
                                      thumbImage:[ShareSDK imageWithUrl:_shareIcon]
                                           image:INHERIT_VALUE
                                    musicFileUrl:INHERIT_VALUE
                                         extInfo:INHERIT_VALUE
                                        fileData:INHERIT_VALUE];
    
    
    //*********************************************************************************************//
    
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    
    if (_shareType==ShareTypeWeixiSession||_shareType==ShareTypeWeixiTimeline||_shareType==ShareTypeQQ||_shareType==ShareTypeSMS||_shareType==ShareTypeMail) {
        
        [ShareSDK shareContent:publishContent type:_shareType authOptions:authOptions shareOptions:nil statusBarTips:NO result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
            if (state == SSResponseStateSuccess)
            {
                [self exitComment];
                [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"分享成功" imageName:@"alert_savephoto_success"];
            }
            else if (state == SSResponseStateFail)
            {
                _yes_btn.userInteractionEnabled=YES;
                NSString *errorDescription=[error errorDescription];
                if ([errorDescription isKindOfClass:[NSNull class]] ||!errorDescription) {
                    errorDescription=@"分享失败";
                }
                NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], errorDescription);
                [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:errorDescription imageName:@"error"];
            }else if(state==SSResponseStateCancel){
                [self exitComment];
                [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"取消分享" imageName:@"error"];
            }
        }];

    }else{
        


        
        [ShareSDK getUserInfoWithType:_shareType authOptions:authOptions result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
            if (result) {
                
                [self savedata:[userInfo nickname] andShareType:_shareType];
                
                [ShareSDK shareContent:publishContent type:_shareType authOptions:nil shareOptions:nil statusBarTips:NO result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                    if (state == SSResponseStateSuccess)
                    {
                        [self exitComment];
                        [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"分享成功" imageName:@"alert_savephoto_success"];
                    }
                    else if (state == SSResponseStateFail)
                    {
                        _yes_btn.userInteractionEnabled=YES;
                        NSString *errorDescription=[error errorDescription];
                        if ([errorDescription isKindOfClass:[NSNull class]] ||!errorDescription) {
                            errorDescription=@"分享失败";
                        }
                        NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], errorDescription);
                        [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:errorDescription imageName:@"error"];
                    }else if(state==SSResponseStateCancel){
                        [self exitComment];
                        [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"取消分享" imageName:@"error"];
                    }
                }];
                
            }else{
                NSLog(@"授权失败!");
            }
        }];
    }
}

-(void)savedata:(NSString *)nickName andShareType:(int)type{
            _yes_btn.userInteractionEnabled=YES;
            
            NSArray *list = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
            
            if (list==nil) {
                
                
                NSMutableArray   *_shareTypeArray = [[NSMutableArray alloc] init];
                
                NSArray *shareTypes = [ShareSDK connectedPlatformTypes];
                for (int i = 0; i < [shareTypes count]; i++)
                {
                    NSNumber *typeNum = [shareTypes objectAtIndex:i];
                    ShareType type = [typeNum integerValue];
                    
                    if (type == ShareTypeSinaWeibo||type == ShareTypeQQSpace|| type == ShareTypeEvernote)
                    {
                        [_shareTypeArray addObject:[NSMutableDictionary dictionaryWithObject:[shareTypes objectAtIndex:i]
                                                                                      forKey:@"type"]];
                    }
                }
                
                NSArray *authList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
                if (authList == nil)
                {
                    [_shareTypeArray writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
                }
                else
                {
                    for (int i = 0; i < [authList count]; i++)
                    {
                        NSDictionary *item = [authList objectAtIndex:i];
                        for (int j = 0; j < [_shareTypeArray count]; j++)
                        {
                            if ([[[_shareTypeArray objectAtIndex:j] objectForKey:@"type"] integerValue] == [[item objectForKey:@"type"] integerValue])
                            {
                                [_shareTypeArray replaceObjectAtIndex:j withObject:[NSMutableDictionary dictionaryWithDictionary:item]];
                                break;
                            }
                        }
                    }
                }
            }
            
            NSArray *temp = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
            
            NSMutableArray *save=[NSMutableArray array];
            
            for (NSDictionary *obj in temp) {
                NSLog(@"type=%@,username=%@",[obj objectForKey:@"type"],[obj objectForKey:@"username"]);
                if ([[obj objectForKey:@"type"]integerValue]==type) {
                    NSMutableDictionary *item=[NSMutableDictionary dictionary];
                    [item setValue:nickName forKey:@"username"];
                    [item setValue:[NSNumber numberWithInt:type] forKey:@"type"];
                    [save addObject:item];
                }else{
                    [save addObject:obj];
                }
            }
            [save writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];

}



#pragma mark - ------------------UITextView的代理方法------------------
- (void)textViewDidChange:(UITextView *)textView {
    UIImage *img=nil;
    if ([textView.text length]>0) {
        img=[UIImage imageNamed:@"comment_yes_selected"];
        _yes_btn.userInteractionEnabled=YES;
    }else{
        img=[UIImage imageNamed:@"comment_yes"];
        _yes_btn.userInteractionEnabled=NO;
    }
    
//    [_yes_btn setImage:img forState:UIControlStateNormal];
//    [_yes_btn setImage:img forState:UIControlStateHighlighted];
}

#pragma mark -注册键盘监听
-(void)initNotificationKeyBoard{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
}

#pragma mark -键盘高度变化
-(void)keyBoardFrameChange:(NSNotification *)info{
    NSDictionary *dic= info.userInfo;
    NSLog(@"%@",dic);
    CGRect rect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float duration=[[dic objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    int curve=[[dic objectForKey:UIKeyboardAnimationCurveUserInfoKey]intValue];
    CGRect temp=_contentView.frame;
    [UIView setAnimationCurve:curve];
    [UIView animateWithDuration:duration animations:^{
        _contentView.frame=CGRectMake(0, rect.origin.y-kContentViewHeight, temp.size.width, kContentViewHeight);
    }];
}

#pragma mark -键盘弹出
-(void)keyBoardWillShow:(NSNotification *)info{
    NSDictionary *dic= info.userInfo;
    NSLog(@"%@",dic);
    CGRect rect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"rect=%@",NSStringFromCGRect(rect));
    float duration=[[dic objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    int curve=[[dic objectForKey:UIKeyboardAnimationCurveUserInfoKey]intValue];
    
    CGRect temp=_contentView.frame;
    [UIView setAnimationCurve:curve];
    [UIView animateWithDuration:duration animations:^{
        _contentView.frame=CGRectMake(0, rect.origin.y-kContentViewHeight, temp.size.width, kContentViewHeight);
    }];
}

-(void)dealloc{

    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


@end
