//
//  SessionsViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "SessionsViewController.h"
#import "SWTableViewCell.h"
#import "MaskView.h"
#import "DCommon.h"
#import "ChatDetailViewController.h"
#import "ESessions.h"
#import "ESessionsDB.h"
#import "EMessagesDB.h"
#import "EMessages.h"
#import "EFriends.h"
#import "ERoom.h"
#import "NSDate+Custom.h"
#import "BindingMobileViewController.h"
#import "FriendRequestViewController.h"
#import "XMPPRoomManager.h"
#import "JSBadgeView.h"
#import "SessionInstance.h"
#import "EFriendsAndRoomsOpration.h"
#import "UIImageView+WebCache.h"

#define kSessionCellHeight 58

@interface SessionsViewController ()
{
    UITableView *_tableView;
    NSOperationQueue *_queue;
}

@end

@implementation SessionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParams];
    // 初始化
    [self initViews];
}

-(void)dealloc{
    _tableView = nil;
    [self removeNotification];
    [_queue cancelAllOperations];
    _queue = nil;
    NSLog(@"-----------sessionViewController-----dealloc---");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark ---------------初始化----------------

-(void)initParams{
    [EFriendsAndRoomsOpration instance].FriendsArray;
    [EFriendsAndRoomsOpration instance].RoomsArray;
    _queue = [[NSOperationQueue alloc] init];
    [_queue setMaxConcurrentOperationCount:2];
    [self initNotification];
    [self loadCacheDatas];
}

-(void)initViews{
    //self.view.backgroundColor = UIColorFromRGB(0x00ffff);
    // 初始化表格
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    [self createTableView];
   
}

-(void)createTableView{
    if (!_tableView) {
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat w = self.view.frame.size.width;
        CGFloat h = self.view.frame.size.height - 40*2;
        if (kDeviceVersion>=7) {
            h -= 20;
        }else{
            
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = kSessionCellHeight;
        _tableView.backgroundColor=ClearColor;
        //_tableView.separatorColor = UIColorFromRGB(0xe1e1e1);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (kDeviceVersion>=7) {
            _tableView.separatorInset = UIEdgeInsetsZero;
        }
        [self.view addSubview:_tableView];
    }
}

-(void)createMoreButtonsViewWithIndex:(int)index{
    NSLog(@"%d",index);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    SWTableViewCell *cell = (SWTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath];
    MaskView *mask = [[MaskView alloc] initWithAlpha:0.5];
    mask.sportView.backgroundColor = UIColorFromRGB(0xe1e1e1);
    mask.sportView.tag = index;
    CGFloat h = 44;
    CGFloat y = mask.sportView.frame.size.height - h;
    CGFloat w = mask.sportView.frame.size.width;
    // 取消按钮
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, y, w, h)];
    bt.backgroundColor = UIColorFromRGB(0xe1e1e1);
    [bt setTitle:@"取   消" forState:UIControlStateNormal];
    [bt setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [bt setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateHighlighted];
    [bt addTarget:mask action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    UIView *line = [DCommon drawLineWithSuperView:bt position:YES];
    line.backgroundColor = UIColorFromRGB(0x808080);
    line = nil;
    [mask.sportView addSubview:bt];
    bt = nil;
    //三个按钮
    NSString *unReadTitle = @"标为未读";
    NSString *isTopTitle = @"标为置顶";
    NSString *isShieldTitle = @"屏蔽提示";
    if (index<INSTANCE.SessionArray.count) {
        ESessions *session = [INSTANCE.SessionArray objectAtIndex:index];
        if (session.unReadCount!=0) {
            unReadTitle = @"标为已读";
        }
        if (session.isTop) {
            isTopTitle = @"取消置顶";
        }
        if (session.isShiled) {
            isShieldTitle = @"取消屏蔽";
        }
    }
    NSArray *titles = @[unReadTitle,isTopTitle,isShieldTitle];
    NSArray *imgs = @[@"Chat_WeiDu",@"Chat_ZhiDing",@"Chat_PingBi"];
    CGFloat x = 0;
    w = mask.frame.size.width/titles.count;
    h = 80;
    for (int i=0; i<titles.count; i++) {
        UIImage *bg = [UIImage imageNamed:[imgs objectAtIndex:i]];
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, w, bg.size.height+30)];
        [b setImage:bg forState:UIControlStateNormal];
        if (kDeviceVersion<7) {
            [b setImageEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 19)];
        }else{
            [b setImageEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 0)];
        }
        b.tag = i;
        [b setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [b setTitleColor:kBrownColor forState:UIControlStateNormal];
        [b setTitleColor:kBrownColor forState:UIControlStateHighlighted];
        b.titleEdgeInsets = UIEdgeInsetsMake(b.frame.size.height, -b.frame.size.width/2, 0, 0);
        [b addTarget:self action:@selector(clickMoreButtonWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [mask.sportView addSubview:b];
        b = nil;
        bg = nil;
        x += w;
    }
    [mask show:nil];
    mask.hideFinishBlock = ^{
        [cell hideUtilityButtonsAnimated:YES];
    };
    mask = nil;
    cell = nil;
    titles = nil;
    imgs = nil;
}
#pragma mark 点击 标为未读，置顶，屏蔽消息按钮
-(void)clickMoreButtonWithIndex:(UIButton*)button{
    UIView *superView = [button superview];
    int cellIndex = superView.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    SWTableViewCell *cell = (SWTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath];
    MaskView *mask = (MaskView*)[superView superview];
    mask.hideFinishBlock = ^{
        [cell hideUtilityButtonsAnimated:YES];
        NSLog(@"%d-%d",button.tag,cellIndex);
    };
    // 处理按钮事件
    ESessions *session = [INSTANCE.SessionArray objectAtIndex:cellIndex];
    switch (button.tag) {
        case 0:
            // 标为未读
            [self setUnRead:session indexPath:indexPath];
            break;
        case 1:
            // 标为置顶
            [self setIsTop:session];
            break;
        case 2:
            // 标为屏蔽
            [self setShiled:session];
            break;
        default:
            break;
    }
    
    [mask hide];
    mask = nil;
    cell = nil;
    indexPath = nil;
    
}

#pragma mark 标为未读
-(void)setUnRead:(ESessions*)session indexPath:(NSIndexPath *)indexpath{
    if (session.unReadCount==0) {
        [[SessionInstance instance] updateUnReadCount:session count:1];
    }else{
        [[SessionInstance instance] updateUnReadCount:session count:0];
    }
//    NSIndexPath *te=[NSIndexPath indexPathForRow:indexpath.row inSection:indexpath.section];//刷新第一个section的第二行
//    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:te,nil] withRowAnimation:UITableViewRowAnimationMiddle];
}

#pragma mark 标为置顶
-(void)setIsTop:(ESessions*)session{
    [[SessionInstance instance]updateSession:session.jid myJID:session.myJID isShield:NO isTop:YES];
}

-(void)setShiled:(ESessions*)session{
    switch (session.session_type) {
        case EsesionPrivateChat:
        {
            [[EFriendsAndRoomsOpration instance]setFriendShield:session.jid];
            [[XMPPRoomManager instance]setUserPushWithJid:session.jid type:0 isShield:session.isShiled completion:^(NSDictionary *staus, BOOL isSuccess) {
                NSLog(@"-------pushSetting----back--");
            }];
        }break;
        case EsesionPublicGroup:{
            [[EFriendsAndRoomsOpration instance]setRoomShield:session.jid];
            [[XMPPRoomManager instance]setUserPushWithJid:session.jid type:1 isShield:session.isShiled completion:^(NSDictionary *staus, BOOL isSuccess) {
                NSLog(@"-------pushSetting----back--");
            }];
        }break;
            
        default:
            break;
    }
    
    [[SessionInstance instance]updateSession:session.jid myJID:session.myJID isShield:YES isTop:NO];
    
    
//    switch (session.session_type) {
//        case EsesionPrivateChat:
//        {
//            EFriends *friend = [[EFriendsAndRoomsOpration instance]getFriendWithJid:session.jid];
//            if (session.isShiled) {
//                session.isShiled = NO;
//                friend.isShield=NO;
//            }else{
//                session.isShiled = YES;
//                friend.isShield=YES;
//            }
//            [[EFriendsAndRoomsOpration instance]updateFriendWithFriend:friend];
//        }
//            break;
//        case EsesionJoinGroup:{
//            ERoom *ef=[[EFriendsAndRoomsOpration instance]getRoomWithJid:session.jid];
//            if (session.isShiled) {
//                ef.isShield=NO;
//            }else{
//                ef.isShield=YES;
//            }
//            [[EFriendsAndRoomsOpration instance]updateRoomWithRoom:ef];
//        
//        }break;
//        default:
//            break;
//    }
    
}

#pragma mark 通知响应
-(void)initNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeSession:) name:kXMPPSessionChangeNotifaction object:nil];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPSessionChangeNotifaction object:nil];
}
#pragma mark 收到通知
-(void)didChangeSession:(NSNotification*)notification
{
    NSString* type=[notification.userInfo objectForKey:kSessionChangeType];
    if(!notification.userInfo||!type){
        return;
    }
    
    switch ([type intValue]) {
        case kSessionNewMsg:
        case kSessionUpdate:
        {
            NSString* flag=[notification.userInfo objectForKey:@"isExist"];
            ESessions* session=[notification.userInfo objectForKey:@"session"];
            if(!flag||[flag isEqualToString:@"0"])
            {
                [self adjustSessionName:session];
            }
        }
            break;
        default:
            break;
    }
    if(_tableView)
    {
        [_tableView reloadData];
        [self setTableViewbgView];
    }
}

