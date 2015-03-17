//
//  ChatSettingViewController.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ChatSettingViewController.h"
#import "UIImageView+WebCache.h"
#import "ERoom.h"
#import "ESessions.h"
#import "EMessagesDB.h"
#import "ERoomMemberDB.h"
#import "ERoomMemberModel.h"
#import "InviteGroupMemberViewController.h"
#import "Rmbutton.h"
#import "XMPPRoomManager.h"
#import "UserinfoViewController.h"
#import "NoticeOperation.h"
#import "EFriends.h"
#import "CreateSeesionViewController.h"
#import "EFriendsAndRoomsOpration.h"
#import "SessionInstance.h"

#define KMarginLeft 15
#define KMarginRight 15

@interface ChatSettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,RmbuttonDeglegate>
{
    UITableView* mainTable_;
    EFriends* currentF_;
    NSString* roomName_;
    BOOL isRoom;
    UIView *_headView;
}

@property (nonatomic,strong) NSMutableArray *memberList;
@property (nonatomic,strong) UIView *alert;

@end

@implementation ChatSettingViewController

-(id)initWithEFriend:(EFriends *)efriend
{
    if(self=[super init]){
        currentF_=efriend;
    }
    return self;
}

-(id)initWithRoom:(NSString *)roomName
{
    if(self=[super init]){
        roomName_=roomName;
        isRoom=YES;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    currentF_=nil;
}

-(void)getRoomMemberList{
    XMPPRoomManager *manager=[XMPPRoomManager instance];
    [manager getRoomUsersListWithRoomJid:roomName_ completion:^(NSDictionary *list, BOOL isSucess) {
        NSMutableArray *temp=[list objectForKey:@"value"];
        self.memberList=temp;
        [self refreshViewLayout];
    }];
}

-(void)initParams
{
    if (isRoom) {
        [self getRoomMemberList];
    }
}

-(void)initView
{
    UIView* topView=[self Title:@"消息设置" returnType:1];
    UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0,topView.frame.size.height-0.5f, topView.frame.size.width,0.5f)];
    topLine.backgroundColor=K808080;
    [topView addSubview:topLine];
    
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    UIView* headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, isRoom?150:80)];
    
    _headView=headView;
    
    [self initRoomMemberListView];
    
//    if(isRoom)
//    {
//        [self initRoomMemberListView];
//       
//    }else{
//        UIImageView* headImage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
//        [headImage setImageWithURL:[NSURL URLWithString:currentF_.iconUrl] placeholderImage:[UIImage imageNamed:@"user_default.png"]];
//        [headView addSubview:headImage];
//    }
    
    mainTable_=[[UITableView alloc]initWithFrame:CGRectMake(0, topView.height+20, self.view.frame.size.width, self.view.frame.size.height-topView.height-20) style:UITableViewStyleGrouped];
    mainTable_.dataSource=self;
    mainTable_.delegate=self;
    mainTable_.backgroundColor=[UIColor clearColor];
    mainTable_.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mainTable_];
    
    mainTable_.tableHeaderView=headView;
}

- (void)pushSwitchAction:(UISwitch*)sender
{
    NSLog(@"%d",sender.on);
    if (isRoom) {
        ERoom *room=[[EFriendsAndRoomsOpration instance]getRoomWithJid:roomName_];
        [[EFriendsAndRoomsOpration instance]setRoomShield:roomName_];
        [[SessionInstance instance]updateSession:roomName_ myJID:room.myJID isShield:YES isTop:NO];
        [[XMPPRoomManager instance]setUserPushWithJid:roomName_ type:1 isShield:sender.on completion:^(NSDictionary *staus, BOOL isSuccess) {
            NSLog(@"-------pushSetting----back--");
        }];
    }{
        [[EFriendsAndRoomsOpration instance]setFriendShield:currentF_.jid];
        [[SessionInstance instance]updateSession:currentF_.jid myJID:currentF_.myJID isShield:YES isTop:NO];
        [[XMPPRoomManager instance]setUserPushWithJid:currentF_.jid type:0 isShield:sender.on completion:^(NSDictionary *staus, BOOL isSuccess) {
            NSLog(@"-------pushSetting----back--");
        }];
    }
}

