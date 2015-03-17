//
//  SelectStockViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-8-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//


//
//  ziXuanIndexViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//  规则：区分本地与会员
//       本地用户不上传自选股数据,只拉取股票指数数据
//       会员默认第一次加载为先更新后提交
//       管理操作都是先提交后更新本地数据
//

#import "SelectStockViewController.h"
#import "FileOperation.h"
#import "basehqCell.h"
#import "mainTableView.h"
#import "hangqingHttpRequest.h"
#import "dapanListModel.h"
#import "KLineViewController.h"
#import "OptionalViewController.h"
#import "NoticeOperation.h"
#import "selfMarketDB.h"
#import "selfMarketModel.h"
#import "ziXuanManageViewController.h"
#import "CommonOperation.h"
#import "UserModel.h"
#import "huShenViewController.h"
#import "DCommon.h"
#import "mainTableView.h"
#import "XinWenHttpMgr.h"
#import "loadingView.h"
#import "NoticeOperation.h"
#import "PushCenterViewController.h"
#import "selfMarketMessageDB.h"
#import "PushNotificationHandler.h"

#define kTitlePadding 5
#define kTitleWidth 48
#define kDapanTitleColor UIColorFromRGB(0x000000)
#define kDapanTitleFont [UIFont fontWithName:kFontName size:16]
#define kDRefreshTime 15


@interface SelectStockViewController ()<UIAlertViewDelegate>{
    NSMutableArray *_data; // 右边数据
    NSMutableArray *_leftData; // 左边标题的数据
    NSMutableArray *_oldData;
    hangqingHttpRequest *_request;
    hangqingHttpRequest *_requestBetch; // 批量接口请求
    XinWenHttpMgr *_loginRequest;// 注销登录
    // 大盘接口参数
    NSMutableArray *_fileds;// 字段集合
    NSString *_element; // 排序字段
    int _orderBy; // 排序类型  0降序 1升序
    int _pageCount;// 分页总数
    int _page;// 当前页码
    selfMarketDB *_db;// 数据库
    selfMarketModel *_model ;// 模型
    NSOperationQueue *_queue ;// 队列
    NSMutableArray *_list; // post的股票集合 [{marketId,type}{marketId,type}...]
    CommonOperation *_co;
    NSString *_tk;// 用户登录令牌
    UserModel *_user;// 用户单例
    UIView *_addView;// 添加视图
    BOOL _isStop;// 是否停止刷新
    loadingView *_loadingView;// 加载视图
    UIView *_tipView;// 提示未读视图
    MJRefreshBaseView *_refreshView;
    BOOL _isRefresh;// 是否继续刷新
    NSString *_pushTags;// 推送给百度的分组名称列表 分组名称规则 ： stock_<股票代码>_<股票类型(0=大盘，1=个股)>
    NSString *_pushDelTags; // 需要删除的分组
    UIView *_top;
    UIButton *_backButton;
}


@property (nonatomic,retain) mainTableView *mainTableView;
@property (nonatomic,assign) BOOL isSubmitThanUpdate ;// 是否是先提交后更新


@end


@implementation SelectStockViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化参数
    [self initParam];
    // 初始化视图
    [self initView];


}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    _isStop = NO;
    // 默认的规则是先更新后提交，针对注册用户
    //self.isSubmitThanUpdate = [DCommon getIsSubmitThanUpdate];
    
    // 初始化tableview
    [self initDidView];
    [self addTipView];
    // 加载本地数据
    [self loadLocalDatas];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"---DFm---卸载大盘");
    _mainTableView = nil;
    _data = nil;
    _leftData = nil;
    _request = nil;
    _fileds = nil;
    _element = nil;
    _oldData = nil;
    _db = nil;
    _model = nil;
    _queue = nil;
    _list = nil;
    _co = nil;
    _user = nil;
    _requestBetch = nil;
    _loginRequest = nil;
    
    NSLog(@"------selectStock-----dealloc---------");
}


#pragma mark --------------------自定义方法------------------

#pragma mark 显示视图
-(void)show{
    CGFloat tipHeight = _tipView.frame.size.height;
    CGFloat changeHeight = [DCommon getChangeHeight];
    if (_mainTableView) {
        CGFloat h = self.view.frame.size.height-61.5-tipHeight;
        if (_leftData.count>0) {
            
            // 重设下高度
            _mainTableView.mainHeight = h;
            [_mainTableView SetTableHeight:_leftData.count*44+changeHeight];
            _mainTableView.mainView.scrollEnabled = YES;
            _mainTableView.backgroundColor=[UIColor blackColor];
            // 当列表很少的时候
            if (_mainTableView.mainView.frame.size.height>(_leftData.count*44)) {
                [_mainTableView.mainView scrollsToTop];
                CGFloat y = 0;
                CGFloat h = _mainTableView.frame.size.height;
                if (tipHeight>0) {
                    y = tipHeight;
                }
                
                _mainTableView.frame = CGRectMake(_mainTableView.frame.origin.x, y, _mainTableView.frame.size.width, h);
            }else{
                
                [_mainTableView SetTableHeight:_leftData.count*44+changeHeight];
                _mainTableView.frame = CGRectMake(_mainTableView.frame.origin.x, tipHeight, _mainTableView.frame.size.width, _mainTableView.frame.size.height);
                NSLog(@"_mainTableView.frame%@",NSStringFromCGRect(_mainTableView.frame));
            }
            
        }
        
    }
    
}