-(void)adjustSessionName:(ESessions*)session
{
    if(!session.sessionName||session.sessionName.length==0)
    {
        switch (session.session_type) {
            case EsesionPrivateChat:
            {
                EFriends *friend = [[EFriendsAndRoomsOpration instance]getFriendWithJid:session.jid];
                session.isShiled=friend.isShield;
                if (friend.userName) {
                    session.sessionName = friend.nickName;
                }else{
                    session.sessionName=[XMPPJID jidWithString:session.jid].user;
                }
            } break;
            case EsesionPublicGroup:{
                ERoom *model=[[EFriendsAndRoomsOpration instance]getRoomWithJid:session.jid];
                if (model.name) {
                    session.sessionName=model.name;
                }else{
                    session.sessionName=[XMPPJID jidWithString:session.jid].user;
                }
                session.isShiled=model.isShield;
            }break;
                
            default:
                break;
        }
    }
}

#pragma mark 初始化数据
-(void)loadCacheDatas{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *sessions = INSTANCE.SessionArray;
        if (sessions.count>0) {
            for (ESessions *item in sessions) {
                [self adjustSessionName:item];
                
                // 内容为最后一条消息
                EMessages *lastMessage = [[EMessagesDB instanceWithFriendJID:item.jid] getLastMessage];
                item.content = lastMessage.content;
                item.message_time = [NSString stringWithFormat:@"%f",lastMessage.time];
                item.nickName = [XMPPJID jidWithString:lastMessage.friends_jid].bare;
                if(item.unReadCount==0)
                {
                    item.unReadCount=[[EMessagesDB instanceWithFriendJID:item.jid] getUnReadCountWithJID:item.myJID];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_tableView){
                [_tableView reloadData];
                [self setTableViewbgView];
            }
        });
    });
}

