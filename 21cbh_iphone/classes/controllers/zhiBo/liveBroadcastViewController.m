//
//  liveBroadcastViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-5-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "liveBroadcastViewController.h"
#import "MJRefresh.h"
#import "liveBroadcastModel.h"
#import "liveBroadcastCell.h"
#import "XinWenHttpMgr.h"
#import "NewsDetailViewController.h"


#define kstopRefresh @"停止刷新"
#define kstartRefresh @"启动刷新"

NSString *const MJTableViewCellIdentifier3 = @"table";

@interface liveBroadcastViewController (){
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
    UITableView *_table;
    UIButton *_controlRefreshBtn;//控制刷新按钮
    
    NSMutableArray *_lbms;
    bool isFirst;//控制加载
    BOOL isRefresh;//控制是否替换整个数据
    BOOL isAutoRefresh;//控制自动刷新
    
    NSTimer *_timer;
}

@end

@implementation liveBroadcastViewController


- (void)viewDidLoad
{
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    self.main.delegate=self;
    if (isFirst) {
        //开启定时器
        [self initTimer];
        isFirst=NO;
    }
}


-(void)viewDidAppear:(BOOL)animated{
    if (!isAutoRefresh) {
        [_timer setFireDate:[NSDate date]];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    if (!isAutoRefresh) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return _lbms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_lbms.count>0){//没数据就返回空
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    static NSString *liveBroadcastCellIdentifier=kliveBroadcastCell;
    liveBroadcastCell *cell =nil;
    liveBroadcastModel *lbm=[_lbms objectAtIndex:indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:liveBroadcastCellIdentifier];
    
    if (!cell) {
        
        cell=[[liveBroadcastCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:liveBroadcastCellIdentifier];
    }
    
    //设置数据
    [cell setCell:lbm];
    
    return cell;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    liveBroadcastModel *lbm=[_lbms objectAtIndex:indexPath.row];
    return [liveBroadcastCell currentHight:lbm];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //跳转到文章详情页
    liveBroadcastModel *lbm=[_lbms objectAtIndex:indexPath.row];
    NewsDetailViewController *ndv=[[NewsDetailViewController alloc] initWithProgramId:lbm.programId articleId:lbm.articleId main:self.main];
    [self.main.navigationController pushViewController:ndv animated:YES];
    // 取消选中某一行
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - ------------------MJTableView的方法---------------
- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _table;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //获取直播列表历史数据
        [self liveBroadcastWithisUp:NO];
    };
    _footer = footer;
    _footer.activityView.color=K808080;
}

- (void)addHeader
{
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _table;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        //获取直播列表最新数据
        [self liveBroadcastWithisUp:YES];
        
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
    // 刷新表格
    [_table reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

#pragma mark - --------------------main的代理方法---------------------------
-(void)bottomDown:(UIView *)bottom{
    [self setTableHeight:61];
}


-(void)bottomUp:(UIView *)bottom{
    [self setTableHeight:-61];
}

#pragma mark - --------------以下为自定义方法---------------------
#pragma mark 初始化数据
-(void)initParams{
    
    _lbms=[NSMutableArray array];
    isFirst=YES;
    isRefresh=YES;
    self.main.delegate=self;
    [self getIsAutoRefresh];
}

#pragma mark 初始布局
-(void)initViews{
    //标题栏
    UIView *top=[self Title:@"新闻直播间" returnType:2];
    self.returnBtn.hidden=YES;
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    
    //控制刷新按钮
    UIButton *controlRefreshBtn=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-64-15, (top.frame.size.height-25)*0.5f, 64, 25)];
    controlRefreshBtn.backgroundColor=UIColorFromRGB(0xffffff);
    controlRefreshBtn.layer.borderWidth=0.5f;
    controlRefreshBtn.layer.borderColor=[UIColorFromRGB(0xcccccc) CGColor];
    controlRefreshBtn.titleLabel.font=[UIFont systemFontOfSize:12];
    controlRefreshBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    
    if (!isAutoRefresh) {
        [controlRefreshBtn setTitle:[NSString stringWithFormat:kstopRefresh]forState:UIControlStateNormal];
        [controlRefreshBtn setTitle:[NSString stringWithFormat:kstopRefresh]forState:UIControlStateHighlighted];
    }else{
        [controlRefreshBtn setTitle:[NSString stringWithFormat:kstartRefresh]forState:UIControlStateNormal];
        [controlRefreshBtn setTitle:[NSString stringWithFormat:kstartRefresh]forState:UIControlStateHighlighted];
    }
    
    [controlRefreshBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
    [controlRefreshBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateHighlighted];
    
    [controlRefreshBtn addTarget:self action:@selector(controlRefreshClick) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:controlRefreshBtn];
    _controlRefreshBtn=controlRefreshBtn;
    
    
    //table列表
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-61-20-40-35)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor=[UIColor clearColor];
    _table.separatorColor=[UIColor clearColor];
    _table.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    [self.view addSubview:_table];
    // 1.注册
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:MJTableViewCellIdentifier3];
    // 3.集成刷新控件
    // 下拉刷新
    [self addHeader];
    //上拉加载更多
    [self addFooter];
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

#pragma mark 直播请求
-(void)liveBroadcastWithisUp:(BOOL)isUp{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.lbvc=self;
    if (isUp) {//下拉刷新
        NSString *addtime=nil;
        if (_lbms&&_lbms.count>0&&_lbms.count<2000) {//限制table显示的条数
            liveBroadcastModel *lbm=[_lbms objectAtIndex:0];
            addtime=[NSString stringWithFormat:@"%@",lbm.addtime];
            isRefresh=NO;
        }else{
            addtime=@"0";
            isRefresh=YES;
        }
        
        [hmgr liveBroadcastWithAddtime:addtime isUp:isUp];
        
        return;
    }
    
    if (!_lbms||_lbms.count<1) {//没有数据就不执行历史记录查询
        [self doneWithView:_footer];
        return;
    }
    
    //上拉查询历史记录
    liveBroadcastModel *lbm=nil;
    lbm=[_lbms objectAtIndex:_lbms.count-1];
    [hmgr liveBroadcastWithAddtime:[NSString stringWithFormat:@"%@",lbm.addtime] isUp:isUp];
    
}

#pragma mark 获取新闻列表数据后的处理
-(void)LiveBroadcastHandle:(NSMutableArray *)lbms isUp:(BOOL)isUp{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (lbms&&lbms.count>0) {//有数据才执行下面的代
            
            NSIndexSet *indexSet=nil;
            if (isUp) {//插入到顶部
                if (isRefresh) {//条数超过了限制,替换所有的数据
                    isRefresh=NO;
                    _lbms=lbms;
                }else{
                    NSRange range = NSMakeRange(0, [lbms count]);
                    indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    [_lbms insertObjects:lbms atIndexes:indexSet];
                }
                
            }else{  //插入到底部
                NSRange range = NSMakeRange(_lbms.count, [lbms count]);
                indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                [_lbms insertObjects:lbms atIndexes:indexSet];
                
            }
            
            //刷新列表
            [_table reloadData];
            
        }else{
            if (lbms&&!isUp) {
                [[NoticeOperation getId] showAlertWithMsg:@"已无更多记录" imageName:@"alert_tanhao" toView:self.main.view autoDismiss:YES viewUserInteractionEnabled:NO];
            }
        }
        
        if (isUp) {
            [self doneWithView:_header];
        }else{
            [self doneWithView:_footer];
        }
    });
}


