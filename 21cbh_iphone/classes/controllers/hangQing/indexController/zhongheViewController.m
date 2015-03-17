//
//  zhongheViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "zhongheViewController.h"
#import "baseTableView.h"
#import "basehqCell.h"
#import "tophqCell.h"
#import "MJRefresh.h"
#import "KLineViewController.h"
#import "hangqingHttpRequest.h"
#import "transformImageView.h"
#import "KLineViewController.h"
#import "baseMarketListViewController.h"
#import "NoticeOperation.h"
#import "AppDelegate.h"
#import "CommonOperation.h"
#import "hangqingHttpRequest.h"
#import "changeListModel.h"
#import "DCommon.h"

#define kTopCellHeight 80
#define kDRefreshTime 10

@interface zhongheViewController (){
    baseTableView *_tableView;
    MJRefreshHeaderView *_header;
    NSMutableArray *_marketData; // 大盘数据
    NSMutableArray *_popularData; // 热门行业数据
    NSMutableArray *_goupData; // 涨幅数据
    NSMutableArray *_downData; // 跌幅数据
    NSMutableArray *_goupData5; // 5分钟涨幅数据
    NSMutableArray *_downData5; // 5分钟跌幅数据
    
    hangqingHttpRequest *_hqRequest;
    tophqCell *_topCell ; // 大盘指数cell
    tophqCell *_popularCell; // 热门行业cell
    NSTimer *_timer;// 定时刷新
    BOOL _isRefresh;// 是否允许刷新
    BOOL _isStop; // 是否停止刷新
    MJRefreshBaseView *_refreshView;
}

@end

@implementation zhongheViewController

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
    [self initDatas];
}