#pragma mark 表格代理

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kSessionCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return INSTANCE.SessionArray.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 0.00001;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0.00001;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"SessionCell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSMutableArray *rightUtilityButtons = [[NSMutableArray alloc]init];
        [rightUtilityButtons addUtilityButtonWithColor:UIColorFromRGB(0xe1e1e1)
                                                 title:@"更多"];
        [rightUtilityButtons addUtilityButtonWithColor:UIColorFromRGB(0xFF0000)
                                                 title:@"删除"];
        
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:_tableView // Used for row height and selection
                                   leftUtilityButtons:nil
                                  rightUtilityButtons:rightUtilityButtons];
        
        cell.delegate = self;
        
        
//        cell.contentView.backgroundColor = [UIColor whiteColor];
//        cell.backgroundColor = [UIColor whiteColor];
//        UIView *selectView = [[UIView alloc] initWithFrame:cell.contentView.frame];
//        selectView.backgroundColor = UIColorFromRGB(0xe1e1e1);
//        cell.selectedBackgroundView = selectView;
        
        //自定义视图
        //icon
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 40, 40)];
        imgView.tag=100;
        [cell.contentView addSubview:imgView];
    
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, cell.frame.size.width-120, cell.frame.size.height)];
        t.font = [UIFont fontWithName:kFontName size:16];
        t.textColor = [UIColor blackColor];
        t.backgroundColor =ClearColor;
        t.tag=101;
        [cell.contentView addSubview:t];
        t = nil;
        
        
        UILabel *d = [[UILabel alloc] initWithFrame:CGRectMake(60, 22, cell.frame.size.width-110, cell.frame.size.height)];
        d.font = [UIFont fontWithName:kFontName size:14];
        d.textColor = UIColorFromRGB(0x666666);
        d.backgroundColor = ClearColor;
        d.tag=102;
        [cell.contentView addSubview:d];
        d = nil;
        // 时间
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, cell.frame.size.width-10, 20)];
        time.font = [UIFont fontWithName:kFontName size:12];
        time.textColor = UIColorFromRGB(0x666666);
        time.backgroundColor = ClearColor;
        time.textAlignment = NSTextAlignmentRight;
        time.tag=103;
        [cell.contentView addSubview:time];
        time = nil;
        // 屏蔽图标
        UIImage *img = [UIImage imageNamed:@"Chat_PingBi_List"];
        UIImageView *pb = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width-img.size.width-10, 32, img.size.height, img.size.width)];
        pb.image = img;
        pb.tag=104;
        [cell.contentView addSubview:pb];
        pb = nil;
        img = nil;
        
        UIImage *topImage = [UIImage imageNamed:@"Chat_Top_List"];
        UIImageView *top = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width-topImage.size.width*2-15, 32, topImage.size.height, topImage.size.width)];
        top.image = topImage;
        top.tag=105;
        [cell.contentView addSubview:top];
        
        JSBadgeView *circle=[[JSBadgeView alloc]initWithParentView:imgView alignment:JSBadgeViewAlignmentTopRight];
        circle.tag=106;
        
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, kSessionCellHeight-0.5, self.view.frame.size.width, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xe1e1e1);
        [cell addSubview:line];
        line = nil;
    }
    
    ESessions *session = [INSTANCE.SessionArray objectAtIndex:indexPath.row];
    UIImageView *imgView=(UIImageView *)[cell.contentView viewWithTag:100];
    switch (session.session_type) {
        case EsesionPrivateChat:
        {
            EFriends *friend=[[EFriendsAndRoomsOpration instance]getFriendWithJid:session.jid];
            [imgView setImageWithURL:[NSURL URLWithString:friend.iconUrl] placeholderImage:[UIImage imageNamed:@"Chat_normal"]];
        }break;
        case EsesionPublicGroup:{
            ERoom *room=[[EFriendsAndRoomsOpration instance]getRoomWithJid:session.jid];
            [imgView setImageWithURL:[NSURL URLWithString:room.icon] placeholderImage:[UIImage imageNamed:@"room_normal"]];
        }break;
            
        default:
            break;
    }
    
    
    UILabel *t = ( UILabel *)[cell.contentView viewWithTag:101];
    t.text=session.sessionName;
    
    //[t sizeToFit];
    UILabel *d = ( UILabel *)[cell.contentView viewWithTag:102];
    d.text = session.content;
    //[d sizeToFit];
    d = nil;
    if ([session.message_time intValue]>0) {
        UILabel *time = ( UILabel *)[cell.contentView viewWithTag:103];
        time.text = [[NSDate dateWithTimeIntervalSince1970:[session.message_time doubleValue]] dateStringForSessionShow];
        time = nil;
    }else{
        UILabel *time = ( UILabel *)[cell.contentView viewWithTag:103];
        time.text=nil;
    }
    // 是否屏蔽
    UIImageView *pb = ( UIImageView *)[cell.contentView viewWithTag:104];
    if (session.isShiled) {
        pb.hidden = NO;
    }else{
        pb.hidden = YES;
    }
    
    UIImageView *top = ( UIImageView *)[cell.contentView viewWithTag:105];
    if (session.isTop) {
        top.hidden = NO;
    }else{
        top.hidden = YES;
    }
    
    // 是否新消息
    JSBadgeView  *circle = (JSBadgeView *)[cell.contentView viewWithTag:106];
    circle.badgeText=[NSString stringWithFormat:@"%d",session.unReadCount];
    //circle.hidden = session.isRead;
    
