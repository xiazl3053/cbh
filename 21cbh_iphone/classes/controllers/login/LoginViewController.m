//
//  LoginViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "LoginViewController.h"
#import "CommonOperation.h"
#import <ShareSDK/ShareSDK.h>
#import "RegisterViewController.h"
#import "MBProgressHUD+Add.h"
#import "XinWenHttpMgr.h"
#import "UserModel.h"
#import "NoticeOperation.h"
#import "UIImage+ZX.h"


#define kBtnWidth 142
#define kBtnHeight 43
#define kSTinterval 17

@interface LoginViewController (){
    UIView *_alert;
    BOOL _isBinding;//是否绑定手机
}


@property(assign,nonatomic)LoginInputView *usernameView;
@property(assign,nonatomic)LoginInputView *passwordView;
@property(assign,nonatomic)NSInteger platformId;//平台类型(0-本平台（21世纪网）, 1-腾讯QQ, 2-新浪微博)
@property(copy,nonatomic)NSString *platformUserId;//第三方平台用户ID

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化数据
    [self initParams];
    //初始化布局
    [self initViews];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //键盘退下
    [self keyboardDown];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - --------------以下为自定义方法---------------------
#pragma mark 初始化数据
-(void)initParams{
    self.platformId=0;
    self.platformUserId=@"";
    _isBinding=NO;
}

#pragma mark 初始布局
-(void)initViews{
    //标题栏
    UIView *top=[self Title:@"帐号登陆" returnType:2];
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    //账号
    LoginInputView *usernameView=[[LoginInputView alloc] initWithFrame:CGRectMake(15, top.frame.origin.y+top.frame.size.height+18, 0, 0) normalName:@"username_normal" highlightedName:@"username_highlighted" defaultText:@"请输入用户名" normalColor:UIColorFromRGB(0xd7d7d7)  hightlightedColor:UIColorFromRGB(0xee5909)];
    [usernameView.textFiled setKeyboardType:UIKeyboardTypeAlphabet];
    usernameView.textFiled.returnKeyType=UIReturnKeyNext;
    usernameView.tag=1001;
    usernameView.delegate=self;
    [self.view addSubview:usernameView];
    self.usernameView=usernameView;
    
    //密码
    LoginInputView *passwordView=[[LoginInputView alloc] initWithFrame:CGRectMake(15, usernameView.frame.origin.y+usernameView.frame.size.height+18, 0, 0) normalName:@"password_normal" highlightedName:@"password_highlighted" defaultText:@"请输入密码" normalColor:UIColorFromRGB(0xd7d7d7) hightlightedColor:UIColorFromRGB(0xee5909)];
    [passwordView.textFiled setKeyboardType:UIKeyboardTypeAlphabet];
    passwordView.textFiled.returnKeyType=UIReturnKeyDone;
    passwordView.tag=1002;
    passwordView.delegate=self;
    passwordView.textFiled.secureTextEntry=YES;
    [self.view addSubview:passwordView];
    self.passwordView=passwordView;
    
    
    //登陆按钮
    UIButton *loginBtn=[[UIButton alloc] initWithFrame:CGRectMake(18, passwordView.frame.origin.y+passwordView.frame.size.height+18, kBtnWidth, kBtnHeight)];
    loginBtn.backgroundColor=UIColorFromRGB(0xee5909);
    [loginBtn setTitle:@"登 陆" forState:UIControlStateNormal];
    [loginBtn setTitle:@"登 陆" forState:UIControlStateHighlighted];
    loginBtn.titleLabel.font=[UIFont fontWithName:kFontName size:15];
    loginBtn.titleLabel.textColor=[UIColor whiteColor];
    loginBtn.layer.cornerRadius = 4;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn addTarget:self action:@selector(getLogin) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    
    //快速注册按钮
    UIButton *registerBtn=[[UIButton alloc] initWithFrame:CGRectMake(loginBtn.frame.origin.x+loginBtn.frame.size.width+6, passwordView.frame.origin.y+passwordView.frame.size.height+18, kBtnWidth, kBtnHeight)];
    registerBtn.backgroundColor=UIColorFromRGB(0x28b779);
    [registerBtn setTitle:@"快速注册" forState:UIControlStateNormal];
    [registerBtn setTitle:@"快速注册" forState:UIControlStateHighlighted];
    registerBtn.titleLabel.font=[UIFont fontWithName:kFontName size:15];
    registerBtn.titleLabel.textColor=[UIColor whiteColor];
    registerBtn.layer.cornerRadius = 4;
    registerBtn.layer.masksToBounds = YES;
    [registerBtn addTarget:self action:@selector(GoToRegister) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    //分割线
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-202)*0.5f, loginBtn.frame.origin.y+loginBtn.frame.size.height+33, 202, 0.5)];
    line.backgroundColor=UIColorFromRGB(0x636363);
    [self.view addSubview:line];
    
    //说明文字
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-202)*0.5f, line.frame.origin.y+line.frame.size.height+13, 202, 20)];
    lable.backgroundColor=[UIColor clearColor];
    lable.font=[UIFont fontWithName:kFontName size:11];
    lable.textColor=UIColorFromRGB(0x636363);
    lable.textAlignment=NSTextAlignmentCenter;
    lable.text=@"您还可以用其他平台登陆";
    [self.view addSubview:lable];
    
    
    UIImage *img=[[UIImage imageNamed:@"SN"] scaleToSize:CGSizeMake(60, 60)];
    //新浪微博登陆
    UIButton *snBtn=[[UIButton alloc]  initWithFrame:CGRectMake((self.view.frame.size.width-kSTinterval)*0.5-img.size.width, lable.frame.origin.y+lable.frame.size.height+13, img.size.width, img.size.height)];
    [snBtn setImage:img forState:UIControlStateNormal];
    [snBtn setImage:img forState:UIControlStateHighlighted];
    snBtn.tag=ShareTypeSinaWeibo;
    [snBtn addTarget:self action:@selector(getAuthoUserInfo:) forControlEvents: UIControlEventTouchUpInside];
    //先屏蔽新浪微博登陆
    [self.view addSubview:snBtn];
    //QQ登陆
    img=[[UIImage imageNamed:@"TX"] scaleToSize:CGSizeMake(60, 60)];
    UIButton *txBtn=[[UIButton alloc]  initWithFrame:CGRectMake(snBtn.frame.origin.x+snBtn.frame.size.width+kSTinterval, snBtn.frame.origin.y, img.size.width, img.size.height)];
    //UIButton *txBtn=[[UIButton alloc]  initWithFrame:CGRectMake((self.view.frame.size.width-img.size.width)*0.5, snBtn.frame.origin.y, img.size.width, img.size.height)];
    [txBtn setImage:img forState:UIControlStateNormal];
    [txBtn setImage:img forState:UIControlStateHighlighted];
    txBtn.tag=ShareTypeQQSpace;
    [txBtn addTarget:self action:@selector(getAuthoUserInfo:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:txBtn];
    
}