-(void)viewWillAppear:(BOOL)animated{
    _isStop = NO; // 允许刷新
    [self clearTimer];
    [self initView];
    [self addHeader];
    // 修正tableView的大小
    [self show];
    [self getMarketIndex:YES]; // 异步加载
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    _isStop = YES; // 停止刷新
    [self clearTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    [self free];
}

#pragma mark --------------------自定义方法------------------
#pragma mark 显示视图
-(void)show{
    _isStop = NO; // 允许刷新
    CGFloat w = _tableView.frame.size.width;
    CGFloat h = self.view.frame.size.height;
    _tableView.frame = CGRectMake(0, 0,w,h);
}
-(void)clear{
    _isStop = YES; // 停止刷新
    [self clearTimer];
}
#pragma mark 清除视图
-(void)free{
    _isStop = YES; // 停止刷新
    [self clearTimer];
    _tableView = nil;
    _marketData = nil;
    _popularData = nil;
    _goupData = nil;
    _downData = nil;
    _goupData5 = nil;
    _downData5 = nil;
    _topCell = nil;
    _popularCell = nil;
    [_header free];
    [self.view removeAllSubviews];
}

#pragma mark 初始化参数
-(void)initParam{
    
    _marketData = [[NSMutableArray alloc] init];
    _popularData = [[NSMutableArray alloc] init];
    _downData = [[NSMutableArray alloc] init];
    _goupData = [[NSMutableArray alloc] init];
    _downData5 = [[NSMutableArray alloc] init];
    _goupData5 = [[NSMutableArray alloc] init];
    _hqRequest = [[hangqingHttpRequest alloc] init];
    _isRefresh = NO;
    _isStop = NO;// 初始化和界面出现都会允许刷新 只有离开界面或者清除内存后就不刷新了
    __unsafe_unretained zhongheViewController *zh = self;
    // 网络异常回调 在此请处理好网络异常事件
    _hqRequest.errorRequest = ^(hangqingHttpRequest* request){
        NSLog(@"---DFM---网络异常");
        [zh->_refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    
    // 网络异常回调 在此请处理好网络异常事件
    _hqRequest.hqResponse.errorResponse = ^(hangqingHttpResponse* response){
        NSLog(@"---DFM---数据异常");
        [zh->_refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
}

#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor = ClearColor;
    if (!_tableView) {
        // 添加tableview
        _tableView = [[baseTableView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height)];
        // NSLog(@"---DFM---frame:%@",NSStringFromCGRect(self.view.frame));
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = ClearColor;
        _tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        if (kDeviceVersion>=7) {
            _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        }
        [self.view addSubview:_tableView];
    }
    
}

#pragma mark 初始化数据
-(void)initDatas{
    _marketData = [DCommon setMarketToLocalWithDatas:nil andPageIndex:0 andType:0 andIsGet:YES];
    _popularData = [DCommon setMarketToLocalWithDatas:nil andPageIndex:0 andType:1 andIsGet:YES];
    
    _downData = [DCommon setMarketToLocalWithDatas:nil andPageIndex:0 andType:2 andIsGet:YES];
    _goupData = [DCommon setMarketToLocalWithDatas:nil andPageIndex:0 andType:3 andIsGet:YES];
    
    _downData5 = [DCommon setMarketToLocalWithDatas:nil andPageIndex:0 andType:4 andIsGet:YES];
    _goupData5 = [DCommon setMarketToLocalWithDatas:nil andPageIndex:0 andType:5 andIsGet:YES];
}


#pragma mark 推出K线图视图
-(void)pushKlineController{
    KLineViewController *kLineController = [[KLineViewController alloc] init];
    kLineController.kId = self.kId; // 个股或者大盘ID
    kLineController.kName = self.kName; // 个股或者大盘名称
    kLineController.kType = self.kType; // 类型 0=大盘 1=沪股 2=深股
    // 封装分页数据
    if (_cellDatas.count>0) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (changeListModel *m in _cellDatas) {
            // 页数
            [temp addObject:[[NSArray alloc] initWithObjects:m.marketId,m.marketName,[NSNumber numberWithInt:self.kType], nil]];
            // 当前页
            if ([m.marketId isEqualToString:self.kId]) {
                kLineController.currentPage = [_cellDatas indexOfObject:m];
            }
        }
        kLineController.pageArray = temp;
        temp = nil;
    }
    
    
    [self.market.navigationController pushViewController:kLineController animated:YES];
    kLineController = nil;
}

#pragma mark 点击更多按钮
-(void)clickMoreButtonAction:(UIButton*)button{
    NSInteger tag = button.tag;
    switch (tag) {
        case 0:
        {
            // 点击大盘指数更多
            [self.market.tabButtonView clickButtonWithTag:101];
        }
            break;
//        case 1:
//        {
//            // 点击热门行业更多
//            baseMarketListViewController *basemarrketList = [[baseMarketListViewController alloc] init];
//            basemarrketList.title = @"行业板块行情";
//            basemarrketList.listType = 1;
//            [self.market.navigationController pushViewController:basemarrketList animated:YES];
//            
//        }
//            break;
        case 1:
        {
            // 点击涨幅榜更多
            baseMarketListViewController *basemarrketList = [[baseMarketListViewController alloc] init];
            basemarrketList.title = @"沪深A股";
            basemarrketList.kType = 3;
            basemarrketList.orderBy = 0;
            basemarrketList.element = @"changeRate";
            [self.market.navigationController pushViewController:basemarrketList animated:YES];
            basemarrketList = nil;
        }
            break;
        case 2:
        {
            // 点击跌幅榜更多
            baseMarketListViewController *basemarrketList = [[baseMarketListViewController alloc] init];
            basemarrketList.title = @"沪深A股";
            basemarrketList.kType = 3;
            basemarrketList.orderBy = 1;
            basemarrketList.element = @"changeRate";
            [self.market.navigationController pushViewController:basemarrketList animated:YES];
            basemarrketList = nil;
        }
            break;
        case 3:
        {
            // 点击五分钟涨幅榜更多
            baseMarketListViewController *basemarrketList = [[baseMarketListViewController alloc] init];
            basemarrketList.title = @"五分钟涨幅";
            basemarrketList.kType = 3;
            basemarrketList.listType = 1;
            basemarrketList.orderBy = 0;
            basemarrketList.element = @"changeRate";
            [self.market.navigationController pushViewController:basemarrketList animated:YES];
            basemarrketList = nil;
        }
            break;
        case 4:
        {
            // 点击五分钟跌幅榜
            baseMarketListViewController *basemarrketList = [[baseMarketListViewController alloc] init];
            basemarrketList.title = @"五分钟跌幅";
            basemarrketList.kType = 5;
            basemarrketList.listType = 1;
            basemarrketList.orderBy = 1;
            basemarrketList.element = @"changeRate";
            [self.market.navigationController pushViewController:basemarrketList animated:YES];
            basemarrketList = nil;
        }
            break;
        default:
            break;
    }
}




#pragma mark --------------------Http接口处理-------------------------------
#pragma mark 请求数据
-(void)getMarketIndex:(BOOL)isAsyn{
    [self clearTimer];
    [self.market.transformImage start];
    // 请求大盘指数
    [_hqRequest requestMarketIndexList:self isAsyn:isAsyn];
    // 请求热门行业
    //[_hqRequest requestPopularProfessionList:self isAsyn:isAsyn];
    // 请求最新涨跌幅数据
    [_hqRequest requestChangeList:self isAsyn:isAsyn];
    // 请求5分钟涨跌幅数据
    [_hqRequest requestFiveMinuteChangeIndex:self isAsyn:isAsyn];
}

#pragma mark 大盘接口数据返回处理
-(void)getMarketIndexBundle:(NSMutableArray *)data isUpdate:(BOOL)update{
    _marketData = data;
    //NSLog(@"---DFM--- 返回大盘指数数据：…%@",_marketData);
    // 缓存大盘数据
    [DCommon setMarketToLocalWithDatas:data andPageIndex:0 andType:0 andIsGet:NO];
    [_tableView reloadData];
}

#pragma mark 热门行业数据返回处理
-(void)getPopularProfessionListBundle:(NSMutableArray *)data isUpdate:(BOOL)update{
    _popularData = data;
    //NSLog(@"---DFM--- 返回热门行业数据：…%@",_popularData);
    // 缓存大盘数据
    [DCommon setMarketToLocalWithDatas:data andPageIndex:0 andType:1 andIsGet:NO];
    [_tableView reloadData];
}

#pragma mark 涨跌榜数据返回处理
-(void)getChangeListBundle:(NSMutableArray *)data isDown:(BOOL)down isUpdate:(BOOL)update{
    if (down) {
        _downData = data;
        // 缓存涨跌幅数据
        [DCommon setMarketToLocalWithDatas:data andPageIndex:0 andType:2 andIsGet:NO];
    }else{
        _goupData = data;
        // 缓存涨跌幅数据
        [DCommon setMarketToLocalWithDatas:data andPageIndex:0 andType:3 andIsGet:NO];
    }
    
    [self.market.transformImage stop];
    [_tableView reloadData];
}

#pragma mark 五分钟涨跌榜数据返回处理
-(void)getFiveMinuteIndexBundle:(NSMutableArray *)data isDown:(BOOL)down isUpdate:(BOOL)update{
    _isRefresh = update;// 是否刷新
    if (down) {
        _downData5 = data;
        // 缓存五分钟数据
        [DCommon setMarketToLocalWithDatas:data andPageIndex:0 andType:4 andIsGet:NO];
    }else{
        _goupData5 = data;
        // 缓存五分钟数据
        [DCommon setMarketToLocalWithDatas:data andPageIndex:0 andType:5 andIsGet:NO];
    }
    
    [_tableView reloadData];
    //NSLog(@"---DFM--- 涨跌榜是否刷新：…%d",_isRefresh);
    if (_isRefresh && !_isStop) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kDRefreshTime target:self selector:@selector(getMarketIndex:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else{
        [self clearTimer];
    }
}

#pragma mark 清除timer
-(void)clearTimer{
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}



#pragma mark ------------------------MJ刷新控件代理方法实现-----------------------------

#pragma mark 添加刷新控件头部
-(void)addHeader{
    if (!_header) {
        __unsafe_unretained zhongheViewController *bc = self;
        _header = [MJRefreshHeaderView header];
        _header.scrollView = _tableView;
        _header.activityView.color = UIColorFromRGB(0x808080);
        _header.backgroundColor = ClearColor;
        // 开始刷新Block
        _header.beginRefreshingBlock = ^(MJRefreshBaseView* refreshView){
            bc->_refreshView = refreshView;
            // 开启旋转按钮
            [bc performSelector:@selector(finishRefresh:) withObject:refreshView afterDelay:0];
        };
        _header.endStateChangeBlock = ^(MJRefreshBaseView* refreshView){
            // 关闭旋转按钮
            //[bc.market.transformImage stop];
        };
    }
    
}


#pragma mark 更新数据 完成刷新
-(void)finishRefresh:(MJRefreshBaseView*)refreshView{
    [self getMarketIndex:NO];
    [_tableView reloadData];
    
    [refreshView endRefreshing];
}

#pragma mark -------------------UITableViewDelegate代理实现--------------------

#pragma mark 表格每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return _goupData.count;
            break;
        case 2:
            return _downData.count;
            break;
        case 3:
            return _goupData5.count;
            break;
        case 4:
            return _downData5.count;
            break;
        default:
            break;
    }
    
    return 0;
}

#pragma mark 表格分组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return kTopCellHeight;
            break;
        default:
            break;
    }
    
    return 44;
}

