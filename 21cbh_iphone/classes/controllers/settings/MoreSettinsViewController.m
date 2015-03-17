//
//  MoreSettinsViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MoreSettinsViewController.h"
#import "KLSwitch.h"
#import "AGAuthViewController.h"
#import "MoreAppViewController.h"
#import "SetFontViewController.h"
#import "FeedBackViewController.h"
#import "VersionCheckViewController.h"
#import <StoreKit/StoreKit.h>
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+Add.h"
#import "NoticeOperation.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "XinWenHttpMgr.h"
#import "CommonOperation.h"
#import "PushNotificationHandler.h"
#import "FileOperation.h"

@interface MoreSettinsViewController ()<SKStoreProductViewControllerDelegate>{
    UIScrollView *_scroll;
    NSMutableArray *_array;
    UILabel *_fontSizeLable;
    KLSwitch *_switchView;//推送关闭开关
}

@end

@implementation MoreSettinsViewController


- (void)viewDidLoad
{
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //设置fontSize的(小中大)显示
    [self setFontSizeShow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MoreSettinsList" ofType:@"plist"];
    _array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
}

#pragma mark 初始化视图
-(void)initView{
    UIView *top=[self Title:@"设 置" returnType:2];
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    UIScrollView *scroll=[[UIScrollView alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    CGSize size=self.view.frame.size;
    size.height=1.01*self.view.frame.size.height;
    scroll.contentSize=size;
    [self.view addSubview:scroll];
    _scroll=scroll;
    
    CGRect frame=CGRectMake(0, 0, 0, 0);
    
    NSMutableArray *array1=[_array objectAtIndex:0];//第一组数据
    [self addMoreSettinsItemViewWithArray:array1 frame:frame];
    frame.origin.y+=42*(array1.count);
    
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(20, frame.origin.y, self.view.frame.size.width, 20)];
    lable.backgroundColor=[UIColor clearColor];
    lable.textAlignment=NSTextAlignmentCenter;
    lable.text=@"请在系统「设置」的「通知中心」修改推送状态";
    lable.textColor=UIColorFromRGB(0x636363);
    lable.font=[UIFont systemFontOfSize:12];
    [_scroll addSubview:lable];
    frame.origin.y+=42;
    
    NSMutableArray *array2=[_array objectAtIndex:1];//第一组数据
    [self addMoreSettinsItemViewWithArray:array2 frame:frame];
    
    
}

#pragma mark 添加MoreSettinsItem
-(void)addMoreSettinsItemViewWithArray:(NSMutableArray *)array frame:(CGRect)frame{
    for (int i=0; i<array.count; i++) {
        NSMutableArray *array1=[array objectAtIndex:i];
        MoreSettinsItemView *msItem=[[MoreSettinsItemView alloc] initWithArray:array1];
        msItem.frame=CGRectMake(0, frame.origin.y+42*i, msItem.frame.size.width, msItem.frame.size.height);
        [_scroll addSubview:msItem];
        msItem.delegate=self;
        
        switch (msItem.tag) {
            case 1001://字号大小
                [self initMsFont:msItem];
                break;
            case 1002://清除缓存
                [self initMsClear:msItem];
                break;
            case 1003://推送
                [self initMsPush:msItem];
                break;
            case 1004://版本
                [self initMsVersion:msItem];
                break;
            default:
                break;
        }
        
        if (i==array.count-1) {
            msItem.line.hidden=YES;
        }
    }
}

#pragma mark 设置字号item
-(void)initMsFont:(MoreSettinsItemView *)item{
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(item.inTag.frame.origin.x-100-10, 0, 100, item.frame.size.height)];
    lable.backgroundColor=[UIColor clearColor];
    lable.textAlignment=NSTextAlignmentRight;
    lable.textColor=UIColorFromRGB(0xe86e25);
    lable.font=[UIFont systemFontOfSize:15];
    lable.tag=10000;
    [item addSubview:lable];
    _fontSizeLable=lable;
    //设置fontSize的(小中大)显示
    [self setFontSizeShow];
}

#pragma mark 设置fontSize的(小中大)显示
-(void)setFontSizeShow{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger fontSize=[[defaults objectForKey:kFontSize] intValue];
    
    switch (fontSize) {
        case 0:
            _fontSizeLable.text=@"小";
            break;
        case 1:
            _fontSizeLable.text=@"中";
            break;
        case 2:
            _fontSizeLable.text=@"大";
            break;
        default:
            break;
    }
}

#pragma mark 设置清除
-(void)initMsClear:(MoreSettinsItemView *)item{
    item.inTag.hidden=YES;
}

#pragma mark 设置推送item
-(void)initMsPush:(MoreSettinsItemView *)item{
    item.canResponse=NO;
    KLSwitch *switchView=[[KLSwitch alloc] initWithFrame:CGRectMake(item.inTag.frame.origin.x, 0, 50, 30)];
    CGRect frame=switchView.frame;
    frame.origin.y=(item.frame.size.height-frame.size.height)*0.5f;
    frame.origin.x=item.frame.size.width-15-frame.size.width;
    switchView.frame=frame;
    [item addSubview:switchView];
    _switchView=switchView;
    item.inTag.hidden=YES;
    //设置开关的状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int isPush=[[defaults objectForKey:kIsPush] intValue];
    switch (isPush) {
        case 0:
            [switchView setOn: NO animated: NO];
            break;
        case 1:
            [switchView setOn: YES animated: NO];
            break;
        default:
            break;
    }

    [switchView setDidChangeHandler:^(BOOL isOn){
        if (isOn) {
            NSString *isPush=@"1";
            [self applePushHanle:isPush];
            NSLog(@"打开");
//            AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
//            //注册苹果推送
//            [app registerApplePush];
            [[PushNotificationHandler instance]registerForRemoteNotification];
            //结果提交服务器
            [self postIsPush:isPush];
        }else{
            NSLog(@"关闭");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"关闭消息推送通知后,将不能及时收到要闻推送"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:@"取消",nil];
            alert.tag=100;
            [alert show];
        }
    }];
}

