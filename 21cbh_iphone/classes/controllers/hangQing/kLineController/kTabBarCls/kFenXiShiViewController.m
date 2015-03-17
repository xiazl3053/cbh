//
//  kFenXiShiViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-1.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kFenXiShiViewController.h"
#import "baseTableView.h"
#import "fenxishiCell.h"
#import "hangqingHttpRequest.h"
#import "loadingView.h"
#import "kFenXiShiDetailViewController.h"
#import "analystListModel.h"
#import "NoticeOperation.h"

#define kDCellHeight 380

@interface kFenXiShiViewController ()<UITableViewDataSource,UITableViewDelegate>{
    baseTableView *_tableView;
    NSMutableArray *_data;
    hangqingHttpRequest *_request;
    CGFloat _tableHeight;
    int _page; // 页码
    BOOL _isMore;// 是否是加载更多数据
    loadingView *_loadingView;// 加载视图
    UILabel *nomessage; // 无新闻资讯提示
}
@end

@implementation kFenXiShiViewController

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

- (void)viewDidAppear:(BOOL)animated{
    // 更新主视图
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self free];
}

#pragma mark --------------------------------自定义方法-------------------------------
-(void)free{
    [self.view removeAllSubviews];
    // 清除请求
    [_request clearRequest];
    _request = nil;
    _data = nil;
    _tableView = nil;
    nomessage = nil;
}
-(void)clear{}
-(void)show{
    if (!_request) {
        // 初始化参数
        [self initParam];
        // 加载数据
        [self getAnalystList:YES];
        // 初始化视图
        [self initViews];
        // 更新主视图
        [self updateView];
    }
}
#pragma 初始化参数
-(void)initParam{
    _request = [[hangqingHttpRequest alloc] init];
    _data = [[NSMutableArray alloc] init];
    _tableHeight = kDCellHeight;
    _isMore = NO;
    _page = 1;
    kFenXiShiViewController *ks = self;
    _request.errorRequest = ^(hangqingHttpRequest *request){
        // 网络出错处理
        [ks updateView];
        // 隐藏加载视图
        [ks hideLoadingView:YES];
        [ks.kLineView.refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    _request.hqResponse.errorResponse = ^(hangqingHttpResponse *response){
        // 数据返回有误
        [ks updateView];
        // 隐藏加载视图
        [ks hideLoadingView:YES];
        [ks.kLineView.refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    // 更新块的定义
    self.kLineView.kUpdateBlock = ^(KLineViewController *klineView){
        ks->_isMore = NO;
        ks->_page = 1;
        NSLog(@"---DFM---主视图下拉更新");
        [ks getAnalystList:YES];
    };
    // 加载更多块的定义
    self.kLineView.kMoreLoadBlock = ^(KLineViewController *klineView){
        ks->_isMore = YES;
        ks->_page ++;
        [ks getAnalystList:YES];
        
        NSLog(@"---DFM---主视图上啦加载更多");
    };
}
#pragma mark 初始化视图
-(void)initViews{
    nomessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 30)];
    nomessage.hidden = YES;
    [self.view addSubview:nomessage];
    if (!_tableView) {
        _tableView = [[baseTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _tableHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = ClearColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (kDeviceVersion>=7) {
            _tableView.separatorInset = UIEdgeInsetsMake(0, 13, 0, 13);
        }
        [self.view addSubview:_tableView];
    }
    [_tableView reloadData];
    // 加载视图
    [self addLoadingView];
}
#pragma mark 更新视图
-(void)updateView{
    if (_data.count>0) {
        _tableHeight = kDCellHeight * _data.count;
        _tableView.hidden = NO;
    }else{
        _tableHeight = kDCellHeight;
        _tableView.hidden = YES;
    }
    NSLog(@"---DFM---更新表格高度:%f",_tableHeight);
    // 更新表格的高度
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableHeight);
    // 更新视图的高度
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, _tableHeight);
    // 更新主视图的高度
    if (self.kLineView) {
        [self.kLineView updateMainViewHeight:(_tableHeight)];
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

#pragma mark ------------------------------UITableViewDelegate代理实现--------------------------
#pragma mark 表格总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}
#pragma mark 表格cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kDCellHeight;
}
#pragma mark 表格cell的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [[NSString alloc] initWithFormat:@"fCell"];
    fenxishiCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell==nil) {
        cell = [[fenxishiCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.controller = self;
        [cell show];
    }
    if (indexPath.row<_data.count) {
        cell.data = [_data objectAtIndex:indexPath.row];
        [cell updateCell];
    }
    return cell;
}
#pragma mark 点击表格行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row<_data.count) {
        NSLog(@"---DFM---点击push：%d",indexPath.row);
        analystListModel *m = (analystListModel*)[_data objectAtIndex:indexPath.row];
        kFenXiShiDetailViewController *detail = [[kFenXiShiDetailViewController alloc] init];
        detail.title = m.title;
        detail.pdf = m.pdf;
        m = nil;
        self.kLineView.isBack = YES;
        [self.kLineView.navigationController pushViewController:detail animated:YES];
        detail = nil;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark -----------------------------接口请求处理-------------------------------
#pragma mark 请求接口
-(void)getAnalystList:(BOOL)isAsyn{
    // 显示加载视图
    [self hideLoadingView:NO];
    _page = _page<1?_page=1:_page;
    // 请求K线图资讯数据
    [_request requestAnalystList:self Type:self.kLineView.kType andkId:self.kLineView.kId andPage:_page isAsyn:isAsyn];
}
#pragma mark 数据返回处理
-(void)getAnalystListBundle:(NSMutableArray*)data{
    if (data.count<=0 && _isMore) {
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"已无更多记录" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    }
    // 隐藏加载视图
    [self hideLoadingView:YES];
    if (_isMore) {
        // 加入更多数据
        [_data addObjectsFromArray:data];
        NSLog(@"---DFM---加载更多数据...");
    }else{
        _data = data;
    }
    if (_data.count<=0) {
        // 暂时没有资讯
        nomessage.hidden = NO;
        nomessage.text = @"该证劵暂无分析师";
        nomessage.textAlignment = NSTextAlignmentCenter;
        nomessage.backgroundColor = ClearColor;
        nomessage.textColor = UIColorFromRGB(0xFFFFFF);
        nomessage = nil;
    }else{
        nomessage.hidden = YES;
    }
    // 更新视图
    [self updateView];
    [_tableView reloadData];
    [self.kLineView.refreshView endRefreshing];
}


@end
