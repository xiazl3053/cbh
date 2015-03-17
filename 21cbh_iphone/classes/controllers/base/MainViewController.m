//
//  MainViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "MainViewController.h"
#import "NewsViewController.h"
#import "OptionalViewController.h"
#import "MarketViewController.h"
#import "liveBroadcastViewController.h"
#import "ListenVoiceViewController.h"
#import "ZXTabbar.h"
#import "ZXTabbarItem.h"
#import "BBCyclingLabel.h"
#import "NewsDetailViewController.h"
#import "XinWenHttpMgr.h"
#import "NewsFlashModel.h"
#import "AppDelegate.h"
#import "GuideController.h"
#import "UIImage+Custom.h"
#import "ChatDetailViewController.h"
#import "CommonOperation.h"
#import "ChatLogIn.h"
#import "SessionInstance.h"
#import "PlayerTool1.h"
#import "VoiceListModel.h"
#import "VoiceListViewController.h"
#import "RequestManager.h"
#import "VoiceListRecordDB.h"
#import "UIImage+ZX.h"
#import "SDiPhoneVersion.h"

#define kTabbarHeight 61
#define KBottomHeight 35
#define kLogoWidth 98
#define kRefreshTime 60

@interface MainViewController (){
    
    UIView *_contentView;// 用来容纳子控制器的view
    NSMutableArray *_items;// 临时存储item
    ZXTabbar *_tab;//ZXTabbar
    bool b;//控制ZXTabbar的升降
    UIView *_bottom;//底部栏bottom
    GuideController* _guideView;//新手引导
    UIView *_chatNumView;//消息数view
    
    NSMutableArray *_nfms;
    NSInteger _index;
    NewsFlashModel *_nfm;
    
    NSTimer *_showTimer; //走马灯
    NSTimer *_newFlashTime;//定时请求新闻快讯数据
    
    PlayerTool1 *_tool;
    UIView *_indiction;
    
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化变量
    [self initParams];
	//初始化视图
    [self initViews];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏标题栏
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //设置当前全屏显示的controller
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentController=self;
    
    //监听有无新消息
    [self listenToMessageNum:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_tool startTextAnimation];
//    [_showTimer setFireDate:[NSDate date]];
//    
//    if ((!_nfms)||_nfms.count<1) {
//       [_newFlashTime setFireDate:[NSDate date]];
//    }else{
//        [_newFlashTime setFireDate:[NSDate dateWithTimeIntervalSinceNow:kRefreshTime]];
//    }
}

-(void)viewDidDisappear:(BOOL)animated{
//    [_showTimer setFireDate:[NSDate distantFuture]];
//    [_newFlashTime setFireDate:[NSDate distantFuture]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{
    //移除通知
    //[self removeNotification];
}

#pragma mark - ------------以下为自定义方法--------------------
#pragma mark 初始化视图
-(void)initViews{
    //初始化contentView
    [self initContentView];
    //初始化子控制器
    [self initControllers];
    //初始化tabbar
    [self initTabbar];
    // 默认选中第一个子控制器
    [self tabbarItemChangeFrom:0 to:0];
    //初始化底部栏
    [self initBottom];
    //新手引导界面
    [self checkStartCount];
    //开启定时器
    //[self initTimer];
    
}

#pragma mark 初始化变量
-(void)initParams{
    b=YES;
    self.dbQueue=[[NSOperationQueue alloc] init];
    [self.dbQueue setMaxConcurrentOperationCount:1];
    _nfms=[NSMutableArray array];
    _index=0;
    //注册通知
    //[self registerNotification];
}

#pragma mark 初始化contentView
- (void)initContentView {
    CGSize size = self.view.bounds.size;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height - KBottomHeight)];
    contentView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    [self.view addSubview:contentView];
    _contentView = contentView;
}