- (void)topSwitchAction:(UISwitch*)sender
{
    if (isRoom) {
        ESessions *session=[[SessionInstance instance]getSession:roomName_];
        [[SessionInstance instance]updateSession:session.jid myJID:session.myJID isShield:NO isTop:YES];
    }else{
        ESessions *session=[[SessionInstance instance]getSession:currentF_.jid];
        if (session) {
            [[SessionInstance instance]updateSession:session.jid myJID:session.myJID isShield:NO isTop:YES];
        }else{
            [[SessionInstance instance]updateSession:currentF_.jid myJID:currentF_.myJID isShield:NO isTop:YES];
        }
    }
}

- (void)congfigCell:(UITableViewCell *)cell needSelectedBg:(BOOL)needSelected backgroundImageName:(NSString *)backgroundImageName selectedBackgroundImageName:(NSString *)selectedBackgroundImageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300,44)];
    imageView.image = [[UIImage imageNamed:backgroundImageName] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    cell.backgroundView = imageView;
    
    if (needSelected)
    {
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300,44)];
        imageView2.image = [[UIImage imageNamed:selectedBackgroundImageName] stretchableImageWithLeftCapWidth:20 topCapHeight:0];
        cell.selectedBackgroundView = imageView2;
    }
}

- (void)showActionSheetWithMessage:(NSString *)message aTag:(NSUInteger)tag
{
    UIActionSheet* actionSheet=[[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"清空消息缓存", nil];
    actionSheet.tag = tag;
    for (UIView * obj in actionSheet.subviews) {
        //  NSLog(@"actionSheet.%@",obj);
        obj.backgroundColor= UIColorFromRGB(0x262626);
    }
    actionSheet.backgroundColor=[UIColor blackColor];
    [actionSheet showInView:self.view];
    actionSheet.actionSheetStyle=UIBarStyleDefault;
}

-(void)rmbuttonUserClick:(Rmbutton *)view
{
    if ([view.member.roomJid isEqual:@"addFriendButton"]) {
        if (isRoom) {
            InviteGroupMemberViewController *invite=[[InviteGroupMemberViewController alloc]initWithJid:roomName_ andType:InviteTYPE_ROOM];
            [self presentViewController:invite animated:YES completion:^{
                
            }];
            invite.completionBlock=^(NSString *status){
                if ([status isEqual:@"success"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getRoomMemberList];
                    });
                }
            };
        }else{
            InviteGroupMemberViewController *invite=[[InviteGroupMemberViewController alloc]initWithJid:currentF_.jid andType:InviteTYPE_CHAT];
            invite.nav=self.navigationController;
            [self presentViewController:invite animated:YES completion:^{
                
            }];
            invite.completionBlock=^(NSString *status){
                if ([status isEqual:@"success"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getRoomMemberList];
                    });
                }
            };
        
        }
    }else{
        XMPPRoomManager *manager=[XMPPRoomManager instance];
        XMPPRoomManager * __weak _manager=manager;
        ChatSettingViewController * __weak __self=self;
        
        self.alert=[[NoticeOperation getId]showAlertWithMsg:@"正在加载" imageName:@"ms_version.png" toView:__self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
        
        [_manager getFriendInfomationWithIdentifer:view.member.member.jid completion:^(NSDictionary *model, BOOL isSucess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
                if (isSucess) {
                    EFriends *ef=[model objectForKey:@"value"];
                    if ([[EFriendsAndRoomsOpration instance]isExist:ef]) {
                        ef=[[EFriendsAndRoomsOpration instance]getFriendWithJid:ef.jid];
                        UserinfoViewController *info=[[UserinfoViewController alloc]initWithJid:ef.jid andType:UserInfomationOpen_TYPE_ChatSet];
                        [__self.navigationController pushViewController:info animated:YES];
                    }else{
                        UserinfoViewController *info=[[UserinfoViewController alloc]initWithJid:ef.jid  andType:UserInfomationOpen_TYPE_ChatSet];
                        [__self.navigationController pushViewController:info animated:YES];
                    }
                }else{
                    if ([[model objectForKey:@"error"]isEqual:@"用户不存在"]) {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"该用户不存在" message:@"无法找到该用户,请检查你填写的账号是否正确。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                    }else if ([[model objectForKey:@"error"]isEqual:@"TimeOut"]){
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请求超时" message:@"请检查网络连接是否正常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
                
            });
        }];
        
        NSLog(@"-------open---------");
    }
    
   }

