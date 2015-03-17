//
//  CreateSeesionViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-6-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CreateSeesionViewController.h"
#import "EFriends.h"
#import "ChineseToPinyin.h"
#import "UnitView.h"
#import "CreateSessionCell.h"
#import "UnitCell.h"
#import "XMPPServer.h"
#import "XMPPRoomManager.h"
#import "NoticeOperation.h"
#import "ESessions.h"
#import "ESessionsDB.h"
#import "EMessages.h"
#import "EMessagesDB.h"
#import "NoticeOperation.h"
#import "ChatDetailViewController.h"
#import "CommonOperation.h"
#import "ERoom.h"
#import "EFriendsAndRoomsOpration.h"

@interface CreateSeesionViewController ()<UnitViewDelegate,UISearchBarDelegate>{

    UIView *_top;
    UnitView *_unitView;


}

@property (nonatomic,strong) NSMutableArray *selectFriends;
@property (nonatomic,strong) UIView *alert;

@end

@implementation CreateSeesionViewController

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
    [self initView];
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
}


-(void)initData{
    
    self.tempA=[[NSMutableArray alloc]init];
    self.xingset=[[NSMutableSet alloc]init];
    self.xingarray=[[NSMutableArray alloc]init];
    self.studic=[[NSMutableDictionary alloc]init];
    self.keyarray=[[NSMutableArray alloc]init];
    self.selectFriends=[NSMutableArray array];
    
     NSArray *friendList=[EFriendsAndRoomsOpration instance].FriendsArray;

    
    //排序
    NSMutableArray *stringsToSort=[NSMutableArray arrayWithArray:friendList];
    [self zhongWenPaiXu:stringsToSort];
    
    self.searchData=[NSMutableArray array];
    for (EFriends *model in friendList) {
        model.pinYin=[[ChineseToPinyin pinyinFromChiniseString:model.nickName]lowercaseString];
        [self.searchData addObject:model];
    }
}

-(void)initTestData{
    
    //Step1:初始化
    EFriends *f1=[[EFriends alloc]init];
    f1.userName=@"电脑";
    f1.iconUrl=@"f001.png";
    EFriends *f2=[[EFriends alloc]init];
    f2.userName=@"显示器";
    f2.iconUrl=@"f002.png";
    EFriends *f3=[[EFriends alloc]init];
    f3.userName=@"你好";
    f3.iconUrl=@"f003.png";
    EFriends *f4=[[EFriends alloc]init];
    f4.userName=@"推特";
    f4.iconUrl=@"f004.png";
    EFriends *f5=[[EFriends alloc]init];
    f5.userName=@"乔布斯";
    f5.iconUrl=@"f005.png";
    EFriends *f6=[[EFriends alloc]init];
    f6.userName=@"再见";
    f6.iconUrl=@"f006.png";
    EFriends *f7=[[EFriends alloc]init];
    f7.userName=@"暑假作业";
    f7.iconUrl=@"f007.png";
    EFriends *f8=[[EFriends alloc]init];
    f8.userName=@"#11";
    f8.iconUrl=@"f008.png";
    EFriends *f9=[[EFriends alloc]init];
    f9.userName=@"TD";
    f9.iconUrl=@"f009.png";
    EFriends *f10=[[EFriends alloc]init];
    f10.userName=@"苹果";
    f10.iconUrl=@"f010.png";
    EFriends *f11=[[EFriends alloc]init];
    f11.userName=@"hong";
    f11.iconUrl=@"f011.png";
    EFriends *f12=[[EFriends alloc]init];
    f12.userName=@"9527";
    f12.iconUrl=@"f012.png";
    EFriends *f13=[[EFriends alloc]init];
    f13.userName=@"t9527";
    f13.iconUrl=@"f013.png";
    
    self.tempA=[[NSMutableArray alloc]init];
    self.xingset=[[NSMutableSet alloc]init];
    self.xingarray=[[NSMutableArray alloc]init];
    self.studic=[[NSMutableDictionary alloc]init];
    self.keyarray=[[NSMutableArray alloc]init];
    
    self.selectFriends=[NSMutableArray array];
    
    NSArray *arr=[NSArray arrayWithObjects:f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,nil];
    
    //排序
    NSMutableArray *stringsToSort=[NSMutableArray arrayWithArray:arr];
    [self zhongWenPaiXu:stringsToSort];
    
    //重组
//    
//    for (EFriends *obj in self.tempA) {
//        obj.pinYin=[[ChineseToPinyin pinyinFromChiniseString:obj.userName]lowercaseString];
//        [self.searchData addObject:obj];
//    }
//    
    //重组
//    self.searchData=[NSMutableArray array];
//    for (EFriends *model in arr) {
//        model.pinYin=[[ChineseToPinyin pinyinFromChiniseString:model.userName]lowercaseString];
//        [self.searchData addObject:model];
//    }
}


