//
//  ContactsViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ContactsViewController.h"
#import "ChatDetailViewController.h"
#import "EFriends.h"
#import "ChineseToPinyin.h"
#import "XMPPServer.h"
#import "ERoomMemberModel.h"
#import "ERoomMemberDB.h"
#import "UIImageView+WebCache.h"
#import "EFriendsAndRoomsOpration.h"
#import "XMPPRoomManager.h"
#import "SessionInstance.h"
#import "UserinfoViewController.h"
#import "EMessagesDB.h"

@interface ContactsViewController (){
}

@end

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNotifcation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)initData{

    self.tempA=[[NSMutableArray alloc]init];
    self.xingset=[[NSMutableSet alloc]init];
    self.xingarray=[[NSMutableArray alloc]init];
    self.studic=[[NSMutableDictionary alloc]init];
    self.keyarray=[[NSMutableArray alloc]init];
    
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

-(void)initNotifcation{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableView) name:kXMPPFriendsChangeNotifaction object:nil];
}

-(void)refreshTableView{
    [self initData];
    [self setTableViewbgView];
    [self.tableView reloadData];
}

-(void)initSearchBar{
    self.searchBarView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    self.searchBarView.backgroundColor=UIColorFromRGB(0Xe1e1e1);
   // self.searchBarView.backgroundColor=[UIColor redColor];
    
    self.searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    self.searchBar.placeholder=@"搜索用户名 发起聊天";
    self.searchBar.delegate=self;
    UIView *v=[self.searchBar.subviews objectAtIndex:0];
    for (UIView *next in v.subviews) {
        //NSLog(@"next=====%@",next);
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
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, self.searchBar.bottom, self.view.frame.size.width, 0.5)];
    line.backgroundColor=UIColorFromRGB(0x636363);

    [self.searchBarView addSubview:self.searchBar];
    [self.searchBarView addSubview:line];
    [self.view addSubview:self.searchBarView];
    
}


-(void)initTableView{
    UIScreen *screen=[UIApplication sharedApplication].keyWindow.screen;
    CGFloat h = screen.bounds.size.height - 44*3-14;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBarView.bottom, 320, h) style:UITableViewStylePlain];
    [self setTableViewbgView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    if (kDeviceVersion>=7.0) {
        //_tableView.sectionIndexBackgroundColor=UIColorFromRGB(0X333333);
        self.tableView.sectionIndexBackgroundColor=[UIColor clearColor];
    }
    self.tableView.sectionIndexColor=[UIColor whiteColor];
    self.tableView.rowHeight = KContactCellHeight;
   // self.tableView.tableHeaderView=self.searchBarView;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return !self.isSearching?self.keyarray:nil;
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
        view.backgroundColor=UIColorFromRGB(0xe1e1e1);
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 305, 21)];
        label.font=[UIFont fontWithName:kFontName size:13];
        label.text=[self.keyarray objectAtIndex:section];
        label.textColor=UIColorFromRGB(0x808080);
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return !self.isSearching?21:0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return KContactCellHeight;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier1 = @"ContactsCell1";
    static NSString *cellIdentifier2 = @"ContactsCell2";
    
    SWTableViewCell *cell=nil;
   
    if (self.isSearching) {
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell==nil) {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier1
                                      containingTableView:self.searchDisplayController.searchResultsTableView // Used for row height and selection
                                       leftUtilityButtons:nil
                                      rightUtilityButtons:nil];
            UIView *selectView = [[UIView alloc] initWithFrame:cell.contentView.frame];
            selectView.backgroundColor = UIColorFromRGB(0xe1e1e1);
            cell.selectedBackgroundView = selectView;
            
            cell.delegate = self;
//            cell.backgroundColor=[UIColor blackColor];
            
            UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 40, 40)];
            imgView.tag=100;
            [cell addSubview:imgView];
            
            
            
            UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(imgView.right+10, 20, 180, 20)];
            name.font=[UIFont fontWithName:kFontName size:17];
            name.textColor=UIColorFromRGB(0x000000);
            name.tag=200;
            [cell addSubview:name];
            
            
            UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, cell.bottom+11, 320, 1)];
            line.backgroundColor=UIColorFromRGB(0Xe1e1e1);
            line.tag=300;
            [cell addSubview:line];

            
        }
    }else{
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
       // [rightUtilityButtons addUtilityButtonWithColor:UIColorFromRGB(0xe1e1e1) title:@"更多"];
        [rightUtilityButtons addUtilityButtonWithColor:UIColorFromRGB(0xe8322b)
                                                 title:@"删除"];
        
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell==nil) {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier2
                                      containingTableView:self.tableView // Used for row height and selection
                                       leftUtilityButtons:nil
                                      rightUtilityButtons:rightUtilityButtons];
            UIView *selectView = [[UIView alloc] initWithFrame:cell.contentView.frame];
            selectView.backgroundColor = UIColorFromRGB(0xe1e1e1);
            cell.selectedBackgroundView = selectView;
            
            cell.delegate = self;
            cell.backgroundColor=[UIColor blackColor];
            
            UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 40, 40)];
            imgView.tag=100;