#pragma mark 定时器
-(void)initTimer{
    //定时器
    NSTimeInterval timeInterval =60.0 ;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerRequest) userInfo:nil repeats:YES];
    _timer=timer;
    
    if (isAutoRefresh) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
}


#pragma mark 定时请求
-(void)timerRequest{
    [_header beginRefreshing];
}


#pragma maek 获取自动刷新标识
-(void)getIsAutoRefresh{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    isAutoRefresh =[defaults boolForKey:@"isAutoRefresh"];
}

#pragma maek 保存自动刷新标识
-(void)saveIsAutoRefresh{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isAutoRefresh forKey:@"isAutoRefresh"];
    [defaults synchronize];
}


#pragma mark controlRefreshBtn点击
-(void)controlRefreshClick{
    isAutoRefresh=!isAutoRefresh;
    if (!isAutoRefresh) {
        [_controlRefreshBtn setTitle:[NSString stringWithFormat:kstopRefresh]forState:UIControlStateNormal];
        [_controlRefreshBtn setTitle:[NSString stringWithFormat:kstopRefresh]forState:UIControlStateHighlighted];
        [_timer setFireDate:[NSDate date]];
    }else{
        [_controlRefreshBtn setTitle:[NSString stringWithFormat:kstartRefresh]forState:UIControlStateNormal];
        [_controlRefreshBtn setTitle:[NSString stringWithFormat:kstartRefresh]forState:UIControlStateHighlighted];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    //保存自动刷新标识
    [self saveIsAutoRefresh];
    
}

@end
