//
//  MessagePushListViewController.m
//  21cbh_iphone
//
//  Created by Franky on 14-4-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MessagePushListViewController.h"
#import "MJRefresh.h"
#import "hangqingHttpRequest.h"
#import "NoticeOperation.h"
#import "selfMarketMessageDB.h"
#import "KLineViewController.h"
#import "kNewsDetailViewController.h"
#import "NewsDetailViewController.h"

typedef void (^MessageHttpBlock)(ASIFormDataRequest *request, BOOL isSuccess, BOOL isUp);

@interface MessagePushListViewController ()
{
    UITableView* dataTableView;
    MJRefreshHeaderView* _header;
    MJRefreshFooterView* _footer;
    bool isFirst;//控制加载
    int currentPage;
    int pageCount;
    NSOperationQueue *_dbQueue;
    NSMutableArray *dataArray;//集合数组
    ASIHTTPRequest* msgRequest;
    MessageHttpBlock myBlock;
    NSString* userId;
}

@end

@implementation MessagePushListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isFirst) {
        //加载本地资源
        [self loadLocalData];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isFirst) {
        //一启动就刷新
        [_header beginRefreshing];
        isFirst=NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    myBlock=nil;
    [_header free];
    if(_footer){
        [_footer free];
    }
    userId=nil;
    [dataArray removeAllObjects];
    dataArray=nil;
    [_dbQueue cancelAllOperations];
    [_dbQueue setSuspended:YES];
    _dbQueue=nil;
    if(msgRequest){
        [msgRequest clearDelegatesAndCancel];
        msgRequest=nil;
    }
}

#pragma mark 初始化变量
-(void)initParams
{
    dataArray=[NSMutableArray arrayWithCapacity:1];
    isFirst=YES;
    currentPage=1;
    pageCount=1;
    userId=[UserModel um].userId;
    _dbQueue=[[NSOperationQueue alloc]init];
    [_dbQueue setMaxConcurrentOperationCount:1];
    __block __unsafe_unretained MessagePushListViewController* viewController=self;
    myBlock=^(ASIFormDataRequest *request, BOOL isSuccess, BOOL isUp){
        [viewController getListCalBack:request isSuccess:isSuccess isUp:isUp];
    };
}

#pragma mark 初始化视图
-(void)initView
{
    //[self test];
}
#pragma mark 加载本地资源
-(void)loadLocalData
{
    //table列表
    dataTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    dataTableView.delegate = self;
    dataTableView.dataSource = self;
    dataTableView.backgroundColor=[UIColor clearColor];
    dataTableView.separatorColor=[UIColor clearColor];
    [self.view addSubview:dataTableView];

    // 下拉刷新
    [self addHeader];
}

#pragma mark 获取推送列表数据
-(void)getListWithisUp:(BOOL)isUp
{
    if(isUp){
        currentPage=1;
    }else{
        currentPage++;
    }
    hangqingHttpRequest* hangqing=[[hangqingHttpRequest alloc]init];
    if(msgRequest){
        [msgRequest clearDelegatesAndCancel];
        msgRequest=nil;
    }
    msgRequest=[hangqing requestSelfMarketMessage:[NSString stringWithFormat:@"%d",currentPage] isUp:isUp block:myBlock];
}

#pragma mark 获取推送列表数据回调
-(void)getListCalBack:(ASIFormDataRequest*)request isSuccess:(BOOL)isSuccess isUp:(BOOL)isUp
{
    if(isSuccess)
    {
        NSString *response=[request responseString];
        NSLog(@"推送列表的返回数据:%@",response);
        NSDictionary *dic= [response JSONValue];
        NSDictionary *data=[dic objectForKey:@"data"];
        int error=[[dic objectForKey:@"errno"] integerValue];
        //NSString *msg=[dic objectForKey:@"msg"];
        if(error==0&&[data isKindOfClass:[NSDictionary class]])
        {
            NSArray* array=[data objectForKey:@"list"];
            if([array isKindOfClass:[NSArray class]])
            {
                pageCount=[[data objectForKey:@"pageCount"] integerValue];
                if(isUp)
                {
                    [dataArray removeAllObjects];
                }
                else if(array.count==0)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NoticeOperation getId] showAlertWithMsg:@"已无更多记录" imageName:@"error" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
                    });
                    return;
                }
                NSString* date=nil;
                NSMutableArray* newArray=nil;
                for (NSDictionary* item in array) {
                    selfMarketMessageModel* model=[[selfMarketMessageModel alloc]initWithNSDictonary:item];
                    [_dbQueue addOperationWithBlock:^{
                        [[selfMarketMessageDB instance] insertIfNotExist:model andUserId:userId];
                    }];
                    if(![date isEqualToString:model.date]){
                        if (newArray!=nil) {
                            [dataArray addObject:newArray];
                            newArray=nil;
                        }
                        date=model.date;
                        newArray=[[NSMutableArray alloc]initWithCapacity:1];
                    }
                    [newArray addObject:model];
                }
                if(newArray!=nil){
                    [dataArray addObject:newArray];
                }
            }
            else
            {
                [[NoticeOperation getId] showAlertWithMsg:@"数据返回错误" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
            }
        }
        else if(error==3)
        {
            [CommonOperation goTOLogin];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NoticeOperation getId] showAlertWithMsg:@"暂无数据" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
            });
        }
    }
    else
    {
        NSLog(@"咨询推送列表获取失败!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [dataTableView reloadData];
        if(dataArray.count>=20&&!_footer)
        {
            //上拉加载更多
            [self addFooter];
        }
        if(dataArray.count<20&&_footer)
        {
            //如果没超过下拉长度，释放footer
            [_footer free];
        }
        if (isUp) {
            [self doneWithView:_header];
        }else{
            [self doneWithView:_footer];
        }
    });
}