#pragma mark 初始化参数
-(void)initParam{
    _isStop = NO;
    _page = 1;
    // 初始化数据仓库
    _data = [[NSMutableArray alloc] init];
    _leftData = [[NSMutableArray alloc] init];
    _list = [[NSMutableArray alloc] init];
    _co = [[CommonOperation alloc] init];
    _user = [UserModel um];
    // 初始化网络连接请求
    _request = [[hangqingHttpRequest alloc] init];
    _requestBetch = [[hangqingHttpRequest alloc] init];
    _loginRequest = [[XinWenHttpMgr alloc] init];
    // 网络异常回调 在此请处理好网络异常事件
    __unsafe_unretained SelectStockViewController *zx = self;
    _request.errorRequest = ^(hangqingHttpRequest* request){
        NSLog(@"---DFM---网络异常");
        [zx hideLoadingView:YES];
        [zx->_refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    // 接口数据有误
    _request.hqResponse.errorResponse = ^(hangqingHttpResponse *response){
        NSLog(@"---DFM---接口数据有误");
        [zx hideLoadingView:YES];
        [zx->_refreshView endRefreshing];
        // 网络异常从右边弹出
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    };
    _queue = [[NSOperationQueue alloc] init];
    // 初始化本地数据
    [self initDB];
    
}
#pragma mark 初始化数据库
-(void)initDB{
    if (!_db) {
        _db = [[selfMarketDB alloc] init];
    }
}

#pragma mark 初始化视图
-(void)initView{
    NSLog(@"---DFM---selfView的高度：%f",self.view.frame.size.height);
    [self initTop];
    self.view.backgroundColor = kMarketBackground;
}

#pragma mark 延迟加载视图
-(void)initDidView{
    
    if (!_mainTableView) {
        // 行情表格
        CGFloat h = self.view.frame.size.height;
        _mainTableView = [[mainTableView alloc] initWithController:self andFrame:CGRectMake(0,_top.bottom,self.view.frame.size.width,h-_top.bottom)];
        NSLog(@"---DFM---当前高度：%f",_mainTableView.frame.size.height);
        [self.view addSubview:_mainTableView];
        _mainTableView.refreshDelegate = self;
        _mainTableView.leftWidth = 80;
        _mainTableView.page = _page;
        //_tableView.isShowRefreshFooter = YES;
        _mainTableView.mainHeight = h;
        [_mainTableView show];
        
        // 添加一根分割线
        UIView *line = [DCommon drawLineWithSuperView:_mainTableView position:YES];
        line.backgroundColor = UIColorFromRGB(0x808080);
        line = nil;
        // 回调标题点击事件
        __block __unsafe_unretained SelectStockViewController *dp = self;
        _mainTableView.titleButtonClickBlock = ^(mainTableView *maintable){
            if (dp->_leftData.count>0 && maintable.buttonIndex>0) {
                // 参数组合
                dp->_orderBy = [[maintable.buttonState objectAtIndex:maintable.buttonIndex] intValue];
                
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
                /*********change********/
                //                if (dp->_fileds) {
                //                    dp->_element = [dp->_fileds objectAtIndex:maintable.buttonIndex+1];
                //                }
                //[dp.Parent.transformImage start];
                
                NSLog(@"---DFm---当前点击了%@,排序：%d",dp->_element,dp->_orderBy);
            }else{
                dp->_orderBy = 0;
                dp->_element = @"";
            }
            // 请求接口
            [dp getSelfMarketList:YES];
            
        };
        
        
        
    }
    
    // 点击旋转按钮 回调块
//    __unsafe_unretained SelectStockViewController *_dp = self;
//    self.Parent.transformImage.clickActionBlock = ^(transformImageView *trans){
//        NSLog(@"---DFM---回调Block");
//        [_dp getSelfStockBatchManage];
//    };
}

#pragma mark 添加视图
-(void)addAddViews{
    if (!_addView) {
        CGFloat w = 80;
        CGFloat h = 80;
        CGFloat x = (self.view.frame.size.width - w)/2+_mainTableView.frame.origin.x;
        CGFloat y = (self.view.frame.size.height - h)/2-50;
        _addView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _addView.layer.borderWidth = 1;
        _addView.layer.borderColor = UIColorFromRGB(0x808080).CGColor;
        _addView.layer.cornerRadius = 5;
        _addView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        
        // 加个十字架
        // 横
        CGFloat height = _addView.frame.size.height / 4;
        CGFloat width = 5;
        UIView *heng = [[UIView alloc] initWithFrame:CGRectMake(height, height*2-width/2, height*2, width)];
        heng.backgroundColor = UIColorFromRGB(0x808080);
        [_addView addSubview:heng];
        heng = nil;
        // 竖
        UIView *shu = [[UIView alloc] initWithFrame:CGRectMake(height*2-width/2, height, width, height*2)];
        shu.backgroundColor = UIColorFromRGB(0x808080);
        [_addView addSubview:shu];
        shu = nil;
        // 加个按钮
        UIButton *addbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        addbutton.backgroundColor = ClearColor;
        [addbutton addTarget:self action:@selector(clickAddButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_addView addSubview:addbutton];
        addbutton = nil;
        // 加个文字描述
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        l.text = @"暂无股票，请点击添加";
        l.font = [UIFont fontWithName:kFontName size:18];
        l.textColor = UIColorFromRGB(0x808080);
        l.backgroundColor = ClearColor;
        [l sizeToFit];
        [_addView addSubview:l];
        l.frame = CGRectMake((x-l.frame.size.width)/2-23, h+20, l.frame.size.width, l.frame.size.height);
        l = nil;
        
        [self.view addSubview:_addView];
        // 这个东东出现都是数据为零的时候
        // 添加一根分割线
        UIView *line = [DCommon drawLineWithSuperView:self.view position:YES];
        line.backgroundColor = UIColorFromRGB(0x808080);
        line = nil;
    }
}

#pragma mark 加载视图
-(void)addLoadingView{
    if (!_loadingView) {
        CGFloat lw = 150;
        CGFloat lh = 100;
        _loadingView = [[loadingView alloc] initWithTitle:@"数据正在同步..." Frame:CGRectMake((self.view.frame.size.width-lw)/2,100,lw, lh) IsFullScreen:YES ];
        _loadingView.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
        _loadingView.layer.shadowOffset = CGSizeMake(3, 3);
        _loadingView.layer.shadowRadius = 5.0;
        _loadingView.layer.shadowOpacity = 1;
        _loadingView.layer.borderWidth = 1;
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



#pragma mark 添加一个未读提示视图
-(void)addTipView{
    // 读取未读数量
    UserModel *user = [UserModel um];
    int total = [[selfMarketMessageDB instance] getUnReadofMessageWithUserId:user.userId];
    //total = 3;
    if (!_tipView) {
        if (total>0 && user.userId>0) {
            CGFloat h = 40;
            _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
            _tipView.backgroundColor = UIColorFromRGB(0x262626);
            
            // 加关闭图片
            UIImage *img = [UIImage imageNamed:@"D_Close.png"];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(_tipView.frame.size.width-img.size.width-15, (h-img.size.height)/2, img.size.width, img.size.height)];
            imgView.image = img;
            [_tipView addSubview:imgView];
            // 文字描述
            __block UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _tipView.frame.size.width, 0)];
            l.text = [NSString stringWithFormat:@"您有%d条未读提醒",total];
            l.textAlignment = NSTextAlignmentCenter;
            l.font = [UIFont fontWithName:kFontName size:16];
            l.textColor = kBrownColor;
            l.backgroundColor = ClearColor;
            [_tipView addSubview:l];
            // 加个按钮吧
            __block UIButton *bt = [[UIButton alloc] initWithFrame:l.frame];
            bt.backgroundColor = ClearColor;
            [_tipView addSubview:bt];
            [bt addTarget:self action:@selector(clickTipViewAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:_tipView];
            // 弹出提示框
            [UIView animateWithDuration:0.3 animations:^{
                // 提示横幅慢慢伸展
                _tipView.frame = CGRectMake(_mainTableView.frame.origin.x, 0, _tipView.frame.size.width, h);
                _tipView.alpha = 1;
                l.frame = CGRectMake(0, 0, _tipView.frame.size.width, _tipView.frame.size.height);
                bt.frame = l.frame;
                // 表格慢慢伸展
                [_mainTableView SetTableHeight:_leftData.count*44 - h];
                ///_mainTableView.frame = CGRectMake(0, h, _mainTableView.frame.size.width, _mainTableView.frame.size.height-h);
                
            } completion:^(BOOL finished){
                bt = nil;
                l = nil;
                
                [self show];
            }];
        }
        
    }else{
        UILabel *l = (UILabel*)[_tipView.subviews objectAtIndex:1];
        l.text = [NSString stringWithFormat:@"您有%d条未读提醒",total];
        l = nil;
    }
    user = nil;
}

#pragma mark 加载本地数据 每次显示界面都先更新
-(void)loadLocalDatas{
    
    // 加载本地数据 如果登陆则返回用户的本地数据，否则默认返回本机的数据
    [_queue addOperationWithBlock:^{
        
        _leftData = [_db getSelfMarketList];
        
        // 行情界面显示的时候才加载
        if (_mainTableView && _mainTableView.frame.origin.x<=0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新视图
                [self updateTable];
                UserModel *user = [UserModel um];
                // 如果用户登录则拉远程的数据下来
                if (user.userId>0) {
                    // 是否先提交后更新 默认第一次加载是先更新后提交，以后的操作就是先提交后更新了
                    if (self.isSubmitThanUpdate) {
                        if (_leftData.count>0) {
                            // 有数据马上隐藏添加按钮
                            if (_addView) {
                                [_addView removeFromSuperview];
                                _addView = nil;
                            }
                            // 先提交后更新
                            [self getSelfStockBatchManage];
                            // 恢复
                            self.isSubmitThanUpdate = NO;
                            [DCommon setIsSubmitThanUpdate:NO];
                        }else{
                            // 用户第一次登陆本设备，本地无此用户数据，所以先从网络下载数据下来
                            // 先更新
                            [self getSelfMarketList:YES];
                        }
                    }else{
                        // 设置为先更新后提交
                        // 先更新
                        [self getSelfMarketList:YES];
                    }
                }else{
                    // 未注册用户 只更新
                    [self getSelfMarketList:YES];
                }
                user = nil;
            });
            
        }
        else{
          
            
        }
        
        
    }];
    
    
}
#pragma mark 保存本地数据 每次点击完成按钮都先提交 后更新
-(void)saveLocalDatas{
    // 先删除原来本地的数据，然后加入新的数据
    [_queue addOperationWithBlock:^{
        
        // 删除原来的数据
        [_db deleteAllSelfMarket];
        if (_leftData.count>0) {
            // 重新添加数据 从后面开始添加
            for (int i=_leftData.count-1;i>=0;i--) {
                selfMarketModel *m = (selfMarketModel*)[_leftData objectAtIndex:i];
                if (_user.userId>0) {
                    m.userId = _user.userId;
                }else{
                    m.userId = @"";
                }
                m.timestamp = [DCommon getTimestamp];
                // 插入数据
                [_db insertWithSelfMarket:m];
                m = nil;
            }
        }
        // 再拿一遍数据
        _leftData = [_db getSelfMarketList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 同步到云端 并下载云端数据
            [self getSelfStockBatchManage];
        });
        
    }];
}