#pragma mark - ------------UITableView 的代理方法----------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return isRoom?3:2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 1;
        case 2:
            return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font=[UIFont boldSystemFontOfSize:17];
    cell.textLabel.textColor=UIColorFromRGB(0x000000);
    cell.backgroundColor=[UIColor whiteColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    int section=indexPath.section;
    int row = indexPath.row;
    NSString* text = nil;
    switch (section) {
        case 0:
            switch (row) {
                case 0:
                {
                    text=@"新消息提醒";
                    UISwitch* pushSwitch=[[UISwitch alloc]init];
                    
                    [pushSwitch addTarget:self action:@selector(pushSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    if (isRoom) {
                        ERoom *room=[[EFriendsAndRoomsOpration instance]getRoomWithJid:roomName_];
                        pushSwitch.on=!room.isShield;
                    }else{
                        EFriends *ef=[[EFriendsAndRoomsOpration instance]getFriendWithJid:currentF_.jid];
                        pushSwitch.on=!ef.isShield;
                    }
                    cell.accessoryView=pushSwitch;
                    cell.imageView.image=[UIImage imageNamed:@"setting_msg.png"];
                }
                    break;
                case 1:
                {
                    text=@"对话置顶";
                    UISwitch* topSwitch=[[UISwitch alloc]init];
                    if (isRoom) {
                        ESessions *session=[[SessionInstance instance]getSession:roomName_];
                        topSwitch.on=session.isTop;
                    }else{
                        ESessions *session=[[SessionInstance instance]getSession:currentF_.jid];
                        topSwitch.on=session.isTop;
                    }
                    [topSwitch addTarget:self action:@selector(topSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView=topSwitch;
                    cell.imageView.image=[UIImage imageNamed:@"setting_top.png"];
                }
                    break;
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 1:
            switch (row) {
                case 0:
                    text=@"清理消息缓存";
                    cell.imageView.image=[UIImage imageNamed:@"setting_clean.png"];
                    break;
            }
            break;
        case 2:{
            cell.backgroundColor=ClearColor;
            UIButton *exit=[[UIButton alloc]init];
            [exit addTarget:self action:@selector(exitRoom:) forControlEvents:UIControlEventTouchUpInside];
            [exit setBackgroundColor:UIColorFromRGB(0xee5909)];
            [exit setTitle:@"删除并退出" forState:UIControlStateNormal];
            exit.titleLabel.textColor=UIColorFromRGB(0xffffff);
            [exit.layer setMasksToBounds:YES];
            [exit.layer setCornerRadius:2.0];
            [exit setFrame:CGRectMake(KMarginLeft, cell.contentView.bottom-43, cell.contentView.width-KMarginLeft-KMarginRight, 43)];
            [cell.contentView addSubview:exit];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        }break;
    }
    if (section!=2) {
        UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 43, 320, 1)];
        line.backgroundColor=UIColorFromRGB(0Xe1e1e1);
        [cell.contentView addSubview:line];
    }
    
    cell.textLabel.text = text;
    
    
    return cell;
}

-(void)exitRoom:(UIButton *)btn{
    //同步服务器
    [[XMPPRoomManager instance]exitRoomWithjid:roomName_ completion:^(NSDictionary *staus, BOOL isSuccess) {
        if (isSuccess) {
            NSString *str=[staus objectForKey:@"value"];
            if ([str isEqual:@"success"]) {
                NSLog(@"exitRoom-----success-----");
                [self popToViewController];
            }else{
                NSLog(@"exitRoom-----fail-----");
            }
        }
    }];
   
    
}

-(void)popToViewController{
    
    //删除session
    [[SessionInstance instance]deleteSession:[[SessionInstance instance]getSession:roomName_]];
    //删除record
    [[EMessagesDB instanceWithFriendJID:roomName_]deleteMessage:roomName_];
    //删除本地好友
    [[EFriendsAndRoomsOpration instance]delRoomWithJid:roomName_];

    UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count -3)];
    [self.navigationController popToViewController:vc animated:YES];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section=indexPath.section;
    int row = indexPath.row;
    switch (section) {
        case 0:
            break;
        case 1:
            switch (row) {
                case 0:
                    [self showActionSheetWithMessage:@"你要清除缓存吗？" aTag:0];
                    break;
            }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ------------UIActionSheetDelegate 的代理方法----------------

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [[EMessagesDB instanceWithFriendJID:isRoom?roomName_:currentF_.jid] deleteAllMessage];
            [[SessionInstance instance] cleanSessionLast:isRoom?roomName_:currentF_.jid];
            if(self.delegate&&[self.delegate respondsToSelector:@selector(cleanAllMessage)])
            {
                [self.delegate cleanAllMessage];
            }
        }
            break;
        default:
            break;
    }
}