#pragma mark - ------------------MJTableView的方法---------------
- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = dataTableView;
    __unsafe_unretained MessagePushListViewController* viewController=self;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //获取推送列表历史记录
        [viewController getListWithisUp:NO];
    };
    _footer = footer;
    _footer.activityView.color=K808080;
}

- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = dataTableView;
    __unsafe_unretained MessagePushListViewController* viewController=self;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //刷新推送列表
        [viewController getListWithisUp:YES];
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        //NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                //NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    _header = header;
    _header.activityView.color=K808080;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    if(refreshView){
        [refreshView endRefreshing];
    }
}

#pragma mark 跳转到公告提醒页
-(void)turnToKNewsDetailWithModel:(selfMarketMessageModel*)model
{
    kNewsDetailViewController* viewController=[[kNewsDetailViewController alloc]initNoticeWithArticleId:model.msgId andkId:model.marketId andkType:model.marketType];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 跳转到K线图
-(void)turnToKLineViewWithModel:(selfMarketMessageModel*)model
{
    KLineViewController* viewController=[[KLineViewController alloc]initWithPush:model.marketId KType:model.marketType.intValue KName:model.marketName RemindType:model.type];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark 跳转到文章详情页
-(void)turnToNewsDetailWithModel:(selfMarketMessageModel*)model
{
    NewsDetailViewController* viewController=[[NewsDetailViewController alloc]initWithProgramId:model.programId articleId:model.newsId main:[[CommonOperation getId] getMain]];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - ------------UITableView 的代理方法----------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* array= [dataArray objectAtIndex:section];
    return array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier=@"MessageCell";
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSArray* array= [dataArray objectAtIndex:indexPath.section];
    selfMarketMessageModel* model=[array objectAtIndex:indexPath.row];
    cell.backgroundColor=UIColorFromRGB(0xf0f0f0);
    cell.textLabel.textColor=UIColorFromRGB(0x000000);
    cell.textLabel.text=model.marketName;
    cell.detailTextLabel.textColor=UIColorFromRGB(0x000000);
    cell.detailTextLabel.text=model.title;
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.selectedBackgroundView =[[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xe1e1e1);
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

    [_dbQueue addOperationWithBlock:^{
        BOOL flag=[[selfMarketMessageDB instance] isReadMessage:model andUserId:userId];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag) {
                cell.textLabel.textColor=UIColorFromRGB(0x8d8d8d);
                cell.detailTextLabel.textColor=UIColorFromRGB(0x8d8d8d);
            }else{
                cell.textLabel.textColor=UIColorFromRGB(0x000000);
                cell.detailTextLabel.textColor=UIColorFromRGB(0x000000);
            }
        });
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray* array= [dataArray objectAtIndex:indexPath.section];
    selfMarketMessageModel* model=[array objectAtIndex:indexPath.row];
    model.isRead=@"1";
    [_dbQueue addOperationWithBlock:^{
        [[selfMarketMessageDB instance] readMessage:model andUserId:userId];
        dispatch_async(dispatch_get_main_queue(),^{
            NSArray *indexArray=[NSArray arrayWithObject:indexPath];
            [tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:NO];
        });
    }];
    int type=model.type.integerValue;
    switch (type) {
        case 0:
        {
            [self turnToKLineViewWithModel:model];
        }
            break;
        case 1:
        {
            [self turnToNewsDetailWithModel:model];
        }
            break;
        case 2:
        {
            [self turnToKNewsDetailWithModel:model];
        }
            break;
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.tag=section;
    view.backgroundColor=UIColorFromRGB(0xe1e1e1);
    
    NSArray* array= [dataArray objectAtIndex:section];
    if(array.count==0){
        return nil;
    }
    selfMarketMessageModel* model=[array objectAtIndex:0];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = CGRectMake(18, 2, 100, 25) ;
    lable.textAlignment=NSTextAlignmentLeft;
    lable.font=[UIFont systemFontOfSize:17];
    lable.textColor=UIColorFromRGB(0x555555);
    lable.backgroundColor=ClearColor;
    lable.text=model.date;
    [view addSubview:lable];
    return view;
}

@end
