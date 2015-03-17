//
//  zRemindViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-24.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "zRemindViewController.h"
#import "selfMarketDB.h"
#import "selfMarketModel.h"
#import "UserModel.h"
#import "hangqingHttpRequest.h"
#import "CommonOperation.h"
#import "FMTextView.h"
#import "loadingView.h"
#import "DNumberKeyBoard.h"
#import "DCommon.h"
#import "PushNotificationHandler.h"

#define kD_SelfMarket_Finished [UIImage imageNamed:@"D_SelfMarket_Finished.png"]
#define kD_SelfMarket_Finished_Hover [UIImage imageNamed:@"D_SelfMarket_Finished_Hover.png"]

@interface zRemindViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,DNumberKeyBoardDelegate,UIAlertViewDelegate>
{
    UITableView *_mainView;
    NSArray *_titles; // 标题
    NSArray *_tips; // 提示
    NSArray *_danwei;// 单位
    NSMutableArray *_bools; // 开关
    selfMarketDB *_db;// 数据库
    NSOperationQueue *_queue ;// 队列
    selfMarketModel *_model;// 模型
    NSMutableArray *_list; // post的股票集合 [{marketId,type}{marketId,type}...]
    hangqingHttpRequest *_request;
    loadingView *_loadingView;// 加载视图
    BOOL _isNewsDatas;// 是否是新添加的
    UILabel *_tipView;// 提示界面
    DNumberKeyBoard* keyboardView;// 自定义键盘视图
    UITextField *_currentTextFiled;// 当前文本框
    BOOL _isShow;// 是否提示过了
    BOOL _isShowSet;// 是否提示过设置通知中心
}
@end

@implementation zRemindViewController

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
    // 加载本地数据
    [self loadLocalDatas];
    // 初始化视图
    [self initViews];
    // 初始化子视图
    [self addSubViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _mainView = nil;
    _request = nil;
    _list = nil;
    _db = nil;
    _model = nil;
    _queue = nil;
    _titles = nil;
    _tips = nil;
    _danwei = nil;
    keyboardView = nil;
}