-(void)initView{
    //标题栏
    UIView *top=[self Title:@"发起聊天" returnType:1];
    UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0,top.frame.size.height-0.5f, top.frame.size.width,0.5f)];
    topLine.backgroundColor=K808080;
    [top addSubview:topLine];
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    _top=top;
    
    
    CGFloat w = 60;
    CGFloat h = 22;
    CGFloat x = self.view.frame.size.width - 15 - w;
    CGFloat y = (top.frame.size.height - h) / 2;
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [bt setTitle:@"确定" forState:UIControlStateNormal];
    [bt setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
//    [bt setTitleColor:UIColorFromRGB(0xCCCCCC) forState:UIControlStateHighlighted];
    bt.titleLabel.font = [UIFont fontWithName:kFontName size:12];
    bt.backgroundColor = UIColorFromRGB(0xffffff);
    [bt addTarget:self action:@selector(doneFriendsSelect:) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:bt];

}

-(void)initSearchBar{
    
    self.searchBarView=[[UIView alloc]initWithFrame:CGRectMake(0, _top.bottom, 320, 100)];
    self.searchBarView.backgroundColor=UIColorFromRGB(0Xe1e1e1);
    
    self.searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 35)];
    self.searchBar.placeholder=@"搜索用户名 发起聊天";
    self.searchBar.delegate=self;
    
    UIView *v=[self.searchBar.subviews objectAtIndex:0];
    
    for (UIView *next in v.subviews) {
      //  NSLog(@"next=====%@",next);
        if ([next isKindOfClass:NSClassFromString(@"UISearchBarBackground")])  {
            [next removeFromSuperview];
        }
        //        if ([next isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
        //            UITextField *field=(UITextField *)next;
        //            field.textColor=[UIColor redColor];
        //        }
    }
    
    
    
    self.searchDisplayVC=[[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    [self.searchDisplayVC setDelegate:self];
    [self.searchDisplayVC setSearchResultsDataSource:self];
    [self.searchDisplayVC setSearchResultsDelegate:self];
    [self.searchBarView addSubview:self.searchBar];
    
    UnitView *unitView = [[UnitView alloc] initWithFrame:CGRectMake(0, self.searchBar.bottom, self.view.frame.size.width, 57)];
    unitView.delegate=self;
    unitView.backgroundColor=ClearColor;
    [self.searchBarView addSubview:unitView];
    _unitView=unitView;
    
    UIView *topLine=[[UIView alloc]initWithFrame:CGRectMake(0, self.searchBar.bottom+1, self.view.frame.size.width, 0.5)];
    topLine.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.searchBarView addSubview:topLine];
    
    UIView *bottomLine=[[UIView alloc]initWithFrame:CGRectMake(0, self.searchBar.bottom+55, self.view.frame.size.width, 0.5)];
    bottomLine.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.searchBarView addSubview:bottomLine];
    
    [self.view addSubview:self.searchBarView];
    
}