#pragma mark 点击退下键盘
-(void)keyboardDown{
    //点击退下键盘
    [self.usernameView.textFiled resignFirstResponder];
    [self.passwordView.textFiled resignFirstResponder];
}


#pragma mark 获取授权用户的资料
-(void)getAuthoUserInfo:(UIButton *)btn{
    if(![[CommonOperation getId] getNetStatus]){//检查网络状态
        //[MBProgressHUD showError:@"网络不给力" toView:self.view];
        [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"error" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        
        return;
    }
    
    [ShareSDK getUserInfoWithType:btn.tag              //平台类型
                      authOptions:nil                                          //授权选项
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {             //返回回调
                               if (result)
                               {
                                   NSLog(@"成功");
                                   NSLog(@"username:%@",[userInfo nickname]);
                                   NSLog(@"uid:%@",[userInfo uid]);
                                   NSLog(@"profileImage:%@",[userInfo profileImage]);
                                   //第三方授权成功后存储用户信息
                                   [[CommonOperation getId] savedata:[userInfo nickname] andShareType:btn.tag];
                                   switch (btn.tag) {
                                       case ShareTypeSinaWeibo:
                                           [self getLoginSSOWithPlatformId:2 platformUserId:[userInfo uid] platformNickName:[userInfo nickname] platformPicUrl:[userInfo profileImage]];
                                           break;
                                       case ShareTypeQQSpace:
                                           [self getLoginSSOWithPlatformId:1 platformUserId:[userInfo uid] platformNickName:[userInfo nickname] platformPicUrl:[userInfo profileImage]];
                                           break;
                                       default:
                                           break;
                                   }
                                   
                               }
                               
                               else
                               {
                                   NSLog(@"失败---------%@",error.errorDescription);
                                   [[NoticeOperation getId] showAlertWithMsg:@"登陆异常" imageName:@"alert_tanhao.png" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
                               }
                           }];
}

#pragma mark 跳转注册页点击btn
-(void)GoToRegister{
    [self goToRegisterWithPlatformId:0 platformUserId:@""];
}

#pragma mark 设置注册页的参数
-(void)goToRegisterWithPlatformId:(NSInteger)platformId platformUserId:(NSString *)platformUserId{
    RegisterViewController *rvc=[[RegisterViewController alloc] init];
    rvc.lvc=self;
    rvc.platformId=platformId;
    rvc.platformUserId=platformUserId;
    [self.navigationController pushViewController:rvc animated:YES];
}


#pragma mark 普通登陆
-(void)getLogin{
    NSString *username=self.usernameView.textFiled.text;
    NSString *password=self.passwordView.textFiled.text;
    
    if (!username||username.length<1) {
        //[MBProgressHUD showError:@"用户名不能为空" toView:self.view];
        [[NoticeOperation getId] showAlertWithMsg:@"用户名不能为空" imageName:@"error" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    if (!password||password.length<1) {
        //[MBProgressHUD showError:@"密码不能为空" toView:self.view];
        [[NoticeOperation getId] showAlertWithMsg:@"密码不能为空" imageName:@"error" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        return;
    }
    
    XinWenHttpMgr *hmg=[[XinWenHttpMgr alloc] init];
    hmg.hh.lvc=self;
    [hmg loginWithUserName:username passWord:password];
    
    //[MBProgressHUD showMessag:@"登陆中..." toView:self.view];
    _alert=[[NoticeOperation getId] showAlertWithMsg:@"登陆中..." imageName:@"D_Refresh" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
}

#pragma mark 普通登陆后的处理
-(void)getLoginHandleWithMsg:(NSString *)msg error:(NSInteger)error{
    UserModel *um=[UserModel um];
    NSLog(@"um.nickName:%@",um.nickName);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token=[defaults objectForKey:@"token"];
    NSLog(@"token:%@",token);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        switch (error) {
            case 0:
                //[MBProgressHUD showSuccess:@"登录成功" toView:self.view];
                [[NoticeOperation getId] hideAlertView:_alert fromView:self.view msg:@"登陆成功" imageName:@"alert_savephoto_success"];
                //发登陆成功的通知
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotifcationKeyForLogin
                                                                   object:nil
                                                                 userInfo:nil];
                //登录成功后返回主界面
                [self itemReturnBack];
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

#pragma mark sso登录
-(void)getLoginSSOWithPlatformId:(NSInteger)platformId platformUserId:(NSString *)platformUserId platformNickName:(NSString *)platformNickName platformPicUrl:(NSString *)platformPicUrl{
    self.platformId=platformId;
    self.platformUserId=platformUserId;
    XinWenHttpMgr *hmg=[[XinWenHttpMgr alloc] init];
    hmg.hh.lvc=self;
    [hmg loginSSOwithPlatformId:[NSString stringWithFormat:@"%i",platformId] platformUserId:platformUserId platformNickName:platformNickName platformPicUrl:platformPicUrl];
    
    //[MBProgressHUD showMessag:@"登陆中..." toView:self.view];
    _alert=[[NoticeOperation getId] showAlertWithMsg:@"登陆中..." imageName:@"D_Refresh" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
}


#pragma mark sso登录后的处理
-(void)getLoginSSOHandleWithMsg:(NSString *)msg error:(NSInteger)error isFirst:(NSInteger)isFirst{
    UserModel *um=[UserModel um];
    NSLog(@"um.nickName:%@",um.nickName);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token=[defaults objectForKey:@"token"];
    NSLog(@"token:%@",token);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        switch (error) {
            case 0:
                //[MBProgressHUD showSuccess:@"登录成功" toView:self.view];
                [[NoticeOperation getId] hideAlertView:_alert fromView:self.view msg:@"登陆成功" imageName:@"alert_savephoto_success"];
                //发登陆成功的通知
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotifcationKeyForLogin
                                                                   object:nil
                                                                 userInfo:nil];
                
                if (isFirst==1) {
                    _isBinding=YES;
                }
                
                //登录成功后返回主界面
                [self itemReturnBack];
                break;
            case 2:
                //[MBProgressHUD showError:msg toView:self.view];
                [[NoticeOperation getId] hideAlertView:_alert fromView:self.view msg:msg imageName:@"error"];
                break;
            case 4://跳转到注册页
                [self goToRegisterWithPlatformId:self.platformId platformUserId:self.platformUserId];
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
            [self dismissViewControllerAnimated:YES completion:^{
                if (_isBinding) {
                    //发送绑定手机
                    //[CommonOperation goToBindPhone];
                }
            }];
        });
    });
}

#pragma mark - -----------------------LoginInputViewDelegate的代理方法---------------------
-(void)clickReturn:(LoginInputView *)loginInputView{
    switch (loginInputView.tag) {
        case 1001://点击用户名的return
            [self.passwordView.textFiled becomeFirstResponder];
            break;
        case 1002://点击密码的return
            
            
            break;
        default:
            break;
    }
}

@end