//        // 如果屏蔽了，将不再有新消息提示
//        if (session.isShiled) {
//            circle.hidden = YES;
//        }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 进入聊天界面
    ESessions *session = [INSTANCE.SessionArray objectAtIndex:indexPath.row];
    switch (session.session_type) {
        case EsesionPrivateChat:
        {
            EFriends *friend = [[EFriendsAndRoomsOpration instance]getFriendWithJid:session.jid];
            if (!friend) {
                friend=[[EFriends alloc]init];
                friend.jid=session.jid;
            }
            
            ChatDetailViewController *chatDetail = [[ChatDetailViewController alloc] initWithFriend:friend];
            INSTANCE.currentJID=friend.jid;
            if(self.nlm)
            {
                chatDetail.currentModel=self.nlm;
                chatDetail.clearModelBlock=^(){ self.nlm=nil;};
            }
            [self.navigationController pushViewController:chatDetail animated:YES];
            
        }break;
            //好友验证
            //            case 10:
            //            {
            //                EFriends *friend = [[EFriendsDB sharedEFriends] getFriendsWithJID:session.jid];
            //                ChatDetailViewController *chatDetail = [[ChatDetailViewController alloc] initWithFriend:friend];
            //                chatDetail.currentModel=self.nlm;
            //                [self performSelector:@selector(pushToChatDetailView:) withObject:chatDetail afterDelay:0.1];
            //                FriendRequestViewController *request = [[FriendRequestViewController alloc]initWithEFriendJid:session.jid];
            //                [self.navigationController pushViewController:request animated:YES];
            //            }break;
            //群聊
        case EsesionPublicGroup:{
            ChatDetailViewController *chatDetail = [[ChatDetailViewController alloc] initWithRoomWithJID:session.jid roomName:session.sessionName];
            INSTANCE.currentJID=session.jid;
            if(self.nlm)
            {
                chatDetail.currentModel=self.nlm;
                chatDetail.clearModelBlock=^(){ self.nlm=nil;};
            }
            [self.navigationController pushViewController:chatDetail animated:YES];
        }break;
        default:{
            
            
        }break;
    }
    [INSTANCE updateUnReadCount:session count:0];
}