-(void)initTableView{
    UIScreen *screen=[UIApplication sharedApplication].keyWindow.screen;
    CGFloat h = screen.bounds.size.height - 20-44-100;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBarView.bottom-54, 320, h+45) style:UITableViewStylePlain];
    self.tableView.backgroundColor =UIColorFromRGB(0xf0f0f0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (kDeviceVersion>=7.0) {
        //_tableView.sectionIndexBackgroundColor=UIColorFromRGB(0X333333);
        self.tableView.sectionIndexBackgroundColor=[UIColor clearColor];
    }
    self.tableView.sectionIndexColor=[UIColor whiteColor];
    self.tableView.rowHeight = KContactCellHeight;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier=@"CreateSeesionCell";
    
    CreateSessionCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell==nil) {
        cell=[[CreateSessionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    if (self.isSearching) {
        EFriends *model=[self.results objectAtIndex:indexPath.row];
        [cell setCellValue:model];
    }else{
        NSString *k=[self.keyarray objectAtIndex:indexPath.section];//通过section在keyarray里拿到相应的key
        NSArray *rowarray=[self.studic objectForKey:k];//通过key在studic中找到（姓）对应的数组
        EFriends *item=((EFriends*)[rowarray objectAtIndex:indexPath.row]);//取出对应的元素
        [cell setCellValue:item];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (!self.isSearching) {
        NSString *k=[self.keyarray objectAtIndex:section];//通过section在keyarray里拿到相应的key
        
        NSArray *rowarray=[self.studic objectForKey:k];//通过key在studic中找到（姓）对应的数组（Student*）
        return rowarray.count;
    }else{
        
        return self.results.count;
    }
}

//返回组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"self.keyarray=%i",[self.keyarray count]);
    return !self.isSearching?[self.keyarray count]:1;//key的个数（姓的个数）就是组的个数
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!self.isSearching) {
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 305, 21)];
        view.backgroundColor=UIColorFromRGB(0Xe1e1e1);
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 305, 21)];
        label.font=[UIFont fontWithName:kFontName size:13];
        label.text=[self.keyarray objectAtIndex:section];
        label.textColor=UIColorFromRGB(0X000000);
        [view addSubview:label];
        //
        //        if (section==0) {
        //            UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,0.3)];
        //            line.backgroundColor=[UIColor grayColor];
        //            [view addSubview:line];
        //        }
        //
        return view;
    }else{
        
        return nil;
    }
    
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return !self.isSearching?self.keyarray:nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return !self.isSearching?21:0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return KContactCellHeight;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSearching) {
        EFriends *item=[self.results objectAtIndex:indexPath.row];
        if (item.isSelect==EFriends_SELECT_STATUS_YES) {
            item.isSelect=EFriends_SELECT_STATUS_NO;
            [_selectFriends removeObject:item];
            for (UnitCell *obj in _unitView.unitList) {
                if (obj.friend.userName==item.userName) {
                    [_unitView unitCellTouched:obj];
                }
            }
        }else{
            for (EFriends *obj in self.tempA) {
                if (obj.userName==item.userName) {
                    obj.isSelect=EFriends_SELECT_STATUS_YES;
                }
            }
            [_selectFriends addObject:item];
           // item.iconUrl=@"settings1";
            [_unitView addNewUnit:item];
        }
        for (EFriends *obj in _selectFriends) {
            NSLog(@"obj===%@",obj.userName);
        }

        [self.searchDisplayVC setActive:NO animated:YES];
        
        NSLog(@"self.searchBar===%@",self.searchBar);
        
    }else{
        NSString *k=[self.keyarray objectAtIndex:indexPath.section];//通过section在keyarray里拿到相应的key
        NSArray *rowarray=[self.studic objectForKey:k];//通过key在studic中找到（姓）对应的数组
        EFriends *item=((EFriends*)[rowarray objectAtIndex:indexPath.row]);//取出对应的元素
        if (item.isSelect==EFriends_SELECT_STATUS_YES) {
            item.isSelect=EFriends_SELECT_STATUS_NO;
            [_selectFriends removeObject:item];
            for (UnitCell *obj in _unitView.unitList) {
                if (obj.friend.userName==item.userName) {
                    [_unitView unitCellTouched:obj];
                }
            }
        }else{
            item.isSelect=EFriends_SELECT_STATUS_YES;
            [_selectFriends addObject:item];
           // item.iconUrl=@"settings1";
            [_unitView addNewUnit:item];
        }
        for (EFriends *obj in _selectFriends) {
            NSLog(@"obj===%@",obj.userName);
        }
        [self.tableView reloadData];
        NSLog(@"------非搜索---------");
    }
    
    if (_selectFriends.count==0) {
        UIScreen *screen=[UIApplication sharedApplication].keyWindow.screen;
        CGFloat h = screen.bounds.size.height - 20-44-100;
        self.tableView.frame= CGRectMake(0, self.searchBarView.bottom-54, 320, h+45);
    }else{
        UIScreen *screen=[UIApplication sharedApplication].keyWindow.screen;
        CGFloat h = screen.bounds.size.height - 20-44-100;
        self.tableView.frame= CGRectMake(0, self.searchBarView.bottom, 320, h);
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"---------searchBarCancelButtonClicked-------");
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if(self.searchDisplayController.searchBar.text.length>0) {
        self.isSearching=YES;
        NSString *strSearchText = self.searchDisplayController.searchBar.text;
        self.results =[NSMutableArray array];
        controller.searchResultsTableView.backgroundColor=[UIColor blackColor];
        controller.searchBar.backgroundColor=UIColorFromRGB(0x333333);
        controller.searchResultsTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        for (EFriends *obj in self.searchData) {
            NSRange range=[obj.nickName rangeOfString:strSearchText];
            BOOL pinyin=[obj.pinYin hasPrefix:strSearchText];
            if (pinyin||(range.length>=1)) {
                [self.results addObject:obj];
            }else{
                NSLog(@"name:---%@------",obj.nickName);
            }
        }
    } else {
        self.isSearching=NO;
    }
    if ([self.tableView isEqual:controller.searchResultsTableView]) {
        NSLog(@"[self.tableView isEqual:controller.searchResultsTableView");
    }
    
    NSLog(@"---------searchDisplayController--------");
    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}