#pragma mark 初始化底部栏
-(void)initBottom{
    
    [self initPlayer];
    
//    UIView *bottom=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.height-KBottomHeight, self.view.frame.size.width, KBottomHeight)];
//    bottom.backgroundColor=UIColorFromRGB(0xe1e1e1);
//    [self.view addSubview:bottom];
//    
//    UIImage *logoImage=[UIImage imageNamed:@"bottom_logo_down.png"];
//    
//    BBCyclingLabel *label=[[BBCyclingLabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-kLogoWidth, KBottomHeight)];
//    [label setText:@"21世纪网" animated:YES];
//    //label.shadowColor = [UIColor colorWithWhite:1 alpha:0.75];
//    //label.shadowOffset = CGSizeMake(0, 1);
//    label.numberOfLines=1;
//    label.transitionDuration = 0.75;
//    label.transitionEffect = BBCyclingLabelTransitionEffectScrollUp;
//    label.clipsToBounds = YES;
//    label.textColor=UIColorFromRGB(0x000000);
//    label.font=[UIFont fontWithName:kFontName size:13];
//    // 创建一个手势识别器
//    UITapGestureRecognizer *oneFingerOneTaps =
//    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lableClick)];
//    // Set required taps and number of touches
//    [oneFingerOneTaps setNumberOfTapsRequired:1];
//    [oneFingerOneTaps setNumberOfTouchesRequired:1];
//    // Add the gesture to the view
//    [label addGestureRecognizer:oneFingerOneTaps];
//    [bottom addSubview:label];
//    label.tag=100;
//    
//    UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-kLogoWidth,0, kLogoWidth, KBottomHeight)];
//    [btn setBackgroundColor:[UIColor clearColor]];
//    [btn setImage:logoImage forState:(UIControlStateNormal)];
//    [btn setImage:logoImage forState:(UIControlStateHighlighted)];
//    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
//    [bottom addSubview:btn];
//    
//    
//    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(btn.frame.origin.x-1, (KBottomHeight-14)*0.5f, 1, 15)];
//    line.backgroundColor=UIColorFromRGB(0xa0a0a0);
//    [bottom addSubview:line];
//    
//    
//    _bottom=bottom;
}