-(void)initRoomMemberListView{
    
    if (isRoom) {
        self.memberList=[[ERoomMemberDB sharedInstance]getGroupMemberWithRoomJid:roomName_];
        ERoomMemberModel *model=[[ERoomMemberModel alloc]init];
        EFriends *memeber=[[EFriends alloc]init];
        memeber.iconUrl=@"setting_add.png";
        model.roomJid=@"addFriendButton";
        model.member=memeber;
        [self.memberList addObject:model];
    }else{
        self.memberList=[NSMutableArray array];
        ERoomMemberModel *model=[[ERoomMemberModel alloc]init];
        model.member=currentF_;
        [self.memberList addObject:model];

        //last
        ERoomMemberModel *model2=[[ERoomMemberModel alloc]init];
        EFriends *memeber=[[EFriends alloc]init];
        memeber.iconUrl=@"setting_add.png";
        model2.roomJid=@"addFriendButton";
        model2.member=memeber;
        [self.memberList addObject:model2];
    }
    NSMutableArray *sections=[NSMutableArray array];
    for (int i=0; i<self.memberList.count; i+=4) {
        if (i+4>self.memberList.count) {
            NSRange range=NSMakeRange(i, self.memberList.count-i);
            NSArray *rows=[self.memberList subarrayWithRange:range];
            [sections addObject:rows];
        }else{
            NSRange range=NSMakeRange(i, 4);
            NSArray *rows=[self.memberList subarrayWithRange:range];
            [sections addObject:rows];
        }
    }
    
    _headView.frame=CGRectMake(0, 0, self.view.frame.size.width, 25+sections.count*75);
    UIView* view=[[UIView alloc]initWithFrame:CGRectMake(10, 10, 300,sections.count*75)];
    view.backgroundColor=[UIColor whiteColor];
    //view.layer.cornerRadius=8.0;
    
    for (int i=0; i<sections.count; i++) {
        NSArray *rows=[sections objectAtIndex:i];
        for (int j=0; j<rows.count;j++) {
            ERoomMemberModel *model=[rows objectAtIndex:j];
            Rmbutton* addButton=[[Rmbutton alloc]initWithFrame:CGRectMake(j*75, i*75, 75, 75)];
            addButton.delegate=self;
            [addButton setViewContentWithRomm:model];
            addButton.member=model;
            [view addSubview:addButton];
        }
    }
    [_headView addSubview:view];
}

-(void)refreshViewLayout{
    for (UIView *obj in _headView.subviews) {
        [obj removeFromSuperview];
    }
    [self initRoomMemberListView];
    mainTable_.tableHeaderView=_headView;
}

@end