-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    NSLog(@"-------searchBarShouldEndEditing---------");
    return YES;
}


- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    self.isSearching=NO;
    NSLog(@"-------searchDisplayControllerDidEndSearch---------");
     [self.tableView reloadData];
}

-(void)UnitViewUserDellUnit:(UnitCell *)cell{
    NSLog(@"----------UnitViewUserDellUnit---------");
    EFriends *friend=cell.friend;
    friend.isSelect=EFriends_SELECT_STATUS_NO;
    [_selectFriends removeObject:cell.friend];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)doneFriendsSelect:(UIButton *)btn{
    if (_selectFriends.count<=0) {
        return ;
    }
    
    if (_selectFriends.count==1) {
        UINavigationController *nav=(UINavigationController *)[[CommonOperation getId] getCurrectNavigationController];
        [self dismissViewControllerAnimated:YES completion:^{
            ChatDetailViewController *chat=[[ChatDetailViewController alloc]initWithFriend:[_selectFriends objectAtIndex:0]];
            [nav pushViewController:chat animated:YES];
        }];
        return ;
    }
    
    NSLog(@"----------doneFriendsSelect----------");
    NSMutableArray *jids=[NSMutableArray array];
    for (EFriends *obj in _selectFriends) {
        NSLog(@"obj.jid===%@",obj.jid);
        XMPPJID *jid=[XMPPJID jidWithString:obj.jid];
         [jids addObject:jid.bare];
    }
    
    NSMutableArray *userNames=[NSMutableArray array];
    for (EFriends *obj in _selectFriends) {
        NSLog(@"obj.remark===%@",obj.nickName);
        [userNames addObject:obj.nickName];
    }

    
    XMPPRoomManager *manager=[XMPPRoomManager instance];
    XMPPRoomManager * __weak _manager=manager;
    CreateSeesionViewController *__weak __self=self;
    
    self.alert=[[NoticeOperation getId]showAlertWithMsg:@"准备开始聊天" imageName:@"ms_version.png" toView:self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
    
    
    [manager createRoomUser:userNames Completion:^(NSDictionary *roomModel, BOOL isSucess) {
        if (isSucess) {
            NSLog(@"--------createRoomName-------ok");
            ERoom *room=[roomModel objectForKey:@"value"];
            [[EFriendsAndRoomsOpration instance]insertRoomWithRoom:room];
            [_manager addRoomUser:jids andRoomJid:room.jid completion:^(NSDictionary *status, BOOL isSucess) {
                if (isSucess) {
                    NSString *identifier=[status objectForKey:@"value"];
                    if ([identifier isEqual:@"success"]) {
                        NSLog(@"--------joinRoomName-------ok");
                        [__self saveSeessionWithJid:room.jid];
                        __self.alert.tag=100;
                        [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
                        //[__self.navigationController popViewControllerAnimated:YES];
                        [__self dismissViewControllerAnimated:YES completion:^{
                            UINavigationController *v=(UINavigationController *)[[CommonOperation getId]getCurrectNavigationController];
                            [_manager joinRoomJid:room.jid];
                            ChatDetailViewController *chat=[[ChatDetailViewController alloc]initWithRoomWithJID:room.jid roomName:room.name];
                            [v pushViewController:chat animated:YES];
                        }];
                    }else{
                        [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
                        [[NoticeOperation getId]showAlertWithMsg:@"创建群聊失败" imageName:@"error" toView:__self.view autoDismiss:YES viewUserInteractionEnabled:NO];
                        NSLog(@"--------joinRoomName-------error");
                    }
                }else{
                    [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
                    [[NoticeOperation getId]showAlertWithMsg:@"创建群聊失败" imageName:@"error" toView:__self.view autoDismiss:YES viewUserInteractionEnabled:NO];
                    NSLog(@"--------joinRoomName-------error");
                }
            }];
        }else{
            NSLog(@"--------createRoomName--------error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
                [[NoticeOperation getId]showAlertWithMsg:@"创建群聊失败" imageName:@"error" toView:__self.view autoDismiss:YES viewUserInteractionEnabled:NO];
            });
            
        }
    }];
    


    
//    manager.createRoomBlock=^(NSString *jid){
//        NSLog(@"-----createRoomBlock---%@-",jid);
//        [_manager addRoomUser:userNames andRoomJid:jid];
//        _manager.JoinRoomBlock=^(NSString *status){
//            if ([status isEqualToString:@"success"]) {
//                [__self saveSeessionWithJid:jid];
//                __self.alert.tag=100;
//                [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
//                [__self.navigationController popViewControllerAnimated:YES];
//                [__self dismissViewControllerAnimated:NO completion:^{
//                    UINavigationController *v=(UINavigationController *)[[CommonOperation getId]getCurrectNavigationController];
//                    [_manager joinRoomJid:jid];
//                    ChatDetailViewController *chat=[[ChatDetailViewController alloc]initWithRoom:jid];
//                    [v pushViewController:chat animated:YES];
//                }];
//            }
//        };
//    };
}

#pragma mark -存储回话信息
-(void)saveSeessionWithJid:(NSString *)jid{
    
//    NSLog(@"[NSThread currentThread]==%@",[NSThread currentThread]);
//    ESessions *session = [[ESessions alloc] init];
//    session.myJID =KUserJID;
//    session.jid =jid;
//    session.time = [[NSDate date] timeIntervalSince1970];
//    session.isTop = NO;
//    session.unReadCount=0;
//    session.session_type=EsesionJoinGroup;
//    if ([[ESessionsDB instance]isExistFriends:session]) {
//        [[ESessionsDB instance] updateWithSession:session];
//    }else{
//        [[ESessionsDB instance] insertWithSession:session];
//    }
    EMessages *msg=[[EMessages alloc]init];
    msg.guid=[[CommonOperation getId] getUUID];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.messageType = EsesionPublicGroup;
    msg.isRead = YES;
    msg.isSys=YES;
    msg.isGroup=YES;
    msg.isSend=YES;
    msg.content=@"创建群聊成功";
    msg.friends_jid=jid;
    msg.myJID=KUserJID;
    [[EMessagesDB instanceWithFriendJID:jid] insertWithMessage:msg isNotifaction:YES];
}

-(void)returnBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)dealloc{
    self.alert=nil;
    self.selectFriends=nil;
    NSLog(@"--------CreateSeesionViewController----dealloc-----");

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