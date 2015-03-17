//
//  UserinfoAndSettingViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-8-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "UserinfoViewController.h"
#import "EFriends.h"
#import "ChatDetailViewController.h"
#import "CommonOperation.h"
#import "ESessionsDB.h"
#import "ESessions.h"
#import "EMessagesDB.h"
#import "XMPPRoomManager.h"
#import "EFriendsAndRoomsOpration.h"
#import "SessionInstance.h"
#import "XMPPServer.h"
#import "SessionInstance.h"

#define KIconWidth 60
#define KMarginLeft 15
#define KMarginRight 15
#define KLocationViewHeight 40
#define KUserViewHeight 85

@interface UserinfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{

    UIImageView *_icon;
    UILabel *_name;
    UILabel *_location;
    EFriends *_efriends;
    UserInfomationOpenType _type;
    UIView *_headView;
    UITableView *mainTable_;
    UIView *_topView;
    UILabel *_nickName;
    NSString *_jid;
    BOOL _isFriend;
}

@property (nonatomic,strong) UIView *alert;

@end

@implementation UserinfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithEFriends:(EFriends *)info andType:(UserInfomationOpenType)type{
    if (self=[super init]) {
        _efriends=info;
        _type=type;
        //_isFriend=[[EFriendsAndRoomsOpration instance]isFriend:info];
    }
    return self;
    
}

-(id)initWithJid:(NSString *)jid andType:(UserInfomationOpenType )type{
    if (self=[super init]) {
        _type=type;
        _jid=jid;
        _efriends=[[EFriendsAndRoomsOpration instance]getFriendWithJid:jid];
        _isFriend=_efriends.isFriend;
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParams];
    [self initViews];
    [self initTableView];
    
}

-(void)initParams{
    if (!_isFriend) {
        [[XMPPRoomManager instance]getFriendInfomationWithIdentifer:_jid completion:^(NSDictionary *model, BOOL isSucess) {
            if (isSucess) {
                EFriends *frend=[model objectForKey:@"value"];
                frend.isFriend=_efriends.isFriend;
                frend.isShield=_efriends.isShield;
                frend.isTop=_efriends.isTop;
                [[EFriendsAndRoomsOpration instance]updateFriendWithFriend:frend];
                _efriends=frend;
                [self refreshView];
            }
        }];
    }
}
-(void)refreshView{
    [_icon setImageWithURL:[NSURL URLWithString:_efriends.iconUrl] placeholderImage:[UIImage imageNamed:@"Chat_normal"]];
    _name.text=_efriends.userName;
    if (_efriends.nickName) {
        _nickName.text=_efriends.nickName;
    }else{
        _nickName.text=_efriends.userName;
    }
}


-(void)initViews{
    
    UIView *top=[self Title:@"详细资料" returnType:1];
    _topView=top;
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, top.bottom, self.view.width, 0.5)];
    line.backgroundColor=UIColorFromRGB(0Xffffff);
    
    //user
    UIView *user=[[UIView alloc]initWithFrame:CGRectMake(0, top.bottom, self.view.width, KUserViewHeight)];
    user.backgroundColor=[UIColor clearColor];
    UIImageView *icon=[[UIImageView alloc]initWithFrame:CGRectMake(KMarginLeft, (KUserViewHeight-KIconWidth)*.5, KIconWidth, KIconWidth)];
    [icon setImageWithURL:[NSURL URLWithString:_efriends.iconUrl] placeholderImage:[UIImage imageNamed:@"Chat_normal"]];

    UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(icon.right+KMarginLeft, 15, 150, 30)];
    name.font=[UIFont fontWithName:kFontName size:15.0];
    if (_efriends) {
        name.text=[NSString stringWithFormat:@"%@",[[_efriends.userName componentsSeparatedByString:@"@"] objectAtIndex:0]];
    }else{
     name.text=[NSString stringWithFormat:@"%@",[[_jid componentsSeparatedByString:@"@"] objectAtIndex:0]];
    }
    name.adjustsFontSizeToFitWidth=YES;
    name.textColor=[UIColor blackColor];
    
    UILabel *notice=[[UILabel alloc]initWithFrame:CGRectMake(icon.right+KMarginLeft, 15+(KUserViewHeight-30)*.5,40, 30)];
    notice.font=[UIFont fontWithName:kFontName size:14.0];
    notice.text=@"昵称:";
    notice.textColor=[UIColor blackColor];
    
    UILabel *nickName=[[UILabel alloc]initWithFrame:CGRectMake(icon.right+KMarginLeft+35, 15+(KUserViewHeight-30)*.5, 150, 30)];
    nickName.font=[UIFont fontWithName:kFontName size:14.0];

    if (_efriends) {
        nickName.text=_efriends.nickName;
    }else{
        nickName.text=[NSString stringWithFormat:@"%@",[[_jid componentsSeparatedByString:@"@"] objectAtIndex:0]];
    }
    
    nickName.adjustsFontSizeToFitWidth=YES;
    nickName.textColor=[UIColor blackColor];
    
    UIButton *remark=[UIButton buttonWithType:UIButtonTypeCustom];
    remark.frame=CGRectMake(self.view.width-KMarginRight-28,(KUserViewHeight-28)*.5, 28, 28);
    [remark setImage:[UIImage imageNamed:@"remark.png"] forState:UIControlStateNormal];
    [remark addTarget:self action:@selector(remark:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (_efriends.isFriend) {
        [user addSubview:remark];
    }
    [user addSubview:icon];
    [user addSubview:name];
    [user addSubview:notice];
    [user addSubview:nickName];
    
    _nickName=nickName;
    _name=name;
    _icon=icon;
    
    
    //local
    UIView *local=[[UIView alloc]initWithFrame:CGRectMake(0, user.bottom, self.view.width, KLocationViewHeight)];
    local.backgroundColor=UIColorFromRGB(0Xe1e1e1);
    UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(KMarginLeft, (KLocationViewHeight-28)*.5, 20, 28)];
    img.image=[UIImage imageNamed:@"location.png"];
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(img.right+KMarginLeft, (KLocationViewHeight-30)*.5, 200, 30)];
    title.text=@"福建 厦门";
    title.textColor=[UIColor blackColor];
    [local addSubview:img];
    [local addSubview:title];
    
    
    
    
    
    [self.view addSubview:line];
    [self.view addSubview:user];
    // [self.view addSubview:local];
   // [self.view addSubview:add];
    
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    _headView=user;
}