#pragma mark - SWTableViewDelegate

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            
            NSLog(@"More button was pressed");
            NSIndexPath *cellIndexPath = [_tableView indexPathForCell:cell];
            [self createMoreButtonsViewWithIndex:cellIndexPath.row];
            cellIndexPath = nil;
            
            break;
        }
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [_tableView indexPathForCell:cell];
            // 删掉数据库数据
            ESessions *session = [INSTANCE.SessionArray objectAtIndex:cellIndexPath.row];
            NSLog(@"before====%@",INSTANCE.SessionArray);
            [INSTANCE deleteSession:session];
            NSLog(@"after====%@",INSTANCE.SessionArray);
           // [_tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [_tableView reloadData];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark -设置TableView背景
-(void)setTableViewbgView{
    if (INSTANCE.SessionArray.count<=0) {
        NSLog(@"INSTANCE.SessionArray==%@",INSTANCE.SessionArray);
        UIView *bgView=[[UIView alloc]init];
        bgView.backgroundColor=[UIColor clearColor];
        UILabel *l=[[UILabel alloc]initWithFrame:CGRectMake(0, (_tableView.frame.size.height-80)*.5, _tableView.frame.size.width, 80)];
        l.text=@"暂无会话消息";
        l.textColor=[UIColor blackColor];
        l.textAlignment=NSTextAlignmentCenter;
        l.font=[UIFont fontWithName:kFontName size:20];
        [bgView addSubview:l];
        _tableView.backgroundView=bgView;
    }else{
        UIView *bgView=[[UIView alloc]init];
        bgView.backgroundColor=[UIColor clearColor];
        _tableView.backgroundView = bgView;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
