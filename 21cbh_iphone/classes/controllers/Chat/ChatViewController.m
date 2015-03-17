//
//  ChatViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ChatViewController.h"
#import "XMPPServer.h"
#import "DCommon.h"
#import "SessionsViewController.h"
#import "ContactsViewController.h"
#import "KxMenu.h"
#import "AddFriendsViewController.h"
#import "CreateSeesionViewController.h"
#import "BindingMobileViewController.h"
#import "CommonOperation.h"
#import "CreateSeesionViewController.h"
#import "SessionInstance.h"

@interface ChatViewController ()
{
    UIView *_contentView;//内容区
    NSMutableArray *_controllers;//临时存放控制器
    UIButton *_startChatButton;
    UIButton *_addFriendButton;
    int _currentIndex;
    UILabel *_title;
    UIView *_topBar;
    UIView *_indicate;
}

@end

@implementation ChatViewController


-(id)initWithModel:(NewListModel *)nlm{
    if (self=[super init]) {
        _nlm=nlm;
    }
    
    return self;
}


- (void)viewDidLoad
{
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
    //注册通知
    [self registerNotification];

    [[Frontia getStatistics]pageviewStartWithName:@"聊天--模块"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[Frontia getStatistics]pageviewEndWithName:@"聊天--模块"];
    //移除通知
    [self removeNotification];
    _contentView = nil;
    
    for (UIViewController *o in _controllers) {
        [o.view removeFromSuperview];
    }
    
    [_controllers removeAllObjects];
    _startChatButton = nil;
    _addFriendButton = nil;
    _title=nil;
    _topBar=nil;
    NSLog(@"------chatViewController----dealloc------");
}

#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    // 连接XMPP服务器并验证
    [[XMPPServer sharedServer] connect];
    _controllers=[NSMutableArray array];
    
    SessionsViewController *session=[[SessionsViewController alloc] init];
    session.nlm=self.nlm;
    [self addChildViewController:session];
    [_controllers addObject:session];
    
    ContactsViewController *contacts=[[ContactsViewController alloc] init];
    contacts.nlm=self.nlm;
    [self addChildViewController:contacts];
    [_controllers addObject:contacts];
    
    [INSTANCE getAddressBook];
}


#pragma mark 注册通知
-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xmppStreamConnectStateChange:) name:kXMPPStreamConnectStateChangeNotiction object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeSession:) name:kXMPPSessionChangeNotifaction object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(returnBack) name:kNotifcationKeyForLogout object:nil];
}


#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPStreamConnectStateChangeNotiction object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPSessionChangeNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForLogout object:nil];
}



-(void)xmppStreamConnectStateChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    NSLog(@"dic=%@,state=%i",dic,[[dic objectForKey:@"state"]integerValue]);
    switch ([[dic objectForKey:@"state"]integerValue]) {
        case XMPPStreamStateConnected:{
            _title.text=@"我的私信";
        }break;
        case XMPPStreamStateDisConnect:{
            _title.text=@"我的私信(未连接)";
        } break;
            
        default:
            break;
    }
}

#pragma mark 收到通知
-(void)didChangeSession:(NSNotification*)notification{
    if ([INSTANCE totalUnReadCount]>0) {
        //显示未读消息数
        [_indicate removeFromSuperview];
        _indicate=[[NoticeOperation getId] showChatNumViewWithPoint:CGPointMake(_topBar.frame.size.width*0.5-10, 10) superView:_topBar msg:@" "];
        _indicate.hidden=NO;
    }else{
        _indicate.hidden=YES;
    }
}

