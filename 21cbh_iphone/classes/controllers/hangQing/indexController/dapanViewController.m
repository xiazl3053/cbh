//
//  dapanViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "dapanViewController.h"
#import "FileOperation.h"
#import "basehqCell.h"
#import "mainTableView.h"
#import "hangqingHttpRequest.h"
#import "dapanListModel.h"
#import "KLineViewController.h"
#import "AppDelegate.h"
#import "CommonOperation.h"
#import "huShenViewController.h"
#import "DCommon.h"
#import "stocksDetailsListModel.h"
#import "NoticeOperation.h"

#define kTitlePadding 5
#define kTitleWidth 48
#define kDapanTitleColor UIColorFromRGB(0x000000)
#define kDapanTitleFont [UIFont fontWithName:kFontName size:16]
#define kDRefreshTime 10

@interface dapanViewController (){
    mainTableView *_tableView;
    NSMutableArray *_data;
    NSMutableArray *_oldData;
    hangqingHttpRequest *_hqRequest;
    // 大盘接口参数
    NSMutableArray *_fileds;// 字段集合
    NSString *_element; // 排序字段
    int _orderBy; // 排序类型  0降序 1升序
    int _pageCount;// 分页总数
    int _page;// 当前页码
    NSTimer *_timer;// 定时刷新
    BOOL _isRefresh;// 是否允许刷新
    NSString *_list;// 刷新ID集合
    BOOL _isStop;// 是否允许刷新，一般界面显示后就允许刷新否则不允许
    MJRefreshBaseView *_refreshView;
    UIView *_pageMoveTipView;// 分页提示横幅
}

@end

@implementation dapanViewController

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
    
}

-(void)viewDidAppear:(BOOL)animated{
    _isStop = NO; // 允许刷新
    // 清除timer
    [self clearTimer];
    // 初始化tableview
    [self initDidView];
    [self initDatas];
    // 异步加载数据
    [self getDapanList:YES];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    _isStop = YES; // 不允许刷新
    [self clearTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self free];
}