#pragma mark 表格每组标题高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kSectionHeight;
}

#pragma mark 自定义表格组标题视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, kSectionHeight)];
    sectionView.backgroundColor = kMarketBackground;
    // 标题
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, _tableView.frame.size.width, kSectionHeight-10)];
    sectionTitle.backgroundColor = ClearColor;
    sectionTitle.textColor = UIColorFromRGB(0x808080);
    sectionTitle.font = kDefaultFont;
    sectionTitle.textAlignment = NSTextAlignmentLeft;
    // 更多按钮
    NSString *path=[[NSBundle mainBundle]pathForResource:@"D_in@2x" ofType:@"png"];
    UIImage *imageSize=[UIImage imageNamed:path];
    
    UIImage *moreImg = [UIImage imageNamed:@"D_in.png"];
    UIImageView *moreView = [[UIImageView alloc] initWithFrame:CGRectMake((50-imageSize.size.width)/2,
                                                                         (sectionView.frame.size.height-imageSize.size.height)/2,
                                                                         imageSize.size.width,
                                                                         imageSize.size.height)];
    moreView.image = moreImg;
    UIButton *btMore = [[UIButton alloc] initWithFrame:CGRectMake(sectionView.frame.size.width-50,
                                                                  0,
                                                                  50,
                                                                  sectionView.frame.size.height)];
    //[btMore setImage:moreImg forState:UIControlStateNormal];
    //[btMore setBackgroundImage:moreImg forState:UIControlStateNormal];
    btMore.backgroundColor = ClearColor;
    [btMore addSubview:moreView];
    btMore.tag = section;
    // 点击更多按钮
    [btMore addTarget:self action:@selector(clickMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [sectionView addSubview:btMore];
    // 添加底线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10,sectionView.frame.size.height-1,sectionView.frame.size.width-20,1)];
    [sectionView addSubview:line];
    line.backgroundColor = kMarketBackground;
    switch (section) {
        case 0:
            sectionTitle.text = @"大盘指数";
            line.backgroundColor = UIColorFromRGB(0x808080);
            break;
//        case 1:
//            sectionTitle.text = @"热门行业";
//            break;
        case 1:
            sectionTitle.text = @"涨幅榜";
            line.backgroundColor = kRedColor;
            break;
        case 2:
            sectionTitle.text = @"跌幅榜";
            line.backgroundColor = kGreenColor;
            break;
        case 3:
            sectionTitle.text = @"五分钟涨幅榜";
            line.backgroundColor = kRedColor;
            break;
        case 4:
            sectionTitle.text = @"五分钟跌幅榜";
            line.backgroundColor = kGreenColor;
            break;
            
        default:
            break;
    }
    line = nil;
    [sectionView addSubview:sectionTitle];
    return sectionView;
}

#pragma mark 表格行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [[NSString alloc] initWithFormat:@"zhcell_%d",indexPath.section];
    basehqCell *cell = (basehqCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        switch (indexPath.section) {
            case 0:{
                if (!_topCell) {
                    _topCell = [[tophqCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    _topCell.height = kTopCellHeight;
                    _topCell.controller = self;
                }
                cell = _topCell;
            }
                break;
//            case 1:{
//                if (!_popularCell) {
//                    _popularCell = [[tophqCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//                    _popularCell.height = kTopCellHeight;
//                    _popularCell.controller = self;
//                }
//                cell = _popularCell;
//                break;
//            }
            default:
                cell = [[basehqCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell show];
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.backgroundColor = [UIColor whiteColor];
    }
    
    switch (indexPath.section) {
        case 0:{
            if (_marketData.count>0) {
                _topCell.data = _marketData;// 大盘指数数据
                [_topCell updateCell];
            }
            break;
        }
//        case 1:
//            if (_popularData.count>0) {
//                _popularCell.data = _popularData;// 热门行业数据
//                [_popularCell updateCell];
//            }
//            break;
        case 1:
            if (_goupData.count>0) {
                cell.data = [_goupData objectAtIndex:indexPath.row];// 涨榜数据
                [cell updateCell];
            }
            break;
        case 2:
            if (_downData.count>0) {
                cell.data = [_downData objectAtIndex:indexPath.row];// 跌榜数据
                [cell updateCell];
            }
            break;
        case 3:
            if (_goupData5.count>0) {
                cell.data = [_goupData5 objectAtIndex:indexPath.row];// 涨榜5分钟数据
                [cell updateCell];
            }
            break;
        case 4:
            if (_downData5.count>0) {
                cell.data = [_downData5 objectAtIndex:indexPath.row];// 跌榜5分钟数据
                [cell updateCell];
            }
            break;
        default:
            
            break;
    }
    
    
    
    return cell;
}

#pragma mark 点击Cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            _cellDatas = _marketData;
            self.kType = 0;
            return;
            break;
        case 1:
            _cellDatas = _goupData;
            break;
        case 2:
            _cellDatas = _downData;
            break;
        case 3:
            _cellDatas = _goupData5;
            break;
        case 4:
            _cellDatas = _goupData5;
            break;
        default:
        
            break;
    }
    self.kType = 1;
    // 取得cell对应的kId;
    basehqCell *cell = (basehqCell*)[tableView cellForRowAtIndexPath:indexPath];
    self.kId = [cell.values objectAtIndex:1];
    self.kName = [cell.values objectAtIndex:0];
    cell = nil;
    [self pushKlineController];
    
}

@end