#pragma mark 初始化视图
-(void)initView{
    //标题栏
    UIView *top=[self Title:@"我的私信" returnType:1];
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    // 发起聊天
    CGFloat w = 60;
    CGFloat h = 22;
    CGFloat x = self.view.frame.size.width - 15 - w;
    CGFloat y = (top.frame.size.height - h) / 2;
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    bt.layer.borderWidth=0.5f;
    bt.layer.borderColor=[UIColorFromRGB(0xcccccc) CGColor];
    [bt setTitle:@"发起聊天" forState:UIControlStateNormal];
    [bt setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
    [bt setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateHighlighted];
    bt.titleLabel.font = [UIFont fontWithName:kFontName size:12];
    bt.backgroundColor = UIColorFromRGB(0xffffff);
    [bt addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:bt];
    _startChatButton = bt;
    bt = nil;
    
    // 添加联系人
    UIImage *addFriendBg = [UIImage imageNamed:@"Chat_AddFriend"];
    x = self.view.frame.size.width - 42-5;
    y = (top.frame.size.height-44)/2;
    UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 42, 44)];
    [add setImage:addFriendBg forState:UIControlStateNormal];
    [add addTarget:self action:@selector(clickAddFriendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:add];
    add.hidden = YES;
    _addFriendButton = add;
    add = nil;
    
    NSArray *array=@[@"消息",@"联系人"];
    TopBar *topBar=[[TopBar alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.frame.size.width, 40) array:array btnTexNormalColor:UIColorFromRGB(0x000000) btnTextSelectedColor:UIColorFromRGB(0xe86e25)];
    [self.view addSubview:topBar];
    topBar.delegate=self;
    _topBar=topBar;
    topBar.backgroundColor=UIColorFromRGB(0xe1e1e1);
    topBar.line.backgroundColor=UIColorFromRGB(0xe86e25);
    
    _contentView=[[UIView alloc] initWithFrame:CGRectMake(0, topBar.frame.origin.y+topBar.frame.size.height, self.view.frame.size.width, KScreenSize.height-top.frame.size.height-topBar.frame.size.height-20)];
    _contentView.backgroundColor = ClearColor;
    [self.view addSubview:_contentView];
    
    
    if (_currentIndex>1) {
        _currentIndex=1;
    }else if(_currentIndex<0){
        _currentIndex=0;
    }
    
    topBar.currentIndex=_currentIndex;
}



- (void)showMenu:(UIButton *)sender
{
//    NSArray *menuItems =
//    @[
//      
//      [KxMenuItem menuItem:@"单人聊天"
//                     image:[UIImage imageNamed:@"Chat_SingleChat"]
//                    target:self
//                    action:@selector(pushMenuItem:)],
//      
//      [KxMenuItem menuItem:@"群组聊天"
//                     image:[UIImage imageNamed:@"Chat_GroupChat"]
//                    target:self
//                    action:@selector(pushMenuItem:)],
//      ];
//    
//    KxMenuItem *first = menuItems[0];
//    first.foreColor = UIColorFromRGB(0xFFFFFF);
//    first.alignment = NSTextAlignmentCenter;
//    KxMenuItem *second = menuItems[1];
//    second.foreColor = UIColorFromRGB(0xFFFFFF);
//    second.alignment = NSTextAlignmentCenter;
//    CGRect frame = sender.frame;
//    if (kDeviceVersion>=7) {
//        frame.origin.y = frame.origin.y + frame.size.height+2;
//    }else{
//        frame.origin.y = frame.origin.y + 2;
//    }
//    
//    [KxMenu setTintColor:UIColorFromRGB(0x464646)];
//    [KxMenu setTitleFont:[UIFont fontWithName:kFontName size:14]];
//    
//    [KxMenu showMenuInView:self.view
//                  fromRect:frame
//                 menuItems:menuItems];
    CreateSeesionViewController *create=[[CreateSeesionViewController alloc]init];
    [self presentViewController:create animated:YES completion:nil];
    
}

- (void) pushMenuItem:(id)sender
{
    CreateSeesionViewController *create=[[CreateSeesionViewController alloc]init];
    [self presentViewController:create animated:YES completion:nil];
    //[self.navigationController pushViewController:create animated:YES];
    NSLog(@"%@", sender);
}

-(void)clickAddFriendButtonAction:(UIButton*)sender{
    AddFriendsViewController *addFriendController = [[AddFriendsViewController alloc] init];
    [self.navigationController pushViewController:addFriendController animated:YES];
    addFriendController = nil;
}

#pragma mark - -----------------TopBar的代理方法------------------
-(void)topBarclickBtn:(UIButton *)btn{
    NSLog(@"topBar的btn.tag==%i",btn.tag);
    [_contentView removeAllSubviews];
    UIViewController *uc=[_controllers objectAtIndex:btn.tag];
    UIView *view=uc.view;
    view.frame=_contentView.bounds;
    [_contentView addSubview:view];
    if (btn.tag==0) {
        _startChatButton.hidden = NO;
        _addFriendButton.hidden = YES;
    }else{
        _startChatButton.hidden = YES;
        _addFriendButton.hidden = NO;
    }
}


@end
