//
//  BaseViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "BaseViewController.h"
#import "UIImage+ZX.h"

@interface BaseViewController (){

}

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
    }else{
        CGRect frame=self.view.frame;
        frame.origin.y-=20;
        self.view.frame=frame;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    //隐藏标题栏
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //self.main.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 初始化top栏和返回按钮
-(UIView *)Title:(NSString *)title returnType:(NSInteger) type{
    self.returnType=type;
    self.view.backgroundColor=kBackgroundcolor;
    
    //标题栏背景
    UIView *top=[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width ,44)];
    //NSLog(@"self.view.frame.size.width:%f",self.view.frame.size.width);
    top.backgroundColor=UIColorFromRGB(0xf0f0f0);
    [self.view addSubview:top];
    
    //标题栏的标题
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, top.frame.size.height)];
    lable.text=title;
    lable.center=top.center;
    lable.textAlignment = NSTextAlignmentCenter;
    lable.backgroundColor=[UIColor clearColor];
    lable.textColor=[UIColor blackColor];
    lable.font = [UIFont fontWithName:kFontName size:18];
    _lable=lable;
    [top addSubview:lable];
    
    //标题栏的返回键
    UIImage *btn_imge=[[UIImage imageNamed:@"return"] scaleToSize:CGSizeMake(12, 21)];
    UIButton *returnBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, top.frame.origin.y, 42, 44)];
    returnBtn.backgroundColor=[UIColor clearColor];
    [returnBtn setImage:btn_imge forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:returnBtn];
    [returnBtn setTag:100];
    _returnBtn=returnBtn;
    
    //ios7适配
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CGRect frame=top.frame;
        frame.origin.y+=20;
        top.frame=frame;
        
        //标题栏顶部背景蒙版
        UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width ,20)];
        backView.backgroundColor=UIColorFromRGB(0x000000);
        [self.view addSubview:backView];
        _backView=backView;
    }
    
    
    //分割线
    UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0,top.frame.size.height-0.5f, self.view.frame.size.width, 0.5f)];
    topLine.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [top addSubview:topLine];
    _topLine=topLine;
    
    
    //默认设置(白色版)
    top.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.backView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.lable.textColor=UIColorFromRGB(0x000000);
        
    return top;
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


@end
