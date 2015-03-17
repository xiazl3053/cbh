//
//  SettingsViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "SettingsViewController.h"
#import "ProgramsViewController.h"
#import "LoginViewController.h"
#import "MyCollectsViewController.h"
#import "CommonOperation.h"
#import "UserModel.h"
#import "UIImageView+WebCache.h"
#import "HeadSettingViewController.h"
#import "MoreSettinsViewController.h"
#import "PushCenterViewController.h"
#import "ZXButton.h"
#import "ROllLabel.h"
#import "UIImage+ZX.h"

#define kContentViewHeight 295
#define kCancelBtnHeight 49

@interface SettingsViewController (){
    UIView *_contentView;
    UIButton *_logoutBtn;
    UIImageView *_headImageview;//头图
    ROllLabel *_nickNameLable;//昵称
    ROllLabel *_userNameLable;//用户名
    UILabel *_phoneLable;//手机号
    
    BOOL islogin;//是否登录
    BOOL _isFirst;//是否是第一次
}

@end

@implementation SettingsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.main.delegate=self.nc;
    //加载用户信息
    [self loadUserInfo];
}

-(void)viewDidAppear:(BOOL)animated{
    
    if (_isFirst) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame=_contentView.frame;
            frame.origin.y-=kContentViewHeight;
            _contentView.frame=frame;
            
        } completion:^(BOOL finished) {
            
            
        }];
        _isFirst=NO;
    }
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{
    [self removeNotification];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // 取出set中的那个UItouch对象
    UITouch *touch = [touches anyObject];
    // 获取触摸点在_contentView上的位置
    CGPoint point = [touch locationInView:_contentView];
    CGFloat x=point.x;
    CGFloat y=point.y;
    if (0<x<_contentView.frame.size.width&&y>0) {//点击到了_contentview的区域
        NSLog(@"点击_contentView");
        return;
    }
    
    //退出设置
    [self exitSettins];
}



#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    _isFirst=YES;
    
    [self registerNotification];
}

#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    
    //内容视图
    UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height, self.view.frame.size.width, kContentViewHeight)];
    contentView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    [self.view addSubview:contentView];
    _contentView=contentView;
    
    //蒙版view
    UIView *coverView=[[UIView alloc] initWithFrame:contentView.bounds];
    coverView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    CGRect frame1000=coverView.frame;
    frame1000.size.height=kContentViewHeight-160;
    coverView.frame=frame1000;
    [contentView addSubview:coverView];
    
    //分割线
    UIView *line1=[[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentView.frame.size.width, 0.5f)];
    line1.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [contentView addSubview:line1];
    
    
    //头像
    UIImage *head=[UIImage imageNamed:@"settings_head"];
    UIImageView *headImageview=[[UIImageView alloc] initWithFrame:CGRectMake(13, 20, 90, 90)];
    [headImageview setImage:head];
    headImageview.layer.masksToBounds = YES;