//            imgView.layer.cornerRadius=5.0;
//            imgView.layer.masksToBounds=YES;
            [cell.contentView addSubview:imgView];
            
            
            
            UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(imgView.right+10, 20, 240, 20)];
            name.font=[UIFont fontWithName:kFontName size:17];
            name.textColor=UIColorFromRGB(0x000000);
            name.tag=200;
            [cell.contentView addSubview:name];
            
            
            UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, cell.bottom+11, 320, 1)];
            line.backgroundColor=UIColorFromRGB(0Xe1e1e1);
            line.tag=300;
            [cell.contentView addSubview:line];
        }
    }
    
    
     
    
    //icon
    UIImageView *imgView=(UIImageView *)[cell viewWithTag:100];
    UILabel *name=(UILabel *)[cell viewWithTag:200];
    
    
    
    imgView.userInteractionEnabled=YES;
    
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfomation:)];
//    tap.numberOfTouchesRequired=1;
//    tap.numberOfTapsRequired=1;
//    [imgView addGestureRecognizer:tap];
    
    if (!self.isSearching) {
        NSString *k=[self.keyarray objectAtIndex:indexPath.section];//通过section在keyarray里拿到相应的key
        NSArray *rowarray=[self.studic objectForKey:k];//通过key在studic中找到（姓）对应的数组
        EFriends *item=((EFriends*)[rowarray objectAtIndex:indexPath.row]);//取出对应的元素
        name.text=item.nickName;
        [imgView setImageWithURL:[NSURL URLWithString:item.iconUrl] placeholderImage:[UIImage imageNamed:@"Chat_normal"]];
    }else{
        EFriends *model=[self.results objectAtIndex:indexPath.row];
        name.text=model.nickName;
        [imgView setImageWithURL:[NSURL URLWithString:model.iconUrl] placeholderImage:[UIImage imageNamed:@"Chat_normal"]];
    }
    
    return cell;
}

#pragma mark - SWTableViewDelegate
- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
       
        case 0:
        {
            // Delete button was pressed
            // *cellIndexPath = [self.tableView indexPathForCell:cell];
            //NSLog(@"cellIndexPath=%@",cellIndexPath);
            //[_data removeObjectAtIndex:cellIndexPath.row];
            NSIndexPath *indexPath= [self getUserClickCellIndexPathWithTapCell:cell];
            EFriends *friend=[self GetEFriendswithIndexPath:indexPath];
           // [[EFriendsDB sharedEFriends]deleteWithFriend:friend];
            //[self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            //同步服务器
            //[[XMPPRoomManager instance]delUserName:friend.jid];
            NSString *uuid=[[friend.jid componentsSeparatedByString:@"@"]objectAtIndex:0];
            [[XMPPRoomManager instance]delFriend:uuid completion:^(NSDictionary *data, BOOL isSucess) {
                
            }];
            //删除本地好友
            [[EFriendsAndRoomsOpration instance]delFriendWithJid:friend.jid];
            //删除session
            ESessions *session=[[SessionInstance instance]getSession:friend.jid];
            [[SessionInstance instance]deleteSession:session];
            //删除聊天信息
            [[EMessagesDB instanceWithFriendJID:friend.jid]deleteAllMessage];
            if ([self.searchDisplayVC isActive]) {
                [self.searchDisplayVC.searchResultsTableView reloadData];
            }else{
                [self.tableView reloadData];
            }
            break;
        }
        case 1:
        {
            NSLog(@"More button was pressed");
            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            [alertTest show];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
            
        default:
            break;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     NSLog(@"deselect.indexpath=%@",indexPath);
//    EFriends *model=[self GetEFriendswithIndexPath:indexPath];
//    ChatDetailViewController *chatDetail =[[ChatDetailViewController alloc] initWithFriend:model];
//    chatDetail.currentModel=self.nlm;
//    [self.navigationController pushViewController:chatDetail animated:YES];
//    [self.searchBar resignFirstResponder];

    [self.searchDisplayVC setActive:NO animated:YES];
    
    EFriends *friend=[self GetEFriendswithIndexPath:indexPath];
   // model=[[EFriendsDB sharedEFriends]getFriendsWithJID:model.jid];
    UserinfoViewController *info=[[UserinfoViewController alloc]initWithJid:friend.jid andType:UserInfomationOpen_TYPE_Contact];
    [self.navigationController pushViewController:info animated:YES];
    INSTANCE.currentJID=friend.jid;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if(self.searchDisplayController.searchBar.text.length>0) {
        self.isSearching=YES;
        NSString *strSearchText = self.searchDisplayController.searchBar.text;
        self.results =[NSMutableArray array];
        controller.searchResultsTableView.backgroundColor=UIColorFromRGB(0xf0f0f0);
        controller.searchBar.backgroundColor=UIColorFromRGB(0xe1e1e1);
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
    }else{
        self.isSearching=NO;
    }
    NSLog(@"---------searchDisplayController--------");
    return YES;
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    self.isSearching=YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    self.isSearching=NO;
    NSLog(@"-------searchDisplayControllerDidEndSearch---------");
    [self.tableView reloadData];
}