#pragma mark --------------------自定义方法------------------
-(void)free{
    [self clearTimer];
    _tableView = nil;
    if ([_data class]==[NSMutableArray class]) {
        [_data removeAllObjects];
    }
    _data = nil;
    if ([_oldData class]==[NSMutableArray class]) {
        [_oldData removeAllObjects];
    }
    _oldData = nil;
    [_hqRequest clearRequest];
    _hqRequest = nil;
    _fileds = nil;
    _element = nil;
    _pageMoveTipView = nil;
    [_refreshView free];
    _refreshView = nil;
    [self.view removeAllSubviews];
}
#pragma mark 显示视图
-(void)show{
    _isStop = NO; // 允许刷新
    if (_tableView) {
        if (_data.count>0) {
            [_tableView SetTableHeight:_data.count*44];
            
        }
        
    }
}
#pragma mark 清除视图
-(void)clear{
    _isStop = YES; // 不允许刷新
    [self clearTimer];
}
#pragma mark 初始化参数
-(void)initParam{
    _page = 1;
    _isRefresh = NO;
    _isStop = NO; // 默认为允许刷新
    // 初始化数据仓库
    _data = [[NSMutableArray alloc] init];
    // 初始化数据仓库
    _oldData = [[NSMutableArray alloc] init];
    _element = @"";
    _orderBy = 0;
    // 初始化网络连接请求
    _hqRequest = [[hangqingHttpRequest alloc] init];
    __unsafe_unretained dapanViewController *dp = self;
    // 网络异常回调 在此请处理好网络异常事件
    _hqRequest.errorRequest = ^(hangqingHttpRequest* request){
        NSLog(@"---DFM---网络异常");
        [dp->_refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    // 网络异常回调 在此请处理好网络异常事件
    _hqRequest.hqResponse.errorResponse = ^(hangqingHttpResponse* response){
        NSLog(@"---DFM---数据异常");
        [dp->_refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
}


#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor = kMarketBackground;
    
}

#pragma mark 延迟加载视图
-(void)initDidView{
    if (!_tableView) {
        CGFloat h = [DCommon getChangeHeight];
        if (h==0) {
            h = self.view.frame.size.height;
        }else{
            h = self.view.frame.size.height-48;
        }
        _tableView = [[mainTableView alloc] initWithController:self andFrame:CGRectMake(0,0,self.view.frame.size.width,h)];
        [self.view addSubview:_tableView];
        _tableView.refreshDelegate = self;
        _tableView.leftWidth = 80;
        _tableView.page = _page;
        _tableView.transformImage = self.market.transformImage;
        _tableView.isShowRefreshFooter = YES;
        _tableView.mainHeight = kMarketTabButtonViewHeight;
        [_tableView show];
        // 回调标题点击事件
        __block __unsafe_unretained dapanViewController *dp = self;
        _tableView.titleButtonClickBlock = ^(mainTableView *maintable){
            if (maintable.buttonIndex>0) {
                /*********change*********/
                    // 参数组合
                    dp->_orderBy = [[maintable.buttonState objectAtIndex:maintable.buttonIndex] intValue];
                    if (dp->_fileds||dp->_fileds.count!=0) {
                        @try {
                            if (maintable.buttonIndex<dp->_fileds.count-1) {
                                dp->_element = [dp->_fileds objectAtIndex:maintable.buttonIndex+1];
                            }
                        }
                        @catch (NSException *exception) {
                            NSLog(@"exception===%@",exception);
                        }
                        @finally {
                        }
                    
                    // 开始旋转
                    [dp.market.transformImage start];
                }
            }
            else{
                dp->_orderBy = 0;
                dp->_element = @"";
            }
            dp->_isRefresh = NO;
            // 请求接口
            [dp getDapanList:YES];
            NSLog(@"---DFm---当前点击了%@,排序：%d",dp->_element,dp->_orderBy);
        };
    }
    
}
#pragma mark 初始化数据
-(void)initDatas{
    int p = self.kType+1;
    _data = [DCommon setMarketToLocalWithDatas:nil andPageIndex:p andType:0 andIsGet:YES];
    [self updateTable];
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
    KLineViewController *kline = [[KLineViewController alloc] init];
    kline.kId = self.kId;
    kline.kName = self.kName;
    kline.kType = self.kType;// 0=大盘 1=个股
    if (self.kType>1) {
        kline.kType = 1;
    }
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (dapanListModel *m in _data) {
        // 页数
        [temp addObject:[[NSArray alloc] initWithObjects:m.marketId,m.marketName,[NSNumber numberWithInt:self.kType], nil]];
        // 当前页
        if ([m.marketId isEqualToString:self.kId]) {
            kline.currentPage = [_data indexOfObject:m];
        }
    }
    kline.pageArray = temp;
    temp = nil;
    [self.market.navigationController pushViewController:kline animated:YES];
    kline = nil;
}


#pragma mark -------------------UITableViewDelegate代理实现--------------------

#pragma mark 表格每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}

#pragma mark 表格行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"dpcell";// [[NSString alloc] initWithFormat:@"dpcell_%d",row];
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
    
    if (indexPath.row<_data.count) {
        // 为Cell建立视图
        if (tableView==_tableView.leftTableView) {
            cell.rowCount = 2;
        }
        // 传递数据
        cell.data = [_data objectAtIndex:indexPath.row];
        cell.oldData = _oldData;
        // 收集字段信息
        if (!_fileds) {
            _fileds = cell.fileds;
        }
        [cell updateCell];
    }
    
    
    return cell;
}

#pragma mark 点击Cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    dapanListModel *dp = (dapanListModel*)[_data objectAtIndex:indexPath.row];
    self.kId = dp.marketId;
    self.kName = dp.marketName;
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
#pragma mark 返回某Id所在的行
-(int)returnIndexWithModel:(stocksDetailsListModel*)model{
    NSString *kId = model.marketId;
    int i = -1;
    for (stocksDetailsListModel *item in _oldData) {
        if ([item.marketId isEqualToString:kId]) {
            i = [_oldData indexOfObject:item];
            break;
        }
    }
    return i;
}
#pragma mark 更新表格
-(void)updateTable{
    if (_data.count>0) {
        // 重设下高度
        [_tableView clear];
        _tableView.data = _data;
        _tableView.page = _page;
        _tableView.pageCount = _pageCount;
        _tableView.changeHeight = self.changeHeight;
        [_tableView update];
        [_tableView SetTableHeight:_data.count*44];
    }
    
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
        if ([_oldData respondsToSelector:@selector(removeAllObjects)]) {
            [_oldData removeAllObjects];
        }
        _oldData = nil;
    }
    if (_isRefresh) {
        _oldData = _data.copy;
    }
    
    if (self.kType==0) {
        // 请求大盘列表数据
        [_hqRequest requestDapanList:self Element:_element OrderBy:[[NSString alloc] initWithFormat:@"%d",_orderBy] andPage:_page andType:self.kType isAsyn:isAsyn];
    }else{
        if (_isRefresh) {
            // 封装ID集合
            [self packageList];
            [_hqRequest requestStockListRefresh:self Element:_element OrderBy:[[NSString alloc] initWithFormat:@"%d",_orderBy] List:_list isAsyn:isAsyn];
        }else{
            // 请求个股详情列表数据
            [_hqRequest requestStocksDetailsList:self Element:_element OrderBy:[[NSString alloc] initWithFormat:@"%d",_orderBy] andPage:_page andType:self.kType isAsyn:isAsyn];
        }
    }
}

#pragma mark 大盘列表接口返回数据
// 接口告诉我是否需要刷新以及总的页数
-(void)getDapanListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount{
    if (data.count>0) {
        if ([[_data class] isSubclassOfClass:[NSMutableArray class]]) {
            [_data removeAllObjects];
            _data = nil;
        }
        if (_page==1 && _element.length<=0) {
            int p = 1;
            [DCommon setMarketToLocalWithDatas:data andPageIndex:p andType:0 andIsGet:NO];
        }
    }
    _pageCount = pageCount;
    _data = data;
    data = nil;
    // 如果不是刷新状态就设置刷新状态，用来默认第一次加载获取是否刷新状态
    if (!_isRefresh) {
        _isRefresh = refresh;
    }
    if (_data.count>0) {
        [self updateTable];
        [_tableView reloadData];
    }

    // 如果服务器允许刷新则刷新，否则清除刷新
    // 还有多少毫秒就开始刷新数据
    
    if (_isRefresh && !_isStop) {
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
#pragma mark 个股详情列表接口返回数据
-(void)getStocksDetailsListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount{
    if (data.count>0) {
        if ([[_data class] isSubclassOfClass:[NSMutableArray class]]) {
            [_data removeAllObjects];
            _data = nil;
        }
        if (!_isRefresh && _element.length<=0 && _page==1) {
            int p = self.kType+1;
            [DCommon setMarketToLocalWithDatas:data andPageIndex:p andType:0 andIsGet:NO];
        }
        
    }
    if (pageCount>0) {
        _pageCount = pageCount;
    }
    _data = data;
    data = nil;
    if (_data.count>0) {
        if (_isRefresh) {
            // 只更新前面三个字段值,目前没有那么多数据
            if (_oldData.count>0) {
                NSMutableArray *oData = [[NSMutableArray alloc] init];
                NSMutableArray *oldDatas = [NSMutableArray new];
                for (stocksDetailsListModel *item in _oldData) {
                    stocksDetailsListModel *nitem = [[stocksDetailsListModel alloc] initWithDic:item.dic];
                    [oldDatas addObject:nitem];
                    nitem = nil;
                }
                for (stocksDetailsListModel *item in _data) {
                    // 找到最新值在旧值中的位置
                    int i = [self returnIndexWithModel:item];
                    if (i<oldDatas.count && i>=0){
                        stocksDetailsListModel *newItem = (stocksDetailsListModel*)[oldDatas objectAtIndex:i];
                        // 替换旧值的 最新值 涨跌幅 涨跌额
                        newItem.newestValue = item.newestValue;
                        newItem.changeRate = item.changeRate;
                        newItem.changeValue = item.changeValue;
                        // 替换
                        [oData addObject:newItem];
                        newItem = nil;
                    }
                    
                }
                _data = oData;
                oData = nil;
                oldDatas = nil;
            }
        }else{
            // 如果不是刷新状态就设置刷新状态，用来默认第一次加载获取是否刷新状态
            _isRefresh = refresh;
        }
        // 防止中途改变刷新的状态，比如下拉刷新的时候
        if (_isRefresh || !refresh) {
            // 重设下高度
            [self updateTable];
            [_tableView reloadData];
        }
        
        
    }
    // 如果服务器允许刷新则刷新，否则清除刷新
//    _isRefresh = YES;
//    _isStop = NO;
    
    if (_isRefresh && !_isStop) {
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
    NSLog(@"---DFM---mainTableBeginRefreshing");
    _refreshView = refreshView;
    _isRefresh = NO;
    _page --;
    // 请求接口 同步
    [self getDapanList:YES];
    
}

#pragma mark 上啦刷新加载
-(void)mainTableMoreRefreshing:(MJRefreshBaseView *)refreshView{
    _refreshView = refreshView;
    _isRefresh = NO;
    _page ++;
    // 请求接口 同步
    [self getDapanList:YES];
    
}

#pragma mark 结束下拉刷新
-(void)mainTableEndRefreshing:(MJRefreshBaseView*)refreshView{
    NSLog(@"---DFM---DaPan.mainTableEndRefreshing");
    [_tableView.mainView setContentOffset:CGPointMake(0, 0)];
}

@end
