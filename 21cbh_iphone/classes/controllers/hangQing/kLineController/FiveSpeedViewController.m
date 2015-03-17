//
//  FiveSpeedViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "FiveSpeedViewController.h"
#import "hangqingHttpRequest.h"
#import "fiveAndDetailModel.h"

@interface FiveSpeedViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    NSMutableArray *_data;
    hangqingHttpRequest *_request;
    CGFloat _cellHeight;
    NSTimer *_timer;// 定时刷新
    
}

@end

@implementation FiveSpeedViewController

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
    
}
-(void)viewWillAppear:(BOOL)animated{
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

#pragma mark --------------------------自定义方法---------------------------
-(void)free{
    [self.view removeAllSubviews];
    [self clearTimer];
    _data = nil;
    // 清除请求
    [_request clearRequest];
    _request = nil;
    _tableView = nil;
    
}
-(void)show{
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _tableView.frame = frame;
    // NSLog(@"---DFM---五档的视图：%@",self.view);
    // 请求五档明细接口
    [self getFiveAndDetail:YES];
}
#pragma mark 初始化控制器
-(id)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        _cellHeight = 17.5;
        // 初始化视图
        [self initViews];
        
    }
    return self;
}
#pragma mark 初始化参数
-(void)initParam{
    _request = [[hangqingHttpRequest alloc] init];
    // 网络错误处理
    _request.errorRequest = ^(hangqingHttpRequest *request){
        
    };
    // 数据返回有误
    _request.hqResponse.errorResponse = ^(hangqingHttpResponse *response){
    
    };
    _data = [[NSMutableArray alloc] init];
    
}
#pragma mark 初始化视图
-(void)initViews{
    self.view.backgroundColor = ClearColor;
    if (!_tableView) {
        // 添加连个买卖两字
        [self addBigFont];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = ClearColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (kDeviceVersion>=7) {
            _tableView.separatorInset = UIEdgeInsetsZero;
        }
        [self.view addSubview:_tableView];
    }
}
#pragma mark 买卖两字
-(void)addBigFont{
    // NSLog(@"---DFM---五档高度：%f",self.view.frame.size.height);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 0.5)];
    line.backgroundColor = UIColorFromRGB(0x333333);
    [self.view addSubview:line];
    line = nil;
    CGFloat size = 50;
    UIFont *font = [UIFont fontWithName:kFontName size:size];
    // 卖字
    UILabel *buy = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height/2)];
    buy.text = @"卖";
    buy.font = font;
    buy.backgroundColor = ClearColor;
    buy.textColor = UIColorFromRGB(0xe1e1e1);
    buy.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:buy];
    buy = nil;
    // 买字
    UILabel *sale = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2)];
    sale.text = @"买";
    sale.backgroundColor = ClearColor;
    sale.textColor = UIColorFromRGB(0xe1e1e1);
    sale.font = font;
    sale.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:sale];
    sale = nil;
}

#pragma mark -------------------------网络接口处理--------------------------------
#pragma mark 请求接口
-(void)getFiveAndDetail:(BOOL)isAsyn{
    [self clearTimer];
    [_request requestFiveAndDetail:self Class:@"0" andkId:self.kLineView.kId  andType:[[NSString alloc] initWithFormat:@"%d",self.kLineView.kType]  isAsyn:isAsyn];
}
#pragma mark 数据返回
-(void)getFiveAndDetailBundle:(NSMutableArray*)data{
    _data = data;
    [_tableView reloadData];
    
    // 如果开盘则开始刷新
    if (!self.kLineView.isStop) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getFiveAndDetail:) userInfo:nil repeats:NO];
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

#pragma mark -------------------------tableView代理实现-------------------------
#pragma mark 总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}
#pragma mark 行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _cellHeight;
}
#pragma mark 每行内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"fivecell";// [[NSString alloc] initWithFormat:@"dpcell_%d",row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = ClearColor;
        UIFont *font = [UIFont fontWithName:kFontName size:10];
        
        // 序号
        UILabel *numlb = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 20, 20)];
        numlb.backgroundColor = ClearColor;
        numlb.text = @"-";
        numlb.font = font;
        numlb.textColor = UIColorFromRGB(0x808080);
        [cell.contentView addSubview:numlb];
        numlb = nil;
        // 成交价
        UILabel *volPriceLb = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-15, 20)];
        volPriceLb.backgroundColor = ClearColor;
        volPriceLb.text = @"-";
        volPriceLb.font = font;
        volPriceLb.textColor = kRedColor;
        [cell.contentView addSubview:volPriceLb];
        volPriceLb = nil;
        
        // 成交量
        UILabel *volLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-3, 20)];
        volLb.backgroundColor = ClearColor;
        volLb.text = @"-";
        volLb.font = font;
        volLb.textColor = UIColorFromRGB(0x000000);
        volLb.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:volLb];
        volLb = nil;
    }
    int row = indexPath.row;
    int rownum = 5-row;
    if (row>=5) {
        rownum = row - 4;
    }
    
    if (row<_data.count) {
        @try {
            NSString *num = [[NSString alloc] initWithFormat:@"%d",rownum];
            // 模型数据
            fiveAndDetailModel *five = (fiveAndDetailModel*)[_data objectAtIndex:indexPath.row];
            // 颜色
            UIColor *color = kRedColor;
            if ([five.priceType intValue]==-1) {
                color = kGreenColor;
            }
            if ([five.priceType intValue]==0) {
                color = UIColorFromRGB(0xFFFFFF);
            }
            NSArray *views = [cell.contentView subviews];
            UILabel *one = (UILabel*)[views objectAtIndex:0];
            one.text = num;
            one = nil;
            UILabel *two = (UILabel*)[views objectAtIndex:1];
            if ([five.two floatValue]>0) {
                two.text = five.two;
            }
            if ([five.two floatValue]<[self.kLineView.yesterdayPrice floatValue]) {
                two.textColor = kGreenColor;
            }
            if ([five.two floatValue]>[self.kLineView.yesterdayPrice floatValue]) {
                two.textColor = kRedColor;
            }
            if ([five.two floatValue]==[self.kLineView.yesterdayPrice floatValue]) {
                two.textColor = UIColorFromRGB(0xFFFFFF);
            }
            two = nil;
            UILabel *three = (UILabel*)[views objectAtIndex:2];
            if ([five.three floatValue]>0) {
                three.text = [[NSString alloc] initWithFormat:@"%0.0f",round([five.three floatValue])];
            }
            three = nil;
            five = nil;
        }
        @catch (NSException *exception) {
            NSLog(@"---DFM---五档Cell数据有误");
        }
        @finally {
            
        }
        
    }
    return cell;
}
@end