#pragma mark 推出子视图
-(void)pushKlineController{
    
//    KLineViewController *kline = [[KLineViewController alloc] init];
//    kline.kId = self.kId;
//    kline.kName = self.kName;
//    kline.kType = self.kType;// 0=大盘 1=个股
//    if (self.kType>1) {
//        kline.kType = 1;
//    }
//    
//    NSMutableArray *temp = [[NSMutableArray alloc] init];
//    for (selfMarketModel *m in _leftData) {
//        // 页数
//        [temp addObject:[[NSArray alloc] initWithObjects:m.marketId,m.marketName,m.marketType, nil]];
//        // 当前页
//        if ([m.marketId isEqualToString:self.kId] && [m.marketType intValue]==self.kType) {
//            kline.currentPage = [_leftData indexOfObject:m];
//        }
//    }
//    kline.pageArray = temp;
//    temp = nil;
//    [self.Parent.navigationController pushViewController:kline animated:YES];
//    kline = nil;
}

#pragma mark 行情/管理视图切换
-(void)moveViews:(BOOL)isChange{
//    CGFloat x = 0;
//    CGFloat ex = -self.view.frame.size.width;
//    // 如果自选股行情页面正在显示 则滑动到管理界面，否则滑动到自选股行情界面
//    if (_mainTableView.frame.origin.x==0) {
//        // 转到管理界面时停止刷新
//        _isStop = YES;
//        x = self.view.frame.size.width;
//        ex = 0;
//        if (isChange) {
//            _ziXuanManage.valueData = _data;
//            _ziXuanManage.data = _leftData;
//            [_ziXuanManage show];
//        }
//    }else{
//        // 回到列表时候开启刷新
//        _isStop = NO;
//        if (isChange) {
//            _leftData = _ziXuanManage.data;
//            // 保存数据
//            [self saveLocalDatas];
//        }else{
//            // 没有操作就只加载数据
//            
//        }
//    }
//    // 动画移动
//    [UIView animateWithDuration:0.2 animations:^{
//        _mainTableView.frame = CGRectMake(x, _mainTableView.frame.origin.y, _mainTableView.frame.size.width, _mainTableView.frame.size.height);
//        _ziXuanManage.view.frame = CGRectMake(ex, _ziXuanManage.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
//        _tipView.frame = CGRectMake(x, _tipView.frame.origin.y, _tipView.frame.size.width, _tipView.frame.size.height);
//    } completion:^(BOOL isFinish){
//        [self.view bringSubviewToFront:_ziXuanManage.view];
//        [self show];
//        // 改变父级的导航栏按钮状态
//        [self.Parent changeButtonViews];
//    }];
}

