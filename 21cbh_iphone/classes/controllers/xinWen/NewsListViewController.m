//
//  NewsListViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "NewsListViewController.h"
#import "FileOperation.h"
#import "NewsDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "XinWenHttpMgr.h"
#import "MJRefresh.h"
#import "WebViewController.h"
#import "NewListCell.h"
#import "PicsListModel.h"
#import "MJPhotoBrowser.h"
#import "NoticeOperation.h"
#import "NewListDB.h"
#import "TopPicDB.h"
#import "AdBarDB.h"
#import "NewListRecordDB.h"
#import "NewsSpecialViewController.h"

#define KTopHeight 100
NSString *const MJTableViewCellIdentifier = @"table";
@interface NewsListViewController (){
    ZXCycleScrollView *_csView;
    UITableView *_table;
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
    
    AdBarModel *_adBarModel;
    NewListDB *_nlmDB;
    TopPicDB *_tpDB;
    AdBarDB *_adDB;
    NewListRecordDB *_nlrDB;
    NSMutableArray *_tpms;//头图信息
    NSMutableArray *_nlms;//新闻列表信息
    NSOperationQueue *_dbQueue;//数据库操作队列
    
    BOOL isFirstLocal;
    bool topFinish;
    bool newListFinish;
}

@property(strong,nonatomic) AdBarView *adBarView;

@end

@implementation NewsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
    
}

-(void)viewDidAppear:(BOOL)animated{
    if (isFirstLocal) {
        //加载本地资源
        [self loadLocalData];
        isFirstLocal=NO;
    }
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if(_csView){
        [_csView stopAnimation];
    }
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //清图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
}


/**
 为了保证内部不泄露，在dealloc中释放占用的内存
 */
-(void)dealloc{
    _nlmDB=nil;
    _tpDB=nil;
    _adDB=nil;
    _nlrDB=nil;
    _tpms=nil;
    _nlms=nil;
    _dbQueue=nil;
    _programId=nil;
    _programName=nil;
    self.main=nil;
    
    [_header free];
    [_footer free];
    //清图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - ------------自定义方法--------------------
#pragma mark 初始化数据
-(void)initParams{
    _tpms=[NSMutableArray array];
    _nlms=[NSMutableArray array];
    _nlmDB=[[NewListDB alloc] init];
    _tpDB=[[TopPicDB alloc] init];
    _adDB=[[AdBarDB alloc] init];
    _nlrDB=[[NewListRecordDB alloc] init];
    isFirstLocal=YES;
    topFinish=NO;
    newListFinish=NO;
    _dbQueue=self.main.dbQueue;
}
#pragma mark 初始化视图
-(void)initViews{
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    //table列表
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-61-20-40-35)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor=[UIColor clearColor];
    _table.separatorColor=[UIColor clearColor];
    _table.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    [self.view addSubview:_table];
    
    
    //头图
    ZXCycleScrollView *csView = [[ZXCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KTopHeight) animationDuration:8.0];
    
    [self.view addSubview:csView];
    csView.delegate = self;
    csView.datasource = self;
    _csView=csView;
    _table.tableHeaderView=_csView;
    _csView.userInteractionEnabled=NO;
    
    // 1.注册
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:MJTableViewCellIdentifier];
    // 3.集成刷新控件
    // 下拉刷新
    [self addHeader];
    //上拉加载更多
    [self addFooter];
}

#pragma mark 当前的子控制器为选中状态
-(void)refreshView{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double recordTime=[[defaults objectForKey:self.programId] doubleValue];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    if ((nowTime-recordTime)>(15*60)) {//每隔15分钟刷新一次
        [defaults setObject:[NSString stringWithFormat:@"%f",nowTime] forKey:self.programId];
        [defaults synchronize];
        [_header beginRefreshing];
    }

    //头图页数大于1就循环滚动
    if (_tpms.count>1) {
        [_csView startAnimation];
    }
    
}

#pragma mark 当前的子控制器为非选中状态
-(void)endRefreshView{    
    [_csView resetAndStopAnimation];
}

#pragma mark 设置table的高度
-(void)setTableHeight:(CGFloat)height{
    
    //调整table的高度
    CGRect frame=_table.frame;
    frame.size.height+=height;
    [UIView animateWithDuration:0.3f animations:^{
        _table.frame=frame;
    }];
}


