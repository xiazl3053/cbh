//
//  kNewsViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-1.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kNewsViewController.h"
#import "basehqCell.h"
#import "baseTableView.h"
#import "hangqingHttpRequest.h"
#import "kChartNewsListModel.h"
#import "loadingView.h"
#import "NewsDetailViewController.h"
#import "kNewsDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "NoticeOperation.h"

@interface kNewsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    baseTableView *_tableView;
    CGFloat _cellHeight; // cell的高度
    NSMutableArray *_data; // 表格的数据
    hangqingHttpRequest *_request;// 接口请求
    int _columnId ;// 栏目id
    int _page; // 页码
    BOOL _isMore;// 是否是加载更多数据
    loadingView *_loadingView;// 加载视图
    UILabel *nomessage; // 无新闻资讯提示
    NSMutableArray *_reads;// 已读列表
}
@end

@implementation kNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [self free];
}

#pragma  mark -----------------------------自定义方法-----------------------------
-(void)free{
    // 清除请求
    [_request clearRequest];
    _request = nil;
    _data = nil;
    _reads = nil;
    _tableView = nil;
    nomessage = nil;
    self.kLineView.kUpdateBlock = nil;
    self.kLineView.kMoreLoadBlock = nil;
    [self.view removeAllSubviews];
}
-(void)clear{
    self.kLineView.kUpdateBlock = nil;
    self.kLineView.kMoreLoadBlock = nil;
}
-(void)show{
    [self initRefreshBlock];
    if (!_request) {
        [self initParam];
        [self initViews];
        // 加载数据
        [self getKChartNewsList:YES];
    }
    
    
}
#pragma mark 初始化参数
-(void)initParam{
    __unsafe_unretained kNewsViewController *nv = self;
    _request = [[hangqingHttpRequest alloc] init];
    _request.errorRequest = ^(hangqingHttpRequest *request){
        // 网络出错处理
        // 更新视图
        [nv updateTable];
        // 隐藏加载视图
        [nv hideLoadingView:YES];
        // 刷新控件结束刷新
        [nv.kLineView.refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    _request.hqResponse.errorResponse = ^(hangqingHttpResponse *response){
        // 数据返回有误
        // 更新视图
        [nv updateTable];
        // 隐藏加载视图
        [nv hideLoadingView:YES];
        // 刷新控件结束刷新
        [nv.kLineView.refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    _page = 1;
    //_columnId = 0; // 默认新闻
    _isMore = NO;
    _cellHeight = 75;
    _data = [[NSMutableArray alloc] init];
    _reads = [[NSMutableArray alloc] init];
    [_reads addObject:@"Null"];
    [self initRefreshBlock];
}

-(void)initRefreshBlock{
    __block __unsafe_unretained kNewsViewController *nv = self;
    // 更新块的定义
    self.kLineView.kUpdateBlock = ^(KLineViewController *klineView){
        
        nv->_isMore = NO;
        nv->_page = 1;
        NSLog(@"---DFM---主视图下拉更新");
        [nv getKChartNewsList:YES];
    };
    // 加载更多块的定义
    self.kLineView.kMoreLoadBlock = ^(KLineViewController *klineView){
        nv->_isMore = YES;
        nv->_page ++;
        [nv getKChartNewsList:YES];
        
        NSLog(@"---DFM---主视图上啦加载更多");
    };
}
#pragma mark 初始化视图
-(void)initViews{
    nomessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 30)];
    nomessage.hidden = YES;
    [self.view addSubview:nomessage];
    [self.view addSubview:nomessage];
    self.view.backgroundColor = ClearColor;
    _tableView = [[baseTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _cellHeight) style:UITableViewStylePlain] ;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = ClearColor;
    _tableView.separatorColor = ClearColor;
    if (kDeviceVersion>=7) {
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [self.view addSubview:_tableView];
    // 加载视图
    [self addLoadingView];
}
#pragma mark 更新表格
-(void)updateTable{
    if (_data.count>0) {
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, _cellHeight*_data.count);
        [_tableView reloadData];
        if (self.kLineView) {
            [self.kLineView updateMainViewHeight:_cellHeight*_data.count];
        }
    }else{
        if (self.kLineView) {
            [self.kLineView updateMainViewHeight:_cellHeight*3];
        }
    }
    
}
#pragma mark 加载视图
-(void)addLoadingView{
    if (!_loadingView) {
        CGFloat lw = 100;
        CGFloat lh = 80;
        _loadingView = [[loadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-lw)/2,
                                                                     20,
                                                                     lw, lh)];
        [self.view addSubview:_loadingView];
    }
}
#pragma mark 是否显示加载视图
-(void)hideLoadingView:(BOOL)yes{
    _loadingView.hidden = yes;
    if (yes) {
        [_loadingView stop];
    }
    else{
        [_loadingView start];
    }
    [self.view bringSubviewToFront:_loadingView];
}
#pragma mark ------------------------------UITableViewDelegate代理实现--------------------------------
#pragma mark 表格总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}
#pragma mark 表格cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}
#pragma mark 表格cell的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"nCell";
    basehqCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell==nil) {
        cell = [[basehqCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // 标题
        UILabel *t = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, cell.frame.size.width-30, 50)];
        t.font = [UIFont fontWithName:kFontName size:14];
        t.numberOfLines = 2;
        t.backgroundColor = ClearColor;
        t.textColor = UIColorFromRGB(0x000000);
        [cell.contentView addSubview:t];
        // 时间
        UILabel *time = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, cell.frame.size.width-30, 22)];
        time.font = [UIFont fontWithName:kFontName size:12];
        time.backgroundColor = ClearColor;
        time.textColor = UIColorFromRGB(0x808080);
        time.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:time];
        time = nil;
        t = nil;
        
    }
    if (indexPath.row<_data.count) {
        kChartNewsListModel *model = (kChartNewsListModel*)[_data objectAtIndex:indexPath.row];
        if (model) {
            NSArray *views = cell.contentView.subviews;
            int one = 1;
            int two = 2;
            if (views.count<3) {
                one = 0;
                two = 1;
            }
            // 标题
            UILabel *t = (UILabel*)[views objectAtIndex:one];
            t.text = model.title;
            int num = [_reads indexOfObject:[NSNumber numberWithInt:indexPath.row]];
            if (num>0 && num<_data.count) {
                t.textColor = UIColorFromRGB(0x999999);
            }
            t = nil;
            // 时间
            UILabel *time = (UILabel*)[views objectAtIndex:two];
            time.text = model.time;
            time = nil;
        }
        model = nil;
    }
    
    
    return cell;
}
#pragma mark 点击表格行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row<_data.count) {
        // 至为已读
        int num = [_reads indexOfObject:[NSNumber numberWithInt:indexPath.row]];
        if (num>_data.count) {
            [_reads addObject:[NSNumber numberWithInt:indexPath.row]];
            // 标题颜色变为已读
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSArray *views = cell.contentView.subviews;
            // 标题
            UILabel *t = (UILabel*)[views objectAtIndex:0];
            t.textColor = UIColorFromRGB(0x999999);
            t = nil;
            views = nil;
        }
        kChartNewsListModel *model = [_data objectAtIndex:indexPath.row];
        // 创建新闻视图
        // 新闻就跳到新闻详情页，个股情报和公告就跳到公告页面
        if ([self.newsType isEqualToString:@"新闻"]) {
            NewsDetailViewController *newsdetail = [[NewsDetailViewController alloc] initWithProgramId:model.programId articleId:model.ids main:[[CommonOperation getId] getMain]];
            model = nil;
            self.kLineView.isBack = YES;
            [self.kLineView.navigationController pushViewController:newsdetail animated:YES];
            newsdetail = nil;
            
        }else{
            kNewsDetailViewController *newsdetail = [[kNewsDetailViewController alloc] init];
            
            newsdetail.articleId = model.ids;
            if ([self.newsType isEqualToString:@"新闻"]) {
                newsdetail.column = @"0";
            }
            if ([self.newsType isEqualToString:@"情报"]) {
                newsdetail.column = @"1";
            }
            if ([self.newsType isEqualToString:@"公告"]) {
                newsdetail.column = @"2";
            }
            newsdetail.kId = self.kLineView.kId;
            newsdetail.kName = self.kLineView.kName;
            newsdetail.kType = self.kLineView.kType;
            model = nil;
            self.kLineView.isBack = YES;
            [self.kLineView.navigationController pushViewController:newsdetail animated:YES];
            newsdetail = nil;
        }
        
    }
}