#pragma mark 更新视图
-(void)updateViews{
    // 更新列表
    [self updateTable];
    
}

#pragma mark ---------------------视图响应事件--------------------------------
#pragma mark 点击添加按钮
-(void)clickAddButtonAction:(UIButton*)button{
    _addView.backgroundColor = UIColorFromRGB(0x000000);
    [_queue addOperationWithBlock:^{
        __block SearchStocksViewController *search = [[SearchStocksViewController alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clickSearchButtonAction:nil];
            _addView.backgroundColor = UIColorFromRGB(0x222222);
            search = nil;
        });
    }];
    
}


#pragma mark 点击提示未读信息横幅
-(void)clickTipViewAction:(UIButton*)button{
    
    CGFloat tipHeight = _tipView.frame.size.height;
    // 跳转到消息中心
    PushCenterViewController *pcvc=[[PushCenterViewController alloc] initWithCurrentIndex:1];
    UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:pcvc];
    pcvc.main=[[CommonOperation getId] getMain];
    nc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
    [self presentViewController:nc animated:YES completion:^{
        // 清空已读
        UserModel *user = [UserModel um];
        [[selfMarketMessageDB instance] cleanAllUnReadMessageWithUserId:user.userId];
        user = nil;
    }];
    
    // 关闭提示横幅并且让各视图恢复原样
    [UIView animateWithDuration:0.2 animations:^{
        // 提示横幅慢慢收缩并消失
        _tipView.frame = CGRectMake(_mainTableView.frame.origin.x, 0, _tipView.frame.size.width, 0);
        _tipView.alpha = 0;
        // 表格恢复置顶
        _mainTableView.frame = CGRectMake(_mainTableView.frame.origin.x, 0, _mainTableView.frame.size.width, _mainTableView.frame.size.height+tipHeight);
        [_mainTableView SetTableHeight:_leftData.count*44];
    } completion:^(BOOL finished){
        [_tipView removeAllSubviews];
        [_tipView removeFromSuperview];
        _tipView = nil;
        [self show];
    }];
}

#pragma mark -------------------UITableViewDelegate代理实现--------------------
#pragma mark 表格每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _leftData.count;
}

