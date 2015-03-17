//
//  hqBaseViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hqBaseViewController.h"
#import "SearchStocksViewController.h"
#import "KLineViewController.h"
#import "DCommon.h"
#import "UIImage+ZX.h"
@interface hqBaseViewController ()

@end

@implementation hqBaseViewController

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
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 初始化一些视图
-(void)initBaseViews{
    self.view.backgroundColor = kMarketBackground;
    // 添加导航视图
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.topView.backgroundColor = ClearColor;
    [self.view addSubview:self.topView];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"D_SearchHover@2x" ofType:@"png"];
    UIImage *imageSize=[UIImage imageWithContentsOfFile:path];
    UIImage *btBg = [UIImage imageNamed:@"D_Search.png"];
    UIImage *btBgHover = [UIImage imageNamed:@"D_SearchHover.png"];
    self.searchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.topView.frame.size.width-imageSize.size.width-10,
                                                                   (self.topView.frame.size.height-imageSize.size.height)/2,
                                                                   imageSize.size.width,
                                                                   imageSize.size.height)];
    [self.searchButton setImage:btBg forState:UIControlStateNormal];
    [self.searchButton setImage:btBgHover forState:UIControlStateHighlighted];
    [self.searchButton addTarget:self action:@selector(clickSearchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.searchButton];
    
    // 添加刷新旋转图片
    self.transformImage = [[transformImageView alloc] initWithFrame:CGRectMake(240, (self.topView.frame.size.height-btBg.size.height)/2-2, 0, 0)];
    [self.topView addSubview:self.transformImage];
    // 添加一根分割线
    UIView *line = [DCommon drawLineWithSuperView:self.topView position:NO];
    line.backgroundColor = UIColorFromRGB(0x808080);
}

#pragma mark 初始视图
-(void)initTitle:(NSString *)title returnType:(int)returnType{
    [self initBaseViews];
    self.returnType = returnType;
    //标题栏的标题
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, self.topView.frame.size.height)];
    lable.text=title;
    lable.textAlignment = NSTextAlignmentCenter;
    lable.backgroundColor=[UIColor clearColor];
    lable.textColor=UIColorFromRGB(0x000000);
    lable.font = [UIFont fontWithName:kFontName size:18];
    [lable sizeToFit];
    if (lable.frame.size.width>250) {
        lable.frame = CGRectMake(0, 0, 250, lable.frame.size.height);
    }
    lable.center= CGPointMake(self.topView.center.x, self.topView.center.y);
    [self.topView addSubview:lable];
    
    //标题栏的返回键
    UIImage *btn_imge=[[UIImage imageNamed:@"return"] scaleToSize:CGSizeMake(12, 21)];
    UIButton *returnBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, self.topView.frame.origin.y, 42, 44)];
    returnBtn.backgroundColor=[UIColor clearColor];
    [returnBtn setImage:btn_imge forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:returnBtn];
    [returnBtn setTag:100];
    
    //ios7适配
    if (kDeviceVersion >= 7) {
        CGRect frame=self.topView.frame;
        frame.origin.y+=20;
        self.topView.frame=frame;
        UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width ,20)];
        backView.backgroundColor=kMarketBackground;
        [self.view addSubview:backView];
    }
    
}

#pragma mark 返回主界面
-(void)returnBack{
    switch (self.returnType) {
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 2:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
    
}

#pragma mark 搜索按钮点击事件
-(void)clickSearchButtonAction:(UIButton*)button{
    // 先保存本页面的成果
    SearchStocksViewController *searchView = [[SearchStocksViewController alloc] init];
    UIViewController *c = self;
    if ([c isKindOfClass:[KLineViewController class]]) {
        KLineViewController *kline = (KLineViewController*)c;
        kline.isBack = YES;
        kline = nil;
    }
    [self.navigationController pushViewController:searchView animated:YES];
    searchView = nil;
}


@end
