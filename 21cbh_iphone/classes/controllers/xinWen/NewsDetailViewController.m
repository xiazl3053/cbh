//
//  NewsDetailViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "FileOperation.h"
#import "UIImageView+WebCache.h"
#import "ShareOperation.h"
#import "CommentViewController.h"
#import "XinWenHttpMgr.h"
#import "NewsDetailDB.h"
#import "ZXPhotoBrowser.h"
#import "MJPhoto.h"
#import "NoticeOperation.h"
#import "XinWenHttpMgr.h"
#import "WebViewController.h"
#import "AdBarDB.h"
#import "NewsCommentViewController.h"
#import "NewListCollectDB.h"
#import "ShareViewController.h"
#import "KLineViewController.h"
#import "ASINetworkQueue.h"
#import "ChatViewController.h"
#import "CommonOperation.h"
#import "ChatLogIn.h"
#import "SessionInstance.h"
#import "UIImage+ZX.h"


@interface NewsDetailViewController (){
    UIView *_top;
    UIButton *_cmnBtn;//评论数按钮
    UIWebView *_web;
    UIView *_loadView;
    UIView *_reLoadview;
    UIView *_bottom;
    UIView *_commentView;
    UIView *_chatNumView;//消息数view
    __block UIButton *_collectBtn;
    
    AdBarModel *_adBarModel;
    AdBarView *_adBarView;
    BOOL _b;//判断是否有数据
    bool isFirst;
    BOOL isBrowser;
    BOOL isWebLoaded;
    BOOL isIamgesLoaded;
    
    NSInteger _doUpDown;//控制点赞
    
    ASINetworkQueue *imageQueue_;
}

@property(strong,nonatomic)NSArray *urls;
@property(strong,nonatomic)ShareOperation *sc;
@property(weak,nonatomic) NSOperationQueue *dbQueue;//数据库操作队列
@property(strong,nonatomic)NewsDetailDB *ndmDB;
@property(strong,nonatomic)AdBarDB *adDB;
@property(strong,nonatomic)NewListCollectDB *nlcDB;

@end

@implementation NewsDetailViewController


-(id)initWithProgramId:(NSString *)programId articleId:(NSString *)articleId main:(UIViewController *)main{
    if (self=[super init]) {
        
        self.programId=programId;
        self.articleId=articleId;
        self.main=main;
    }
    return self;
}


-(id)initWithProgramId:(NSString *)programId articleId:(NSString *)articleId main:(UIViewController *)main isReturn:(BOOL)isReturn{
    if (self=[super init]) {
        
        self.programId=programId;
        self.articleId=articleId;
        self.main=main;
        self.isReturn=isReturn;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化变量
    [self initParams];
    //初始化视图
    [self initViews];
    
}

-(void)viewDidAppear:(BOOL)animated{
    if (isFirst) {
        //加载数据
        [self loadData];
        //获取广告栏数据
        [self getAdBar];
        isFirst=NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    
    //删除图片
    //[self deleteImageFile];
    [self cleanQueue];
    //[[SDImageCache sharedImageCache] clearMemory];
    [super viewDidDisappear:animated];
     //添加文章查看时长统计
    [[Frontia getStatistics]eventEnd:@"news_pv" eventLabel:[NSString stringWithFormat:@"%@:%@:%@",self.ndm.title,self.programId,self.articleId]];
   // [[Frontia getStatistics]pageviewEndWithName:[NSString stringWithFormat:@"%@:%@:%@",self.ndm.title,self.programId,self.articleId]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (isBrowser) {
        [_web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"scrollToPosition(%i)",self.currentIndex]];
        isBrowser=NO;
        //NSLog(@"移动网页位置%i",self.currentIndex);
    }
    if(isWebLoaded&&!isIamgesLoaded){
        [self asynLoadHtmlImages];
    }
    
    //监听有无新消息
    [self listenToMessageNum:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self cleanQueue];
    //self.view=nil;
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self cleanQueue];
    _adBarView.delegate=nil;
    self.articleId=nil;
    self.programId=nil;
    self.urls=nil;
    self.sc=nil;
    self.ndm=nil;
    self.dbQueue=nil;
    self.ndmDB=nil;
    self.adDB=nil;
    self.nlcDB=nil;
    [self.view removeAllSubviews];
    //移除通知
    //[self removeNotification];
}