#pragma mark ---------------------------自定义方法---------------------------
#pragma mark 初始化参数
-(void)initParam{
    //_titles = [[NSArray alloc] initWithObjects:@"股价涨到",@"股价跌到",@"日涨跌幅超",@"公告提醒",@"资讯提醒", nil];
    _titles = [[NSArray alloc] initWithObjects:@"股价涨到",@"股价跌到",@"日涨跌幅超",@"公告提醒",@"新闻提醒", nil];
    _tips = [[NSArray alloc] initWithObjects:@"较当前价涨",@"较当前价跌",@"", nil];
    _danwei = [[NSArray alloc] initWithObjects:@"元",@"元",@"%", nil];
    _bools = [[NSMutableArray alloc] initWithObjects:
              [NSNumber numberWithBool:NO],
              [NSNumber numberWithBool:NO],
              [NSNumber numberWithBool:NO],
              [NSNumber numberWithBool:NO],
              [NSNumber numberWithBool:NO],
            nil];
    _db = [[selfMarketDB alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    _list = [[NSMutableArray alloc] init];
    _isNewsDatas = NO;// 默认已经存在
    // 初始化网络连接请求
    _request = [[hangqingHttpRequest alloc] init];
    // 网络异常回调 在此请处理好网络异常事件
    __unsafe_unretained zRemindViewController *ze = self;
    _request.errorRequest = ^(hangqingHttpRequest* request){
        NSLog(@"---DFM---网络异常");
        [ze hideLoadingView:YES];
    };
    // 接口数据有误
    _request.hqResponse.errorResponse = ^(hangqingHttpResponse *response){
        NSLog(@"---DFM---接口数据有误");
        [ze hideLoadingView:YES];
    };
}

#pragma mark 初始化视图
-(void)initViews{
    self.view.backgroundColor = kBackgroundcolor;
    [self initTitle:@"预警设置" returnType:1];
    // 隐藏返回按钮
    for (UIView *item in self.topView.subviews) {
        // 返回按钮留着
//        if (item == [self.topView.subviews lastObject]) {
//            continue;
//        }
        // 标题留着
        if ([item class]!=[UILabel class]) {
            [item removeFromSuperview];
        }
    }
    // 添加一根分割线
    UIView *line = [DCommon drawLineWithSuperView:self.topView position:NO];
    line.backgroundColor = UIColorFromRGB(0x808080);
    UIImage *bg = [DCommon imageWithColor:UIColorFromRGB(0xf0f0f0) andSize:CGSizeMake(60, self.topView.frame.size.height-1)];
    //UIImage *bgHover = [DCommon imageWithColor:UIColorFromRGB(0x000000) andSize:CGSizeMake(60, self.topView.frame.size.height-1)];
    // 添加一个管理按钮
    UIButton *_editButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, 66, 28)];
    [_editButton setTitle:@"完成" forState:UIControlStateNormal];
    _editButton.layer.borderColor=UIColorFromRGB(0xcccccc).CGColor;
    _editButton.layer.borderWidth=0.5f;
    _editButton.layer.masksToBounds=YES;
    [_editButton setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
    [_editButton setBackgroundImage:bg forState:UIControlStateNormal];
    
    
    [_editButton addTarget:self action:@selector(clickOverButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_editButton];
    _editButton = nil;
    
    // 提示界面
    _tipView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _tipView.hidden = YES;
    _tipView.backgroundColor = UIColorFromRGB(0x333333);
    _tipView.layer.borderColor = UIColorFromRGB(0x444444).CGColor;
    _tipView.layer.borderWidth = 1;
    _tipView.font = [UIFont fontWithName:kFontName size:10];
    _tipView.textColor = UIColorFromRGB(0xFFFFFF);
    _tipView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_tipView];
    // 自定义键盘
    keyboardView = [[[NSBundle mainBundle] loadNibNamed:@"DNumberKeyBoard" owner:nil options:nil ] objectAtIndex:0];
    keyboardView.backgroundColor = UIColorFromRGB(0xDDDDDD);
    keyboardView.delegate = self;
  
}
#pragma mark 添加子视图
-(void)addSubViews{
    if (!_mainView) {
        CGFloat y = self.topView.frame.size.height+self.topView.frame.origin.y;
        _mainView = [[UITableView alloc] initWithFrame:CGRectMake(0,y, self.view.frame.size.width,self.view.frame.size.height-y)];
        _mainView.delegate = self;
        _mainView.dataSource = self;
        _mainView.backgroundColor = ClearColor;
        _mainView.separatorColor = UIColorFromRGB(0xcccccc);
        if (kDeviceVersion>=7) {
            _mainView.separatorInset = UIEdgeInsetsZero;
        }
        CGFloat vy = 15;
        // 表格头部
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainView.frame.size.width, 50)];
        view.backgroundColor = ClearColor;
        // 股票名称
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(15, vy, _mainView.frame.size.width, view.frame.size.height)];
        t.text = self.marketName;
        t.backgroundColor = ClearColor;
        t.textColor = UIColorFromRGB(0x000000);
        [t sizeToFit];
        [view addSubview:t];
        // 最新价
        UILabel *n = [[UILabel alloc] initWithFrame:CGRectMake(t.frame.size.width+t.frame.origin.x+10, vy, _mainView.frame.size.width, view.frame.size.height)];
        n.text = [[NSString alloc] initWithFormat:@"最新价 %@",self.newsValue];
        n.backgroundColor = ClearColor;
        n.textColor = UIColorFromRGB(0x000000);
        n.font = [UIFont fontWithName:kFontName size:14];
        [n sizeToFit];
        [view addSubview:n];
        // 涨跌幅
        UILabel *c = [[UILabel alloc] initWithFrame:CGRectMake(n.frame.size.width+n.frame.origin.x+10, vy, _mainView.frame.size.width, view.frame.size.height)];
        c.text = [[NSString alloc] initWithFormat:@"涨跌幅 %@",self.changeRate];
        c.backgroundColor = ClearColor;
        c.font = [UIFont fontWithName:kFontName size:14];
        c.textColor = UIColorFromRGB(0x000000);
        [c sizeToFit];
        [view addSubview:c];
        n = nil;
        c = nil;
        t = nil;
        _mainView.tableHeaderView = view;
        view = nil;
        // 表格尾部
        UIView *footerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainView.frame.size.width, 44)];
        footerview.backgroundColor = ClearColor;
        // 描述
        CGFloat fy = -30;
        if (kDeviceVersion<7) {
            fy=-20;
        }
        FMTextView *ft = [[FMTextView alloc] initWithFrame:CGRectMake(10, fy+20, _mainView.frame.size.width-20, 60)];
        ft.font = [UIFont fontWithName:kFontName size:12];
        ft.lineHeight = 6;
        ft.backgroundColor = ClearColor;
        ft.text = @"自选股提醒为您提供实时股价提醒服务，该服务依赖于苹果信息推送系统，个别情况下会出现延迟。";
        ft.textColor = UIColorFromRGB(0x999999);
        [footerview addSubview:ft];
        ft = nil;
        _mainView.tableFooterView = footerview;
        footerview = nil;
        [self.view addSubview:_mainView];
    }
}