-(void)initTableView{
    
    mainTable_=[[UITableView alloc]initWithFrame:CGRectMake(0, _topView.bottom, self.view.frame.size.width, self.view.frame.size.height-_topView.height-20) style:UITableViewStyleGrouped];
    mainTable_.dataSource=self;
    mainTable_.delegate=self;
    mainTable_.backgroundColor=[UIColor clearColor];
    mainTable_.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mainTable_];
    
    mainTable_.tableHeaderView=_headView;


}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _efriends.isFriend?3:1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _isFriend?2:1;
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
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font=[UIFont boldSystemFontOfSize:17];
    cell.textLabel.textColor=UIColorFromRGB(0x000000);
    cell.backgroundColor=[UIColor whiteColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    int section=indexPath.section;
    int row = indexPath.row;
    NSString* text = nil;
    if (_efriends.isFriend) {
        switch (section) {
            case 0:
                switch (row) {
                    case 0:
                    {
                        text=@"新消息提醒";
                        UISwitch* pushSwitch=[[UISwitch alloc]init];
                        pushSwitch.on=!_efriends.isShield;
                        [pushSwitch addTarget:self action:@selector(pushSwitchAction:) forControlEvents:UIControlEventValueChanged];
                        cell.accessoryView=pushSwitch;
                        cell.imageView.image=[UIImage imageNamed:@"setting_msg.png"];
                    }
                        break;
                    case 1: {
                                           text=@"对话置顶";
                                            UISwitch* topSwitch=[[UISwitch alloc]init];
                                            ESessions *session=[[ESessionsDB instance]getSessionWithJid:_efriends.jid];
                                            topSwitch.on=session.isTop;
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
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                }
                break;
            case 2:{
                //add
                cell.backgroundColor=ClearColor;
                UIButton *add=[[UIButton alloc]init];
                [add addTarget:self action:@selector(popStartChat:) forControlEvents:UIControlEventTouchUpInside];
                [add setBackgroundColor:UIColorFromRGB(0xee5909)];
                [add setTitle:@"开始聊天" forState:UIControlStateNormal];
                add.titleLabel.textColor=UIColorFromRGB(0xffffff);
                [add.layer setMasksToBounds:YES];
                [add.layer setCornerRadius:2.0];
                [add setFrame:CGRectMake(KMarginLeft, KMarginLeft-10, cell.contentView.width-KMarginLeft-KMarginRight, 43)];
                [cell.contentView addSubview:add];
                if (_type==UserInfomationOpen_TYPE_ChatDetail) {
                    add.hidden=YES;
                }
            }break;
        }
        
        if (section!=2) {
            UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 43, 320, 1)];
            line.backgroundColor=UIColorFromRGB(0Xe1e1e1);
            [cell.contentView addSubview:line];
        }
        
    }else{
        //为自己不能添加
        if (![_jid isEqual:KUserJID]) {
            UIButton *add=[[UIButton alloc]init];
            [add addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
            [add setBackgroundColor:UIColorFromRGB(0xee5909)];
            [add setTitle:@"添加到通讯录" forState:UIControlStateNormal];
            add.titleLabel.textColor=UIColorFromRGB(0xffffff);
            [add.layer setMasksToBounds:YES];
            [add.layer setCornerRadius:2.0];
            [add setFrame:CGRectMake(KMarginLeft, cell.contentView.bottom-30, cell.contentView.width-KMarginLeft-KMarginRight, 43)];
            [cell.contentView addSubview:add];
        }
    }
    
    cell.textLabel.text = text;
    
    return cell;
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

#pragma mark -pop
-(void)popStartChat:(UIButton *)btn{
    NSInteger floor = 0;
    switch (_type) {
        case UserInfomationOpen_TYPE_LocalContact:
            floor=1;
            break;
        case UserInfomationOpen_TYPE_Contact:
            floor=2;
            break;
        case UserInfomationOpen_TYPE_AddFriend:
            floor=3;
            break;
        case UserInfomationOpen_TYPE_ChatSet:
            floor=4;
            break;
        default:{
        }
            break;
    }
    UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count -floor)];
    [self.navigationController popToViewController:vc animated:NO];
    ChatDetailViewController *chat=[[ChatDetailViewController alloc]initWithFriend:_efriends];
    UINavigationController *nav=(UINavigationController *)[[CommonOperation getId] getCurrectNavigationController];
    [nav pushViewController:chat animated:YES];
    
}