#pragma mark 表格行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"dpcell";// [[NSString alloc] initWithFormat:@"dpcell_%d",indexPath.row];
    basehqCell *cell = (basehqCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[basehqCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.leftWidth = _mainTableView.leftWidth;
        if (tableView==_mainTableView.rightTableView) {
            cell.startIndex = 2;
            cell.rowCount = _mainTableView.titleData.count;
        }
        [cell show];
    }
    int index = indexPath.row;
    if (index<_leftData.count) {
        // 为Cell建立视图
        if (tableView==_mainTableView.leftTableView) {
            cell.rowCount = 2;
            if ([_element isEqualToString:@""] || !_element) {
                cell.data = [_leftData objectAtIndex:index];
            }else{
                if (indexPath.row<_data.count) {
                    cell.data = [_data objectAtIndex:index];
                }
            }
        }
        if (tableView==_mainTableView.rightTableView) {
            if (_data.count>0 && indexPath.row<_data.count) {
                // 传递数据
                cell.data = [_data objectAtIndex:index];
                if (_oldData.count>0) {
                    cell.oldData = _oldData;
                }
                // 收集字段信息
                if (!_fileds) {
                    _fileds = cell.fileds;
                }
            }
            
        }
        
        [cell updateCell];
    }
    
    return cell;
}

#pragma mark 点击Cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"indexpath=%@",indexPath);
    if (_data.count>0 && indexPath.row<_data.count) {
        dapanListModel *dp = (dapanListModel*)[_data objectAtIndex:indexPath.row];
//        self.kId = dp.marketId;
//        self.kName = dp.marketName;
//        self.kType = [dp.type intValue];
//        dp = nil;
//        [self pushKlineController];
        if (self.userSelectStockinfo) {
            self.userSelectStockinfo(dp.marketId,dp.type,dp.marketName);
        }
    }else if (indexPath.row<_leftData.count) {
        selfMarketModel *dp = (selfMarketModel*)[_leftData objectAtIndex:indexPath.row];
//        self.kId = dp.marketId;
//        self.kName = dp.marketName;
//        self.kType = [dp.marketType intValue];
//        dp = nil;
//        [self pushKlineController];
        if (self.userSelectStockinfo) {
            self.userSelectStockinfo(dp.marketId,dp.marketType,dp.marketName);
        }
    }
    [self returnBack];
}


#pragma mark 更新表格
-(void)updateTable{
    if (_addView) {
        [_addView removeFromSuperview];
        _addView = nil;
    }
    if (_leftData.count>0) {
        
        // 重设下高度
        _mainTableView.hidden = NO;
        _mainTableView.data = _leftData;
        // NSLog(@"leftdata=%@",_leftData);
        _mainTableView.page = _page;
        _mainTableView.pageCount = _pageCount;
        _mainTableView.changeHeight = self.changeHeight;
        [_mainTableView update];
        [_mainTableView SetTableHeight:_leftData.count*44];
        [_mainTableView reloadData];
        // 不能滚动
        _mainTableView.mainView.scrollEnabled = YES;
        if (_mainTableView.mainView.frame.size.height>_leftData.count*44) {
            [_mainTableView.mainView scrollsToTop];
            //_mainTableView.mainView.scrollEnabled = NO;
        }
    }else{
        _mainTableView.hidden = YES;
        // 没有数据就显示添加按钮视图
        [_mainTableView reloadData];
        [self addAddViews];
    }
//    // 更新管理界面
//    if (_ziXuanManage) {
//        _ziXuanManage.valueData = _data;
//        _ziXuanManage.data = _leftData;
//        [_ziXuanManage show];
//    }
    
    
}

#pragma mark 封装股票集合
-(void)packageList{
    if (_list) {
        [_list removeAllObjects];
    }
    
    // 加载本地数据
    //[_queue addOperationWithBlock:^{
    NSMutableArray *localDatas = [_db getSelfMarketList];
    if (localDatas.count>0) {
        _pushTags = @"";
        _pushDelTags = @"";
        for (int i=0;i<localDatas.count;i++) {
            selfMarketModel *item = (selfMarketModel*)[localDatas objectAtIndex:i];
            if ([item class]==[selfMarketModel class]) {
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     item.marketId,@"marketId",
                                     item.marketName,@"marketName",
                                     item.marketType,@"type",
                                     item.timestamp,@"timestamp",
                                     item.heightPrice,@"heightPrice",
                                     item.lowPrice,@"lowPrice",
                                     item.todayChangeRate,@"todayChangeRate",
                                     item.isNotice,@"isNotice",
                                     item.isNews,@"isNews",
                                     nil];
                [_list addObject:dic];
                // 封装百度云分组名称
                // 如果有提醒数据
                NSString *tagstr = [NSString stringWithFormat:@"stock_%@_%@",item.marketId,item.marketType];
                if ([item.heightPrice floatValue]>0 || [item.lowPrice floatValue]>0 || [item.todayChangeRate floatValue]>0 || [item.isNews boolValue] || [item.isNotice boolValue]) {
                    if ([_pushTags isEqualToString:@""]) {
                        _pushTags = tagstr;
                    }else{
                        if ([_pushTags rangeOfString:tagstr].length<=0) {
                            _pushTags = [NSString stringWithFormat:@"%@,%@",_pushTags,tagstr];
                        }
                        
                    }
                }else{
                    // 删除的分组
                    if ([_pushDelTags isEqualToString:@""]) {
                        _pushDelTags = tagstr;
                    }else{
                        if ([_pushDelTags rangeOfString:tagstr].length<=0) {
                            _pushDelTags = [NSString stringWithFormat:@"%@,%@",_pushDelTags,tagstr];
                        }
                        
                    }
                }
                dic = nil;
            }
            item = nil;
            
        }
    }
    localDatas = nil;
    //}];
    
    
    
}