#pragma mark 隐藏键盘
-(void)hideKeyborad{
    // 隐藏键盘
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
#pragma mark 加载本地数据
-(void)loadLocalDatas{
    [_queue addOperationWithBlock:^{
        _model = [_db getSelfMarketModelWithMarketId:self.marketId andMarketType:self.marketType];
        [_mainView reloadData];
    }];
}

#pragma mark 封装股票集合
-(void)packageList{
    if (_list) {
        [_list removeAllObjects];
    }
    if (_model) {
        // 单独更新一个提醒数据
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                             _model.marketId,@"marketId",
                             _model.marketType,@"type",
                             _model.heightPrice,@"heightPrice",
                             _model.lowPrice,@"lowPrice",
                             _model.todayChangeRate,@"todayChangeRate",
                             _model.isNotice,@"isNotice",
                             _model.isNews,@"isNews",
                             nil];
        [_list addObject:dic];
        dic = nil;
    }

}
#pragma mark 是否登陆
-(BOOL)isLogin{
    BOOL l = NO;
    UserModel *user = [UserModel um];
    if (user.userId<=0 || !user) {
        // 弹出登陆视图
        [CommonOperation goTOLogin];
    }else{
        l = YES;
    }
    user = nil;
    return l;
}

#pragma mark ------------------------视图响应方法-----------------------------
#pragma mark 点击完成按钮
-(void)clickOverButtonAction:(UIButton*)button{
    NSLog(@"---DFM---点击完成按钮");
    // 是否登陆
    if ([self isLogin]) {
        // 保存数据
        // 股价涨到
        UITableViewCell *cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *t = (UITextField*)[cell.contentView.subviews objectAtIndex:1];
        NSString *heightPrice = t.text;
//        if (![self checkTextFiledValue:t]) {
//            return;
//        }
        t = nil;
        // 股价跌到
        cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        t = (UITextField*)[cell.contentView.subviews objectAtIndex:1];
        NSString *lowPrice = t.text;
//        if (![self checkTextFiledValue:t]) {
//            return;
//        }
        t = nil;
        // 日涨跌幅超
        cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        t = (UITextField*)[cell.contentView.subviews objectAtIndex:1];
        NSString *todayChangeRate = t.text;
//        if (![self checkTextFiledValue:t]) {
//            return;
//        }
        t = nil;
        // 公告提醒
        cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        UISwitch *s = (UISwitch*)[cell.contentView.subviews objectAtIndex:1];
        BOOL isNotice = s.on;// 目前不做公告提醒
        // 资讯提醒
        cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        s = (UISwitch*)[cell.contentView.subviews objectAtIndex:1];
        BOOL isNews = s.on;
        s = nil;
        cell = nil;
        
        
        // 加载视图
        [self addLoadingView];
        [self hideLoadingView:NO];
        
        // 组装模型
        selfMarketModel *m = [[selfMarketModel alloc] init];
        // 如果什么都没修改直接返回
        if ([heightPrice isEqualToString:m.heightPrice] && [lowPrice isEqualToString:m.lowPrice] && [todayChangeRate isEqualToString:m.todayChangeRate] && isNews==[m.isNews boolValue] && isNotice==[m.isNotice boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        m.marketId = self.marketId;
        m.marketType = self.marketType;
        m.heightPrice = heightPrice;
        m.lowPrice = lowPrice;
        m.todayChangeRate = todayChangeRate;
        m.userId = @"";
        
        
        UserModel *_user = [UserModel um];
        if (_user.userId>0) {
            m.userId = _user.userId;
        }
        _user = nil;
        m.isNotice = [[NSString alloc] initWithFormat:@"%d",isNotice];
        m.isNews = [[NSString alloc] initWithFormat:@"%d",isNews];
        if (m) {
            // 更新数据库
            [_queue addOperationWithBlock:^{
                // 查询本地数据是否存在
                selfMarketModel *em = [[selfMarketModel alloc] init];
                em.marketId = self.marketId;
                em.marketType = self.marketType;
                BOOL isExit = [_db isExistSelfMarket:em];
                // 如果自选股不存在则自动加进去
                if (!isExit) {
                    // 至标识为需要单独添加
                    _isNewsDatas = YES;
                    // 插入
                    selfMarketModel *model = [[selfMarketModel alloc]init];
                    model.marketId = self.marketId;
                    model.marketName = self.marketName;
                    model.marketType = self.marketType;
                    UserModel *user = [UserModel um];
                    if (user.userId>0) {
                        model.userId = user.userId;
                    }else{
                        model.userId = @"";
                    }
                    user = nil;
                    model.isSyn = NO;
                    model.timestamp = [DCommon getTimestamp];
                    model.heightPrice = m.heightPrice;
                    model.lowPrice = m.lowPrice;
                    model.todayChangeRate = m.todayChangeRate;
                    model.isNotice = m.isNotice;
                    model.isNews = m.isNews;
                    [_db insertWithSelfMarket:model];
                    model = nil;
                }
                if (![m.isSyn boolValue]) {
                    _isNewsDatas = YES;
                }
                m.isSyn = @"1";
                
                
                
                // 更新数据
                [_db updateRemindWithSelfMarket:m];
                // 读取单例
                _model = [_db getSelfMarketModelWithMarketId:self.marketId andMarketType:self.marketType];
                // 同步到远程服务器
                [self getSelfMarketRemind:YES];
                // 设置为已经操作过
                [DCommon SetIsChanged:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 向百度发送分组
                    if ([m.heightPrice floatValue]>0 || [m.lowPrice floatValue]>0 || [m.todayChangeRate floatValue]>0 || [m.isNotice boolValue] || [m.isNews boolValue]) {
                        // 添加分组
                        [[PushNotificationHandler instance] addPushTags:[NSString stringWithFormat:@"stock_%@_%@",self.marketId,self.marketType]];
                        [[PushNotificationHandler instance] savePushTags];
                    }else{
                        // 删除分组
                        [[PushNotificationHandler instance] deletePushTags:[NSString stringWithFormat:@"stock_%@_%@",self.marketId,self.marketType]];
                        [[PushNotificationHandler instance] savePushTags];
                    }
                });
            }];
        }
    }
}
#pragma mark 点击开关
-(void)clickSwitchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    UITableViewCell *cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:switchButton.tag inSection:0]];
    // 得到文本框 得到焦点
    UILabel *t = (UILabel*)[cell.contentView.subviews objectAtIndex:1];
    cell = nil;
    [t becomeFirstResponder];
    // 开关变量
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        
    }else {
        t.text = @"";
    }
    t = nil;
    switchButton = nil;
}