#pragma mark 头图调整
-(void)adjustCsView{
    if (_tpms.count<2) {
        _csView.scrollView.contentSize=CGSizeMake(self.view.frame.size.width, 0);
        _csView.pageControl.hidden=YES;
        [self endRefreshView];
    }else{
        _csView.scrollView.contentSize=CGSizeMake(self.view.frame.size.width*3, 0);
        _csView.pageControl.hidden=NO;
    }
}

#pragma mark 加载本地资源
-(void)loadLocalData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //新闻列表本地资源
        _nlms=[_nlmDB getNewListWithProgramId:self.programId];
        
        //头图列表本地资源
        _tpms=[_tpDB getTopPicsWithProgramId:self.topProgramId];
        if (_tpms.count>0) {
            _csView.userInteractionEnabled=YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self adjustCsView];
            [_csView reloadData];
            [_table reloadData];
        });
        
    });
}


#pragma mark 检测该广告栏广告是否是用户点击过的
-(void)checkAdBar:(AdBarModel *)abm{
    [_dbQueue addOperationWithBlock:^{
        BOOL b=[_adDB isExistAdBar:abm];
        if (!b) {
            [self getAdBarHandle:abm];
        }
    }];
}

#pragma mark 获取广告栏数据
-(void)getAdBar{
    //NSLog(@"请求广告栏数据");
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.nlv=self;
    NSLog(@"广告栏数据self.programId:%@",self.programId);
    [hmgr adBarWithProgramId:self.programId isProgram:@"1"];
}


#pragma mark 获取广告栏数据后的处理
-(void)getAdBarHandle:(AdBarModel *)adBarModel{
    //NSLog(@"获取广告栏数据后的处理");
    _adBarModel=adBarModel;
    if (!adBarModel.picUrl) {//没picUrl不执行下面的代码
        dispatch_async(dispatch_get_main_queue(), ^{
        if (_adBarView) {
            if (_table.frame.origin.y>0) {
                //执行动画
                [[NoticeOperation getId] yMoveAnimate:-40 view:_table];
                
                CGRect frame=_table.frame;
                frame.size.height+=40;
                _table.frame=frame;
            }
                [_adBarView removeFromSuperview];
            }
            
        });
        
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_adBarView) {
            if (_table.frame.origin.y>0) {
                CGRect frame=_table.frame;
                frame.size.height+=40;
                _table.frame=frame;
            }
            
            [_adBarView removeFromSuperview];
        }
        //广告栏控件
        AdBarView *adBarView=[[AdBarView alloc] initWithPicUrl:adBarModel.picUrl location_y:0];
        adBarView.delegate=self;
        //设置广告栏图片
        [adBarView adBarSetPic];
        [self.view addSubview:adBarView];
        _adBarView=adBarView;
        
    });
    
}

#pragma mark 获取头图数据
-(void)getHead{
    //NSLog(@"请求头图数据");
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.nlv=self;
    [hmgr headWithProgramId:self.topProgramId];
    topFinish=NO;
}

#pragma mark 获取头图数据后的处理
-(void)getHeadHandle:(NSMutableArray *)tpms{
    topFinish=YES;
    if (tpms&&tpms.count>0) {//有数据才执行下面的代码
        [_tpms removeAllObjects];
        _tpms=nil;
        _tpms=tpms;
        if (_tpms.count>0) {
            _csView.userInteractionEnabled=YES;
        }
        
        [_dbQueue addOperationWithBlock:^{
            //插入头图数据
            [_tpDB deleteTpmWithProgramId:self.topProgramId];
            for (int i=_tpms.count-1; i>=0; i--) {
                TopPicModel *tpm=[_tpms objectAtIndex:i];
                [_tpDB insertTpm:tpm programId:self.topProgramId];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self adjustCsView];
            [_csView reloadData];
            if (topFinish&&newListFinish) {
                [self doneWithView:_header];
            }
            
        });
    }else{
        NSLog(@"头图失败后的处理");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (topFinish&&newListFinish) {
                [self doneWithView:_header];
            }
            
        });
    }
}

