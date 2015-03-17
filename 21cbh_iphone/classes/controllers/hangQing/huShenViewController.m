//
//  huShenViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "huShenViewController.h"
#import "hangqingHttpRequest.h"
#import "DCommon.h"

@interface huShenViewController ()
{
    hangqingHttpRequest *_request;// 请求
    UILabel *_hu;// 沪指
    UILabel *_shen;// 深指
    UILabel *_huChangeValue;// 沪指涨跌
    UILabel *_shenChangeValue;// 深指涨跌
    CGFloat _height;// 高度
    BOOL _isFinish;// 是否请求完成
}

@end

@implementation huShenViewController

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
    [self initViews];
    // 请求接口
    [self getHushenStocksIndex:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    // 请求接口
    [self getHushenStocksIndex:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----------------------------自定义方法----------------------------
#pragma mark 初始化沪深控制器
-(id)initWithParent:(UIViewController*)controller andFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        _height = 25;
        CGFloat viewheight = frame.size.height-_height;
        // 把View添加到父视图最底部
        self.view.frame = CGRectMake(0, viewheight, frame.size.width, _height);
        [controller.view addSubview:self.view];
    }
    return self;
}
#pragma mark 初始化参数
-(void)initParam{
    _height = 25;
    _isFinish = YES;
    // 初始化网络连接请求
    _request = [[hangqingHttpRequest alloc] init];
    // 网络异常回调 在此请处理好网络异常事件
    _request.errorRequest = ^(hangqingHttpRequest* request){
        NSLog(@"---DFM---网络异常");
        
    };
    // 接口数据有误
    _request.hqResponse.errorResponse = ^(hangqingHttpResponse *response){
        NSLog(@"---DFM---接口数据有误");
    };
}
#pragma mark 初始化视图
-(void)initViews{
    UIFont *font = [UIFont fontWithName:kFontName size:12];
    self.view.backgroundColor = UIColorFromRGB(0xe1e1e1);
    self.view.layer.borderWidth=0.5;
    self.view.layer.borderColor=UIColorFromRGB(0x8d8d8d).CGColor;
    self.view.layer.masksToBounds=YES;
    
    CGFloat h = _height;
    // 沪指
    UILabel *hl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 42, h)];
    hl.text = @"沪指：";
    hl.font = font;
    hl.backgroundColor = ClearColor;
    hl.textColor = UIColorFromRGB(0x000000);
    [self.view addSubview:hl];
    // 沪指值
    _hu = [[UILabel alloc] initWithFrame:CGRectMake(hl.frame.origin.x+hl.frame.size.width, 0, 60, h)];
    _hu.text = @"--";
    _hu.font = font;
    _hu.backgroundColor = ClearColor;
    [self.view addSubview:_hu];
    // 沪指涨跌
    _huChangeValue = [[UILabel alloc] initWithFrame:CGRectMake(_hu.frame.origin.x+_hu.frame.size.width, 0, 60, h)];
    _huChangeValue.text = @"--";
    _huChangeValue.font = font;
    _huChangeValue.backgroundColor = ClearColor;
    [self.view addSubview:_huChangeValue];
    
    // 深指
    UILabel *sl = [[UILabel alloc] initWithFrame:CGRectMake(5+self.view.frame.size.width/2, 0, 42, h)];
    sl.text = @"深指：";
    sl.font = font;
    sl.backgroundColor = ClearColor;
    sl.textColor = UIColorFromRGB(0x000000);
    [self.view addSubview:sl];
    // 深指值
    _shen = [[UILabel alloc] initWithFrame:CGRectMake(sl.frame.origin.x+sl.frame.size.width, 0, 60, h)];
    _shen.text = @"--";
    _shen.font = font;
    _shen.backgroundColor = ClearColor;
    [self.view addSubview:_shen];
    // 深指涨跌
    _shenChangeValue = [[UILabel alloc] initWithFrame:CGRectMake(_shen.frame.origin.x+_shen.frame.size.width, 0, 60, h)];
    _shenChangeValue.text = @"--";
    _shenChangeValue.font = font;
    _shenChangeValue.backgroundColor = ClearColor;
    [self.view addSubview:_shenChangeValue];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, h-0.5, self.view.frame.size.width, 0.5)];
    line.backgroundColor = UIColorFromRGB(0x808080);
    [self.view addSubview:line];
    line = nil;
}
#pragma mark 更新视图
-(void)updateViews:(NSDictionary*)hu andShen:(NSDictionary*)shen{
    // 更新沪指
    _hu.text = [hu objectForKey:@"totalValue"];
    _hu.text = [[NSString alloc] initWithFormat:@"%0.2f",[_hu.text floatValue]];
    _huChangeValue.text = [hu objectForKey:@"changeValue"];
    if (![_huChangeValue.text isEqualToString:@""]) {
        if ([_huChangeValue.text floatValue]<0) {
            _hu.textColor = kGreenColor;
            _huChangeValue.textColor = kGreenColor;
        }else{
            _hu.textColor = kRedColor;
            _huChangeValue.textColor = kRedColor;
        }
    }
    // 更新深指
    _shen.text = [shen objectForKey:@"totalValue"];
    _shen.text = [[NSString alloc] initWithFormat:@"%0.2f",[_shen.text floatValue]];
    _shenChangeValue.text = [shen objectForKey:@"changeValue"];
    if (![_shenChangeValue.text isEqualToString:@""]) {
        if ([_shenChangeValue.text floatValue]<0) {
            _shen.textColor = kGreenColor;
            _shenChangeValue.textColor = kGreenColor;
        }else{
            _shen.textColor = kRedColor;
            _shenChangeValue.textColor = kRedColor;
        }
    }
}

#pragma mark ----------------------请求网络接口-----------------------
#pragma mark 请求接口
-(void)getHushenStocksIndex:(BOOL)isAsyn{
    if (_isFinish) {
        _isFinish = NO;
        [_request requestHushenStocksIndex:self isAsyn:isAsyn];
    }
    
}

#pragma mark 接口返回
-(void)getHushenStocksIndexBundle:(NSDictionary*)hu andShen:(NSDictionary*)shen{
    _isFinish = YES;
    if (hu && shen) {
        [self updateViews:hu andShen:shen];
    }
}

@end