#pragma mark 加载视图
-(void)addLoadingView{
    if (!_loadingView) {
        CGFloat lw = 150;
        CGFloat lh = 100;
        _loadingView = [[loadingView alloc] initWithTitle:@"数据正在同步..." Frame:CGRectMake((self.view.frame.size.width-lw)/2,150,lw, lh) IsFullScreen:YES ];
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==1001) {
        // 注销账号
        [[CommonOperation getId] loginout];
        // 返回上一页
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        if (buttonIndex==1 || alertView.numberOfButtons==1) {
            // 返回上一页
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSString *deviceToken = [[CommonOperation getId] getAppleToken];
            if (!deviceToken) {
                // 调用appdelegate重新注册推送
                //            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                //            [app registerApplePush];
                [[PushNotificationHandler instance]registerForRemoteNotification];
                // 延迟一下 继续同步
                [self performSelector:@selector(getSelfMarketRemind:) withObject:[NSNumber numberWithBool:YES] afterDelay:1];
                //app = nil;
            }else{
                [self getSelfMarketRemind:YES];
            }
            
        }
    }
}


#pragma mark -------------------------网络接口方法--------------------------
#pragma mark 请求接口
-(void)getSelfMarketRemind:(BOOL)isAsyn{
    //设置开关的状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int isPush=[[defaults objectForKey:kIsPush] intValue];
    if (isPush==0 && !_isShow) {
        _isShow = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingView:YES];
            // 提示信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"关闭消息推送通知后，将不能及时收到行情推送" delegate:self cancelButtonTitle:@"继续同步" otherButtonTitles:nil, nil];
            [alert show];
        });
        return ;
    }
    //设备Token
    NSString *deviceToken = [[CommonOperation getId] getAppleToken];
    //deviceToken = nil;
    if (([deviceToken isEqualToString:@""] || !deviceToken) && !_isShowSet) {
        _isShowSet = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingView:YES];
            // 提示信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知中心提示" message:@"请在 系统设置->通知中心 开启通知功能" delegate:self cancelButtonTitle:@"继续同步" otherButtonTitles:@"返回上一页", nil];
            [alert show];
            return ;
        });
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLoadingView];
            [self hideLoadingView:NO];
        });
        // 检查是否需要单独添加
        if (_isNewsDatas) {
            // 单独添加到远程服务器
            [self getSelfStockManage:isAsyn];
        }else{
            // 封装数据
            [self packageList];
            // 同步远程数据
            [_request requestSelfMarketRemind:self List:_list isAsyn:isAsyn];
        }
    }
}
#pragma mark 接口返回
-(void)getSelfMarketRemindBundle:(BOOL)isSuccess{
    [self hideLoadingView:YES];
    if (isSuccess) {
        NSLog(@"---DFM---提醒数据同步成功");
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSLog(@"---DFM---提醒数据同步失败");
        // 提示信息
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"同步提示" message:@"数据同步失败，请检查网络连接是否打开" delegate:self cancelButtonTitle:@"继续同步" otherButtonTitles:@"返回上一页", nil];
        [alert show];
    }
    
}