#pragma mark - ------------代理方法----------------------
#pragma mark - ---------UIWebView代理方法---------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    @try {
        NSString *url=[NSString stringWithFormat:@"%@",[request URL]];
        NSLog(@"url:%@",url);
        if ([url hasPrefix:@"http://21appinfo"]) {
            
            NSArray *array=[url componentsSeparatedByString:@":"];
            NSString* type=[array objectAtIndex:2];
            NSInteger redirectType=type.length==0?5:[type intValue];
            //跳转类型(0:个股,1:行业,2:多图浏览,3:图集,4:视频,5:文章)
            switch (redirectType) {
                case 0://个股
                    [self webClickIndividual:array];
                    break;
                case 1://行业
                    
                    break;
                case 2://多图
                    [self webClickPics:array];
                    break;
                case 3://图集
                    [self webClickPicsDetail:array];
                    break;
                case 4://视频
                    
                    break;
                case 5://文章
                    [self webClickNewsDetail:array];
                    break;
                case 6://点赞处理
                    [self doUpDownHandle:array];
                    break;
                case 7://评论页
                    [self goToNcv];
                    break;
                default:
                    break;
            }
            
            return NO;
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"新闻详情页点击跳转异常!");
    }
    @finally {
        
    }
    
    
    
    
    return YES;
}


-(void)webViewDidStartLoad:(UIWebView *)webView{
    
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_loadView) {
        [[NoticeOperation getId] viewFaceOut:_loadView];
    }
    isWebLoaded=YES;
    //异步加载网页图片
    [self asynLoadHtmlImages];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

#pragma mark - ------------AdBarView代理方法--------------------
-(void)finishImage{
    
    if (_web.frame.origin.y==(_top.frame.origin.y+_top.frame.size.height)) {
        
        NSLog(@"下移40");
        //执行动画
        [[NoticeOperation getId] yMoveAnimate:40 view:_web];
        CGRect frame=_web.frame;
        frame.size.height-=40;
        _web.frame=frame;
    }
}

-(void)clickImage{
    NSLog(@"点击了广告栏的图片");
    if ([_adBarModel.adUrl hasPrefix:@"https://itunes.apple.com/cn/app/"]) {//如果是appStore的下载就直接跳转到appStore
        [[UIApplication sharedApplication]  openURL:[NSURL URLWithString:_adBarModel.adUrl]];
        return;
    }
    
    
    WebViewController *wv=[[WebViewController alloc] initWithAdId:_adBarModel.adId type:@"5" url:_adBarModel.adUrl];
    [self.navigationController pushViewController:wv animated:YES];
}

-(void)clickBtn{
    
    NSLog(@"点击了广告栏的按钮");
    if (_web.frame.origin.y>(_top.frame.origin.y+_top.frame.size.height)) {
        //执行动画
        [[NoticeOperation getId] yMoveAnimate:-40 view:_web];
        
        CGRect frame=_web.frame;
        frame.size.height+=40;
        _web.frame=frame;
    }
    //插入广告栏数据进数据库
    [self.dbQueue addOperationWithBlock:^{
        [self.adDB deleteAdBar:_adBarModel];
        [self.adDB insertWithAdBar:_adBarModel];
    }];
}

