//
//  BindingMobileCheckCodeViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-7-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BindingMobileCheckCodeViewController.h"
#import "FMTextView.h"
#import "DCommon.h"
#import "XinWenHttpMgr.h"
#import "UserModel.h"
#import "CommonOperation.h"

#define kTimeOut 120

@interface BindingMobileCheckCodeViewController ()
{
    UIView *_body;
    int _timeOut;
    NSTimer *_timer;
    UIButton *_codeBt;
    int _startTime;
    UIView *_top;
    UITextField *_telTf;//验证码输入框
    UIView *_alert;//提示窗口
    
    NSString *_phoneNum;
}

@end

@implementation BindingMobileCheckCodeViewController

-(id)initWithPhoneNum:(NSString *)phoneNum{
    if (self=[super init]) {
        _phoneNum=phoneNum;
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

-(void)viewWillDisappear:(BOOL)animated{
    [self clearTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self clearTimer];
    [self removeNotification];
}

#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    _timeOut = kTimeOut;
    // 注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self initNotification];
}

#pragma mark 初始化视图
-(void)initView{
    // 标题栏
    UIView *top=[self Title:@"验证手机号" returnType:1];
    
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
    // 输入手机号
    h = 40;
    UITextField *telTf = [[UITextField alloc] initWithFrame:CGRectMake(x, 10, w, h)];
    telTf.backgroundColor = UIColorFromRGB(0xffffff);
    telTf.textColor = UIColorFromRGB(0x000000);
    telTf.placeholder = @"请输入验证码";
    telTf.font = [UIFont fontWithName:kFontName size:14];
    [telTf setValue:UIColorFromRGB(0x808080) forKeyPath:@"_placeholderLabel.textColor"];//修改颜色
    [telTf setValue:telTf.font forKeyPath:@"_placeholderLabel.font"];//修改颜色
    telTf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    telTf.leftViewMode = UITextFieldViewModeAlways;
    telTf.keyboardType = UIKeyboardTypeNumberPad;
    telTf.layer.borderWidth=0.5f;
    telTf.layer.borderColor=[UIColorFromRGB(0xd7d7d7) CGColor];
    [_body addSubview:telTf];
    telTf.tag=100;
    [telTf addTarget:self action:@selector(limitTextlength:) forControlEvents:UIControlEventEditingChanged];
    _telTf=telTf;
    
    // 下一步按钮
    y = telTf.frame.size.height + telTf.frame.origin.y + 15;
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    bt.layer.backgroundColor = kBrownColor.CGColor;
    bt.titleLabel.font = [UIFont fontWithName:kFontName size:16];
    bt.layer.cornerRadius = 3;
    bt.layer.masksToBounds = YES;
    [bt setTitle:@"下一步" forState:UIControlStateNormal];
    [bt setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(clickNextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [bt setBackgroundImage:[DCommon imageWithColor:UIColorFromRGB(0xcd5710) andSize:CGSizeMake(w, h)] forState:UIControlStateHighlighted];
    [_body addSubview:bt];
    
    y = bt.frame.size.height + bt.frame.origin.y+10;
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(x+45, y, w-90, 40)];
    description.backgroundColor = ClearColor;
    description.font = [UIFont fontWithName:kFontName size:12];
    description.text = @"若未收到验证码或验证码已过期";
    description.textColor = UIColorFromRGB(0x888888);
    description.textAlignment = NSTextAlignmentCenter;
    UIView *line = [DCommon drawLineWithSuperView:description position:YES];
    line.backgroundColor = UIColorFromRGB(0x808080);
    line = nil;
    
    [_body addSubview:description];
    
    // 重新获取验证码
    y = description.frame.size.height + description.frame.origin.y ;
    UIButton *btCode = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    btCode.titleLabel.font = [UIFont fontWithName:kFontName size:16];
    btCode.layer.backgroundColor = UIColorFromRGB(0x28b779).CGColor;
    btCode.layer.cornerRadius = 3;
    btCode.layer.masksToBounds = YES;
    [btCode setTitle:@"重新获取验证码" forState:UIControlStateNormal];
    [btCode setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    [btCode addTarget:self action:@selector(clickCodeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [btCode setBackgroundImage:[DCommon imageWithColor:UIColorFromRGB(0x17a165) andSize:CGSizeMake(w, h)] forState:UIControlStateHighlighted];
    [_body addSubview:btCode];
    _codeBt = btCode;
    
    btCode = nil;
    bt = nil;
    description = nil;
    telTf = nil;
    
    [self.view sendSubviewToBack:_body];
    
    //默认进来就计时
    [self startGetCode];
}

#pragma mark 点击下一步
-(void)clickNextButtonAction{
    [self bodyTapAction];
    
    if (!_telTf.text||_telTf.text.length<6) {//检查手机格式
        [[NoticeOperation getId] showAlertWithMsg:@"请输入6位数字的验证码!" imageName:@"alert_tanhao" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    //绑定手机号码
    [self bindPhone];
    
}


#pragma mark 重新获取验证码
-(void)clickCodeButtonAction{
    [self bodyTapAction];
    [self startGetCode];
}

#pragma mark 获取手机验证码
-(void)getPhoneAuthCode{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    [hmgr phoneAuthCodeWithPhoneNum:_phoneNum];
}

#pragma mark 绑定手机号码
-(void)bindPhone{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.bmccvc=self;
    [hmgr bindPhoneWithPhoneNum:_phoneNum authCode:_telTf.text];
    
    _alert=[[NoticeOperation getId] showAlertWithMsg:@"手机号码绑定中..." imageName:@"D_Refresh" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
}

#pragma mark 绑定手机号码的处理
-(void)bindPhoneHandleWithMsg:(NSString *)msg error:(NSInteger)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (error) {
            case 0:
            {
                [[NoticeOperation getId] hideAlertView:_alert fromView:self.view msg:@"手机号码绑定成功!" imageName:@"alert_savephoto_success"];
                //更新用户的本地账号信息
                UserModel *um=[UserModel um];
                um.phoneNum=_phoneNum;
                [CommonOperation writeUmToLoacal:um];
                //返回
                [self itemReturnBack];
            }
                break;
            case 2:
                //[MBProgressHUD showError:msg toView:self.view];
                [[NoticeOperation getId] hideAlertView:_alert fromView:self.view msg:msg imageName:@"error"];
                break;
                
            default:
                break;
        }
        
    });
}


#pragma mark 开始获取验证码
-(void)startGetCode{
    if (!_timer) {
        //获取手机验证码
        [self getPhoneAuthCode];
        
        if (_startTime<=0) {
            _startTime = [[NSDate date] timeIntervalSince1970];
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}
#pragma mark 获取验证码超时
-(void)timerAction{
    int nowTime = [[NSDate date] timeIntervalSince1970];
    _timeOut = kTimeOut - (nowTime - _startTime);
    if (_timeOut<=0) {
        _timeOut = kTimeOut;
        _startTime = 0;
        [self clearTimer];
        NSLog(@"验证码到期");
        [_codeBt setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        // 验证码时间到
        // {.....}
    }else{
        // 按钮小时时间进度
        [_codeBt setTitle:[NSString stringWithFormat:@"%d秒后重新获取",_timeOut] forState:UIControlStateNormal];
    }
}

-(void)clearTimer{
    [_timer invalidate];
    [_timer setFireDate:[NSDate distantFuture]];
    _timer = nil;
}

-(void)bodyTapAction{
    [self.view endEditing:YES];
}


#pragma mark 返回
-(void)itemReturnBack{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}


#pragma mark 键盘通知
-(void)keyboardWillShow:(NSNotification*)notification{

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

#pragma mark 通知响应
-(void)initNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAppActive:) name:kNotifcationKeyForActive object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAppEnterGround:) name:kNotifcationKeyForEnterGround object:nil];
}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForActive object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForEnterGround object:nil];
}

-(void)didAppActive:(NSNotification*)notification{
    if (_timeOut>0 && _timeOut<kTimeOut) {
        [self startGetCode];
    }
    NSLog(@"APP激活");
}
-(void)didAppEnterGround:(NSNotification*)notification{
    NSLog(@"APP进入后台");
    [self clearTimer];
}

#pragma mark - -----------UITextField代理方法和监听方法---------------
#pragma mark 限制输入长度
-(void)limitTextlength:(UITextField *)textField{
    
    switch (textField.tag) {
        case 100:
            if ([textField.text length]>6) {
                
                textField.text=[textField.text substringToIndex:6];
                
            }
            break;
        default:
            break;
    }
}

@end
