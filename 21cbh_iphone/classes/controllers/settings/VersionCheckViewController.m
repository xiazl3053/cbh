//
//  VersionCheckViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "VersionCheckViewController.h"
#import "NCMConstant.h"
#import "PingLunHttpRequest.h"
#import <StoreKit/StoreKit.h>
#import "NoticeOperation.h"
#import "CommonOperation.h"

#define kLeftMargin 15
#define kRowHeight 41
#define kVersionLabelFontSize 15

@interface VersionCheckViewController ()<SKStoreProductViewControllerDelegate>{
    UIView *_top;
    UIButton *_mostNewVersionDetail;
    NSString *_lastVersion;
    UIView *_reLoadview;//重新加载view
    UIView *_alert;//提示view
}

@end

@implementation VersionCheckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    _top=nil;
    _lastVersion=nil;
    _reLoadview=nil;
    NSLog(@"---------versionCheckView------Delloc---------");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParams];
    [self initNavigationBar];
    
    

}

#pragma mark -背景View
-(void)initBGView{
    if (_reLoadview) {
        [_reLoadview removeFromSuperview];
    }
    _reLoadview=[[NoticeOperation getId] getReLoadview:self.view obj:self imageName:@"alert_load"];
    
}

#pragma mark -初始化View
-(void)initViews{
    [self initContentView];
}

#pragma mark -初始化内容View
-(void)initContentView{
    UILabel *curVerSion=[[UILabel alloc]init];
    [curVerSion setText:@"当前版本"];
    curVerSion.backgroundColor=[UIColor clearColor];
    curVerSion.font=[UIFont fontWithName:kFontName size:kVersionLabelFontSize];;
    curVerSion.textColor=UIColorFromRGB(0x000000);
    curVerSion.frame=CGRectMake(kLeftMargin, _top.bottom+5, 300, kRowHeight);
    
    UILabel *curVsionDetail=[[UILabel alloc]init];
    [curVsionDetail setTextColor:UIColorFromRGB(0x8d8d8d)];
    [curVsionDetail setText:[NSString stringWithFormat:@"%@  %@",@"21世纪网iPhone版",kAppCurVersion]];
    curVsionDetail.backgroundColor=[UIColor clearColor];
    curVsionDetail.font=[UIFont fontWithName:kFontName size:kVersionLabelFontSize];
    curVsionDetail.frame=CGRectMake(kLeftMargin, curVerSion.bottom-kLeftMargin, 300, kRowHeight);
    

    
    
    UILabel *mostNewVersion=[[UILabel alloc]init];
    [mostNewVersion setText:@"最新版本"];
    mostNewVersion.backgroundColor=[UIColor clearColor];
    [mostNewVersion setTextColor:UIColorFromRGB(0xe86e25)];
    mostNewVersion.font=[UIFont fontWithName:kFontName size:kVersionLabelFontSize];
    mostNewVersion.frame=CGRectMake(kLeftMargin, curVsionDetail.bottom+5, 300, kRowHeight);

    UIButton *mostNewVersionDetail=[[UIButton alloc]init];
    mostNewVersionDetail.backgroundColor=[UIColor clearColor];
    [mostNewVersionDetail setTitleColor:UIColorFromRGB(0x8d8d8d) forState:UIControlStateNormal];
    [mostNewVersionDetail setTitleColor:UIColorFromRGB(0x8d8d8d) forState:UIControlStateHighlighted];
    mostNewVersionDetail.titleLabel.font=[UIFont fontWithName:kFontName size:kVersionLabelFontSize];;
    mostNewVersionDetail.frame=CGRectMake(kLeftMargin, mostNewVersion.bottom-kLeftMargin, KScreenSize.width, kRowHeight);
    [mostNewVersionDetail addTarget:self action:@selector(updateVersion) forControlEvents:UIControlEventTouchUpInside];
    mostNewVersionDetail.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [mostNewVersionDetail.titleLabel setTextAlignment:NSTextAlignmentLeft];
    _mostNewVersionDetail=mostNewVersionDetail;
    
    
    //白色的背景
    UIView *bgView=[[UIView alloc]init];
    bgView.frame=CGRectMake(0, _top.bottom, 320, 150);
    bgView.backgroundColor=UIColorFromRGB(0xffffff);
    
    
    
    //分割线
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, bgView.frame.origin.y+bgView.frame.size.height*0.5-0.5f, self.view.frame.size.width, 0.5f)];
    line.backgroundColor=UIColorFromRGB(0xcccccc);
    
    
    [self.view addSubview:bgView];
    [self.view addSubview:curVerSion];
    [self.view addSubview:curVsionDetail];
    [self.view addSubview:mostNewVersion];
    [self.view addSubview:mostNewVersionDetail];
    [self.view addSubview:line];

}

#pragma mark -初始化NavigationBar
-(void)initNavigationBar{
    UIView *view=[self Title:@"版本" returnType:1];
    _top=view;
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
}

#pragma mark -添置检查按钮
-(void)initCheckButton{
    UIButton *check=[[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-150)*.5, 100, 150, 100)];
    [check setTitle:@"检查" forState:UIControlStateNormal];
    [check addTarget:self action:@selector(onCheckVersion) forControlEvents:UIControlEventTouchUpInside];
    [check setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:check];
}



#pragma mark -初始化参数
-(void)initParams{
    [self onCheckVersion];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -数据回调
-(void)getAppleIDBackData:(NSDictionary *)desc isSuccess:(BOOL)success{
    if (_reLoadview) {
        [_reLoadview removeFromSuperview];
    }
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NoticeOperation getId] hideAlertView:_alert fromView:self.view];
            [self initViews];
            NSArray *infoArray = [desc objectForKey:@"results"];
            if ([infoArray count]) {
                NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                NSString *lastVersion = [releaseInfo objectForKey:@"version"];
                _lastVersion=lastVersion;
                NSLog(@"curr.version=%@",kAppCurVersion);
                NSLog(@"update.version=%@",lastVersion);
                [_mostNewVersionDetail setTitle:[NSString stringWithFormat:@"%@  %@",@"21世纪网iPhone版",lastVersion] forState:UIControlStateNormal];
            }
            [self.view bringSubviewToFront:_alert];
        });
        
    }else{        
        [[NoticeOperation getId]hideAlertView:_alert fromView:self.view msg:KNoticeLoadVersionFailTitle imageName:KNoticeLoadVersionFailIcon];
        [self initBGView];
        NSLog(@"query version error");
    }

}

#pragma mark -更新版本
-(void)updateVersion{
    NSComparisonResult result = [_lastVersion compare:kAppCurVersion options:NSLiteralSearch];
    if (result==NSOrderedDescending) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
        alert.tag = 10000;
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本已是最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = 10001;
        [alert show];
    }
}

#pragma mark -检查更新
-(void)onCheckVersion
{
    //检查网络状态
    if(![[CommonOperation getId] getNetStatus]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
            [self initBGView];
        });
                
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _alert=[[NoticeOperation getId] showAlertWithMsg:@"检测新版本..." imageName:@"D_Refresh" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
    });
    
    PingLunHttpRequest *quest=[[PingLunHttpRequest alloc]init];
    [quest getAppleID:self];
}

#pragma mark 点击重新加载数据
-(void)clickReload{
    [self onCheckVersion];
}

#pragma mark -进入下载页面
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10000) {
        if (buttonIndex==1) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:KAppStorePath]];
        }
    }
}

#pragma mark -退出当前窗口
-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