//    headImageview.layer.cornerRadius=10;//设置圆角
    headImageview.layer.borderWidth=1;
    headImageview.layer.borderColor=[UIColorFromRGB(0xcccccc) CGColor];
    [contentView addSubview:headImageview];
    headImageview.userInteractionEnabled=YES;
    _headImageview=headImageview;
    // 创建一个手势识别器
    UITapGestureRecognizer *tap=
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [headImageview addGestureRecognizer:tap];
    
    
    //昵称
    UIImage *nickName=[UIImage imageNamed:@"settings_nickName"];
    UIImageView *nickNameImageview=[[UIImageView alloc] initWithFrame:CGRectMake(headImageview.frame.origin.x+headImageview.frame.size.width+13, headImageview.frame.origin.y, 18, 18)];
    [nickNameImageview setImage:nickName];
    [contentView addSubview:nickNameImageview];
    
    ROllLabel *nickNameLable=[ROllLabel rollLabelTitle:@"" color:UIColorFromRGB(0x000000) font:[UIFont fontWithName:kFontName size:13] superView:contentView fram:CGRectMake(nickNameImageview.frame.origin.x+nickNameImageview.frame.size.width+9, nickNameImageview.frame.origin.y+(nickNameImageview.frame.size.height-20)*0.5f, 90, 20)];
    _nickNameLable=nickNameLable;
    
    
    //用户名
    UIImage *userName=[UIImage imageNamed:@"settings_userName"];
    UIImageView *userNameImageview=[[UIImageView alloc] initWithFrame:CGRectMake(nickNameImageview.frame.origin.x, nickNameImageview.frame.origin.y+nickNameImageview.frame.size.height+10, 18, 18)];
    [userNameImageview setImage:userName];
    [contentView addSubview:userNameImageview];
    
    
    ROllLabel *userNameLable=[ROllLabel rollLabelTitle:@"" color:UIColorFromRGB(0x000000) font:[UIFont fontWithName:kFontName size:13] superView:contentView fram:CGRectMake(nickNameLable.frame.origin.x, userNameImageview.frame.origin.y+(userNameImageview.frame.size.height-20)*0.5f, 150, 20)];
    _userNameLable=userNameLable;
    
    
    //注销账号
    UIImage *logout=islogin?[UIImage imageNamed:@"settings_logout"]:[UIImage imageNamed:@"settings_login"];
    CGFloat logWidth=islogin?67.5:89.5;
    CGFloat logHeight=23.5;
    UIButton *logoutBtn=[[UIButton alloc] initWithFrame:CGRectMake(nickNameImageview.frame.origin.x, userNameImageview.frame.origin.y+userNameImageview.frame.size.height+9, logWidth, logHeight*2)];
    logoutBtn.tag=2001;
    [logoutBtn addTarget:self action:@selector(loginOrOut) forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn setImage:logout forState:UIControlStateNormal];
    [logoutBtn setImage:logout forState:UIControlStateHighlighted];
    [contentView addSubview:logoutBtn];
    _logoutBtn=logoutBtn;
    
    
    //手机号
    UIImage *phone=[UIImage imageNamed:@"settings_phone"];
    UIImageView *phoneImageview=[[UIImageView alloc] initWithFrame:CGRectMake(nickNameImageview.frame.origin.x, headImageview.frame.origin.y+(headImageview.frame.size.height-phone.size.height)-5, phone.size.width, phone.size.height)];
    [phoneImageview setImage:phone];
    //[contentView addSubview:phoneImageview];

    UILabel *phoneLable=[[UILabel alloc] initWithFrame:CGRectMake(nickNameLable.frame.origin.x, phoneImageview.frame.origin.y+(phoneImageview.frame.size.height-20)*0.5f, 200, 20)];
    phoneLable.backgroundColor=[UIColor clearColor];
    phoneLable.font=[UIFont fontWithName:kFontName size:13];
    phoneLable.textColor=UIColorFromRGB(0x000000);
    phoneLable.textAlignment=NSTextAlignmentLeft;
    //expbalanceLable.text=@"距离LV100还差20经验";
    //[contentView addSubview:phoneLable];
    _phoneLable=phoneLable;
    // 创建一个手势识别器
    UITapGestureRecognizer *tap2=
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPhoneBind)];
    [tap2 setNumberOfTapsRequired:1];
    [tap2 setNumberOfTouchesRequired:1];
    [phoneLable addGestureRecognizer:tap2];

    //分割线
    UIView *line2=[[UIView alloc] initWithFrame:CGRectMake(0, headImageview.frame.origin.y+headImageview.frame.size.height+25-0.5f,_contentView.frame.size.width, 0.5f)];
    line2.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [contentView addSubview:line2];
    
    
    //加载更多设置
    [self loadMoreSettings:headImageview.frame.origin.y+headImageview.frame.size.height+40];
    
    
    //分割线
    UIView *line3=[[UIView alloc] initWithFrame:CGRectMake(0, _contentView.frame.size.height-kCancelBtnHeight, _contentView.frame.size.width, 0.5)];
    line3.backgroundColor=UIColorFromRGB(0x8d8d8d);
    
    
    //取消按钮
    UIButton *cancelBtn=[[UIButton alloc]  initWithFrame:CGRectMake(0, line3.frame.origin.y, _contentView.frame.size.width, kCancelBtnHeight)];
    cancelBtn.titleLabel.font=[UIFont fontWithName:kFontName size:20];
    [cancelBtn setTitle:@"取     消" forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取     消" forState:UIControlStateHighlighted];
    [cancelBtn setTitleColor:K808080 forState:UIControlStateNormal];
    [cancelBtn setTitleColor:UIColorFromRGB(0xee5909) forState:UIControlStateHighlighted];
    [cancelBtn setBackgroundColor:UIColorFromRGB(0xe1e1e1)];
    cancelBtn.tag=2003;
    [cancelBtn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];

    [contentView addSubview:cancelBtn];
    [contentView addSubview:line3];
    
}