#pragma mark -显示用户信息
-(void)showUserInfomation:(UIGestureRecognizer *)tap{
    UIView *superView = tap.view.superview;
    NSIndexPath *indexPath=[self getUserClickCellIndexPathWithTapCell:superView];
    NSLog(@"indexpath=%@",indexPath);
    EFriends *model=[self GetEFriendswithIndexPath:indexPath];
    UserinfoViewController *info=[[UserinfoViewController alloc]initWithEFriends:model andType:UserInfomationOpen_TYPE_AddFriend];
    [self.navigationController pushViewController:info animated:YES];
}

-(NSIndexPath *)getUserClickCellIndexPathWithTapCell:(UIView *)cell{
    UIView *superView =cell;
    UITableViewCell *foundSuperView = nil;
    while (nil != superView && nil == foundSuperView) {
        if ([superView isKindOfClass:[UITableViewCell class]]) {
            foundSuperView = (UITableViewCell *)superView;
        } else {
            superView = superView.superview;
        }
    }
    NSIndexPath *indexPath=nil;
    if ([self.searchDisplayVC isActive]) {
        indexPath=[self.searchDisplayVC.searchResultsTableView indexPathForCell:foundSuperView];
    }else{
        indexPath=[self.tableView indexPathForCell:foundSuperView];
    }
    NSLog(@"indexpath=%@",indexPath);
    return indexPath;
}

#pragma mark -根据indexPath获取EFriends
-(EFriends *)GetEFriendswithIndexPath:(NSIndexPath *)indexPath{
    EFriends *model=nil;
    if (self.isSearching) {
        model=[self.results objectAtIndex:indexPath.row];
    }else{
        NSString *k=[self.keyarray objectAtIndex:indexPath.section];//通过section在keyarray里拿到相应的key
        NSArray *rowarray=[self.studic objectForKey:k];//通过key在studic中找到（姓）对应的数组
        model=((EFriends*)[rowarray objectAtIndex:indexPath.row]);//取出对应的元素
    }
    return model;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark -设置TableView背景
-(void)setTableViewbgView{
    if (self.keyarray.count<=0) {
        NSLog(@"INSTANCE.SessionArray==%@",INSTANCE.SessionArray);
        UIView *bgView=[[UIView alloc]init];
        bgView.backgroundColor=UIColorFromRGB(0xf0f0f0);
        UILabel *l=[[UILabel alloc]initWithFrame:CGRectMake(0, (self.tableView.frame.size.height-80)*.5, self.tableView.frame.size.width, 80)];
        l.text=@"暂无联系人";
        l.textColor=[UIColor blackColor];
        l.textAlignment=NSTextAlignmentCenter;
        l.font=[UIFont fontWithName:kFontName size:20];
        [bgView addSubview:l];
        self.tableView.backgroundView=bgView;
    }else{
        UIView *bgView=[[UIView alloc]init];
        bgView.backgroundColor=UIColorFromRGB(0xf0f0f0);
        self.tableView.backgroundView = bgView;
    }
}

-(void)dealloc{
    NSLog(@"--------contact-------delloc-----------");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kXMPPFriendsChangeNotifaction object:nil];
    self.searchDisplayVC=nil;
    self.searchBar=nil;
    self.searchBarView=nil;
    self.tempA=nil;
    self.xingset=nil;
    self.xingarray=nil;
    self.studic=nil;
    self.keyarray=nil;
    self.tableView=nil;
    self.results=nil;
    self.searchData=nil;

}

@end
