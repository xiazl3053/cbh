//
//  gangguViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "gangguViewController.h"
#import "FileOperation.h"
#import "basehqCell.h"
#import "mainTableView.h"
#import "hangqingHttpRequest.h"
#import "KLineViewController.h"
#import "dapanListModel.h"

#define kTitlePadding 5
#define kTitleWidth 48

@interface gangguViewController (){
    mainTableView *_tableView;
    NSMutableArray *_data;
    hangqingHttpRequest *_hqRequest;
    // 大盘接口参数
    NSMutableArray *_fileds;// 字段集合
    NSString *_element; // 排序字段
    int _orderBy; // 排序类型  0降序 1升序
    int _page; // 页码
    int _pageCount;// 总页数
    
}

@property (strong,nonatomic) NSMutableArray *dptitles;
@property (strong,nonatomic) FileOperation *fo;

@end

@implementation gangguViewController

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
	// 初始化数据
    [self getPlistData];
}

-(void)viewDidAppear:(BOOL)animated{
    // 初始化视图
    [self initView];
    // 延迟加载视图
    [self initDidView];
    // 异步加载数据
    [self getGangguList:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _tableView = nil;
    _data = nil;
    _hqRequest = nil;
}

#pragma mark --------------------自定义方法------------------
#pragma mark 显示视图
-(void)show{
    // 重设下高度
    if (_tableView && _data.count>0) {
        [_tableView SetTableHeight:_data.count*44-44];
    }
}
#pragma mark 清除视图
-(void)clear{
    
}
#pragma mark 初始化参数
-(void)initParam{
    _data = [[NSMutableArray alloc] init];
    _page = 1;
    _hqRequest = [[hangqingHttpRequest alloc] init];
}

#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor = kBackgroundcolor;
}

#pragma mark 延迟加载视图
-(void)initDidView{
    if (!_tableView) {
        _tableView = [[mainTableView alloc] initWithController:self andFrame:CGRectMake(0,0,
                                                                                        self.view.frame.size.width,
                                                                                        self.view.frame.size.height)];
        _tableView.refreshDelegate = self;
        _tableView.leftWidth = 80;
        _tableView.isShowRefreshFooter = YES;
        _tableView.transformImage = self.market.transformImage;
        [_tableView show];
        __unsafe_unretained gangguViewController *gg = self;
        _tableView.titleButtonClickBlock = ^(mainTableView *maintable){
            // 参数组合
            gg->_orderBy = [[maintable.buttonState objectAtIndex:maintable.buttonIndex] intValue];
            if (gg->_fileds) {
                gg->_element = [gg->_fileds objectAtIndex:maintable.buttonIndex+1];
            }
            // 开始旋转
            [gg.market.transformImage start];
            // 请求接口
            [gg getGangguList:YES];
            NSLog(@"---DFm---当前点击了%@,排序：%d",gg->_element,gg->_orderBy);
        };
        [self.view addSubview:_tableView];
    }
    // 点击旋转按钮 回调块
    __unsafe_unretained gangguViewController *_dp = self;
    self.market.transformImage.clickActionBlock = ^(transformImageView *trans){
        NSLog(@"---DFM---回调Block");
        [_dp getGangguList:YES];
    };
}

#pragma mark 读取plist数据
-(void)getPlistData{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"hangqing" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.dptitles=[data objectForKey:KPlistKey3]; // 板块分类标题集合
    data=nil;
    NSLog(@"--DFM--%@",self.dptitles);
}

#pragma mark 推出视图
-(void)pushKlineController{
    KLineViewController *kLine = [[KLineViewController alloc] init];
    kLine.kType = 3;
    kLine.kId = self.kId;
    kLine.kName = self.kName;
    [self.market.navigationController pushViewController:kLine animated:YES];
}

#pragma mark -----------------------------网络接口响应实现------------------------------------------

#pragma mark 请求数据
-(void)getGangguList:(BOOL)isAsyn{
    // 格式化页码
    _page = _page>_pageCount?_pageCount:_page;
    _page = _page<1?1:_page;
    [self.market.transformImage start];
    // 请求大盘列表数据
    [_hqRequest requestGangguList:self Element:_element OrderBy:[[NSString alloc] initWithFormat:@"%d",_orderBy] andPage:_page isAsyn:isAsyn];
}

#pragma mark 大盘列表接口返回数据
-(void)getGangguListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount{
    _data = data;
    _pageCount = pageCount;
    if (_data.count>0) {
        // 重设下高度
        _tableView.data = _data;
        _tableView.page = _page;
        _tableView.pageCount = _pageCount;
        [_tableView update];
        [_tableView SetTableHeight:_data.count*44];
        [_tableView reloadData];
    }
    [self.market.transformImage stop];
}

#pragma mark -------------------UITableViewDelegate代理实现--------------------

#pragma mark 表格每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}

#pragma mark 表格行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"ggcell";// [[NSString alloc] initWithFormat:@"ggcell_%d",row];
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
        if (indexPath.row<_data.count) {
            cell.data = [_data objectAtIndex:indexPath.row];
            cell.rowCount = 2;
            [cell updateCell];
        }
    }
    if (tableView==_tableView.rightTableView) {
        if (indexPath.row<_data.count) {
            // 收集字段信息
            if (!_fileds) {
                _fileds = cell.fileds;
            }
            cell.data = [_data objectAtIndex:indexPath.row];
            [cell updateCell];
        }
    }
    return cell;
}

#pragma mark 点击Cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    dapanListModel *gg = (dapanListModel*)[_data objectAtIndex:indexPath.row];
    self.kId = gg.marketId;
    self.kName = gg.marketName;
    [self pushKlineController];
}


#pragma mark --------------------------mainTableViewDelegate代理实现-------------------------------
-(void)mainTableBeginRefreshing:(MJRefreshBaseView*)refreshView{
    // 页码自减
    _page--;
    NSLog(@"---DFM---mainTableBeginRefreshing");
    [self getGangguList:NO];
    [refreshView endRefreshing];
}

-(void)mainTableMoreRefreshing:(MJRefreshBaseView *)refreshView{
    // 页码自加
    _page++;
    [self getGangguList:NO];
    [refreshView endRefreshing];
}

-(void)mainTableEndRefreshing:(MJRefreshBaseView*)refreshView{
    NSLog(@"---DFM---mainTableEndRefreshing");
    //[refreshView free];
}


@end
