//
//  quanquiViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "quanquiViewController.h"
#import "FileOperation.h"
#import "basehqCell.h"
#import "mainTableView.h"
#import "hangqingHttpRequest.h"
#import "globalMarketList.h"
#import "KLineViewController.h"

#define kTitlePadding 5
#define kTitleWidth 48
#define kDapanTitleColor UIColorFromRGB(0x000000)
#define kDapanTitleFont [UIFont systemFontOfSize:16]
#define kDRefreshTime 15

@interface quanquiViewController (){
    mainTableView *_tableView;
    NSMutableArray *_data;
    NSMutableArray *_oldData;
    hangqingHttpRequest *_hqRequest;
    NSTimer *_timer;// 定时刷新
    NSMutableArray *_fileds;// 字段集合
    NSString *_element; // 排序字段
    int _orderBy; // 排序类型  0降序 1升序
}

@property (strong,nonatomic) NSMutableArray *dptitles;
@property (strong,nonatomic) FileOperation *fo;
@end

@implementation quanquiViewController

- (void)viewDidLoad
{
    NSLog(@"---DFm---显示大盘");
    [super viewDidLoad];
    // 初始化参数
    [self initParam];
	// 初始化数据
    [self getPlistData];
    // 初始化视图
    [self initView];
}
-(void)viewWillDisappear:(BOOL)animated{
    // 清除timer
    [self clearTimer];
}
-(void)viewDidAppear:(BOOL)animated{
    // 清除timer
    [self clearTimer];
    NSLog(@"---DFm---大盘界面显示完成");
    // 初始化tableview
    [self initDidView];
    // 异步加载数据
    [self getGlobalMarketList:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"---DFm---卸载大盘");
    _tableView = nil;
    _data = nil;
    _hqRequest = nil;
}

#pragma mark --------------------自定义方法------------------
#pragma mark 初始化参数
-(void)initParam{
    _data = [[NSMutableArray alloc] init];
    _element = @"";
    _orderBy = 0;
    _hqRequest = [[hangqingHttpRequest alloc] init];
    _hqRequest.errorRequest = ^(hangqingHttpRequest* request){
        NSLog(@"---DFM---网络异常");
        
    };
    // 点击旋转按钮 回调块
    __unsafe_unretained quanquiViewController *_dp = self;
    self.market.transformImage.clickActionBlock = ^(transformImageView *trans){
        NSLog(@"---DFM---回调Block");
        [_dp getGlobalMarketList:YES];
    };
}
#pragma mark 显示视图
-(void)show{
    if (_tableView && _data.count>0) {
        // 重设下高度
        [_tableView SetTableHeight:_data.count*44-44];
    }
}
#pragma mark 清除视图
-(void)clear{
    // 清除timer
    [self clearTimer];
}



#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor = kBackgroundcolor;
    
}

#pragma mark 延迟加载视图
-(void)initDidView{
    if (!_tableView) {
        NSLog(@"---DFM---添加tableview");
        _tableView = [[mainTableView alloc] initWithController:self andFrame:CGRectMake(0,0,
                                                                                        self.view.frame.size.width,
                                                                                        self.view.frame.size.height)];
        [self.view addSubview:_tableView];
        _tableView.refreshDelegate = self;
        _tableView.leftWidth = 160;
        _tableView.transformImage = self.market.transformImage;
        _tableView.isScrollLeft = NO; // 不左右滚动
        [_tableView show];
        // 回调标题点击事件
        __block __unsafe_unretained quanquiViewController *qq = self;
        _tableView.titleButtonClickBlock = ^(mainTableView *maintable){
            // 参数组合
            qq->_orderBy = [[maintable.buttonState objectAtIndex:maintable.buttonIndex] intValue];
            if (qq->_fileds) {
                qq->_element = [qq->_fileds objectAtIndex:maintable.buttonIndex+1];
            }
            // 开始旋转
            [qq.market.transformImage start];
            // 请求接口
            [qq getGlobalMarketList:YES];
            NSLog(@"---DFm---当前点击了%@,排序：%d",qq->_element,qq->_orderBy);
        };
        
    }
    
}



#pragma mark 读取plist数据
-(void)getPlistData{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"21cbh" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.dptitles=[data objectForKey:KPlistKey3]; // 板块分类标题集合
    data=nil;
    NSLog(@"--DFM--%@",self.dptitles);
}

-(void)pushKlineController{
    KLineViewController *kline = [[KLineViewController alloc] init];
    kline.kId = self.kId;
    kline.kName = self.kName;
    kline.kType = 4; // 全球
    [self.market.navigationController pushViewController:kline animated:YES];
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
        if (tableView==_tableView.leftTableView) {
            cell.cellType = 1;// 图文列表
            CGFloat w = 36;
            CGFloat h = 21;
            cell.imageView.frame = CGRectMake(15, (cell.frame.size.height-h)/2, w, h);
        }
        [cell show];
    }
    // 传递模型数据
    cell.data = [_data objectAtIndex:indexPath.row];
    if (_oldData.count>0) {
        cell.oldData = _oldData;
    }
    // 为Cell建立视图
    if (tableView==_tableView.leftTableView) {
        cell.rowCount = 2;
        globalMarketList *gm = (globalMarketList*)cell.data;
        cell.imageView.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"D_Flag_%@",gm.state]];
        gm = nil;
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
    globalMarketList *dp = (globalMarketList*)[_data objectAtIndex:indexPath.row];
    self.kId = dp.marketId;
    self.kName = dp.marketName;
    dp = nil;
    [self pushKlineController];
}

#pragma mark -----------------------------网络接口响应实现------------------------------------------

#pragma mark 请求数据
-(void)getGlobalMarketList:(BOOL)isAsyn{
    // 清除timer
    [self clearTimer];
    [self.market.transformImage start];
    // 请求数据前保留上一份数据
    _oldData = _data;
    // 请求大盘列表数据
    [_hqRequest requestGlobalMarketList:self Element:_element OrderBy:[[NSString alloc] initWithFormat:@"%d",_orderBy] isAsyn:isAsyn];
}

#pragma mark 全球列表接口返回数据
-(void)getGlobalMarketListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh{
    _data = data;
    if (_data.count>0) {
        // 重设下高度
        _tableView.data = _data;
        [_tableView update];
        [_tableView SetTableHeight:_data.count*44];
        [_tableView reloadData];
    }
    
    [self.market.transformImage stop];
    // 如果服务器允许刷新则刷新，否则清除刷新
    NSLog(@"---DFM---是否允许刷新：%d",refresh);
    if (!refresh) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kDRefreshTime target:self selector:@selector(getGlobalMarketList:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else{
        [self clearTimer];
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
    
    // 请求接口 同步
    [self getGlobalMarketList:NO];
    [refreshView endRefreshing];
}

#pragma mark 结束下拉刷新
-(void)mainTableEndRefreshing:(MJRefreshBaseView*)refreshView{
    NSLog(@"---DFM---DaPan.mainTableEndRefreshing");
    
    //[refreshView free];
}


@end
