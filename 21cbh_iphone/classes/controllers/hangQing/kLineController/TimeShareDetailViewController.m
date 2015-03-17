//
//  TimeShareDetailViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "TimeShareDetailViewController.h"
#import "hangqingHttpRequest.h"
#import "fiveAndDetailModel.h"
#import "stockBetsModel.h"

#define kD_kDownPng [UIImage imageNamed:@"D_kDown.png"]
#define kD_kUpPng [UIImage imageNamed:@"D_kUp.png"]

@interface TimeShareDetailViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    NSMutableArray *_data;
    hangqingHttpRequest *_request;
    CGFloat _cellHeight;
    CGFloat _titleHeight;
    NSTimer *_timer;// 定时刷新
    CGFloat _preValue;// 上一个值
}


@end

@implementation TimeShareDetailViewController

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
    
    // 请求五档明细接口
    [self getFiveAndDetail:YES];
}
#pragma mark 初始化控制器
-(id)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        _titleHeight = 20;
        _cellHeight = 17.5;
        // 初始化视图
        [self initViews];
        // 请求五档明细接口
        [self getFiveAndDetail:YES];
    }
    return self;
}
#pragma mark 初始化参数
-(void)initParam{
    _request = [[hangqingHttpRequest alloc] init];
    // 网络错误处理
    _request.errorRequest = ^(hangqingHttpRequest *request){
        
    };
    _data = [[NSMutableArray alloc] init];
    
}
#pragma mark 初始化视图
-(void)initViews{
    self.view.backgroundColor = ClearColor;
    if (!_tableView) {

        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _titleHeight, self.view.frame.size.width, self.view.frame.size.height-_titleHeight) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = ClearColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (kDeviceVersion>=7) {
            _tableView.separatorInset = UIEdgeInsetsZero;
        }
        [self.view addSubview:_tableView];
        // 添加标题
        [self addTitleView];
        
    }
}

#pragma mark 时价量标题
-(void)addTitleView{
    // 创建标题内容
    NSArray *ts = [[NSArray alloc] initWithObjects:@"时",@"价",@"量", nil];
    for (int i=0; i<3; i++) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(i*self.view.frame.size.width/3, 0, self.view.frame.size.width/3, _titleHeight)];
        l.textColor = UIColorFromRGB(0x000000);
        l.font = [UIFont fontWithName:kFontName size:10];
        l.textAlignment = NSTextAlignmentCenter;
        l.backgroundColor = UIColorFromRGB(0xe1e1e1);
        l.text = [ts objectAtIndex:i];
        [self.view addSubview:l];
    }
    // 添加分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _titleHeight, self.view.frame.size.width, 0.5)];
    line.backgroundColor = UIColorFromRGB(0x333333);
    [self.view addSubview:line];
    line = nil;

}
#pragma mark -------------------------网络接口处理--------------------------------
#pragma mark 请求接口
-(void)getFiveAndDetail:(BOOL)isAsyn{
    [self clearTimer];
    [_request requestFiveAndDetail:self Class:@"1" andkId:self.kLineView.kId andType:[[NSString alloc] initWithFormat:@"%d",self.kLineView.kType] isAsyn:isAsyn];
}
#pragma mark 数据返回
-(void)getFiveAndDetailBundle:(NSMutableArray*)data{
    _data = data;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _tableView.frame = frame;
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
        // 时间
        UILabel *numlb = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, self.view.frame.size.width/3, 20)];
        numlb.backgroundColor = ClearColor;
        numlb.text = @"-";
        numlb.font = font;
        numlb.textColor = UIColorFromRGB(0x808080);
        numlb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:numlb];
        numlb = nil;
        // 成交价
        UILabel *volPriceLb = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3, 0, self.view.frame.size.width/3+3, 20)];
        volPriceLb.backgroundColor = ClearColor;
        volPriceLb.text = @"-";
        volPriceLb.font = font;
        volPriceLb.textColor = kRedColor;
        volPriceLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:volPriceLb];
        
        // 成交量
        UILabel *volLb = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/3*2-8, 0, self.view.frame.size.width/3, 20)];
        volLb.backgroundColor = ClearColor;
        volLb.text = @"-";
        volLb.font = font;
        volLb.textColor = kGreenColor;
        volLb.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:volLb];
        volLb = nil;
        
        NSString *path=[[NSBundle mainBundle]pathForResource:@"D_kDown@2x" ofType:@"png"];
        UIImage *imageSize=[UIImage imageWithContentsOfFile:path];
        
        // 箭头
        UIImageView *jiantou = [[UIImageView alloc] initWithFrame:CGRectMake(volPriceLb.frame.origin.x+volPriceLb.frame.size.width, volPriceLb.frame.origin.y, imageSize.size.width, imageSize.size.height)];
        jiantou.image = kD_kDownPng;
        [cell.contentView addSubview:jiantou];
        jiantou = nil;
        volPriceLb = nil;
        
    }
    if (indexPath.row<_data.count) {
        @try {
            // 模型数据
            fiveAndDetailModel *five = (fiveAndDetailModel*)[_data objectAtIndex:indexPath.row];
            if (indexPath.row+1<_data.count) {
                fiveAndDetailModel *pre = (fiveAndDetailModel*)[_data objectAtIndex:indexPath.row+1];
                _preValue = [pre.two floatValue];
            }else
            {
                _preValue = 0;
            }
            CGFloat yestodayClosePrice = [self.kLineView.pDatas.yesterdayPrice floatValue];
            // 颜色
            UIColor *color = kRedColor;
            UIImage *img = kD_kDownPng;
            if ([five.two floatValue]<yestodayClosePrice) {
                color = kGreenColor;
            }
            NSArray *views = [cell.contentView subviews];
            UILabel *one = (UILabel*)[views objectAtIndex:0];
            one.text = five.one;
            one = nil;
            UILabel *two = (UILabel*)[views objectAtIndex:1];
            two.text = [[NSString alloc] initWithFormat:@"%0.2f",[five.two floatValue]];
            // 根据与昨日收盘价的对比得出红绿色
            two.textColor = color;
            // 根据与上一分钟的价格对比得出红绿色箭头
            if ([five.two floatValue]<_preValue) {
                img = kD_kDownPng;
            }
            if ([five.two floatValue]>_preValue) {
                img = kD_kUpPng;
            }
            if ([five.two floatValue]==_preValue) {
                img = nil;
            }
            // 根据价格类型来定义成交量的红绿色
            if ([five.priceType floatValue]==1) {
                color = kRedColor;
            }
            if ([five.priceType intValue]==-1) {
                color = kGreenColor;
            }
            UILabel *three = (UILabel*)[views objectAtIndex:2];
            three.text = [[NSString alloc] initWithFormat:@"%0.0f",[five.three floatValue]];
            three.textColor = color;
            
            
            UIImageView *jiantou = (UIImageView*)[views objectAtIndex:3];
            jiantou.image = img;
            jiantou.frame = CGRectMake(self.view.frame.size.width/3*3-5, 5, kD_kUpPng.size.width, kD_kUpPng.size.height);
            // 释放
            color = nil;
            five = nil;
            two = nil;
            three = nil;
            jiantou = nil;
        }
        @catch (NSException *exception) {
            NSLog(@"---DFM---明细数据有误啊");
        }
        @finally {
            
        }
        
    }
    
    return cell;
}
@end
