//
//  ShareViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareContentViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "NoticeOperation.h"
#import "CommonOperation.h"
#import "UIImage+ZX.h"

#define kContentViewHeight 250
#define ksetLableHeight 15
#define ksetLableWidth 60
#define ksetLableInterval 10
#define kCancelBtnHeight 49

@interface ShareViewController (){
    
    UIView *_contentView;
    
    NSString *_title;
    NSString *_url;
    NSString *_icon;
    NSMutableArray *_data;
    UIViewController *_controller;
    
    BOOL _isFirst;
    
    UIView *_alert;//提示窗口
}

@end

@implementation ShareViewController

-(id)initWithTitle:(NSString *)title url:(NSString *)url icon:(NSString *)icon controller:(UIViewController *)controller{
    if (self=[super init]) {
        _title=title;
        _url=url;
        _icon=icon;
        _controller=controller;
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
    
}


-(void)viewDidAppear:(BOOL)animated{
    
    if (_isFirst) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame=_contentView.frame;
            frame.origin.y-=kContentViewHeight;
            _contentView.frame=frame;
            
        } completion:^(BOOL finished) {
            
            
        }];
        _isFirst=NO;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self exitSettins];
}



#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    _isFirst=YES;
}
#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    
    //内容视图
    UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height, self.view.frame.size.width, kContentViewHeight)];
    contentView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    [self.view addSubview:contentView];
    _contentView=contentView;
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    line.backgroundColor=UIColorFromRGB(0x808080);
    [contentView addSubview:line];
    
    //标题
    UILabel *title_lable=[[UILabel alloc] initWithFrame:CGRectMake((contentView.frame.size.width-100)*0.5f, 10, 100, 20)];
    title_lable.backgroundColor=[UIColor clearColor];
    title_lable.text=@"分享到";
    title_lable.textAlignment=NSTextAlignmentCenter;
    title_lable.font=[UIFont fontWithName:kFontName size:20];
    title_lable.textColor=UIColorFromRGB(0x000000);
    [contentView addSubview:title_lable];
    
    [self loadMoreShareItems:title_lable.frame.origin.y+title_lable.frame.size.height+15];

    //分割线
    UIView *line2=[[UIView alloc] initWithFrame:CGRectMake(0, _contentView.frame.size.height-kCancelBtnHeight, _contentView.frame.size.width, 0.5)];
    line2.backgroundColor=UIColorFromRGB(0x808080);
    
    
    //取消按钮
    UIButton *cancelBtn=[[UIButton alloc]  initWithFrame:CGRectMake(0, line2.frame.origin.y, _contentView.frame.size.width, kCancelBtnHeight)];
    cancelBtn.titleLabel.font=[UIFont fontWithName:kFontName size:20];
    [cancelBtn setTitle:@"取     消" forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取     消" forState:UIControlStateHighlighted];
    [cancelBtn setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:UIColorFromRGB(0xee5909) forState:UIControlStateHighlighted];
    [cancelBtn setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    cancelBtn.tag=2003;
    [cancelBtn addTarget:self action:@selector(exitSettins) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:cancelBtn];
    [contentView addSubview:line2];
    
}


#pragma mark 加载更多设置选项
-(void)loadMoreShareItems:(CGFloat)height{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"share" ofType:@"plist"];
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    _data=data;
    CGFloat interval=(_contentView.frame.size.width-4*36)/5;
    NSLog(@"data.count:%i",data.count);
    for (int i=0; i<data.count; i++) {
        NSMutableArray *array=[data objectAtIndex:i];
        UIImage *img=[[UIImage imageNamed:[array objectAtIndex:0]] scaleToSize:CGSizeMake(36, 36)];
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        btn.tag=i;
        [btn setImage:img forState:UIControlStateNormal];
        [btn setImage:img forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame=btn.frame;
        int num=i%4;
        frame.origin.x=(num+1)*interval+num*img.size.width;
        
        frame.origin.y=height+(img.size.height+ksetLableHeight+ksetLableInterval*2)*(i/4);
        btn.frame=frame;
        
        
        UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x+(btn.frame.size.width-ksetLableWidth)*0.5f, btn.frame.origin.y+btn.frame.size.height+ksetLableInterval, ksetLableWidth, ksetLableHeight)];
        lable.backgroundColor=[UIColor clearColor];
        lable.text=[array objectAtIndex:1];
        lable.textAlignment=NSTextAlignmentCenter;
        lable.font=[UIFont fontWithName:kFontName size:12];
        lable.textColor=UIColorFromRGB(0x000000);
        
        
        [_contentView addSubview:btn];
        [_contentView addSubview:lable];
        
    }
}


#pragma mark 各种按钮的点击事件
-(void)btnclick:(UIButton *)btn{
    //退出应用
    [self exitSettins];
    NSMutableArray *array=[_data objectAtIndex:btn.tag];
    [self shareBtn:[[array objectAtIndex:2]intValue]];

}