#pragma mark -----------------------------接口请求处理-------------------------------
#pragma mark 请求接口
-(void)getKChartNewsList:(BOOL)isAsyn{
    // 更新视图
    [self updateTable];
    // 显示加载视图
    [self hideLoadingView:NO];
    _page = _page<1?_page=1:_page;
    // 请求K线图资讯数据
    [_request requestKChartNewsList:self Type:self.kLineView.kType andkId:self.kLineView.kId ColumnID:_columnId andPage:_page isAsyn:isAsyn];
}
#pragma mark 数据返回处理
-(void)getKChartNewsListBundle:(NSMutableArray*)data{
    if (data.count<=0 && _isMore) {
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"已无更多记录" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    }
    // 隐藏加载视图
    [self hideLoadingView:YES];
    if (_isMore) {
        // 加入更多数据
        [_data addObjectsFromArray:data];
    }else{
        _data = data;
    }
    if (_data.count<=0) {
        // 暂时没有资讯
        nomessage.hidden = NO;
        nomessage.text = [[NSString alloc] initWithFormat:@"该证劵暂无%@",self.newsType];
        nomessage.textAlignment = NSTextAlignmentCenter;
        nomessage.backgroundColor = ClearColor;
        nomessage.textColor = UIColorFromRGB(0xFFFFFF);
    }else{
        nomessage.hidden = YES;
    }
    // 更新视图
    [self updateTable];
    [_tableView reloadData];
    // 刷新控件结束刷新
    [self.kLineView.refreshView endRefreshing];
}

@end