#pragma mark - ------------自定义方法----------------------
#pragma mark 初始化变量
-(void)initParams{
    self.sc=[[ShareOperation alloc] init];
    self.dbQueue=self.main.dbQueue;
    self.ndmDB=[[NewsDetailDB alloc] init];
    self.adDB=[[AdBarDB alloc] init];
    self.nlcDB=[[NewListCollectDB alloc] init];
    self.currentIndex=0;
    _b=[[FileOperation getId] isFileExistWithFileDirName:@"html" fileName:[NSString stringWithFormat:@"%@.html",self.articleId]];
    isFirst=YES;
    isBrowser=NO;
    isWebLoaded=NO;
    isIamgesLoaded=NO;
    _doUpDown=10;
    
    if(imageQueue_){
        [self cleanQueue];
    }
    imageQueue_=[[ASINetworkQueue alloc]init];
    [imageQueue_ setMaxConcurrentOperationCount:1];
    
    //注册通知
    //[self registerNotification];
}

-(void)startDownLoadImage
{
    if(imageQueue_.operationCount>0)
    {
        [imageQueue_ go];
    }
}

#pragma mark 清空下载队列
-(void)cleanQueue
{
    for (ASIHTTPRequest* imgRequest in imageQueue_.operations) {
        [imgRequest setDelegate:nil];
        [imgRequest cancel];
    }
    [imageQueue_ reset];
    imageQueue_=nil;
}

#pragma mark 初始化视图
-(void)initViews{
    
    //顶部标题栏
    UIView *top=nil;
    if (!self.isVertical) {
        top=[self Title:@"21世纪网" returnType:1];
    }else{
        top=[self Title:@"21世纪网" returnType:2];
    }
    _top=top;
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    //评论数
    UIView *cmnBtnBack=[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-10-50, (top.frame.size.height-20)*0.5f, 50, 20)];
    cmnBtnBack.backgroundColor=UIColorFromRGB(0xffffff);
    cmnBtnBack.layer.borderWidth=0.5f;
    cmnBtnBack.layer.borderColor=[UIColorFromRGB(0xcccccc) CGColor];
    [top addSubview:cmnBtnBack];
    
    UIButton *cmnBtn=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-10-50, 0, 50, top.frame.size.height)];
    cmnBtn.titleLabel.font=[UIFont fontWithName:kFontName size:11];
    cmnBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [cmnBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
    [cmnBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateHighlighted];
    [cmnBtn addTarget:self action:@selector(goToNcv) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:cmnBtn];
    _cmnBtn=cmnBtn;
    _cmnBtn.userInteractionEnabled=NO;
    
    UIWebView *web=[[UIWebView alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-top.frame.size.height-44-20)];
    web.backgroundColor=[UIColor clearColor];
    web.scrollView.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    web.delegate=self;
    web.opaque=NO;//背景不透明设置为NO
    _web=web;
    [self.view addSubview:web];
    
    //底部工具栏
    UIView *bottom=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    bottom.backgroundColor=UIColorFromRGB(0xe3e3e3);
    [self.view addSubview:bottom];
    _bottom=bottom;
    bottom.hidden=YES;
    
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    line.backgroundColor=UIColorFromRGB(0x636363);
    [bottom addSubview:line];
    
    //评论框
    UIView *commentView=[[UIView alloc] initWithFrame:CGRectMake(10, (bottom.frame.size.height-28)*0.5f, 195, 28)];
    commentView.backgroundColor=[UIColor whiteColor];
    [bottom addSubview:commentView];
    _commentView=commentView;
    commentView.layer.borderWidth = 1;
    commentView.layer.borderColor=[UIColorFromRGB(0x959595) CGColor];
    // 创建一个手势识别器
    UITapGestureRecognizer *tap=
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comment)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [commentView addGestureRecognizer:tap];
    
    UILabel *lable=[[UILabel alloc] initWithFrame:commentView.bounds];
    lable.text=@"  我要评论... ...";
    lable.textColor=UIColorFromRGB(0x808080);
    lable.font=[UIFont fontWithName:kFontName size:12];
    lable.textAlignment=NSTextAlignmentLeft;
    [commentView addSubview:lable];
    
    
    UIImage *img1=[[UIImage imageNamed:@"newsDetail_forward"] scaleToSize:CGSizeMake(20, 20)];
    UIButton *forwardBtn=[[UIButton alloc] initWithFrame:CGRectMake(commentView.frame.origin.x+commentView.frame.size.width+25, (bottom.frame.size.height-img1.size.height*2)*0.5f, img1.size.width*2, img1.size.height*2)];
    [forwardBtn setImage:img1 forState:UIControlStateNormal];
    [forwardBtn setImage:img1 forState:UIControlStateHighlighted];
    [forwardBtn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:forwardBtn];
    
    
    //两个icon中间的分割线
    UIView *line1=[[UIView alloc] initWithFrame:CGRectMake(forwardBtn.frame.origin.x+forwardBtn.frame.size.width+5, (bottom.frame.size.height-15)*0.5f, 1, 15)];
    line1.backgroundColor=UIColorFromRGB(0xa0a0a0);
    [bottom addSubview:line1];
    
    
    UIImage *img2=[[UIImage imageNamed:@"newsDetail_collect"] scaleToSize:CGSizeMake(20, 20)];
    UIButton *collectBtn=[[UIButton alloc] initWithFrame:CGRectMake(bottom.frame.size.width-img2.size.width*2, (bottom.frame.size.height-img2.size.height*2)*0.5f, img2.size.width*2, img2.size.height*2)];
    [collectBtn setImage:img2 forState:UIControlStateNormal];
    [collectBtn setImage:img2 forState:UIControlStateHighlighted];
    [collectBtn addTarget:self action:@selector(collectBtn) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:collectBtn];
    _collectBtn=collectBtn;
    //设置收藏按钮的状态图像
    [self setCollectBtnImage];
    