-(void)checkStartCount
{
    int startCount=[GuideController addStartCount];
    if(startCount==1)
    {
        CGRect bounds=self.view.bounds;
        NSInteger iphoneType=[SDiPhoneVersion deviceVersion];
        NSArray* imageArray=nil;
        if (iphoneType==iPhone4S) {//iphone4/4s
            imageArray=[NSArray arrayWithObjects:
                        [[UIImage imageNamed:@"introduce1.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        [[UIImage imageNamed:@"introduce2.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        [[UIImage imageNamed:@"introduce3.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        nil];
        }else if(iphoneType==iPhone4S||iphoneType==iPhone5||iphoneType==iPhone5||iphoneType==iPhone5S){//iphone5/5c/5s
            imageArray=[NSArray arrayWithObjects:
                        [[UIImage imageNamed:@"introduce11.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        [[UIImage imageNamed:@"introduce22.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        [[UIImage imageNamed:@"introduce33.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        nil];
        }else if(iphoneType==iPhone6){//iphone6
            imageArray=[NSArray arrayWithObjects:
                        [[UIImage imageNamed:@"introduce111.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        [[UIImage imageNamed:@"introduce222.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        [[UIImage imageNamed:@"introduce333.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        nil];
        }else if(iphoneType==iPhone6Plus){//iphone6 plus
            imageArray=[NSArray arrayWithObjects:
                        [[UIImage imageNamed:@"introduce1111.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        [[UIImage imageNamed:@"introduce2222.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        [[UIImage imageNamed:@"introduce3333.jpg"] scaleToSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)],
                        nil];
        }
        
        _guideView=[[GuideController alloc] init];
        [_guideView showGuideWithSuperView:self.view bounds:bounds bgColor:[UIColor blackColor] imageArray:imageArray bgContentMode:UIViewContentModeTop index:0 delegate:self buttonRect:CGRectZero closeRect:CGRectZero animated:YES];
    }
}

#pragma mark 底部栏的按钮点击方法
-(void)click:(UIButton *)btn{
    b=!b;
    
    [btn setImage:[UIImage imageNamed:b?@"bottom_logo_down.png":@"bottom_logo_up.png"] forState:(UIControlStateNormal)];
    [btn setImage:[UIImage imageNamed:b?@"bottom_logo_down.png":@"bottom_logo_up.png"] forState:(UIControlStateHighlighted)];
    
    CGRect frame= _tab.frame;
    frame.origin.y+=b?-kTabbarHeight:kTabbarHeight;
   
    //执行动画
    [UIView beginAnimations:@"up" context:nil];
    [UIView setAnimationDuration:0.3f];
     _tab.frame=frame;
    [UIView commitAnimations];
    
    //监听bottom的升降
    if (!b) {//降
        
        if ([self.delegate respondsToSelector:@selector(bottomDown:)]) {
            [self.delegate bottomDown:_bottom];
        }
        
    }else{//升
        
        if ([self.delegate respondsToSelector:@selector(bottomUp:)]) {
            [self.delegate bottomUp:_bottom];
        }
    }
    
}

#pragma mark 点击快讯栏
-(void)lableClick{
    NSLog(@"点击了快讯lable");
    if(!_nfm){
        return;
    }
    NewsDetailViewController *ndv=[[NewsDetailViewController alloc] init];
    ndv.programId=_nfm.programId;
    ndv.main=self;
    ndv.articleId=_nfm.articleId;
    [self.navigationController pushViewController:ndv animated:YES];
}


#pragma mark 定时器
-(void)initTimer{
    //走马灯
    NSTimeInterval timeInterval =4.0 ;
    NSTimer *showTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(bottomTextGo) userInfo:nil repeats:YES];
    _showTimer=showTimer;
    //定时请求新闻快讯数据
     NSTimer *newFlashTime = [NSTimer scheduledTimerWithTimeInterval:kRefreshTime target:self selector:@selector(getNewsFlash) userInfo:nil repeats:YES];
    _newFlashTime=newFlashTime;
    
}


#pragma mark 底部栏的走马灯
-(void)bottomTextGo{
    if ((!_nfms)||_nfms.count<1) {
        return;
    }
    
    
    BBCyclingLabel *label=(BBCyclingLabel *)[_bottom viewWithTag:100];
    NewsFlashModel *nfm=[_nfms objectAtIndex:_index];
    _nfm=nfm;
    
    _index++;
    if (_index>_nfms.count-1) {
        _index=0;
    }
    
    NSString *title=nfm.title;
    if (!title) {
        title=[NSString stringWithFormat:@""];
    }
    
    [label setText:title animated:YES];
    
}

#pragma mark 添加子控制器和item
- (void)addController:(UIViewController *)vc title:(NSString *)title normal:(NSString *)normal highlighted:(NSString *)highlighted {
    // 初始化item
    ZXTabbarItemDesc *item = [ZXTabbarItemDesc itemWithTitle:title normal:normal highlighted:highlighted];
    [_items addObject:item];
    // 包装控制器
    //UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc];
    // 对子控制器做了一次retain
    if (vc) {
        [self addChildViewController:vc];
    }
    
}

#pragma mark 初始化子控制器
- (void)initControllers {
    _items = [NSMutableArray array];
    
    NewsViewController *nc= [[NewsViewController alloc] init];
    nc.main=self;
    [self addController:nc title:@"新闻" normal:@"tabbar_news.png" highlighted:@"tabbar_news_selected.png"];
    
    liveBroadcastViewController *lbvc = [[liveBroadcastViewController alloc] init];
    lbvc.main=self;
    [self addController:lbvc title:@"直播" normal:@"tabbar_liveBroadcast.png" highlighted:@"tabbar_liveBroadcast_selected.png"];
    
//    OptionalViewController * oc= [[OptionalViewController alloc] init];
//    oc.main=self;
//    [self addController:oc title:@"自选" normal:@"tabbar_optional.png" highlighted:@"tabbar_optional_selected.png"];
//    
//    
//    MarketViewController *mc = [[MarketViewController alloc] init];
//    mc.main=self;
//    [self addController:mc title:@"行情" normal:@"tabbar_market.png" highlighted:@"tabbar_market_selected.png"];
    
    ListenVoiceViewController *lvc=[[ListenVoiceViewController alloc] init];
    lvc.main=self;
    [self addController:lvc title:@"听闻" normal:@"tabbar_radio.png" highlighted:@"tabbar_radio_selected.png"];
}

#pragma mark 初始化tabbar
- (void)initTabbar {
    CGSize size = self.view.bounds.size;
    CGRect frame = CGRectMake(0, size.height - kTabbarHeight-KBottomHeight, size.width, kTabbarHeight);
    ZXTabbar *tab = [[ZXTabbar alloc] initWithFrame:frame items:_items];
    // 设置代理
    tab.delegate = self;
    [self.view addSubview:tab];
    _tab=tab;
    _tab.backgroundColor=UIColorFromRGB(0xe1e1e1);
    
    //tab与bottom的分割线
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, _tab.frame.origin.y+_tab.frame.size.height-0.5f, self.view.frame.size.width, 0.5f)];
    line.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [self.view addSubview:line];
}


#pragma mark 新闻快讯接口请求
-(void)getNewsFlash{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.main=self;
    [hmgr newsFlash];
}

#pragma mark 新闻快讯接口请求处理
-(void)getNewsFlashHandle:(NSMutableArray *)nfms{
    if ((!nfms)||nfms.count<1) {
        return;
    }
    _nfms=nfms;
    _index=0;
}

#pragma mark 通知响应
-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(listenToMessageNum:) name:kXMPPSessionChangeNotifaction object:nil];
}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPSessionChangeNotifaction object:nil];
}

#pragma mark 监听未读消息数
-(void)listenToMessageNum:(NSNotification *)notification{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_chatNumView) {
                [_chatNumView removeFromSuperview];
            }
            if ([INSTANCE totalUnReadCount]>0) {
                //显示未读消息数
                _chatNumView=[[NoticeOperation getId] showChatNumViewWithPoint:CGPointMake(_tab.frame.size.width-10, 10) superView:_tab msg:@" "];
            }
            
        });
    });
}


#pragma mark - ------------------ZXTabbar的代理方法--------------
// 在这里切换子控制器
- (void)tabbarItemChangeFrom:(int)from to:(int)to {
        
    UIViewController *old = [self.childViewControllers objectAtIndex:from];
    // 移除旧控制器的view
    [old.view removeFromSuperview];
    [self addProgramaStatisticsFrom:from to:to];
    
    // 取出新控制器
    UIViewController *new1 = [self.childViewControllers objectAtIndex:to];
    new1.view.frame = _contentView.bounds;
    // 添加新控制器的view
    [_contentView addSubview:new1.view];
    if (to==4) {
        [_indiction removeFromSuperview];
    }
}

#pragma mark - GuideControllerDelegate
-(void)handleGuidePageChanged:(GuideController*)guideController
{

}
-(void)handleGuideFinish:(UIButton*)sender
{
    [_guideView hideGuideAnimated];
}

-(void)addProgramaStatisticsFrom:(NSInteger )from to:(NSInteger )to{
    
    ZXTabbarItem *fromItem=[_tab.subviews objectAtIndex:from];
    ZXTabbarItem *toItem= [_tab.subviews objectAtIndex:to];
    
    NSLog(@"from.text=%@,to.text===%@",fromItem.titleLabel.text,toItem.titleLabel.text);
    if (from==to) {
        [[Frontia getStatistics]pageviewStartWithName:[NSString stringWithFormat:@"%@--模块",toItem.titleLabel.text]];
    }else{
        [[Frontia getStatistics]pageviewEndWithName:[NSString stringWithFormat:@"%@--模块",fromItem.titleLabel.text]];
        [[Frontia getStatistics]pageviewStartWithName:[NSString stringWithFormat:@"%@--模块",toItem.titleLabel.text]];
    }
}

#pragma mark -初始化播放器
-(void)initPlayer{
    PlayerTool1 *tool=[[PlayerTool1 alloc]initWithFrame:CGRectMake(0, self.view.height-KBottomHeight, 320, KBottomHeight)];
    tool.delegate=self;
    _tool=tool;
    [self.view addSubview:tool];
    NSMutableArray *voiceList=[[VoiceListRecordDB sharedInstance]getVoiceList];
    if (voiceList.count>0) {
        [tool setPlayerList:[self sortWithSourceNSArray:voiceList] NowNumber:0 isExternal:NO];
    }
    RequestManager *manager=[RequestManager shareRequestManager];
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:@"voiceList",KSubInterface,@"voice",KMainInterface,@"0",@"addtime", nil];
    __block PlayerTool1 *__block_tool=_tool;
    [manager addRequestWithParameter:dic completion:^(NSDictionary *dic, ReposeStausCode code) {
        if(code==ReposeStausCode_Success){
            NSDictionary *data=[dic objectForKey:KResponseData];
            NSArray *list=[data objectForKey:@"voiceList"];
            NSMutableArray *voiceList=[NSMutableArray array];
            for (NSDictionary *dic in list) {
                VoiceListModel *model=[[VoiceListModel alloc]initWithDict:dic];
                [voiceList addObject:model];
                [[VoiceListRecordDB sharedInstance]insertWithVoiceModel:model];
            }
            [__block_tool setPlayerList:[self sortWithSourceNSArray:voiceList] NowNumber:0 isExternal:NO];
            [self addRedIndiction];
        }
    }];
}

#pragma mark -打开歌曲列表
-(void)PlayerTool1:(PlayerTool1 *)tool userClick:(UIButton *)aButton{
    VoiceListViewController *list=[[VoiceListViewController alloc]init];
    __block PlayerTool1 *__block_tool=_tool;
    list.selectChapterModelblock=^(NSArray *list,NSInteger number){
        [__block_tool setPlayerList:list NowNumber:number isExternal:YES];
        PlayManager *manager=[PlayManager sharedPlayManager];
        manager.player.shouldAutoplay=YES;
        [manager startPlay];
    };
    [self presentViewController:list animated:YES completion:^{
    }];
}

-(NSArray *)sortWithSourceNSArray:(NSArray *)arr{
    NSSortDescriptor *addtime = [NSSortDescriptor sortDescriptorWithKey:@"addtime" ascending:NO];
    NSArray *descs = [NSArray arrayWithObjects:addtime, nil];
    NSArray *newArray = [arr sortedArrayUsingDescriptors:descs];
    return newArray;
}

-(void)addRedIndiction{
    ZXTabbarItem *item=(ZXTabbarItem *)[_tab viewWithTag:4];
    UIView *indiction=[[NoticeOperation getId]showChatNumViewWithPoint:CGPointMake(20, 15) superView:item msg:@" "];
    _indiction=indiction;
}

-(void)PlayerTool1:(PlayerTool1 *)tool voiceChange:(VoiceListModel *)model{
    NSLog(@"%s,chapter=%@",__FUNCTION__,model.title);
}

@end
