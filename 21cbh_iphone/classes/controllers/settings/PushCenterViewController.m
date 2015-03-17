//
//  PushCenterViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PushCenterViewController.h"
#import "ConsultPushListViewController.h"
#import "MessagePushListViewController.h"

@interface PushCenterViewController (){
    UIView *_contentView;//内容区
    NSMutableArray *_controllers;//临时存放控制器
    
    int _currentIndex;
}

@end

@implementation PushCenterViewController


#pragma mark (0:资讯推送  1:行情推送)
-(id)initWithCurrentIndex:(int)currentIndex{
    if (self=[super init]) {
        _currentIndex=currentIndex;
    }
    
    
    return self;
}


- (void)viewDidLoad
{
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    _controllers=[NSMutableArray array];
    
    ConsultPushListViewController *cplvc=[[ConsultPushListViewController alloc] init];
    [self addChildViewController:cplvc];
    [_controllers addObject:cplvc];
    
    MessagePushListViewController *mplvc=[[MessagePushListViewController alloc] init];
    [self addChildViewController:mplvc];
    [_controllers addObject:mplvc];
}

#pragma mark 初始化视图
-(void)initView{
    //标题栏
    UIView *top=[self Title:@"消息中心" returnType:2];
    top.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.backView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.lable.textColor=UIColorFromRGB(0x000000);
    
    NSArray *array=@[@"资讯推送",@"行情推送"];
    TopBar *topBar=[[TopBar alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, 40) array:array btnTexNormalColor:UIColorFromRGB(0x000000) btnTextSelectedColor:UIColorFromRGB(0xe86e25)];
    topBar.backgroundColor=UIColorFromRGB(0xe1e1e1);
    topBar.line.backgroundColor=UIColorFromRGB(0xe86e25);
    [self.view addSubview:topBar];
    topBar.delegate=self;
    topBar.hidden=YES;
    
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0,topBar.frame.size.height-0.5f, topBar.frame.size.width,0.5f)];
    line.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [topBar addSubview:line];
    [topBar bringSubviewToFront:topBar.line];
    
   // _contentView=[[UIView alloc] initWithFrame:CGRectMake(0, topBar.frame.origin.y+topBar.frame.size.height, self.view.frame.size.width, KScreenSize.height-top.frame.size.height-topBar.frame.size.height-20)];
    _contentView=[[UIView alloc] initWithFrame:CGRectMake(0, topBar.frame.origin.y, self.view.frame.size.width, KScreenSize.height-top.frame.size.height-20)];
    [self.view addSubview:_contentView];
    
    
    if (_currentIndex>1) {
        _currentIndex=1;
    }else if(_currentIndex<0){
        _currentIndex=0;
    }
    
    topBar.currentIndex=_currentIndex;
}





#pragma mark - -----------------TopBar的代理方法------------------
-(void)topBarclickBtn:(UIButton *)btn{
    NSLog(@"topBar的btn.tag==%i",btn.tag);
    [_contentView removeAllSubviews];
    UIViewController *uc=[_controllers objectAtIndex:btn.tag];
    UIView *view=uc.view;
    view.frame=_contentView.bounds;
    [_contentView addSubview:view];
}


@end
