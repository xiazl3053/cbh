//
//  baseMarketListViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "baseMarketListViewController.h"
#import "FileOperation.h"
#import "basehqCell.h"
#import "mainTableView.h"
#import "hangqingHttpRequest.h"
#import "dapanListModel.h"
#import "KLineViewController.h"
#import "AppDelegate.h"
#import "CommonOperation.h"
#import "stocksDetailsListModel.h"
#import "huShenViewController.h"
#import "DCommon.h"
#import "NoticeOperation.h"

#define kTitlePadding 5
#define kTitleWidth 48
#define kDapanTitleColor UIColorFromRGB(0x000000)
#define kDapanTitleFont [UIFont systemFontOfSize:16]
#define kDRefreshTime 10

@interface baseMarketListViewController (){
    mainTableView *_tableView;
    NSMutableArray *_data;
    NSMutableArray *_oldData;
    hangqingHttpRequest *_hqRequest;
    // 大盘接口参数
    NSMutableArray *_fileds;// 字段集合
    int _pageCount;// 分页总数
    int _page;// 当前页码
    NSTimer *_timer;// 定时刷新
    BOOL _isRefresh;// 是否允许刷新
    NSString *_list;// 刷新ID集合
    huShenViewController *_huShen;// 沪深股显示
    MJRefreshBaseView *_refreshView;
    UIView *_pageMoveTipView;// 分页提示视图
}

@end

@implementation baseMarketListViewController


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
    // 初始化参数
    [self initParam];
    // 初始化视图
    [self initView];
    // 清除timer
    [self clearTimer];
    
}

