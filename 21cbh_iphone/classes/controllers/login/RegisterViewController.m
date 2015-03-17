//
//  RegisterBtnViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "RegisterViewController.h"
#import "CommonOperation.h"
#import "MBProgressHUD+Add.h"
#import "XinWenHttpMgr.h"
#import "NoticeOperation.h"
#import "UserModel.h"

@interface RegisterViewController (){
    UIScrollView *_scroll;
    
    LoginInputView *_usernameView;
    LoginInputView *_nickNameView;
    LoginInputView *_mailView;
    LoginInputView *_passwordView1;
    LoginInputView *_passwordView2;
    
    UIView *_alert;
    
    BOOL _isBinding;//是否绑定手机
}


@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化数据
    [self initParams];
    //初始化布局
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //键盘退下
    [self keyboardDown];
}

#pragma mark - --------------以下为自定义方法---------------------
#pragma mark 初始化数据
-(void)initParams{
    _isBinding=NO;
}

#pragma mark 初始布局
-(void)initViews{
    //标题栏
    UIView *top=[self Title:@"快速注册" returnType:1];
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    //滚动视图
    UIScrollView *scroll=[[UIScrollView alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-top.frame.size.height)];
    CGSize size=scroll.contentSize;
    size.height=self.view.frame.size.height+100;
    scroll.contentSize=size;
    [self.view addSubview:scroll];
    scroll.backgroundColor=[UIColor clearColor];
    _scroll=scroll;
    
    //用户账号
    LoginInputView *usernameView=[[LoginInputView alloc] initWithFrame:CGRectMake(15, 18, 0, 0) normalName:@"" highlightedName:@"" defaultText:@"用户账号" normalColor:UIColorFromRGB(0xd7d7d7) hightlightedColor:UIColorFromRGB(0x28b779)];
    [scroll addSubview:usernameView];
    _usernameView=usernameView;
    usernameView.textFiled.returnKeyType=UIReturnKeyNext;
    usernameView.tag=1001;
    usernameView.delegate=self;
    
    //用户昵称
    LoginInputView *nickNameView=[[LoginInputView alloc] initWithFrame:CGRectMake(15, usernameView.frame.origin.y+usernameView.frame.size.height+18, 0, 0) normalName:@"" highlightedName:@"" defaultText:@"用户昵称" normalColor:UIColorFromRGB(0xd7d7d7) hightlightedColor:UIColorFromRGB(0x28b779)];
    [scroll addSubview:nickNameView];
    _nickNameView=nickNameView;
    nickNameView.textFiled.returnKeyType=UIReturnKeyNext;
    nickNameView.tag=1002;
    nickNameView.delegate=self;
    
    //注册邮箱
    LoginInputView *mailView=[[LoginInputView alloc] initWithFrame:CGRectMake(15, nickNameView.frame.origin.y+nickNameView.frame.size.height+18, 0, 0) normalName:@"" highlightedName:@"" defaultText:@"注册邮箱" normalColor:UIColorFromRGB(0xd7d7d7) hightlightedColor:UIColorFromRGB(0x28b779)];
    [scroll addSubview:mailView];
    _mailView=mailView;
    mailView.textFiled.returnKeyType=UIReturnKeyNext;
    mailView.tag=1003;
    mailView.delegate=self;

    //登陆密码
    LoginInputView *passwordView1=[[LoginInputView alloc] initWithFrame:CGRectMake(15, mailView.frame.origin.y+mailView.frame.size.height+18, 0, 0) normalName:@"" highlightedName:@"" defaultText:@"登陆密码" normalColor:UIColorFromRGB(0xd7d7d7) hightlightedColor:UIColorFromRGB(0x28b779)];
    [scroll addSubview:passwordView1];
    _passwordView1=passwordView1;
    passwordView1.textFiled.returnKeyType=UIReturnKeyNext;
    passwordView1.textFiled.secureTextEntry=YES;
    passwordView1.tag=1004;
    passwordView1.delegate=self;
    
    //确认密码
    LoginInputView *passwordView2=[[LoginInputView alloc] initWithFrame:CGRectMake(15, passwordView1.frame.origin.y+passwordView1.frame.size.height+18, 0, 0) normalName:@"" highlightedName:@"" defaultText:@"确认密码" normalColor:UIColorFromRGB(0xd7d7d7) hightlightedColor:UIColorFromRGB(0x28b779)];
    [scroll addSubview:passwordView2];
    _passwordView2=passwordView2;
    passwordView2.textFiled.returnKeyType=UIReturnKeyDone;
    passwordView2.textFiled.secureTextEntry=YES;
    passwordView2.tag=1005;
    passwordView2.delegate=self;
    
    //注册按钮
    UIButton *registerBtn=[[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-290)*0.5f, passwordView2.frame.origin.y+passwordView2.frame.size.height+18, 290, 43)];
    registerBtn.backgroundColor=UIColorFromRGB(0x28b779);
    registerBtn.layer.cornerRadius = 2;
    registerBtn.layer.masksToBounds = YES;
    [registerBtn setTitle:@"注 册" forState:UIControlStateNormal];
    [registerBtn setTitle:@"注 册" forState:UIControlStateHighlighted];
    registerBtn.titleLabel.font=[UIFont fontWithName:kFontName size:16];
    [scroll addSubview:registerBtn];
    [registerBtn addTarget:self action:@selector(getRegister) forControlEvents:UIControlEventTouchUpInside];
    
}