#pragma mark 封装股票ID集合
-(void)packageIdList{
    if (_list) {
        [_list removeAllObjects];
    }
    // 加载本地数据
    NSMutableArray *localDatas = [_db getSelfMarketList];
    if (localDatas.count>0) {
        _pushTags = @"";
        _pushDelTags = @"";
        for (int i=0;i<localDatas.count;i++) {
            selfMarketModel *item = (selfMarketModel*)[localDatas objectAtIndex:i];
            if ([item class]==[selfMarketModel class]) {
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     item.marketId,@"marketId",
                                     item.marketType,@"type",
                                     nil];
                [_list addObject:dic];
                
                // 封装百度云分组名称
                // 如果有提醒数据
                NSString *tagstr = [NSString stringWithFormat:@"stock_%@_%@",item.marketId,item.marketType];
                if ([item.heightPrice floatValue]>0 || [item.lowPrice floatValue]>0 || [item.todayChangeRate floatValue]>0 || [item.isNews boolValue] || [item.isNotice boolValue]) {
                    if ([_pushTags isEqualToString:@""]) {
                        _pushTags = tagstr;
                    }else{
                        if ([_pushTags rangeOfString:tagstr].length<=0) {
                            _pushTags = [NSString stringWithFormat:@"%@,%@",_pushTags,tagstr];
                        }
                        
                    }
                }else{
                    // 删除的分组
                    if ([_pushDelTags isEqualToString:@""]) {
                        _pushDelTags = tagstr;
                    }else{
                        if ([_pushDelTags rangeOfString:tagstr].length<=0) {
                            _pushDelTags = [NSString stringWithFormat:@"%@,%@",_pushDelTags,tagstr];
                        }
                        
                    }
                }
                dic = nil;
            }
            item = nil;
            
        }
    }
    localDatas = nil;
}

#pragma mark 删除百度云所有分组
-(void)deleteBaiduTags{
    UserModel *user = [UserModel um];
    if (user.userId>0) {
        // 封装好提交的数据集合
        [self packageList];
        NSLog(@"---DFM---分组列表：%@",_pushDelTags);
        NSString *alltags = _pushTags;
        if ([_pushTags isEqualToString:@""]) {
            alltags = _pushDelTags;
        }else{
            if (![_pushDelTags isEqualToString:@""]) {
                alltags = [NSString stringWithFormat:@"%@,%@",alltags,_pushDelTags];
            }
        }
        if (alltags.length>0) {
            // push给百度删除
            [[PushNotificationHandler instance] deletePushTags:_pushDelTags];
            [[PushNotificationHandler instance] savePushTags];
        }
        
    }
    user = nil;
}
#pragma mark 删除用户未设置提醒的分组
-(void)deleteBaiduTagsPart{
    UserModel *user = [UserModel um];
    if (user.userId>0) {
        // 封装好提交的数据集合
        [self packageList];
        NSLog(@"---DFM---分组列表：%@",_pushDelTags);
        // push给百度删除
        [[PushNotificationHandler instance] deletePushTags:_pushDelTags];
        [[PushNotificationHandler instance] savePushTags];
    }
    user = nil;
}

#pragma mark 添加百度云分组
-(void)pushBaiduTags{
    UserModel *user = [UserModel um];
    if (user.userId>0 && _pushTags.length>0) {
        // 封装好提交的数据集合
        [self packageList];
        NSLog(@"---DFM---分组列表：%@",_pushTags);
        //_pushTags = [_pushTags stringByAppendingString:@",dangfm"];
        // push给百度
        [[PushNotificationHandler instance] addPushTags:_pushTags];
        [[PushNotificationHandler instance] savePushTags];
    }
    user = nil;
}


#pragma mark -----------------------------网络接口响应实现------------------------------------------