-(void)limitMoreTenRemind:(NSString*)message{
    NSLog(@"---DFM---只能设置十个提醒");
    // 提示信息
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"返回上一页", nil];
    [alert show];
}

#pragma mark 请求单个管理接口
-(void)getSelfStockManage:(BOOL)isAsyn{
    [self addLoadingView];
    [self hideLoadingView:NO];
    // 封装数据
    NSString *handle = @"0"; //操作类型，0：增加，1：删除，2更新修改(更新时间戳);
    // 同步远程数据
    [_request requestSelfStockManage:self Handle:handle MarketId:_model.marketId MarketType:_model.marketType Timestamp:_model.timestamp isAsyn:isAsyn];
}
#pragma mark 单个管理接口返回
-(void)getSelfStockManageBundle:(int)isSuccess{
    if (isSuccess==0 || isSuccess==1) {
        NSLog(@"---DFM---单个数据管理成功");
        _isNewsDatas = NO;
        // 添加到远程后 再更新提醒数据到远程服务器
        [self getSelfMarketRemind:YES];
    }else{
        if (isSuccess<3) {
            NSLog(@"---DFM---单个数据管理失败");
            [self hideLoadingView:YES];
            // 提示信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"同步提示" message:@"数据同步失败，请检查网络连接是否打开" delegate:self cancelButtonTitle:@"继续同步" otherButtonTitles:@"返回上一页", nil];
            [alert show];
        }
        if (isSuccess==3) {
            NSLog(@"---DFM---用户多处登陆");
            [self hideLoadingView:YES];
            // 提示信息
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"同步提示" message:@"您的账号已在其他设备登陆，您被迫下线，请重新登陆" delegate:self cancelButtonTitle:@"返回上一页" otherButtonTitles:nil, nil];
            alert.tag = 1001;
            [alert show];
        }
        
    }
    
}
#pragma mark 验证文本的值
-(BOOL)checkTextFiledValue:(UITextField*)textField{
    // 判断并提示
    switch (textField.tag) {
        case 0:
            _tipView.hidden = YES;
            if ([textField.text floatValue]<[self.newsValue floatValue] && [textField.text floatValue]>0) {
                _tipView.text = @"低于当前价";
                _tipView.hidden = NO;
            }
            if ([textField.text floatValue]>100000  && [textField.text floatValue]>0) {
                _tipView.text = @"输入的股价大于理论值";
                _tipView.hidden = NO;
            }
            break;
        case 1:
            _tipView.hidden = YES;
            if ([textField.text floatValue]>[self.newsValue floatValue]  && [textField.text floatValue]>0) {
                _tipView.text = @"高于当前价";
                _tipView.hidden = NO;
            }
            break;
        case 2:
            _tipView.hidden = YES;
            if ([textField.text floatValue]>10  && [textField.text floatValue]>0) {
                _tipView.text = @"涨跌幅最高为10%";
                _tipView.hidden = NO;
            }
            break;
        default:
            _tipView.hidden = YES;
            break;
    }
//    if ([textField.text floatValue]<=0) {
//        _tipView.text = @"请输入大于0的值";
//        _tipView.hidden = NO;
//        
//    }
    // 如果文本框有值，那么开关打开
    
    if (!_tipView.hidden) {
        [self.view bringSubviewToFront:_tipView];
        [_tipView sizeToFit];
        CGFloat x = textField.frame.origin.x;
        CGFloat y = _mainView.frame.origin.y + textField.tag*54+54-_tipView.frame.size.height;
        CGFloat w = _tipView.frame.size.width+5;
        CGFloat h = _tipView.frame.size.height+5;
        _tipView.frame = CGRectMake(x, y, w, h);
        [textField becomeFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark ------------------------UITableViewDelegate 代理实现方法 -------------------------------
#pragma mark 分组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
#pragma mark 表格每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 3;
            break;
        default:
            break;
    }
    return 2;
}
#pragma mark 分组高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
#pragma mark 组头
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
    view.backgroundColor = ClearColor;
    return view;
}
#pragma mark 组尾
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
    view.backgroundColor = ClearColor;
    return view;
}
#pragma mark 行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}
#pragma mark 表格行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"cell"; // [[NSString alloc] initWithFormat:@"dpcell_%d",indexPath.row];
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xffffff);
        //cell.contentView.backgroundColor = UIColorFromRGB(0x262626);
        // 标题
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 90, 54)];
        t.backgroundColor = ClearColor;
        t.textAlignment = NSTextAlignmentLeft;
        t.textColor = UIColorFromRGB(0x000000);
        t.font = [UIFont fontWithName:kFontName size:16];
        [cell.contentView addSubview:t];
        // 第一组
        if (indexPath.section==0) {
            // 文本框
            UITextField *f = [[UITextField alloc] initWithFrame:CGRectMake(t.frame.size.width+t.frame.origin.x, 12, 100, 30)];
            f.delegate = self;
            f.font = [UIFont fontWithName:kFontName size:14];
            //f.borderStyle = UITextBorderStyleLine;
//            f.layer.borderWidth = 0.5;
//            f.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
//            f.layer.cornerRadius = 2;
            f.autocorrectionType = UITextAutocorrectionTypeYes;
            f.keyboardType = UIKeyboardTypeNumberPad;
            f.placeholder = @"";
            f.returnKeyType = UIReturnKeyDone;
            f.clearButtonMode = UITextFieldViewModeWhileEditing;
            f.clearButtonMode = UITextFieldViewModeNever;
            f.textAlignment = NSTextAlignmentRight;
            f.layer.borderWidth=0.5f;
            f.layer.borderColor=UIColorFromRGB(0x8d8d8d).CGColor;
            f.layer.masksToBounds=YES;
            //f.backgroundColor = UIColorFromRGB(0x8d8d8d);
//            f.textColor = UIColorFromRGB(0xFFFFFF);
            f.inputView = keyboardView;
            [f addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [cell.contentView addSubview:f];
            
            // 元
            UILabel *y = [[UILabel alloc] initWithFrame:CGRectMake(f.frame.size.width+f.frame.origin.x+3, 0, 15, 54)];
            y.backgroundColor = ClearColor;
            y.text = @"元";
            y.font = [UIFont fontWithName:kFontName size:16];
            y.textColor = UIColorFromRGB(0x000000);
            [cell.contentView addSubview:y];
            y = nil;
            f = nil;
        }
        
        // 开关
        CGFloat x = tableView.frame.size.width-70;
        if (kDeviceVersion<7) {
            x -= 20;
        }
        UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(x, 12, 30, 30)];
        s.on = NO;
        //s.tintColor = UIColorFromRGB(0x999999);
        [s addTarget:self action:@selector(clickSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:s];
        s = nil;
        t = nil;
    }
    // 标题
    UILabel *t = (UILabel*)[cell.contentView.subviews objectAtIndex:0];
    t.text = [_titles objectAtIndex:indexPath.row];
    t.tag = indexPath.row;
    if (indexPath.section==1) {
        t.tag = indexPath.row+3;
        t.text = [_titles objectAtIndex:indexPath.row+3];
    }
    t = nil;
    // 第一组
    if (indexPath.section==0) {
        UILabel *y = (UILabel*)[cell.contentView.subviews objectAtIndex:2];
        y.text = [_danwei objectAtIndex:indexPath.row];
        y = nil;
        // 文本框
        UITextField *f = (UITextField*)[cell.contentView.subviews objectAtIndex:1];
        f.tag = indexPath.row;
        if (_model) {
            switch (indexPath.row) {
                case 0:
                    if ([_model.heightPrice floatValue]>0) {
                        f.text = _model.heightPrice;
                    }
                    
                    break;
                case 1:
                    if ([_model.lowPrice floatValue]>0) {
                        f.text = _model.lowPrice;
                    }
                    
                    break;
                case 2:
                    if ([_model.todayChangeRate floatValue]>0) {
                        f.text = _model.todayChangeRate;
                    }
                    
                    break;
                default:
                    break;
            }
        }
        
    }
    // 开关
    UISwitch *s = (UISwitch*)[cell.contentView.subviews lastObject];
    s.tag = indexPath.row;
    if (indexPath.section==0) {
        s.tag = indexPath.row;
        if (_model) {
            // 股价涨到开关
            if ([_model.heightPrice floatValue]>0 && indexPath.row==0) {
                [_bools replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
            }
            // 股价跌到开关
            if ([_model.lowPrice floatValue]>0 && indexPath.row==1) {
                [_bools replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
            }
            // 日涨跌幅超开关
            if ([_model.todayChangeRate floatValue]>0 && indexPath.row==2) {
                [_bools replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
            }
        }
    }
    s.on = [[_bools objectAtIndex:indexPath.row] boolValue];
    if (indexPath.section==1) {
        s.tag = indexPath.row+3;
        if (_model) {
            // 公告提醒开关
            if ([_model.isNotice boolValue]) {
                [_bools replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:YES]];
            }
            // 新闻提醒开关
            if ([_model.isNews boolValue]) {
                [_bools replaceObjectAtIndex:4 withObject:[NSNumber numberWithBool:YES]];
            }
        }
        s.on = [[_bools objectAtIndex:indexPath.row+3] boolValue];
    }
    s = nil;
    
    return cell;
}
#pragma mark 点击CELL
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark 滑动隐藏键盘
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideKeyborad];
}