//    //两个icon中间的分割线
//    UIView *line2=[[UIView alloc] initWithFrame:CGRectMake(collectBtn.frame.origin.x+collectBtn.frame.size.width+5, (bottom.frame.size.height-15)*0.5f, 1, 15)];
//    line2.backgroundColor=UIColorFromRGB(0xa0a0a0);
//    [bottom addSubview:line2];
//    
//    UIImage *img3=[UIImage imageNamed:@"newsDetail_privateLetter"];
//    UIButton *privateLetterBtn=[[UIButton alloc] initWithFrame:CGRectMake(line2.frame.origin.x+line2.frame.size.width+5, (bottom.frame.size.height-img3.size.height*2)*0.5f, img3.size.width*2, img3.size.height*2)];
//    [privateLetterBtn setImage:img3 forState:UIControlStateNormal];
//    [privateLetterBtn setImage:img3 forState:UIControlStateHighlighted];
//    [privateLetterBtn addTarget:self action:@selector(privateLetterBtn) forControlEvents:UIControlEventTouchUpInside];
//    [bottom addSubview:privateLetterBtn];
    
}

#pragma mark 设置收藏按钮的状态图像
-(void)setCollectBtnImage{
    [self.dbQueue addOperationWithBlock:^{
        BOOL b=[self.nlcDB isExistNlmWithArticleId:self.articleId programId:self.programId];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (b) {
                [_collectBtn setImage:[[UIImage imageNamed:@"newsDetail_collect_selected"] scaleToSize:CGSizeMake(20, 20)] forState:UIControlStateNormal];
                [_collectBtn setImage:[[UIImage imageNamed:@"newsDetail_collect_selected"] scaleToSize:CGSizeMake(20, 20)] forState:UIControlStateHighlighted];
            }else{
                [_collectBtn setImage:[[UIImage imageNamed:@"newsDetail_collect"] scaleToSize:CGSizeMake(20, 20)] forState:UIControlStateNormal];
                [_collectBtn setImage:[[UIImage imageNamed:@"newsDetail_collect"] scaleToSize:CGSizeMake(20, 20)] forState:UIControlStateHighlighted];
            }
        });
        
    }];
}


#pragma mark 跳转到评论页
-(void)goToNcv{
    if (!self.programId||!self.articleId) {
        return;
    }
    NewsCommentViewController *ncv=[[NewsCommentViewController alloc] initWithProgramId:self.programId andFollowID:self.articleId];
    ncv.main=self.main;
    [self.navigationController pushViewController:ncv animated:YES];
}