#pragma mark 请求数据
-(void)getSelfMarketList:(BOOL)isAsyn{
    _mainTableView.isClick=NO;
    // 自动下拉刷新 条件是 刷新标识为否，操作已经发生改变
    if (!_isRefresh && !_mainTableView.header.refreshing) {
        [_mainTableView.header beginRefreshing];
        return;
    }
    
    // 封装好提交的数据集合
    [self packageIdList];
    // 格式化页码
    _page = _page>_pageCount?_pageCount:_page;
    _page = _page<1?1:_page;
    //[self clearTimer];
    // 请求数据前保留上一份数据
    if (_oldData) {
        [_oldData removeAllObjects];
        _oldData = nil;
    }
    _oldData = _data;
    // 请求数据
    [_request requestSelfMarketIndexList:self Element:_element OrderBy:_orderBy Page:_page List:_list isAsyn:isAsyn];
    
//    if (_huShen) {
//        // 请求沪深指数
//        [_huShen getHushenStocksIndex:YES];
//    }
}
#pragma mark 请求批量管理接口
-(void)getSelfStockBatchManage{
    [self updateTable];
    UserModel *user = [UserModel um];
    // 会员改变
    if ([DCommon getIsChanged] && user.userId>0) {
        // 提示
        [self addLoadingView];
        [self hideLoadingView:YES];
        
        if (user.userId>0 && _leftData.count>0){
            [self hideLoadingView:NO];
        }
        // 封装好提交的数据集合
        [self packageList];
        // 提交远端保存
        [_requestBetch requestSelfStockBatchManage:self List:_list isAsyn:YES];
    }
    // 非会员改变
    if ([DCommon getIsChanged] && user.userId<=0) {
        // 如果是非会员，返回到列表时候加载网络数据
        // 更新
        [self getSelfMarketList:YES];
        
    }
    user = nil;
}
#pragma mark 批量管理接口是否成功
-(void)getSelfStockBatchManageBundle:(int)isSuccess{
    if (isSuccess==0 || isSuccess==1) {
        NSLog(@"---DFM---批量同步请求成功");
        // 设置为未操作过
        [DCommon SetIsChanged:NO];
        // 同步完成才开始请求数据下来
        [_mainTableView.header beginRefreshing];
    }else{
        if (isSuccess==3) {
            // 提示信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"账号多处登陆提示" message:@"您的账号已在其他设备登陆，您被迫下线，请重新登陆" delegate:self cancelButtonTitle:@"重新登录" otherButtonTitles:@"此设备下线", nil];
            [alert show];
        }else{
            NSLog(@"---DFM---批量同步请求失败");
            // 提示信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"同步数据失败，请重新同步" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续同步", nil];
            alert.tag = 1001;
            [alert show];
        }
    }
    
}

#pragma mark 接口返回数据
// 接口告诉我是否需要刷新以及总的页数
-(void)getSelfMarketListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh pageCount:(int)pageCount{
    _isRefresh = refresh;
    _mainTableView.isClick=YES;
    // 判断用户是否在其他设备登录
    if (data.count>0) {
        if ([[[data lastObject] class] isSubclassOfClass:[NSNumber class]]) {
            if ([[data lastObject] intValue]==3) {
                NSLog(@"---DFM---您的账号已在其他设备登录，请重新登录");
                // 更新本地数据
                if (_leftData && _leftData.count>0) {
                    [_leftData removeAllObjects];
                }
                [self updateTable];
                // 提示信息
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"账号多处登陆提示" message:@"您的账号已在其他设备登陆，您被迫下线，请重新登陆" delegate:self cancelButtonTitle:@"重新登录" otherButtonTitles:@"此设备下线", nil];
                [alert show];
                return;
            }
            
        }
    }
    _pageCount = pageCount;
    _data = data;
    if (_loadingView) {
        [_loadingView setSelfTitle:@"同步成功" isSuccess:YES andSecond:2];
    }
    
    if (_data.count>0) {
        // 更新本地数据
        if (_leftData && _leftData.count>0) {
            [_leftData removeAllObjects];
        }
        // 先清空原有记录
        [_db deleteAllSelfMarket];
        // 添加新记录
        
        for (int i=0; i<_data.count; i++) {
            dapanListModel *m=[_data objectAtIndex:i];
            selfMarketModel *model = [[selfMarketModel alloc] init];
            model.marketId = m.marketId;
            model.marketName = m.marketName;
            model.marketType = m.type;
            model.timestamp = m.timestamp;
            model.isSyn = @"1";
            model.userId = @"";
            if (_user.userId>0) {
                model.userId = _user.userId;
            }
            model.heightPrice = m.heightPrice;
            model.lowPrice = m.lowPrice;
            model.todayChangeRate = m.todayChangeRate;
            model.isNotice = m.isNotice;
            model.isNews = m.isNews;
            [_leftData addObject:model];
            // 更新本地数据库
            [_db insertWithSelfMarket:model];
            model = nil;
        }
        //            for (dapanListModel *m in _data) {
        //                selfMarketModel *model = [[selfMarketModel alloc] init];
        //                model.marketId = m.marketId;
        //                model.marketName = m.marketName;
        //                model.marketType = m.type;
        //                model.timestamp = m.timestamp;
        //                model.isSyn = @"1";
        //                model.userId = @"";
        //                if (_user.userId>0) {
        //                    model.userId = _user.userId;
        //                }
        //                model.heightPrice = m.heightPrice;
        //                model.lowPrice = m.lowPrice;
        //                model.todayChangeRate = m.todayChangeRate;
        //                model.isNotice = m.isNotice;
        //                model.isNews = m.isNews;
        //                [_leftData addObject:model];
        //                // 更新本地数据库
        //                [_db insertWithSelfMarket:model];
        //                model = nil;
        //            }
        
        // 如果服务器允许刷新则刷新，否则清除刷新
        // NSLog(@"---DFM---是否允许刷新=%d,leftCount=%d,dataCount=%d",refresh,_leftData.count,_data.count);
        if (refresh && !_isStop) {
//            _timer = [NSTimer scheduledTimerWithTimeInterval:kDRefreshTime target:self selector:@selector(getSelfMarketList:) userInfo:nil repeats:NO];
//            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        }else{
           // [self clearTimer];
        }
    }
    // push给百度
    /*******change********/
    [self pushBaiduTags];
    // 更新表格
    [self updateTable];
    [_refreshView endRefreshing];
    // 加载提示栏
    [self addTipView];
}

