//
//  BindingMobileViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-7-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BindingMobileViewController.h"
#import "FMTextView.h"
#import "DCommon.h"
#import "BindingMobileCheckCodeViewController.h"
#import "CommonOperation.h"
#import "NoticeOperation.h"
#import "LoginViewController.h"

@interface BindingMobileViewController ()
{
    UIView *_body;
    UIView *_top;
    UITextField *_telTf;//手机号码输入框
}

@end

@implementation BindingMobileViewController

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
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
}

#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    // 注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 初始化视图
-(void)initView{
    // 标题栏
    UIView *top=[self Title:@"账号绑定" returnType:2];
    _top = top;
   self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    // 内容
    CGFloat x = 0;
    CGFloat y = top.frame.size.height+top.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-top.frame.size.height-top.frame.origin.y;
    _body = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [self.view addSubview:_body];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bodyTapAction)];
    [_body addGestureRecognizer:tap];
    tap = nil;
    // 描述
    x = 15;
    w = w - 2*x;
    FMTextView *description = [[FMTextView alloc] initWithFrame:CGRectMake(x-5, -10, w+8, 100)];
    description.backgroundColor = ClearColor;
    description.font = [UIFont fontWithName:kFontName size:14];
    description.lineHeight = 8;
    description.text = @"绑定手机号后系统将会根据你的手机通讯录匹配好友，以便交流之用。手机号传输与存储均会进行加密处理。";
    description.textColor = UIColorFromRGB(0x888888);
    [description setEditable:NO];
    //[description sizeToFit];
    
    [_body addSubview:description];
    
    // 输入手机号
    y = description.frame.size.height + description.frame.origin.y + 20;
    h = 40;
    UITextField *telTf = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    telTf.backgroundColor = UIColorFromRGB(0xffffff);
    telTf.textColor = UIColorFromRGB(0x000000);
    telTf.placeholder = @"请输入手机号码";
    telTf.keyboardType = UIKeyboardTypeNumberPad;
    telTf.font = [UIFont fontWithName:kFontName size:14];
    [telTf setValue:UIColorFromRGB(0x808080) forKeyPath:@"_placeholderLabel.textColor"];//修改颜色
    [telTf setValue:telTf.font forKeyPath:@"_placeholderLabel.font"];//修改颜色
    telTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    telTf.leftViewMode = UITextFieldViewModeAlways;
    telTf.layer.borderWidth=0.5f;
    telTf.layer.borderColor=[UIColorFromRGB(0xd7d7d7) CGColor];
    [_body addSubview:telTf];
    telTf.tag=100;
    [telTf addTarget:self action:@selector(limitTextlength:) forControlEvents:UIControlEventEditingChanged];
    _telTf=telTf;
    
    // 提交按钮
    y = telTf.frame.size.height + telTf.frame.origin.y + 20;
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    bt.titleLabel.font = [UIFont fontWithName:kFontName size:16];
    bt.layer.backgroundColor = kBrownColor.CGColor;
    bt.layer.cornerRadius = 3;
    bt.layer.masksToBounds = YES;
    [bt setTitle:@"获取验证码" forState:UIControlStateNormal];
    [bt setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    [bt setBackgroundImage:[DCommon imageWithColor:UIColorFromRGB(0xcd5710) andSize:CGSizeMake(w, h)] forState:UIControlStateHighlighted];
    [bt addTarget:self action:@selector(clickButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_body addSubview:bt];
    
    bt = nil;
    description = nil;
    telTf = nil;
    
    [self.view sendSubviewToBack:_body];
}


#pragma mark 点击了获取验证手机号码
-(void)clickButtonAction{
    [self bodyTapAction];
    
    if (!_telTf.text||[_telTf.text isEqual:@""]) {
        [[NoticeOperation getId] showAlertWithMsg:@"手机号码不为空!" imageName:@"alert_tanhao" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    
    if (![[CommonOperation getId] isValidateMobile:_telTf.text]) {//检查手机格式
        [[NoticeOperation getId] showAlertWithMsg:@"输入的手机号码格式不对!" imageName:@"alert_tanhao" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    
    if (![[CommonOperation getId] getNetStatus]) {//检查网络状态
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
        
    BindingMobileCheckCodeViewController *bmcv = [[BindingMobileCheckCodeViewController alloc] initWithPhoneNum:_telTf.text];
    [self.navigationController pushViewController:bmcv animated:YES];
}


-(void)bodyTapAction{
    [self.view endEditing:YES];
}



#pragma mark 键盘通知
-(void)keyboardWillShow:(NSNotification*)notification{
    CGRect rt = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIButton *loginBt = [_body.subviews lastObject];
    CGFloat h = (self.view.frame.size.height-rt.size.height) - (loginBt.frame.origin.y+loginBt.frame.size.height+_body.frame.origin.y);
    if (h<0) {
        CGRect frame = _body.frame;
        frame.origin = CGPointMake(frame.origin.x, h);
        [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            _body.frame = frame;
        } completion:^(BOOL isFinish){}];
    }
    
}

-(void)keyboardWillHide:(NSNotification*)notification{
    CGFloat x = 0;
    CGFloat y = _top.frame.size.height+_top.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-_top.frame.size.height-_top.frame.origin.y;
    CGRect frame = CGRectMake(x, y, w, h);
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        _body.frame = frame;
    } completion:^(BOOL isFinish){}];
    
}

#pragma mark - -----------UITextField代理方法和监听方法---------------
#pragma mark 限制输入长度
-(void)limitTextlength:(UITextField *)textField{
    
    switch (textField.tag) {
        case 100:
            if ([textField.text length]>11) {
                
                textField.text=[textField.text substringToIndex:11];
                
            }
            break;
        default:
            break;
    }
}


@end