#pragma mark 点击退下键盘
-(void)keyboardDown{
    //点击退下键盘
    [_usernameView.textFiled resignFirstResponder];
    [_nickNameView.textFiled resignFirstResponder];
    [_mailView.textFiled resignFirstResponder];
    [_passwordView1.textFiled resignFirstResponder];
    [_passwordView2.textFiled resignFirstResponder];
}


#pragma mark 注册
-(void)getRegister{
    NSString *username=_usernameView.textFiled.text;
    NSString *nickName=_nickNameView.textFiled.text;
    NSString *mail=_mailView.textFiled.text;
    NSString *password1=_passwordView1.textFiled.text;
    NSString *password2=_passwordView2.textFiled.text;
    
    if (![[CommonOperation getId] isValidateName:username]) {
        //[MBProgressHUD showError:@"用户名格式不对" toView:self.view];
        [[NoticeOperation getId] showAlertWithMsg:@"用户名格式不对" imageName:@"error" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    if (![[CommonOperation getId] isValidateName:nickName]) {
        //[MBProgressHUD showError:@"昵称格式不对" toView:self.view];
        [[NoticeOperation getId] showAlertWithMsg:@"昵称格式不对" imageName:@"error" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    if (![[CommonOperation getId] isValidateEmail:mail]) {
        //[MBProgressHUD showError:@"邮箱格式不对" toView:self.view];
        [[NoticeOperation getId] showAlertWithMsg:@"邮箱格式不对" imageName:@"error" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    if (![[CommonOperation getId] isValidatePassword:password1]||![[CommonOperation getId] isValidatePassword:password2]) {
        //[MBProgressHUD showError:@"密码格式不对" toView:self.view];
        [[NoticeOperation getId]showAlertWithMsg:@"密码格式不对" imageName:@"error" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    if (![password1 isEqualToString:password2]) {
        //[MBProgressHUD showError:@"两次输入的密码不一致!" toView:self.view];
        [[NoticeOperation getId] showAlertWithMsg:@"两次输入的密码不一致!" imageName:@"error" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    
    
    XinWenHttpMgr *hmg=[[XinWenHttpMgr alloc] init];
    hmg.hh.rvc=self;
    [hmg registerWithUserName:username nickName:nickName email:mail passWord:password1 platformId:[NSString stringWithFormat:@"%i",self.platformId] platformUserId:self.platformUserId];
    //[MBProgressHUD showMessag:@"注册中..." toView:self.view];
    _alert=[[NoticeOperation getId] showAlertWithMsg:@"注册中..." imageName:@"D_Refresh" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
    
}

#pragma mark 注册后的处理
-(void)getRegisterHandleWithMsg:(NSString *)msg error:(NSInteger)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        switch (error) {
            case 0:
            {
                //[MBProgressHUD showSuccess:@"注册成功" toView:self.view];
                [[NoticeOperation getId] hideAlertView:_alert fromView:self.view msg:@"注册成功" imageName:@"alert_savephoto_success"];
                //发登陆成功的通知
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotifcationKeyForLogin
                                                                   object:nil
                                                                 userInfo:nil];
                
                UserModel *um=[UserModel um];
                if (!um.phoneNum||um.phoneNum.length<11) {//需要绑定手机号码
                    _isBinding=YES;
                }
                //返回登录界面
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


#pragma mark 返回
-(void)itemReturnBack{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                if (_isBinding) {
                    //发送绑定手机通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifcationKeyForBindingPhone object:nil userInfo:nil];
                }
            }];
        });
    });
}

#pragma mark - -----------------------LoginInputViewDelegate的代理方法---------------------
-(void)clickReturn:(LoginInputView *)loginInputView{
    switch (loginInputView.tag) {
        case 1001:
            [_nickNameView.textFiled becomeFirstResponder];
            break;
        case 1002:
            [_mailView.textFiled becomeFirstResponder];
            [_scroll setContentOffset:CGPointMake(_scroll.frame.origin.x, _scroll.frame.origin.y+30) animated:YES];

            break;
        case 1003:
            [_passwordView1.textFiled becomeFirstResponder];
            break;
        case 1004:
            [_passwordView2.textFiled becomeFirstResponder];
            [_scroll setContentOffset:CGPointMake(_scroll.frame.origin.x, _scroll.frame.origin.y+120) animated:YES];
            break;
        case 1005:
            //注册
            [self getRegister];
            break;
        default:
            break;
    }
}

-(void)clickTextFiled:(LoginInputView *)loginInputView{
    switch (loginInputView.tag) {
        case 1001:
            break;
        case 1002:
            
            break;
        case 1003:
            [_scroll setContentOffset:CGPointMake(_scroll.frame.origin.x, _scroll.frame.origin.y+30) animated:YES];
            break;
        case 1004:
            [_scroll setContentOffset:CGPointMake(_scroll.frame.origin.x, _scroll.frame.origin.y+80) animated:YES];
            break;
        case 1005:
            [_scroll setContentOffset:CGPointMake(_scroll.frame.origin.x, _scroll.frame.origin.y+120) animated:YES];
            break;
        default:
            break;
    }
}

@end