#pragma mark 获取新闻列表数据
-(void)getNewsListWithisUp:(BOOL)isUp{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.nlv=self;
    if (isUp) {//下拉刷新
        [hmgr newsListWithProgramId:self.programId type:@"" id:@"" order:@"0" addtime:@"0" isUp:isUp];
        newListFinish=NO;
        return;
    }
    
    if (!_nlms||_nlms.count<1) {//没有数据就不执行历史记录查询
        [self doneWithView:_footer];
        return;
    }
    
    //上拉查询历史记录
    NewListModel *nlm=nil;
    nlm=[_nlms objectAtIndex:_nlms.count-1];
    
    
    //有数据刷新
    NSString *newListId=@"";
    NSInteger type=[nlm.type intValue];//类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广)
    switch (type) {
        case 0:
            newListId=nlm.articleId;
            break;
        case 1:
            newListId=nlm.articleId;
            break;
        case 2:
            newListId=nlm.specialId;
            break;
        case 3:
            newListId=nlm.picsId;
            break;
        case 4:
            newListId=nlm.videoId;
            break;
        case 5:
            newListId=nlm.adId;
            break;
        default:
            break;
    }
    
    [hmgr newsListWithProgramId:self.programId type:nlm.type id:newListId order:nlm.order addtime:nlm.addtime isUp:isUp];
}

#pragma mark 获取新闻列表数据后的处理
-(void)getNewsListHandle:(NSMutableArray *)nlms isUp:(BOOL)isUp{
    
    newListFinish=YES;
    if (nlms&&nlms.count>0) {//有数据才执行下面的代码
        
        if (isUp) {//刷新全部替换数据
            [_nlms removeAllObjects];
            _nlms=nil;
            _nlms=nlms;
            //插入新闻列表数据
            [_dbQueue addOperationWithBlock:^{
                [_nlmDB deleteNdmWithProgramId:self.programId];
                for (int i=_nlms.count-1; i>=0; i--) {
                    NewListModel *nlm=[_nlms objectAtIndex:i];
                    [_nlmDB insertNlm:nlm programId:self.programId];
                }
            }];
            
        }else{  //插入到底部
            NSIndexSet *indexSet=nil;
            NSRange range = NSMakeRange(_nlms.count, [nlms count]);
            indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            [_nlms insertObjects:nlms atIndexes:indexSet];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_table reloadData];
            if (topFinish&&newListFinish) {
                if (isUp) {
                    [self doneWithView:_header];
                }else{
                    [self doneWithView:_footer];
                }
            }
            
        });
        
    }else{
        NSLog(@"新闻列表失败后的处理");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doneWithView:_header];
            [self doneWithView:_footer];
            
            if (nlms&&!isUp) {
                [[NoticeOperation getId] showAlertWithMsg:@"已无更多记录" imageName:@"alert_tanhao" toView:self.main.view autoDismiss:YES viewUserInteractionEnabled:NO];
            }
        });
    }
}


#pragma mark 跳转到新闻详情页
-(void)turnToNewsDetailWithArticleId:(NSString *)articleId{
    NewsDetailViewController *ndv=[[NewsDetailViewController alloc] initWithProgramId:self.programId articleId:articleId main:self.main];
    [self.main.navigationController pushViewController:ndv animated:YES];
}

#pragma mark 跳转到图片浏览页
-(void)turnToPicsWithPicsId:(NSString *)picsId followNum:(NSString *)followNum title:(NSString *)title{

    MJPhotoBrowser *mpb=[[MJPhotoBrowser alloc] initWithProgramId:self.programId picsId:picsId followNum:followNum main:self.main];
    [self.main.navigationController pushViewController:mpb animated:YES];
    
}

#pragma mark 跳转到推广广告页
-(void)turnToAdWithAdId:(NSString *)adId type:(NSString *)type url:(NSString *)url{
    WebViewController *wv=[[WebViewController alloc] initWithAdId:adId type:type url:url];
    [self.main.navigationController pushViewController:wv animated:YES];
}

#pragma mark 跳转到专题页
-(void)turnToNpvWithSpecialID:(NSString *)specialID{
    NewsSpecialViewController *npv=[[NewsSpecialViewController alloc] initWithProgramID:self.programId AndSpecialID:specialID];    
    npv.main=self.main;
    [self.main.navigationController pushViewController:npv animated:YES];
}


