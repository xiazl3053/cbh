//
//  FriendResquestViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-7-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "FriendRequestViewController.h"
#import "PingLunHttpRequest.h"
#import "EFriends.h"
#import "UIImageView+WebCache.h"
#import "XMPPRoomManager.h"

#define KIconWidth 60
#define KMarginLeft 15
#define KMarginRight 15
#define KLocationViewHeight 40
#define KUserViewHeight 85

@interface FriendRequestViewController (){
    
    UIImageView *_icon;
    UILabel *_name;
    UILabel *_location;
    NSString *_friendJid;
    
}
@end

@implementation FriendRequestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithEFriendJid:(NSString *)jid{
    if (self=[super init]) {
        _friendJid=jid;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParams];
    
    [self initViews];
    
    // Do any additional setup after loading the view.
}

-(void)initParams{
    PingLunHttpRequest *quest=[[PingLunHttpRequest alloc]init];
    
    
    
}

-(void)initViews{
    
    UIView *top=[self Title:@"详细资料" returnType:1];
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, top.bottom, self.view.width, 0.5)];
    line.backgroundColor=UIColorFromRGB(0Xffffff);
    
    //user
    UIView *user=[[UIView alloc]initWithFrame:CGRectMake(0, top.bottom, self.view.width, KUserViewHeight)];
    user.backgroundColor=[UIColor clearColor];
    UIImageView *icon=[[UIImageView alloc]initWithFrame:CGRectMake(KMarginLeft, (KUserViewHeight-KIconWidth)*.5, KIconWidth, KIconWidth)];
    icon.image=[UIImage imageNamed:@"Chat_normal"];
    UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(icon.right+KMarginLeft, (KUserViewHeight-30)*.5, 200, 30)];
    name.font=[UIFont fontWithName:kFontName size:15.0];
    name.text=@"好好先生Angel";
    name.adjustsFontSizeToFitWidth=YES;
    name.textColor=[UIColor whiteColor];
    UIButton *remark=[UIButton buttonWithType:UIButtonTypeCustom];
    remark.frame=CGRectMake(self.view.width-KMarginRight-28,(KUserViewHeight-28)*.5, 28, 28);
    [remark setImage:[UIImage imageNamed:@"remark.png"] forState:UIControlStateNormal];
   // [remark addTarget:self action:@selector(remark:) forControlEvents:UIControlEventTouchUpInside];
    
    
   // [user addSubview:remark];
    [user addSubview:icon];
    [user addSubview:name];
    
    
    //local
    UIView *local=[[UIView alloc]initWithFrame:CGRectMake(0, user.bottom, self.view.width, KLocationViewHeight)];
    local.backgroundColor=UIColorFromRGB(0X333333);
    UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(KMarginLeft, (KLocationViewHeight-28)*.5, 20, 28)];
    img.image=[UIImage imageNamed:@"location.png"];
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(img.right+KMarginLeft, (KLocationViewHeight-30)*.5, 200, 30)];
    title.text=@"福建 厦门";
    title.textColor=[UIColor whiteColor];
    [local addSubview:img];
    [local addSubview:title];
    
    //add
    UIButton *accept=[[UIButton alloc]initWithFrame:CGRectMake(KMarginLeft, local.bottom+KMarginLeft, self.view.width-KMarginLeft-KMarginRight, 30)];
    [accept addTarget:self action:@selector(accept:) forControlEvents:UIControlEventTouchUpInside];
    [accept setBackgroundColor:UIColorFromRGB(0xee5909)];
    [accept setTitle:@"同意" forState:UIControlStateNormal];
    accept.titleLabel.textColor=UIColorFromRGB(0xffffff);
    [accept.layer setMasksToBounds:YES];
    [accept.layer setCornerRadius:2.0];
    
    UIButton *reject=[[UIButton alloc]initWithFrame:CGRectMake(KMarginLeft, accept.bottom+KMarginLeft, self.view.width-KMarginLeft-KMarginRight, 30)];
    [reject addTarget:self action:@selector(reject:) forControlEvents:UIControlEventTouchUpInside];
    [reject setBackgroundColor:UIColorFromRGB(0xee5909)];
    [reject setTitle:@"拒绝" forState:UIControlStateNormal];
    reject.titleLabel.textColor=UIColorFromRGB(0xffffff);
    [reject.layer setMasksToBounds:YES];
    [reject.layer setCornerRadius:2.0];

    
    
    [self.view addSubview:line];
    [self.view addSubview:user];
    [self.view addSubview:local];
    [self.view addSubview:accept];
    [self.view addSubview:reject];
    
    
    self.view.backgroundColor=UIColorFromRGB(0x000000);
    
    
}

#pragma mark -添加好友
-(void)accept:(UIButton *)btn{
    NSLog(@"---accept--");
    XMPPRoomManager *manager=[XMPPRoomManager instance];
    [manager acceptPresenceSubscriptionRequestFrom:_friendJid andAccept:YES];
}
#pragma mark -修改备注
-(void)reject:(UIButton *)btn{
    XMPPRoomManager *manager=[XMPPRoomManager instance];
    [manager acceptPresenceSubscriptionRequestFrom:_friendJid andAccept:NO];
    NSLog(@"------reject---");
}

#pragma mark -用户信息回调
-(void)userinfoBackData:(EFriends *)info isSuccess:(BOOL)success{
    if (success) {
        _location.text=info.location;
        _name.text=info.nickName;
        [_icon setImageWithURL:[NSURL URLWithString:info.iconUrl] placeholderImage:[UIImage imageNamed:@"settings_head"]];
    }else{
        NSLog(@"------------获取用户信息失败---------");
    }
    
}

-(void)returnBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