#pragma mark ---------------------------文本框代理方法----------------------------
#pragma mark 点击文本框
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    keyboardView.frame = CGRectMake(0, 0, self.view.frame.size.width, 223);
    NSLog(@"---DFM---键盘%@",keyboardView);
    _currentTextFiled = textField;
    UITableViewCell *cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    // 得到开关
    UISwitch *s = (UISwitch*)[cell.contentView.subviews objectAtIndex:3];
    if (!s.on) {
        [s setOn:YES animated:YES];
    }
    s = nil;
    cell = nil;
    _tipView.hidden = YES;
}

- (void) textFieldDidChange:(UITextField *) textField{
    NSLog(@"---DFM---正在输入");
    [self checkTextFiledValue:textField];
}

#pragma mark 鼠标移开文本框
-(void)textFieldDidEndEditing:(UITextField *)textField{
    UITableViewCell *cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    // 得到开关
    if ([textField.text isEqualToString:@""]) {
        UISwitch *s = (UISwitch*)[cell.contentView.subviews objectAtIndex:3];
        if (s.on) {
            [s setOn:NO animated:YES];
        }
        s = nil;
    }
    
    cell = nil;
}

#pragma mark ---------------------------键盘代理实现---------------------------------
-(void)numberKeyBoardInput:(NSString*)buttonVlaue{
    UITextField *f = _currentTextFiled;
    if ([buttonVlaue isEqualToString:@"隐藏"]) {
        // 隐藏键盘
        [self hideKeyborad];
        return;
    }
    if ([buttonVlaue isEqualToString:@"清空"]) {
        f.text = @"";
        return;
    }
    if ([buttonVlaue isEqualToString:@"确定"]) {
        // 隐藏键盘
        [self hideKeyborad];
        return;
    }
    
    // 删除键
    if ([buttonVlaue isEqualToString:@""] || !buttonVlaue) {
        NSMutableString* mutableString = [[NSMutableString alloc] initWithFormat:@"%@", f.text];
        if ([mutableString length] > 0) {
            NSRange tmpRange;
            tmpRange.location = [mutableString length] - 1;
            tmpRange.length = 1;
            [mutableString deleteCharactersInRange:tmpRange];
        }
        f.text = mutableString;
        return;
    }
    NSString *oldText = f.text;
    f.text = [oldText stringByAppendingString:buttonVlaue];
    
    UITableViewCell *cell = [_mainView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:f.tag inSection:0]];
    // 得到开关
    UISwitch *s = (UISwitch*)[cell.contentView.subviews objectAtIndex:3];
    if ([f.text isEqualToString:@""]) {
        [s setOn:NO animated:YES];
    }
    else{
        [s setOn:YES animated:YES];
    }
    s = nil;
    
    
    // 检验文本
    [self checkTextFiledValue:f];
    f = nil;
}
@end