#pragma mark 加载更多设置选项
-(void)loadMoreSettings:(CGFloat)height{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SettingsList" ofType:@"plist"];
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    //NSLog(@"data.count:%i",data.count);
    CGFloat btnWidth=_contentView.frame.size.width/4;
    CGFloat btnHeight=80;
    for (int i=0; i<data.count; i++) {
        NSMutableArray *array=[data objectAtIndex:i];
        UIImage *img=[[UIImage imageNamed:[array objectAtIndex:2]] scaleToSize:CGSizeMake(52, 52)];
        UIImage *img1=[[UIImage imageNamed:[array objectAtIndex:3]] scaleToSize:CGSizeMake(52, 52)];
        ZXButton *btn=[[ZXButton alloc] initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
        btn.tag=[[array objectAtIndex:0] intValue];
        // 设置UIImageView的图片居中
        btn.imageView.contentMode = UIViewContentModeCenter;
        [btn setImage:img forState:UIControlStateNormal];
        [btn setImage:img1 forState:UIControlStateHighlighted];
        [btn setTitle:[array objectAtIndex:1] forState:UIControlStateNormal];
        [btn setTitle:[array objectAtIndex:1] forState:UIControlStateHighlighted];
        // 设置文字居中
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 设置字体大小
        btn.titleLabel.font=[UIFont fontWithName:kFontName size:13];
        //设置字体颜色
        [btn setTitleColor:K808080 forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
        [btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateSelected];
        
        [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame=btn.frame;
        int num=i%4;
        frame.origin.x=num*btnWidth;
        
        frame.origin.y=height+(btnHeight+10)*(i/4);
        btn.frame=frame;
        
        [_contentView addSubview:btn];
        
    }
}


#pragma mark 加载用户信息
-(void)loadUserInfo{
    NSString *token=[[CommonOperation getId] getToken];
    islogin=(token)?YES:NO;
    UIImage *img=islogin?[UIImage imageNamed:@"settings_logout"]:[UIImage imageNamed:@"settings_login"];
    CGFloat logWidth=islogin?67:89.5;
    CGFloat logHeight=23.5;
    CGRect frame=_logoutBtn.frame;
    frame.size.width=logWidth;
    _logoutBtn.frame=frame;
    [_logoutBtn setImage:[img scaleToSize:CGSizeMake(logWidth, logHeight)] forState:UIControlStateNormal];
    [_logoutBtn setImage:[img scaleToSize:CGSizeMake(logWidth, logHeight)] forState:UIControlStateHighlighted];
    if (islogin) {
        UserModel *um=[UserModel um];
        [_headImageview setImageWithURL:[NSURL URLWithString:um.picUrl] placeholderImage:[UIImage imageNamed:@"settings_head"]];
        frame=_nickNameLable.frame;
        [_nickNameLable removeFromSuperview];
        _nickNameLable=[ROllLabel rollLabelTitle:um.nickName color:UIColorFromRGB(0x000000) font:[UIFont fontWithName:kFontName size:13] superView:_contentView fram:frame];
        frame=_userNameLable.frame;
        [_userNameLable removeFromSuperview];
        _userNameLable=[ROllLabel rollLabelTitle:um.userName color:UIColorFromRGB(0x000000) font:[UIFont fontWithName:kFontName size:13] superView:_contentView fram:frame];
        
        if (um.phoneNum.length==11) {
            _phoneLable.text=@"手机已绑定";
            _phoneLable.userInteractionEnabled=NO;
        }else{
            _phoneLable.text=@"手机未绑定";
            _phoneLable.userInteractionEnabled=YES;
        }
        
    }else{
        [_headImageview setImage:[UIImage imageNamed:@"settings_head"]];
        frame=_nickNameLable.frame;
        [_nickNameLable removeFromSuperview];
        _nickNameLable=[ROllLabel rollLabelTitle:@"请登录账号" color:UIColorFromRGB(0x000000) font:[UIFont fontWithName:kFontName size:13] superView:_contentView fram:frame];
        frame=_userNameLable.frame;
        [_userNameLable removeFromSuperview];
        _userNameLable=[ROllLabel rollLabelTitle:@"尚未登录" color:UIColorFromRGB(0x000000) font:[UIFont fontWithName:kFontName size:13] superView:_contentView fram:frame];
        _phoneLable.text=@"登录后可绑定";
        _phoneLable.userInteractionEnabled=NO;
    }
    [_contentView bringSubviewToFront:_logoutBtn];
}


#pragma mark 点击头像
-(void)clickHead{
    //退出应用
    [self exitSettins];
    if (islogin) {//跳转头像设置页
        HeadSettingViewController *hsc=[[HeadSettingViewController alloc] init];
        hsc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
        [self presentViewController:hsc animated:YES completion:nil];
        
    }else{//跳转登陆页
        LoginViewController *lvc=[[LoginViewController alloc] init];
        lvc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
        [self presentViewController:lvc animated:YES completion:nil];
    }
}

#pragma mark 点击手机绑定
-(void)clickPhoneBind{
    [CommonOperation goToBindPhone];
}

#pragma mark 各种按钮的点击事件
-(void)btnclick:(UIButton *)btn{
    //退出应用
    [self exitSettins];
    switch (btn.tag) {
        case 2001://登陆或注销
            [self loginOrOut];
            break;
        case 2002:
            
            break;
        case 2003://退出设置
            
            break;
        case 3001://编辑栏目
            [self programSet];
            break;
        case 3002://我的收藏
            [self myCollect];
            break;
        case 3003://消息推送
            [self pushCenter];
            break;
        case 3006://更多设置
            [self moreSettins];
            break;
        default:
            break;
    }

}

#pragma mark 退出设置
-(void)exitSettins{
    [UIView animateWithDuration:0.3f animations:^{//设置面板退下
        CGRect frame=_contentView.frame;
        frame.origin.y+=kContentViewHeight;
        _contentView.frame=frame;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2f animations:^{//界面渐隐
            self.view.alpha=0;
            
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
        
       
    }];
}

#pragma mark 登陆或注销
-(void)loginOrOut{
    if (islogin) {//注销
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"帐号管理"
                                                        message:@"您确定要退出当前帐号吗？"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:@"取消",nil];
        alert.tag=100;
        [alert show];
        
    }else{//登录
        //[self exitSettins];
        LoginViewController *lvc=[[LoginViewController alloc] init];
        UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:lvc];
        nc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
        [self presentViewController:nc animated:YES completion:nil];
    }
    

}


#pragma mark 点击栏目设置
-(void)programSet{
    ProgramsViewController *pvc=[[ProgramsViewController alloc] init];
    pvc.nc=self.nc;
    UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:pvc];;
    nc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark 点击我的收藏
-(void)myCollect{
    
    MyCollectsViewController *mcv=[[MyCollectsViewController alloc] init];
    UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:mcv];
    mcv.main=self.main;
    nc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark 点击消息中心
-(void)pushCenter{
    PushCenterViewController *pcvc=[[PushCenterViewController alloc] initWithCurrentIndex:0];
    UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:pcvc];
    pcvc.main=self.main;
    nc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
    [self presentViewController:nc animated:YES completion:nil];
}


#pragma mark 点击更多设置
-(void)moreSettins{
    MoreSettinsViewController *msvc=[[MoreSettinsViewController alloc] init];
    msvc.main=self.main;
    UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:msvc];
    nc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
    [self presentViewController:nc animated:YES completion:nil];
}


#pragma mark 通知响应
-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getNotificationHandle:) name:kNotifcationKeyForBindingPhone object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadUserInfo) name:kNotifcationKeyForLogout object:nil];
}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForBindingPhone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForLogout object:nil];
}

#pragma mark 通知处理
-(void)getNotificationHandle:(NSNotification*)notification{
    //跳转绑定手机页
    [CommonOperation goToBindPhone];
}

#pragma mark - ---------------UIAlertView代理方法----------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==100){//注销提醒alert
        switch (buttonIndex) {
            case 0:
                //退出登录
                [[CommonOperation getId] loginout];
                //加载用户信息
                [self loadUserInfo];
                break;
            case 1:

                break;
            default:
                break;
        }
    }
}

@end