#pragma mark - ------------AdBarView代理方法--------------------
-(void)finishImage{
    
    if (_table.frame.origin.y==0) {
        
        NSLog(@"下移40");
        //执行动画
        [[NoticeOperation getId] yMoveAnimate:40 view:_table];
        CGRect frame=_table.frame;
        frame.size.height-=40;
        _table.frame=frame;
    }
}


-(void)clickImage{
    NSLog(@"点击了广告栏的图片");
    if ([_adBarModel.adUrl hasPrefix:@"https://itunes.apple.com/cn/app/"]) {//如果是appStore的下载就直接跳转到appStore
        [[UIApplication sharedApplication]  openURL:[NSURL URLWithString:_adBarModel.adUrl]];
        return;
    }
    
    
    WebViewController *wv=[[WebViewController alloc] initWithAdId:_adBarModel.adId type:@"5" url:_adBarModel.adUrl];
    wv.url=_adBarModel.adUrl;
    
    [self.main.navigationController pushViewController:wv animated:YES];
}

-(void)clickBtn{
    
    NSLog(@"点击了广告栏的按钮");
    if (_table.frame.origin.y>0) {
        //执行动画
        [[NoticeOperation getId] yMoveAnimate:-40 view:_table];
        
        CGRect frame=_table.frame;
        frame.size.height+=40;
        _table.frame=frame;
    }
    
    //插入广告栏数据进数据库
    [_dbQueue addOperationWithBlock:^{
        [_adDB deleteAdBar:_adBarModel];
        [_adDB insertWithAdBar:_adBarModel];
    }];
}



#pragma mark - ------------XLCycleScrollView代理方法----------------------------------
- (NSInteger)numberOfPages
{
    return _tpms.count;
}

#pragma mark 头图滚动到当前页面
- (UIView *)pageAtIndex:(NSInteger)index scrollView:(ZXCycleScrollView*)scrollView
{
    CWPCycleView* view=[scrollView dequeueReusableCell];
    if(!view)
    {
        view=[[CWPCycleView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KTopHeight)];
    }
    view.backgroundColor=UIColorFromRGB(0xe1e1e1);

    if (_tpms.count>0&&index<_tpms.count) {
        TopPicModel *tpm=[_tpms objectAtIndex:index];
        [view fillDataWithModel:tpm];
    }

    return view;
}


#pragma mark 点击了gallery上面某个item
- (void)didClickPage:(ZXCycleScrollView *)csView atIndex:(NSInteger)index
{
    TopPicModel *tpm=[_tpms objectAtIndex:index];
    int type=[tpm.type integerValue];
    //百度头图点击统计
    [[Frontia getStatistics]logEvent:@"news_click" eventLabel:[NSString stringWithFormat:@"%@:新闻头图:%i",self.programName,index+1]];
    
    //添加百度不同文章类型统计
    [self addNewsTypeStatictics:type];
    
    switch (type) {
        case 0://普通文章
            [self turnToNewsDetailWithArticleId:tpm.articleId];
            break;
        case 1://原创文章
            [self turnToNewsDetailWithArticleId:tpm.articleId];
            break;
        case 2://专题
            [self turnToNpvWithSpecialID:tpm.specialId];
            break;
        case 3://图集
            [self turnToPicsWithPicsId:tpm.picsId followNum:@"" title:tpm.desc];
            break;
        case 4://视频
            
            break;
        case 5://推广
            [self turnToAdWithAdId:tpm.adId type:tpm.type url:tpm.adUrl];
            break;
        case 6://独家
            [self turnToNewsDetailWithArticleId:tpm.articleId];
            break;
        case 7://活动
            [self turnToAdWithAdId:tpm.adId type:tpm.type url:tpm.adUrl];
            break;
        default:
            break;
            
    }
    
    
}