-(void)viewDidAppear:(BOOL)animated{
    // 清除timer
    [self clearTimer];
    // 初始化tableview
    [self initDidView];
    // 异步加载数据
    [self getDapanList:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [self clearTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //self.view = nil;
    
}

-(void)dealloc{
    [self free];
}

#pragma mark --------------------自定义方法------------------
-(void)free{
    [self clearTimer];
    _tableView = nil;
    _data = nil;
    [_hqRequest clearRequest];
    _hqRequest = nil;
    _fileds = nil;
    _element = nil;
    _oldData = nil;
    _huShen = nil;
    _pageMoveTipView = nil;
    [self.view removeAllSubviews];
}
#pragma mark 显示视图
-(void)show{
    if (_tableView && _data.count>0) {
        [_tableView SetTableHeight:_data.count*44];
    }
}
#pragma mark 清除视图
-(void)clear{
    [self clearTimer];
}
#pragma mark 初始化参数
-(void)initParam{
    _page = 1;
    _isRefresh = NO;
    // 初始化数据仓库
    _data = [[NSMutableArray alloc] init];
    // 初始化网络连接请求
    _hqRequest = [[hangqingHttpRequest alloc] init];
    // 网络异常回调 在此请处理好网络异常事件
    __unsafe_unretained baseMarketListViewController *mk = self;
    _hqRequest.errorRequest = ^(hangqingHttpRequest* request){
        NSLog(@"---DFM---网络异常");
        [mk->_refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    
    // 网络异常回调 在此请处理好网络异常事件
    _hqRequest.hqResponse.errorResponse = ^(hangqingHttpResponse* response){
        NSLog(@"---DFM---数据异常");
        [mk->_refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
}


#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor = kBackgroundcolor;
    // 头部
    [self initTitle:self.title returnType:0];
}

#pragma mark 延迟加载视图
-(void)initDidView{
    if (!_tableView) {
        // 根据高度变化适配屏幕
        CGFloat h = [DCommon getChangeHeight];
        CGFloat topHeight = self.topView.frame.size.height+self.topView.frame.origin.y;
        if (h==0) {
            h = self.view.frame.size.height-topHeight;
        }else{
            h = self.view.frame.size.height-topHeight-h;
        }
        
        _tableView = [[mainTableView alloc] initWithController:self andFrame:CGRectMake(0,topHeight,self.view.frame.size.width,h)];
        [self.view addSubview:_tableView];
        _tableView.refreshDelegate = self;
        _tableView.leftWidth = 80;
        _tableView.page = _page;
        _tableView.isShowRefreshFooter = YES;
        _tableView.buttonIndex = 2; // 涨幅按钮
        _tableView.orderBy = self.orderBy; // 默认排序
        if (self.listType>0) {
            _tableView.isScrollLeft = NO;
        }
        _tableView.mainHeight = h;
        [_tableView show];
        // 回调标题点击事件
        __block __unsafe_unretained baseMarketListViewController *dp = self;
        _tableView.titleButtonClickBlock = ^(mainTableView *maintable){
            if (maintable.buttonIndex>0) {
                // 参数组合
                dp->_orderBy = [[maintable.buttonState objectAtIndex:maintable.buttonIndex] intValue];
                if (dp->_fileds) {
                    dp->_element = [dp->_fileds objectAtIndex:maintable.buttonIndex+1];
                }
                // 开始旋转
                [dp.market.transformImage start];
            }else{
                dp->_element = @"";
                dp->_orderBy = 0;
            }
            dp->_isRefresh = NO;
            // 请求接口
            [dp getDapanList:YES];
            NSLog(@"---DFm---当前点击了%@,排序：%d",dp->_element,dp->_orderBy);
        };
    }
    
    // 点击旋转按钮 回调块
    __unsafe_unretained baseMarketListViewController *_dp = self;
    self.market.transformImage.clickActionBlock = ^(transformImageView *trans){
        NSLog(@"---DFM---回调Block");
        [_dp getDapanList:YES];
    };
    
    // 放沪深股在底部
    if (!_huShen) {
        _huShen = [[huShenViewController alloc] initWithParent:self andFrame:self.view.frame];
    }
}

#pragma mark 添加一个分页提示视图
-(void)addTipView{
    if (!_pageMoveTipView) {
        CGFloat x = 5;
        CGFloat y = _tableView.frame.origin.y+44;
        CGFloat w = self.view.frame.size.width-10;
        CGFloat h = 25;
        _pageMoveTipView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _pageMoveTipView.backgroundColor = UIColorFromRGB(0x262626);
        _pageMoveTipView.layer.cornerRadius = 3;
        _pageMoveTipView.alpha = 0;
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        t.backgroundColor = ClearColor;
        t.text = [NSString stringWithFormat:@"当前是第%d页",_page];
        t.font = [UIFont fontWithName:kFontName size:14];
        t.textAlignment = NSTextAlignmentCenter;
        t.textColor = UIColorFromRGB(0xFFFFFF);
        [_pageMoveTipView addSubview:t];
        t = nil;
        [self.view addSubview:_pageMoveTipView];
        // 逐渐显示并移除
        [UIView animateWithDuration:1 animations:^{
            _pageMoveTipView.alpha = 0.8;
        } completion:^(BOOL finished){
            [self performSelector:@selector(removeTipView) withObject:nil afterDelay:1];
        }];
    }
}
-(void)removeTipView{
    [UIView animateWithDuration:0.5 animations:^{
        _pageMoveTipView.alpha = 0;
    } completion:^(BOOL finished){
        [_pageMoveTipView removeFromSuperview];
        _pageMoveTipView = nil;
    }];
}

#pragma mark 推出子视图
-(void)pushKlineController{
    int currentPage = 1;
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (dapanListModel *m in _data) {
        // 页数
        [temp addObject:[[NSArray alloc] initWithObjects:m.marketId,m.marketName,[NSNumber numberWithInt:self.kType], nil]];
        // 当前页
        if ([m.marketId isEqualToString:self.kId]) {
            currentPage = [_data indexOfObject:m];
        }
    }
    
    KLineViewController *kline = [[KLineViewController alloc] initWithBackController:self kId:self.kId KType:self.kType KName:self.kName andPageArray:temp andPage:currentPage];
    temp = nil;
    [self.navigationController pushViewController:kline animated:YES];
    kline = nil;
    
}
#pragma mark 返回上一级视图
-(void)returnBack{
    [self free];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -------------------UITableViewDelegate代理实现--------------------

#pragma mark 表格每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}

#pragma mark 表格行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"dpcell";// [[NSString alloc] initWithFormat:@"dpcell_%d",row];
    basehqCell *cell = (basehqCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[basehqCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.leftWidth = _tableView.leftWidth;
        if (tableView==_tableView.rightTableView) {
            cell.startIndex = 2;
            cell.rowCount = _tableView.titleData.count;
        }
        [cell show];
    }
    
    // 为Cell建立视图
    if (tableView==_tableView.leftTableView) {
        cell.rowCount = 2;
    }
    // 传递数据
    cell.data = [_data objectAtIndex:indexPath.row];
    if (_oldData.count>0) {
        cell.oldData = _oldData;
    }
    // 收集字段信息
    if (!_fileds) {
        _fileds = cell.fileds;
    }
    [cell updateCell];
    
    return cell;
}

#pragma mark 点击Cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    dapanListModel *dp = (dapanListModel*)[_data objectAtIndex:indexPath.row];
    self.kId = dp.marketId;
    self.kName = dp.marketName;
    self.kType = 1; // 个股详情和涨跌榜都是个股 所以都为1
    dp = nil;
    [self pushKlineController];
}

#pragma mark 封装股票集合
-(void)packageList{
    NSString *ids = [[NSString alloc] init];
    for (int i=0; i<_data.count; i++) {
        stocksDetailsListModel *m = (stocksDetailsListModel*)[_data objectAtIndex:i];
        NSString *marketId = m.marketId;
        if (i==0) {
            ids = marketId;
        }else{
            ids = [ids stringByAppendingString:[[NSString alloc] initWithFormat:@",%@",marketId]];
        }
    }
    _list = ids;
}

#pragma mark -----------------------------网络接口响应实现------------------------------------------

#pragma mark 请求数据
-(void)getDapanList:(BOOL)isAsyn{
    // 格式化页码
    _page = _page>_pageCount?_pageCount:_page;
    _page = _page<1?1:_page;
    [self clearTimer];
    // 请求数据前保留上一份数据
    if (_oldData) {
        [_oldData removeAllObjects];
        _oldData = nil;
    }
    if (_isRefresh) {
        _oldData = _data;
    }
    
    if (self.listType==0) {
        if (_isRefresh) {
            // 封装ID集合
            [self packageList];
            [_hqRequest requestStockListRefresh:self Element:_element OrderBy:[[NSString alloc] initWithFormat:@"%d",_orderBy] List:_list isAsyn:isAsyn];
        }else{
            // 请求个股详情列表数据
            [_hqRequest requestStocksDetailsList:self Element:_element OrderBy:[[NSString alloc] initWithFormat:@"%d",_orderBy] andPage:_page andType:self.kType isAsyn:isAsyn];
        }
    }else{
        // 请求列表页五分钟涨跌幅数据
        [_hqRequest requestFiveMinuteChangeList:self Element:_element OrderBy:[[NSString alloc] initWithFormat:@"%d",_orderBy] andPage:_page isAsyn:isAsyn];
    }
    // 刷新沪深指数
    if (_isRefresh) {
        // 请求沪深指数
        [_huShen getHushenStocksIndex:isAsyn];
    }
  
}

#pragma mark 个股详情列表接口返回数据 五分钟涨跌榜也采用此方法
-(void)getStocksDetailsListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount{
    _pageCount = pageCount;
    _data = data;
    // 如果不是刷新状态就设置刷新状态，用来默认第一次加载获取是否刷新状态
    if (!_isRefresh) {
        _isRefresh = refresh;
    }
    if (_data.count>0) {
        // 重设下高度
        _tableView.data = _data;
        _tableView.page = _page;
        _tableView.pageCount = _pageCount;
        _tableView.changeHeight = self.changeHeight+_huShen.view.frame.size.height;
        [_tableView update];
        [_tableView SetTableHeight:_data.count*44];
        [_tableView reloadData];
        
    }
    [self.market.transformImage stop];
    // 如果服务器允许刷新则刷新，否则清除刷新
    if (_isRefresh) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kDRefreshTime target:self selector:@selector(getDapanList:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else{
        [self clearTimer];
    }
    
    if (_refreshView) {
        if (_refreshView.isRefreshing) {
            // 提示第几页
            [self addTipView];
        }
        
        [_refreshView endRefreshing];
    }
}




#pragma mark 清除timer
-(void)clearTimer{
    // NSLog(@"---DFM---清除Timer");
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}




#pragma mark --------------------------mainTableViewDelegate代理实现-------------------------------
#pragma mark 开始下拉刷新
-(void)mainTableBeginRefreshing:(MJRefreshBaseView*)refreshView{
    _refreshView = refreshView;
    NSLog(@"---DFM---mainTableBeginRefreshing");
    _page --;
    [_data removeAllObjects];
    _data = nil;
    // 请求接口 同步
    [self getDapanList:YES];
    
}

#pragma mark 上啦刷新加载
-(void)mainTableMoreRefreshing:(MJRefreshBaseView *)refreshView{
    _refreshView = refreshView;
    _page ++;
    [_data removeAllObjects];
    _data = nil;
    // 请求接口 同步
    [self getDapanList:YES];

    
}

#pragma mark 结束下拉刷新
-(void)mainTableEndRefreshing:(MJRefreshBaseView*)refreshView{
    NSLog(@"---DFM---DaPan.mainTableEndRefreshing");
    [_tableView.mainView setContentOffset:CGPointMake(0, 0)];
}

@end
