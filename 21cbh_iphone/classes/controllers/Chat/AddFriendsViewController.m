//
//  AddFriendsViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "AddFriendCell.h"
#import <ShareSDK/ShareSDK.h>
#import "LocalContactViewController.h"
#import "FriendRequestViewController.h"
#import "XMPPRoomManager.h"
#import "EFriends.h"
#import "NoticeOperation.h"
#import "XMPPServer.h"
#import "UserinfoViewController.h"
#import "EFriendsAndRoomsOpration.h"
#import "NCMConstant.h"

#define KImgKey @"img"
#define KTitleKey @"title"

@interface AddFriendsViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{

    UISearchBar *_searchBar;
    UIView *_bgView;
    UIView *_top;
    NSArray *_data;

}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *alert;

@end

@implementation AddFriendsViewController

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
    //初始化变量
    [self initParams];
    //初始化视图
    [self initViewS];
}

-(void)initViewS{

    [self initTopView];
    [self initTableViewHeader];
    [self initTableView];

}


-(void)initTableViewHeader{
    UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    bgView.backgroundColor=ClearColor;
    
    UISearchBar *searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    searchBar.placeholder=@"搜索手机号/用户名 添加好友";
    searchBar.delegate=self;
    searchBar.backgroundColor=UIColorFromRGB(0xe1e1e1);
    UIView *v=[searchBar.subviews objectAtIndex:0];
    
    for (UIView *next in v.subviews) {
       // NSLog(@"next=====%@",next);
        if ([next isKindOfClass:NSClassFromString(@"UISearchBarBackground")])  {
            [next removeFromSuperview];
        }
    }
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, bgView.bottom-1, 320, 0.5)];
    line.backgroundColor=UIColorFromRGB(0xe1e1e1);
    
    [bgView addSubview:searchBar];
    [bgView addSubview:line];
    _searchBar=searchBar;
    _bgView=bgView;
}