#pragma mark 账号多处登陆提示按钮
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // tag=1001为“同步数据失败，请重新同步”对话框
    if (alertView.tag==1001) {
        [self hideLoadingView:YES];
        if (buttonIndex==1) {
            // 继续同步
            [self getSelfStockBatchManage];
        }
    }else{
        [self hideLoadingView:YES];
        // 更新本地数据
        if (_leftData && _leftData.count>0) {
            [_leftData removeAllObjects];
        }
        [self updateTable];
        // 注销账号
        [[CommonOperation getId] loginout];
        
        if (buttonIndex==0) {
            // 重新登陆视图
            [CommonOperation goTOLogin];
        }else{
            // 删除百度云上的用户分组
            [self deleteBaiduTags];
        }
    }
}

#pragma mark --------------------------mainTableViewDelegate代理实现-------------------------------
#pragma mark 开始下拉刷新
-(void)mainTableBeginRefreshing:(MJRefreshBaseView*)refreshView{
    _isRefresh = NO;
    _refreshView = refreshView;
    NSLog(@"---DFM---mainTableBeginRefreshing");
    _page --;
    [_data removeAllObjects];
    _data = nil;
    // 请求接口 同步
    [self getSelfMarketList:YES];
}

#pragma mark 上啦刷新加载
-(void)mainTableMoreRefreshing:(MJRefreshBaseView *)refreshView{
    _refreshView = refreshView;
    _page ++;
    [_data removeAllObjects];
    _data = nil;
    // 请求接口 同步
    [self getSelfMarketList:YES];
    
}

#pragma mark 结束下拉刷新
-(void)mainTableEndRefreshing:(MJRefreshBaseView*)refreshView{
    NSLog(@"---DFM---DaPan.mainTableEndRefreshing");
    [_mainTableView.mainView setContentOffset:CGPointMake(0, 0)];
}

-(void)setMainTableViewTimer{
    NSLog(@"========setMainTableViewTimer========");
    _mainTableView.isClick=YES;
}

-(void)returnBack{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark 初始化视图
-(void)initTop{
    //[self myDealloc];
    
    if (!_top) {
        // 头部
        _top = [self Title:@"自选股中心" returnType:1];
        [self.view addSubview:_top];
        // 隐藏返回按钮
//        for (UIView *item in _top.subviews) {
//            if ([item class]==[UIButton class]) {
//                _backButton = (UIButton*)item;
//            }else{
//                if ([item class]!=[UILabel class]) {
//                    [item removeFromSuperview];
//                }
//            }
//            
//        }
//        _backButton.hidden = YES;
//        [_backButton addTarget:self action:@selector(clickReturnBack:) forControlEvents:UIControlEventTouchUpInside];
        // 添加一个管理按钮
//        UIImage *bg = [DCommon imageWithColor:UIColorFromRGB(0x000000) andSize:CGSizeMake(60, top.frame.size.height)];
//        UIImage *bgHover = [DCommon imageWithColor:UIColorFromRGB(0x000000) andSize:CGSizeMake(60, top.frame.size.height)];
//        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, bg.size.width, bg.size.height)];
//        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
//        [_editButton setBackgroundImage:bg forState:UIControlStateNormal];
//        [_editButton setBackgroundImage:bgHover forState:UIControlStateHighlighted];
//        [_editButton addTarget:self action:@selector(clickEditButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        [top addSubview:_editButton];
        // 搜索按钮
        UIImage *btBg = [UIImage imageNamed:@"D_Search.png"];
        UIImage *btBgHover = [UIImage imageNamed:@"D_SearchHover.png"];
        
        self.searchButton = [[UIButton alloc] initWithFrame:CGRectMake(_top.frame.size.width-100-10,0,100,_top.frame.size.height)];
        [self.searchButton setImage:btBg forState:UIControlStateNormal];
        [self.searchButton setImage:btBgHover forState:UIControlStateHighlighted];
        [self.searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, 75, 0, 0)];
        [self.searchButton addTarget:self action:@selector(clickSearchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_top addSubview:self.searchButton];
        
        //    // 添加刷新旋转图片
        //    self.transformImage = [[transformImageView alloc] initWithFrame:CGRectMake(240, self.searchButton.frame.origin.y-2, 0, 0)];
        //
        //    [top addSubview:self.transformImage];
        //    // 添加一根分割线
        //    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.transformImage.frame.origin.x+self.transformImage.frame.size.width +6,
        //                                                            self.transformImage.frame.origin.y,
        //                                                            1,
        //                                                            top.frame.size.height-self.transformImage.frame.origin.y*2)];
        //    line.backgroundColor = UIColorFromRGB(0x636363);
        //    [top addSubview:line];
        
    }
    
}

#pragma mark 搜索按钮点击事件
-(void)clickSearchButtonAction:(UIButton*)button{
    // 保存本页面的成果
    //    if (_zixuan) {
    //        // 点击搜索相当于离开本界面，那么保存用户信息并同步到远程服务器
    //        [_zixuan saveLocalDatas];
    //        // 设置标志为提交后再更新 ,为二级视图返回做准备
    //        _zixuan.isSubmitThanUpdate = YES;
    //        // 设置共享标志
    //        [DCommon setIsSubmitThanUpdate:YES];
    //    }
    SelectStockViewController __weak *__self=self;
    SearchStocksViewController *searchView = [[SearchStocksViewController alloc] init];
    searchView.type=888888;
    [self.navigationController pushViewController:searchView animated:YES];
    searchView.userSelectStockinfo=^(NSString *markID,NSString *markType,NSString* markName){
        __self.userSelectStockinfo(markID,markType,markName);
        [__self dismissViewControllerAnimated:YES completion:nil];
    };
    
   
}

@end