#pragma mark 退出设置
-(void)exitSettins{
    [UIView animateWithDuration:0.3f animations:^{//设置面板退下
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
-(void)shareBtn:(NSInteger)type{
    
    _alert=[[NoticeOperation getId] showAlertWithMsg:@"分享中..." imageName:@"D_Refresh" toView:_controller.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
    
    if (!_url||_url.length<2) {
        _url=@"http://www.21cbh.com";
    }
    
    NSString *shareTitle=[NSString stringWithFormat:@"%@",_title];
    NSString *shareUrl=_url;
    id<ISSCAttachment> img=nil;
    NSString *shareIcon=_icon;
    if (shareIcon&&shareIcon.length>1) {
        img=[ShareSDK imageWithUrl:shareIcon];
    }
    NSLog(@"shareIcon:%@",shareIcon);
    if (!img) {
        shareIcon=[[NSBundle mainBundle]pathForResource:@"Icon_120x120" ofType:@"png"];
        img=[ShareSDK imageWithPath:shareIcon];
    }
    
    NSString *shareContent=[NSString stringWithFormat:@"%@ %@",_title,KSharePrefixTitle];
    NSInteger shareType=type;
    
    
    id<ISSContent> publishContent =nil;
    
    if (shareType==ShareTypeSinaWeibo) {
        
        
        publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@ %@ %@",shareContent,shareUrl,@"@21世纪网"]
                                           defaultContent:shareContent
                                                    image:img
                                                    title:shareTitle
                                                      url:shareUrl
                                              description:NSLocalizedString(@"21cbh", @"21世纪网")
                                                mediaType:SSPublishContentMediaTypeNews];
    }else{
        publishContent = [ShareSDK content:shareContent
                            defaultContent:shareContent
                                     image:img
                                     title:shareTitle
                                       url:shareUrl
                               description:nil
                                 mediaType:SSPublishContentMediaTypeNews];
    }

    
    //*****************************************定制***********************************************//
    
    //定制微信好友信息
    [publishContent addWeixinSessionUnitWithType:[NSNumber numberWithInt:2]
                                         content:shareContent
                                           title:shareTitle
                                             url:shareUrl
                                      thumbImage:img
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    
    //定制微信朋友圈信息
    [publishContent addWeixinTimelineUnitWithType:[NSNumber numberWithInteger:2]
                                          content:shareContent
                                            title:shareContent
                                              url:shareUrl
                                       thumbImage:img
                                            image:INHERIT_VALUE
                                     musicFileUrl:nil
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    
    
    
    //定制QQ分享内容
    [publishContent addQQUnitWithType:[NSNumber numberWithInt:2]
                              content:shareContent
                                title:shareTitle
                                  url:shareUrl
                                image:img];
    
    //定制短信信息
    [publishContent addSMSUnitWithContent:[NSString stringWithFormat:@"%@ %@",shareContent,shareUrl]];
    

    //定制邮件信息
    [publishContent addMailUnitWithSubject:shareTitle
                                   content:[NSString stringWithFormat:@"%@ %@",shareContent,shareUrl]
                                    isHTML:[NSNumber numberWithBool:YES]
                               attachments:INHERIT_VALUE
                                        to:nil
                                        cc:nil
                                       bcc:nil];
    
    
    //定制QQ空间信息
    [publishContent addQQSpaceUnitWithTitle:shareContent
                                        url:shareUrl
                                       site:KCompanyName
                                    fromUrl:KCompanyUrl
                                    comment:shareContent
                                    summary:INHERIT_VALUE
                                      image:img
                                       type:INHERIT_VALUE
                                    playUrl:nil
                                       nswb:nil];
    
    //*********************************************************************************************//
    
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];

    
    if (shareType==ShareTypeWeixiSession||shareType==ShareTypeWeixiTimeline||shareType==ShareTypeQQ||shareType==ShareTypeSMS||shareType==ShareTypeMail) {
        
        [ShareSDK shareContent:publishContent type:shareType authOptions:authOptions shareOptions:nil statusBarTips:NO result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
            
            
            if (state == SSResponseStateSuccess)
            {
                [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"分享成功" imageName:@"alert_savephoto_success"];
            }
            else if (state == SSResponseStateFail)
            {
                NSString *errorDescription=[error errorDescription];
                if ([errorDescription isKindOfClass:[NSNull class]] ||!errorDescription) {
                    errorDescription=@"分享失败";
                }
                NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], errorDescription);
                [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:errorDescription imageName:@"error"];
            }else if(state==SSResponseStateCancel){
               [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"取消分享" imageName:@"error"];
            }
        }];
        
    }else{
        
        [ShareSDK getUserInfoWithType:shareType authOptions:authOptions result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
            if (result) {
                
                 //第三方授权成功后存储用户信息
                [[CommonOperation getId] savedata:[userInfo nickname] andShareType:shareType];
                
                [ShareSDK shareContent:publishContent type:shareType authOptions:nil shareOptions:nil statusBarTips:NO result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                    
                    if (state == SSResponseStateSuccess)
                    {
                         [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"分享成功" imageName:@"alert_savephoto_success"];
                    }
                    else if (state == SSResponseStateFail)
                    {
                        NSString *errorDescription=[error errorDescription];
                        if ([errorDescription isKindOfClass:[NSNull class]] ||!errorDescription) {
                            errorDescription=@"分享失败";
                        }
                        NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], errorDescription);
                        
                       [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:errorDescription imageName:@"error"];
                        
                    }else if(state==SSResponseStateCancel){
                        [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"取消分享" imageName:@"error"];
                    }
                }];
                
            }else{
                NSLog(@"授权失败!错误码:%d,错误描述:%@", [error errorCode], error.errorDescription);
                [[NoticeOperation getId] hideAlertView:_alert fromView:_controller.view  msg:@"取消分享" imageName:@"error"];
            }
        }];
    }
}

@end