#pragma mark 评论弹窗
-(void)comment{
    CommentViewController *cvc=[[CommentViewController alloc] initWithProgarmID:self.programId andArticleID:self.articleId andPicsID:nil andFollowID:nil];
    cvc.ndv=self;
    [self addChildViewController:cvc];
    [self.view addSubview:cvc.view];
}

#pragma mark 分享
-(void)shareBtn{
    ShareViewController *svc=[[ShareViewController alloc] initWithTitle:self.ndm.title  url:self.ndm.articUrl icon:self.ndm.sharePic controller:self];
    [self addChildViewController:svc];
    [self.view addSubview:svc.view];
}

#pragma mark 收藏
-(void)collectBtn{
    if (!self.ndm) {
        return;
    }
    __block UIView *alert=nil;
    [self.dbQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
            [dic setObject:self.ndm.title forKey:@"title"];
            [dic setObject:self.ndm.articleId forKey:@"articleId"];
            [dic setObject:self.ndm.programId forKey:@"programId"];
            [dic setObject:self.ndm.type forKey:@"type"];
            [dic setObject:self.ndm.addtime forKey:@"addtime"];
            
            NewListModel *nlm=[[NewListModel alloc] initWithDict:dic];
            
            BOOL b=[self.nlcDB isExistNlmWithArticleId:self.articleId programId:self.programId];
            if (b) {
                NSLog(@"有数据");
                dispatch_async(dispatch_get_main_queue(), ^{
                    alert=[[NoticeOperation getId] showAlertWithMsg:@"已取消收藏" imageName:@"alert_collect_cancel" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO];
                });
                [self.nlcDB deleteNlm:nlm];
            }else{
                NSLog(@"没有数据");
                dispatch_async(dispatch_get_main_queue(), ^{
                    alert=[[NoticeOperation getId] showAlertWithMsg:@"收藏成功" imageName:@"alert_collect_success" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO];
                });
                [self.nlcDB insertNlm:nlm];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NoticeOperation getId] hideAlertView:alert fromView:self.view];
                [self setCollectBtnImage];
            });
        });
    }];
}

#pragma mark 聊天
-(void)privateLetterBtn{
    if (!_isReturn) {//打开聊天界面
        if (_chatNumView) {//如果有红点就移除
            [_chatNumView removeFromSuperview];
        }
        //封装一个NewListModel对象传给聊天界面
        NewListModel *nlm=[self getNewListModel];
        //手动登陆
        [[ChatLogIn getId] manualLoginWithModel:nlm];
        
    }else{//返回聊天界面
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 封装一个NewListModel对象传给聊天界面
-(NewListModel *)getNewListModel{
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:_ndm.type forKey:@"type"];
    [dic setValue:_ndm.programId forKey:@"programId"];
    [dic setValue:_ndm.articleId forKey:@"articleId"];
    [dic setValue:_ndm.title forKey:@"title"];
    [dic setValue:_ndm.breif forKey:@"desc"];
    [dic setValue:_ndm.followNum forKey:@"followNum"];
    NSMutableArray *picUrls=[NSMutableArray array];
    [picUrls addObject:_ndm.sharePic];
    [dic setValue:picUrls forKey:@"picUrls"];
    
    NewListModel *nlm=[[NewListModel alloc] initWithDict:dic];
    return nlm;
}


#pragma mark 检测该广告栏广告是否是用户点击过的
-(void)checkAdBar:(AdBarModel *)abm{
    [self.dbQueue addOperationWithBlock:^{

        BOOL b=[self.adDB isExistAdBar:abm];
        if (!b) {
            [self getAdBarHandle:abm];
        }
    }];
}

#pragma mark 获取广告栏数据
-(void)getAdBar{
    //NSLog(@"请求广告栏数据");
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.ndv=self;
    NSLog(@"广告栏数据self.programId:%@",self.programId);
    [hmgr adBarWithProgramId:self.programId isProgram:@"0"];
}


#pragma mark 获取广告栏数据后的处理
-(void)getAdBarHandle:(AdBarModel *)adBarModel{
    //NSLog(@"获取广告栏数据后的处理");
    _adBarModel=adBarModel;
    if (!adBarModel.picUrl) {//没picUrl不执行下面的代码
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_adBarView) {
            [_adBarView removeFromSuperview];
        }
        //广告栏控件
        AdBarView *adBarView=[[AdBarView alloc] initWithPicUrl:adBarModel.picUrl location_y:(_top.frame.origin.y+_top.frame.size.height)];
        adBarView.delegate=self;
        //设置广告栏图片
        [adBarView adBarSetPic];
        [self.view addSubview:adBarView];
        _adBarView=adBarView;
    });
    
}