#pragma mark - ------------UITableView 的代理方法----------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _nlms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_nlms.count>0){//没数据就返回空
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    static NSString *newListCellIdentifier1 = kNewCell1;
    static NSString *newListCellIdentifier2 = kNewCell2;
    NewListCell *cell =nil;
    NewListModel *nlm=[_nlms objectAtIndex:indexPath.row];
    NSInteger type=[[NSString stringWithFormat:@"%@",nlm.type] intValue];
    if (type==3) {//图集三张微缩图
        cell = [tableView dequeueReusableCellWithIdentifier:newListCellIdentifier2];
        if (!cell) {
            cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newListCellIdentifier2];
        }
        cell.dbQueue=_dbQueue;
        cell.nlrDB=_nlrDB;
        [cell setCell2:nlm];
    }else{//单张微缩图
        cell = [tableView dequeueReusableCellWithIdentifier:newListCellIdentifier1];
        if (!cell) {
            cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newListCellIdentifier1];
        }
        cell.dbQueue=_dbQueue;
        cell.nlrDB=_nlrDB;
        [cell setCell1:nlm];
    }
    
    return cell;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewListModel *nlm=[_nlms objectAtIndex:indexPath.row];
    NSInteger type=[[NSString stringWithFormat:@"%@",nlm.type] intValue];
    if(type==3){
        return 135;
    }else{
        return 77;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //添加新闻列表统计
    [[Frontia getStatistics]logEvent:@"news_click" eventLabel:[NSString stringWithFormat:@"%@:新闻列表:%i",self.programName,indexPath.row+1]];
   
    
    NewListModel *nlm=[_nlms objectAtIndex:indexPath.row];
    [_dbQueue addOperationWithBlock:^{
        [_nlrDB insertWithNlm:nlm];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *indexArray=[NSArray arrayWithObject:indexPath];
            [tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:NO];
        });
        
       
    }];
    
    int type=[nlm.type integerValue];
    
    //添加百度不同文章类型统计
    [self addNewsTypeStatictics:type];
    
    switch (type) {
        case 0://普通文章
            [self turnToNewsDetailWithArticleId:nlm.articleId];
            break;
        case 1://原创文章
            [self turnToNewsDetailWithArticleId:nlm.articleId];
            break;
        case 2://专题
            [self turnToNpvWithSpecialID:nlm.specialId];
            break;
        case 3://图集
            [self turnToPicsWithPicsId:nlm.picsId followNum:nlm.followNum title:nlm.title];
            break;
        case 4://视频
            
            break;
        case 5://推广
            [self turnToAdWithAdId:nlm.adId type:nlm.type url:nlm.adUrl];
            break;
        case 6://独家
            [self turnToNewsDetailWithArticleId:nlm.articleId];
            break;
        case 7://活动
            [self turnToAdWithAdId:nlm.adId type:nlm.type url:nlm.adUrl];
            break;
        default:
            break;
    }
    // 取消选中某一行
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    //    CGPoint point = [cell convertPoint:cell.frame.origin toView:self.view];
    //    NSLog(@"cell.y:%f",point.y);
}

#pragma mark - ------------------MJTableView的方法---------------
- (void)addFooter
{
    __unsafe_unretained NewsListViewController *nlv = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _table;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        //获取新闻列表信息
        [self getNewsListWithisUp:NO];
        
        
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是footer
        //[nlv performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0.3];
        // NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer = footer;
    _footer.activityView.color=K808080;
}

- (void)addHeader
{
    __unsafe_unretained NewsListViewController *nlv = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _table;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //        static int i=0;
        //        NSLog(@"刷新:%i",i);
        //        i++;
        //统计用户刷新次数
        [[Frontia getStatistics]logEvent:@"news_refresh" eventLabel:self.programName];
        
        //获取广告栏数据
        [self getAdBar];
        //获取头图信息
        [self getHead];
        //获取新闻列表信息
        [self getNewsListWithisUp:YES];
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        //NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                //NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    //一启动就刷新
    //[header beginRefreshing];
    _header = header;
    _header.activityView.color=K808080;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}


#pragma mark 百度不同类型统计
-(void)addNewsTypeStatictics:(NSInteger )type{

    NSString *typeName;
    
    switch (type) {
        case 0://普通文章
            typeName=@"普通文章";
            break;
        case 1://原创文章
            typeName=@"原创文章";
            break;
        case 2://专题
            typeName=@"专题";
            break;
        case 3://图集
            typeName=@"图集";
            break;
        case 4://视频
             typeName=@"视频";
            break;
        case 5://推广
            typeName=@"推广";
            break;
        case 6://独家
            typeName=@"独家";
            break;
        case 7://活动
            typeName=@"活动";
            break;
        default:
            break;
    }
    
    [[Frontia getStatistics]logEvent:@"news_newstype" eventLabel:[NSString stringWithFormat:@"%@:%@",self.programName,typeName]];
}

@end