-(void)initTableView{

    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, _top.bottom, 320, self.view.frame.size.height-_top.bottom) style:UITableViewStyleGrouped];
    _tableView.tableHeaderView=_bgView;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor = ClearColor;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return _data.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSArray *rows=[_data objectAtIndex:section];
    
    return rows.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIndentifier=@"AddFriendCell";
    AddFriendCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell==nil) {
        cell=[[AddFriendCell alloc]init];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UIView *selectView = [[UIView alloc] initWithFrame:cell.contentView.frame];
        selectView.backgroundColor = [UIColor grayColor];
        cell.selectedBackgroundView = selectView;
    }
    
    NSArray *data=[_data objectAtIndex:indexPath.section];
    NSDictionary *dic=[data objectAtIndex:indexPath.row];
    [cell setCellValue:[dic objectForKey:KImgKey] andtitle:[dic objectForKey:KTitleKey]];
    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 43;

}
/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"----------searchBarSearchButtonClicked---------");
    [searchBar resignFirstResponder];
   
    XMPPRoomManager *manager=[XMPPRoomManager instance];
   // [manager getFriendInfomationWithIdentifer:searchBar.text];
    XMPPRoomManager * __weak _manager=manager;
    AddFriendsViewController * __weak __self=self;
    
    self.alert=[[NoticeOperation getId]showAlertWithMsg:@"正在加载" imageName:@"ms_version.png" toView:__self.view autoDismiss:NO viewUserInteractionEnabled:NO isRotate:YES];
    
    
    
    [_manager getFriendInfomationWithIdentifer:searchBar.text completion:^(NSDictionary *model, BOOL isSucess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NoticeOperation getId]hideAlertView:__self.alert fromView:__self.view];
            if (isSucess) {
                EFriends *ef=[model objectForKey:@"value"];
                if ([[EFriendsAndRoomsOpration instance]isExist:ef]) {
                    UserinfoViewController *info=[[UserinfoViewController alloc]initWithJid:ef.jid andType:UserInfomationOpen_TYPE_AddFriend];
                     [__self.navigationController pushViewController:info animated:YES];
                }else{
                    if ([ef.jid isEqualToString:KUserJID]) {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"你不能添加自己到通讯录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                        return ;
                    }

                    UserinfoViewController *info=[[UserinfoViewController alloc]initWithJid:ef.jid andType:UserInfomationOpen_TYPE_Contact];
                    [__self.navigationController pushViewController:info animated:YES];
                    
                }
            }else{
                if ([[model objectForKey:@"error"]isEqual:@"用户不存在"]) {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"该用户不存在" message:@"无法找到该用户，请检查你查找的账号是否正确。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }else if ([[model objectForKey:@"error"]isEqual:@"TimeOut"]){
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请求超时" message:@"请检查网络连接是否正常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }

        });
    }];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    ShareType shareType=0;
    
    if (indexPath.section==0) {
        LocalContactViewController* view=[[LocalContactViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
    
    }else{
        switch (indexPath.row) {
            case 0:{
                shareType=19;
                [self shareFriend:shareType];
            }break;
            case 1:{
                shareType=22;
                [self shareFriend:shareType];
            }break;
            default:{
            }break;
        }
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    [_searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    self.alert=nil;
    NSLog(@"--------addfriends-------dealloc----------");
}

#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:@"contacts.png",KImgKey,@"匹配通讯录好友",KTitleKey, nil];
    NSDictionary *dic2=[NSDictionary dictionaryWithObjectsAndKeys:@"sms.png",KImgKey,@"短信邀请好友加入",KTitleKey, nil];
    NSDictionary *dic3=[NSDictionary dictionaryWithObjectsAndKeys:@"weixin",KImgKey,@"微信邀请好友加入",KTitleKey, nil];
    
    NSArray *section1=[NSArray arrayWithObjects:dic, nil];
    NSArray *section2=[NSArray arrayWithObjects:dic2,dic3,nil];
    
    NSArray *data=[NSArray arrayWithObjects:section1,section2,nil];
    _data=data;
    
}

#pragma mark 初始化视图
-(void)initTopView{
    //标题栏
    UIView *top=[self Title:@"添加好友" returnType:1];
    UIView *topLine=[[UIView alloc] initWithFrame:CGRectMake(0,top.frame.size.height-0.5f, top.frame.size.width,0.5f)];
    topLine.backgroundColor=K808080;
    [top addSubview:topLine];
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    _top=top;

}

-(void)shareFriend:(NSInteger )shareType{

    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@ %@",@"1",@"2"]
                                       defaultContent:@"3"
                                                image:nil
                                                title:@"5"
                                                  url:@"6"
                                          description:NSLocalizedString(@"21cbh", @"21世纪网")
                                            mediaType:SSPublishContentMediaTypeNews];
    
    
     NSString *appStoreUrl=[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/21shi-ji-wang-yuan-chuang/id%@",KApple_ID];
    
    //定制短信信息
    [publishContent addSMSUnitWithContent:[NSString stringWithFormat:@"21世纪网客户端除了可以看投资资讯，还可以聊天，挺好用的，推荐你用一下。下载地址：%@。记得安装后搜索加我",appStoreUrl]];
    
    
    //定制微信好友信息
    [publishContent addWeixinSessionUnitWithType:[NSNumber numberWithInt:2]
                                         content:[NSString stringWithFormat:@"21世纪网客户端除了可以看投资资讯，还可以聊天，挺好用的，推荐你用一下。记得安装后搜索加我。"]
                                           title:@"21世纪网客户端"
                                             url:appStoreUrl
                                      thumbImage:[ShareSDK pngImageWithImage:[UIImage imageNamed:@"Icon_120x120"]]
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    [ShareSDK shareContent:publishContent type:shareType authOptions:authOptions shareOptions:nil statusBarTips:NO result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
        
        
    }];
}



@end