#pragma mark 加载数据
-(void)loadData{
    _loadView=[[NoticeOperation getId] getLoadView:self.view imageName:@"alert_load"];
    if (_b) {
        NSLog(@"本地有该文章的缓存,先从本地获取数据");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [_dbQueue addOperationWithBlock:^{
                self.ndm=[self.ndmDB getNdmWith:self.articleId];
                
                self.ndm.body=[[FileOperation getId] getHtmlWithFileDirName:@"html" fileName:[NSString stringWithFormat:@"%@.html",self.articleId]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_web loadHTMLString:[self webHandle:self.ndm.body] baseURL:[NSURL fileURLWithPath:[[FileOperation getId] getFileDirWithFileDirName:@"html"]]];
                    [_cmnBtn setTitle:[NSString stringWithFormat:@"%@评",self.ndm.followNum]forState:UIControlStateNormal];
                    [_cmnBtn setTitle:[NSString stringWithFormat:@"%@评",self.ndm.followNum]forState:UIControlStateHighlighted];
                    _bottom.hidden=NO;
                    _cmnBtn.userInteractionEnabled=YES;
                    
                    if (_loadView) {
                        [[NoticeOperation getId] viewFaceOut:_loadView];
                    }
                    
                    //从网络获取数据
                    [self getNewsDetail];
                });
            }];
            
        });
        
    }else{
        NSLog(@"本地无该文章的缓存,直接从网络获取数据");
        [self getNewsDetail];
    }
}

#pragma mark 获取文章详情页数据
-(void)getNewsDetail{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.ndv=self;
    [hmgr newsDetailWithArticleId:self.articleId programId:self.programId isLocalExist:_b];
}

#pragma mark 获取文章详情页数据后的处理
-(void)getNewsDetailHandle:(NewsDetailModel *)ndm{
    NSLog(@"进入getNewsDetailHandle");
    
    dispatch_async(dispatch_get_main_queue(), ^{//没加载成功出线重新加载view
        if (_loadView) {
            [[NoticeOperation getId] viewFaceOut:_loadView];
        }
        
        if (!ndm||ndm.body.length<10) {
            if (!_b) {
                _reLoadview=[[NoticeOperation getId] getReLoadview:self.view obj:self imageName:@"alert_load"];
            }
            return;
        }
        
        self.ndm=ndm;
        self.programId=ndm.programId;
        self.articleId=ndm.articleId;
        [self setCollectBtnImage];
        [_cmnBtn setTitle:[NSString stringWithFormat:@"%@评",ndm.followNum]forState:UIControlStateNormal];
        [_cmnBtn setTitle:[NSString stringWithFormat:@"%@评",ndm.followNum]forState:UIControlStateHighlighted];
        
        //添加文章查看时长统计
        //[[Frontia getStatistics]pageviewStartWithName:[NSString stringWithFormat:@"%@:%@:%@",self.ndm.title,self.programId,self.articleId]];
        [[Frontia getStatistics]eventStart:@"news_pv" eventLabel:[NSString stringWithFormat:@"%@:%@:%@",self.ndm.title,self.programId,self.articleId]];
        NSString *body = ndm.body;
        
        if (body&&body.length>100) {
            if (!_b) {
                _bottom.hidden=NO;
                _cmnBtn.userInteractionEnabled=YES;
                [_web loadHTMLString:[self webHandle:body] baseURL:[NSURL fileURLWithPath:[[FileOperation getId] getFileDirWithFileDirName:@"html"]]];
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData* htmlData = [body dataUsingEncoding:NSUTF8StringEncoding];
                //html保存本地
                [[FileOperation getId] saveHtmlWithData:htmlData FileDirName:@"html" fileName:[NSString stringWithFormat:@"%@.html",self.articleId]];
                [_dbQueue addOperationWithBlock:^{
                    //ndm保存到数据库
                    //删除旧数据
                    [self.ndmDB deleteNdm:self.articleId];
                    //插入新数据
                    [self.ndmDB insertNdm:ndm];
                }];
                
            });
        }
    });
}

