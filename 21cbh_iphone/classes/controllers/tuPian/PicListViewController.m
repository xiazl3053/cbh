//
//  PicListViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicListViewController.h"
#import "UIImageView+WebCache.h"
#import "XinWenHttpMgr.h"
#import "MJRefresh.h"
#import "PicsListCell.h"
#import "WebViewController.h"
#import "MJPhotoBrowser.h"
#import "NoticeOperation.h"
#import "AdBarDB.h"
#import "PicsListDB.h"

NSString *const MJTableViewCellIdentifier1 = @"table";

@interface PicListViewController (){
    UITableView *_table;
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
    AdBarModel *_adBarModel;
    AdBarView *_adBarView;
    NSMutableArray *_plms;//图集列表信息
    AdBarDB *_adDB;
    PicsListDB *_plDB;
    NSOperationQueue *_dbQueue;//数据库操作队列
    bool isFirst;//控制加载
    BOOL isFirstLocal;//控制加载本地资源
}


@end

@implementation PicListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    //[super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    if (isFirstLocal) {
        //加载本地资源
        [self loadLocalData];
        isFirstLocal=NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    //清图片缓存
    //[[SDImageCache sharedImageCache] clearMemory];
    [super viewDidDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    //清图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _plms=nil;
    _dbQueue=nil;
    _adDB=nil;
    _plDB=nil;
    self.main=nil;
    self.programId=nil;
    //清图片缓存
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - ------------自定义方法--------------------
#pragma mark 初始化数据
-(void)initParams{
    _plms=[NSMutableArray array];
    _dbQueue=self.main.dbQueue;
    _adDB=[[AdBarDB alloc] init];
    _plDB=[[PicsListDB alloc] init];
    isFirst=YES;
    isFirstLocal=YES;
}
#pragma mark 初始化视图
-(void)initViews{
    self.view.backgroundColor=k000000;
    
    //table列表
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44-20-40-20)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor=[UIColor clearColor];
    _table.separatorColor=[UIColor clearColor];
    [self.view addSubview:_table];
    
    
    // 1.注册
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:MJTableViewCellIdentifier1];
    // 3.集成刷新控件
    // 下拉刷新
    [self addHeader];
    //上拉加载更多
    [self addFooter];
    
}

#pragma mark 当前的子控制器为选中状态
-(void)refreshView{
    if (isFirst) {
        //一启动就刷新
        [_header beginRefreshing];
        isFirst=NO;
    }
}

#pragma mark 当前的子控制器为非选中状态
-(void)endRefreshView{
    
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

#pragma mark 加载本地资源
-(void)loadLocalData{
    //图集列表本地资源
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _plms=[_plDB getPlmsWithProgramId:self.programId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
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
    hmgr.hh.plc=self;
    NSLog(@"广告栏数据self.programId:%@",self.programId);
    [hmgr adBarWithProgramId:self.programId isProgram:@"1"];
}


#pragma mark 获取广告栏数据后的处理
-(void)getAdBarHandle:(AdBarModel *)adBarModel{
    NSLog(@"图集列表获取广告栏数据后的处理");
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


#pragma mark 获取新闻列表数据
-(void)getPicsListWithisUp:(BOOL)isUp{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.plc=self;
    if (isUp) {//下拉刷新
        [hmgr picsListWithProgramId:self.programId id:@"" order:@"0" addtime:@"0" isUp:isUp];
        return;
    }
    
    if (!_plms||_plms.count<1) {//没有数据就不执行历史记录查询
        [self doneWithView:_footer];
        return;
    }
    
    //上拉查询历史记录
    PicsListModel *plm=nil;
    plm=[_plms objectAtIndex:_plms.count-1];
    
    [hmgr picsListWithProgramId:self.programId id:plm.picsId order:plm.order addtime:plm.addtime isUp:isUp];
}

#pragma mark 获取新闻列表数据后的处理
-(void)getPicsListHandle:(NSMutableArray *)plms isUp:(BOOL)isUp{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (plms&&plms.count>0) {//有数据才执行下面的代码
            
            if (isUp) {//刷新全部替换数据
                _plms=plms;
                //将新图集列表数据插入数据库
                [_dbQueue addOperationWithBlock:^{
                    [_plDB deletePlmsWithProgramId:self.programId];
                    for (int i=plms.count-1; i>=0; i--) {
                        PicsListModel *plm=[plms objectAtIndex:i];
                        [_plDB insertPlm:plm programId:self.programId];
                    }
                }];
                
                
            }else{  //插入到底部
                NSIndexSet *indexSet=nil;
                NSRange range = NSMakeRange(_plms.count, [plms count]);
                indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                [_plms insertObjects:plms atIndexes:indexSet];
            }
            
            //刷新列表
            [_table reloadData];
            
        }else{
            if (plms&&!isUp) {
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


#pragma mark - ------------AdBarView代理方法--------------------
-(void)finishImage{
    if (_table.frame.origin.y==0) {
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


#pragma mark - ------------UITableView 的代理方法----------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _plms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_plms.count>0){//没数据就返回空
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    static NSString *cellIdentifier1 = kPicCell1;
    static NSString *cellIdentifier2 = kPicCell2;
    static NSString *cellIdentifier3 = kPicCell3;
    
    PicsListCell *cell =nil;
    PicsListModel *plm=[_plms objectAtIndex:indexPath.row];
    NSInteger type=[plm.type intValue];
    
    if (type==0) {//大
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (!cell) {
            
            cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        }
        [cell setCell1:plm];
    }else if(type==1){//大小小
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (!cell) {
            cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        
        [cell setCell2:plm];
        
    }else if(type==2){//小小大
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
        if (!cell) {
            cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
        }
        
        [cell setCell3:plm];
    }
    
    return cell;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    return 179;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //添加图片列表统计
    [[Frontia getStatistics]logEvent:@"news_click" eventLabel:[NSString stringWithFormat:@"%@:图片列表:%i",self.programName,indexPath.row+1]];
    
    // 取消选中某一行
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PicsListModel *plm=[_plms objectAtIndex:indexPath.row];
    MJPhotoBrowser *mpb=[[MJPhotoBrowser alloc] init];
    mpb.main=self.main;
    mpb.plm=plm;
    [self.main.navigationController pushViewController:mpb animated:YES];
}



#pragma mark - ------------------MJTableView的方法---------------
- (void)addFooter
{
    __unsafe_unretained PicListViewController *plc = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _table;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //获取图集列表
        [self getPicsListWithisUp:NO];
    };
    _footer = footer;
    _footer.activityView.color=K808080;
}

- (void)addHeader
{
    __unsafe_unretained PicListViewController *plc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _table;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        //统计用户刷新次数
        [[Frontia getStatistics]logEvent:@"news_refresh" eventLabel:self.programName];
        //获取广告栏数据
        [self getAdBar];
        //获取图集列表
        [self getPicsListWithisUp:YES];
        
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

@end