#pragma mark -添加好友
-(void)addFriend:(UIButton *)btn{
    
    self.alert=[[NoticeOperation getId]showAlertWithMsg:@"添加好友" imageName:@"ms_version.png" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
    
    _efriends.isFriend=YES;
    _efriends.nickName=_nickName.text;
    
    XMPPRoomManager *manager=[XMPPRoomManager instance];
    UserinfoViewController *__weak __self=self;
   // [manager addFriendSubscribe:_efriends.jid];
    NSString *uuid=[[_efriends.jid componentsSeparatedByString:@"@"]objectAtIndex:0];
    [manager addFriend:uuid completion:^(NSDictionary *data, BOOL isSucess) {
        NSLog(@"-----addFriend----sucess---%@",uuid);
        if (isSucess) {
            [[EFriendsAndRoomsOpration instance]insertFriendWithFriend:_efriends];
            [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
            [__self startChat:nil];
        }else{
            NSLog(@"--------addFriend--------fail");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
                [[NoticeOperation getId]showAlertWithMsg:@"添加好友失败" imageName:@"error" toView:__self.view autoDismiss:YES viewUserInteractionEnabled:NO];
            });
        }
    }];
    NSLog(@"------addFriend=%@--------",_efriends.userName);
    
}

-(void)startChat:(UIButton *)btn{
    NSLog(@"-----startChat---");
    int i=_type==UserInfomationOpen_TYPE_ChatSet?4:3;
    UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count -i)];
    [self.navigationController popToViewController:vc animated:NO];
    ChatDetailViewController *chat=[[ChatDetailViewController alloc]initWithFriend:_efriends];
    UINavigationController *nav=(UINavigationController *)[[CommonOperation getId] getCurrectNavigationController];
    [nav pushViewController:chat animated:YES];
}

- (void)pushSwitchAction:(UISwitch*)sender
{
    NSLog(@"%d",sender.on);
    [[SessionInstance instance]updateSession:_efriends.jid myJID:_efriends.myJID isShield:YES isTop:NO];
    [[EFriendsAndRoomsOpration instance]setFriendShield:_efriends.jid];
    [[XMPPRoomManager instance]setUserPushWithJid:_efriends.jid type:0 isShield:sender.on completion:^(NSDictionary *staus, BOOL isSuccess) {
        NSLog(@"-------pushSetting----back--");
    }];
}

- (void)topSwitchAction:(UISwitch*)sender
{
    [[SessionInstance instance]updateSession:_efriends.jid myJID:_efriends.myJID isShield:NO isTop:YES];
    NSLog(@"%d",sender.on);
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

#pragma mark -actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [[EMessagesDB instanceWithFriendJID:_efriends.jid] deleteAllMessage];
        [[SessionInstance instance] cleanSessionLast:_efriends.jid];
    }
    NSLog(@"buttonIndex==%i",buttonIndex);

}

#pragma mark -修改备注
-(void)remark:(UIButton *)btn{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"备注" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    alert.delegate=self;
    UITextField *tf=[alert textFieldAtIndex:0];//获得输入框
    tf.text=_nickName.text;
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        UITextField *tf=[alertView textFieldAtIndex:0];//获得输入框
        if (tf.text.length>=1&&tf.text.length<=7) {
            XMPPRoomManager *manager=[XMPPRoomManager instance];
            [manager setUserNickName:tf.text toUser:_efriends.jid];
            NSString *uuid=[[_efriends.jid componentsSeparatedByString:@"@"]objectAtIndex:0];
            [manager setFriendNickName:tf.text toFrienduuid:uuid completion:^(NSDictionary *data, BOOL isSucess) {
                if (isSucess) {
                    if ([[data objectForKey:@"value"]isEqual:@"success"]) {
                        NSLog(@"-------nickName-------success");
                    }
                }
            }];
            _nickName.text=[NSString stringWithFormat:@"%@",tf.text];
            _efriends.nickName=_nickName.text;
            [[EFriendsAndRoomsOpration instance]updateFriendWithFriend:_efriends];
            [[SessionInstance instance]updateSessionWithFriend:_efriends];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"-----userinfoViewController------dealloc");
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