#pragma mark 发表评论接口
-(void)getComment:(NSString *)commentString{
    NSLog(@"发表评论:%@",commentString);
}

#pragma mark 异步加载网页的图片
-(void)asynLoadHtmlImages
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *picUrls=self.ndm.picUrls;
        for (int i=0;i<picUrls.count; i++ ){
            NSString *picUrl=[picUrls objectAtIndex:i];
            BOOL isExist=[[SDImageCache sharedImageCache] diskImageExistsWithKey:picUrl];
            if(!isExist)
            {
                NSURL* url = [NSURL URLWithString:picUrl];
                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
                request.tag=i;
                [request setDidFinishSelector:@selector(requestImageFinished:)];
                [request setDidFailSelector:@selector(requestImageFailed:)];
                [request setDelegate:self];
                [imageQueue_ addOperation:request];
            }
            else
            {
                [self setHtmlPicWithId:[NSString stringWithFormat:@"%d",i] picUrl:picUrl];
            }
        }
        [self startDownLoadImage];
    });
}

#pragma mark 图片下载成功
- (void)requestImageFinished:(ASIHTTPRequest *)request
{
    //下载到图片
    NSString* url = [[request originalURL] absoluteString];
    //  NSLog(@"下载到image url:%@",url);
    int num=request.tag;
    NSData* data = [request responseData];
    NSString* mimeType = [request.responseHeaders objectForKey:@"Content-Type"];
    if (data && [mimeType hasPrefix:@"image"])
    {
        [self saveImageAndSetToHtml:data imgNum:num imgUrl:url];
    }
}

#pragma mark 图片下载失败
- (void)requestImageFailed:(ASIHTTPRequest *)request
{
}

#pragma mark 下载图片到本地
- (void)saveImageAndSetToHtml:(NSData*)data imgNum:(int)num imgUrl:(NSString*)imgUrl
{
    NSString *picName=[[SDImageCache sharedImageCache] myCachedNameForUrl:imgUrl];
    NSString *imageDir = [[FileOperation getId] getFileDirWithFileDirName:@"html/images/imgCache"];
    NSString *uniquePath=[imageDir stringByAppendingPathComponent:picName];
    [data writeToFile:uniquePath atomically:NO];
    [self setHtmlPicWithId:[NSString stringWithFormat:@"%d",num] picUrl:imgUrl];
}

#pragma mark 设置html的图片
-(void)setHtmlPicWithId:(NSString *)imgId picUrl:(NSString *)picUrl{

    NSString *picName=[[SDImageCache sharedImageCache] myCachedNameForUrl:picUrl];
    NSString *meta2 = [NSString stringWithFormat:@"document.getElementById('%@').src='images/imgCache/%@'",imgId,picName];
    //更新webView
    [_web performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:meta2 waitUntilDone:NO];
}


#pragma mark 点击重新加载数据
-(void)clickReload{
    if (_reLoadview) {
        [_reLoadview removeFromSuperview];
    }
    //加载数据
    [self loadData];
}