#pragma mark 设置版本item
-(void)initMsVersion:(MoreSettinsItemView *)item{
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(item.inTag.frame.origin.x-100-10, 0, 100, item.frame.size.height)];
    lable.backgroundColor=[UIColor clearColor];
    lable.textAlignment=NSTextAlignmentRight;
    lable.textColor=UIColorFromRGB(0xe86e25);
    lable.font=[UIFont systemFontOfSize:15];
    lable.text=[[CommonOperation getId] getVersion];
    lable.tag=10000;
    [item addSubview:lable];
}


#pragma mark 点击分享设置
-(void)clickMsShare{
    AGAuthViewController *auth=[[AGAuthViewController alloc] init];
    [self.navigationController pushViewController:auth animated:YES];
}

#pragma mark 点击字号大小
-(void)clickMsFont{
    SetFontViewController *sfvc=[[SetFontViewController alloc] init];
    [self.navigationController pushViewController:sfvc animated:YES];
}

#pragma mark 点击清除缓存
-(void)clickMsClear{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //清缓存
        [[CommonOperation getId] clearCach];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NoticeOperation getId] showAlertWithMsg:@"清除缓存成功" imageName:@"alert_savephoto_success" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        });
    });
    
    
}



#pragma mark 点击版本
-(void)clickMsVersion{
    VersionCheckViewController *vcvc=[[VersionCheckViewController alloc] init];
     [self.navigationController pushViewController:vcvc animated:YES];
}

#pragma mark 点击关于
-(void)clickMsAbout{
    AboutViewController *avc=[[AboutViewController alloc] init];
    [self.navigationController pushViewController:avc animated:YES];
}

#pragma mark 点击去appStore评分
-(void)clickMsAppstore{
//    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:KApple_ID forKey:SKStoreProductParameterITunesItemIdentifier];
//    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
//        if (result) {
//            
//        }
//    }];
//    storeProductVC.delegate=self;
//    [self presentViewController:storeProductVC animated:YES completion:nil];
    
    NSString *appStoreUrl=[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/21shi-ji-wang-yuan-chuang/id%@",KApple_ID];
    [[UIApplication sharedApplication]  openURL:[NSURL URLWithString:appStoreUrl]];
    
    NSLog(@"appstore======%@",appStoreUrl);
}

#pragma mark 点击意见反馈
-(void)clickMsOpinion{
    FeedBackViewController *fbvc=[[FeedBackViewController alloc] init];
    [self.navigationController pushViewController:fbvc animated:YES];
}

#pragma mark 点击更多应用
-(void)clickMsMoreApps{
    MoreAppViewController *mavc=[[MoreAppViewController alloc] init];
    [self.navigationController pushViewController:mavc animated:YES];
}

#pragma mark - -------------MoreSettinsItemView的代理方法-------------------
-(void)clickMoreSettinsItem:(MoreSettinsItemView *)msiv{
    switch (msiv.tag) {
        case 1000:
            NSLog(@"点击了分享设置");
            [self clickMsShare];
            break;
        case 1001:
            NSLog(@"点击了字号大小");
            [self clickMsFont];
            break;
        case 1002:
            NSLog(@"点击了清除缓存");
            [self clickMsClear];
            break;
        case 1003:
            NSLog(@"点击了消息推送");
            
            break;
        case 1004:
            NSLog(@"点击了版本");
            [self clickMsVersion];
            break;
        case 1005:
            NSLog(@"点击了关于");
            [self clickMsAbout];
            break;
        case 1006:
            NSLog(@"点击了去appstore评分");
            [self clickMsAppstore];
            break;
        case 1007:
            NSLog(@"点击了意见反馈");
            [self clickMsOpinion];
            break;
        case 1008:
            NSLog(@"点击了更多应用");
            [self clickMsMoreApps];
            break;
        default:
            break;
    }
}

#pragma mark 苹果推送处理
-(void)applePushHanle:(NSString *)isPush{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:isPush forKey:kIsPush];
    [defaults synchronize];
}

#pragma mark 提交推送状态
-(void)postIsPush:(NSString *)isPush{
    
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    [hmgr postIsPushWithIsPush:isPush];
}

#pragma mark - --------------SKStoreProductViewController的代理方法------------------------
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:NO];
}


#pragma mark - ---------------UIAlertView代理方法----------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==100){//推送提醒alert
        NSString *isPush=nil;
        switch (buttonIndex) {
            case 0:
                isPush=@"0";
                [self applePushHanle:isPush];
                [_switchView setOn:NO animated:YES];
                //注销苹果推送
                //[[UIApplication sharedApplication] unregisterForRemoteNotifications];
                [[PushNotificationHandler instance]unregisterForRemoteNotifications];
                //结果提交服务器
                [self postIsPush:isPush];
                break;
            case 1:
                [_switchView setOn:YES animated:YES];                
                break;
            default:
                break;
        }
        
    }
}

@end