#pragma mark webview加载后的处理
-(NSString *)webHandle:(NSString *)body{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger fontSize=[[defaults objectForKey:kFontSize] intValue];
    switch (fontSize) {
        case 0:
            body=[body stringByReplacingOccurrencesOfString:@"article.css" withString:@"article_s.css"];
            break;
        case 1:
            body=[body stringByReplacingOccurrencesOfString:@"article.css" withString:@"article.css"];
            break;
        case 2:
            body=[body stringByReplacingOccurrencesOfString:@"article.css" withString:@"article_b.css"];
            break;
        default:
            break;
    }
    
    return body;
}

#pragma mark 删除图片
-(void)deleteImageFile{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.ndm.picUrls&&self.ndm.picUrls.count>0) {
            for (int i=0; i<self.ndm.picUrls.count; i++) {
                NSString *filePath=[[FileOperation getId] getFilePathWithURL:[self.ndm.picUrls objectAtIndex:i] FileDirName:@"html/images/imgCache"];
                [[FileOperation getId] deleteFolderWithPath:filePath];
            }
        }
    });
}

#pragma mark 点击个股
-(void)webClickIndividual:(NSArray *)array{
    NSString *kId=[array objectAtIndex:3];
    NSInteger kType=[[array objectAtIndex:4] intValue];
    KLineViewController *kLineController = [[KLineViewController alloc] initWithIsBack:YES KId:kId KType:kType KName:nil];
    
    [self.navigationController pushViewController:kLineController animated:YES];
}


#pragma mark 点击多图
-(void)webClickPics:(NSArray *)array{
    
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray array];
    for (int i = 0; i<[self.ndm.picUrls count]; i++) {
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:[self.ndm.picUrls objectAtIndex:i]]; // 图片路径
        [photos addObject:photo];
    }
    // 2.显示相册
    ZXPhotoBrowser *browser = [[ZXPhotoBrowser alloc] init];
    browser.currentPhotoIndex = [[array objectAtIndex:3] intValue]; // 弹出相册时显示的第一张图片是？
    browser.ndv=self;
    browser.photos = photos; // 设置所有的图片
    [self.navigationController pushViewController:browser animated:YES];
    isBrowser=YES;
}

#pragma mark 点击图集详情
-(void)webClickPicsDetail:(NSArray *)array{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:[array objectAtIndex:3] forKey:@"programId"];
    [dic setValue:[array objectAtIndex:4]forKey:@"picsId"];
    PicsListModel *plm=[[PicsListModel alloc] initWithDict:dic];
    MJPhotoBrowser *mpb=[[MJPhotoBrowser alloc] init];
    mpb.main=self.main;
    mpb.plm=plm;
    [self.navigationController pushViewController:mpb animated:YES];
}


#pragma mark 点击文章详情
-(void)webClickNewsDetail:(NSArray *)array{
    NewsDetailViewController *ndv=[[NewsDetailViewController alloc] initWithProgramId:[array objectAtIndex:3] articleId:[array objectAtIndex:4] main:self.main];
    [self.navigationController pushViewController:ndv animated:YES];
}

#pragma mark 点赞处理
-(void)doUpDownHandle:(NSArray *)array{
    if (_doUpDown==0||_doUpDown==1) {
        NSString *text=(_doUpDown==0)?@"踩":@"赞";
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"21世纪网"
                                                        message:[NSString stringWithFormat:@"您已经%@过了",text]
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    
    NSInteger type=[[array objectAtIndex:3] intValue];
    NSString *fun=(type==0)?@"do_down()":@"do_up()";
    [_web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@",fun]];
    _doUpDown=type;
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
            //显示未读消息数
            if ([INSTANCE totalUnReadCount]>0) {
                _chatNumView=[[NoticeOperation getId] showChatNumViewWithPoint:CGPointMake(_bottom.frame.size.width-7, 8) superView:_bottom msg:@" "];
            }
            
        });
    });
}



@end
