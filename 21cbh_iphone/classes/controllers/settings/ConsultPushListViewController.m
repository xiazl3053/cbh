//
//  PushListViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ConsultPushListViewController.h"
#import "MJRefresh.h"
#import "XinWenHttpMgr.h"
#import "NewListCell.h"
#import "PushListDB.h"
#import "NewListRecordDB.h"
#import "WebViewController.h"
#import "NewsSpecialViewController.h"
#import "NoticeOperation.h"
#import "CommonOperation.h"
#import "ListHearderView.h"

NSString *const MJTableViewCellIdentifier2 = @"table";

@interface ConsultPushListViewController ()<ListHearderViewDelegate>{
    UITableView *_table;
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
    bool isFirst;//控制加载
    
    NSMutableArray *_nlmsGroups;//集合数组
    PushListDB *_plDB;//推送新闻列表数据库操作类
    NewListRecordDB *_nlrDB;
    NSOperationQueue *_dbQueue;
    
    NSMutableDictionary *_isOpenDic;//记录分组是否打开
}

@end

@implementation ConsultPushListViewController


- (void)viewDidLoad
{
    //初始化变量
    [self initParams];
    //初始化视图
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (isFirst) {
        //加载本地资源
        [self loadLocalData];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if (isFirst) {
        //一启动就刷新
        [_header beginRefreshing];
        isFirst=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ---------------以下为自定义方法------------------------
#pragma mark 初始化变量
-(void)initParams{
    _nlmsGroups=[NSMutableArray array];
    isFirst=YES;
    _plDB=[[PushListDB alloc] init];
    _nlrDB=[[NewListRecordDB alloc] init];
    _dbQueue=[[CommonOperation getId] getMain].dbQueue;
    
    _isOpenDic = [[NSMutableDictionary alloc] init];
    for (int i= 0; i <3 ; i++)
    {
        [_isOpenDic setValue:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",i]];
        
    }
}

#pragma mark 初始化视图
-(void)initView{
    //table列表
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-20-70)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor=[UIColor clearColor];
    _table.separatorColor=[UIColor clearColor];
    [self.view addSubview:_table];
    
    
    // 1.注册
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:MJTableViewCellIdentifier2];
    // 3.集成刷新控件
    // 下拉刷新
    [self addHeader];
    //上拉加载更多
    [self addFooter];
}

#pragma mark 加载本地资源
-(void)loadLocalData{
    
    [_dbQueue addOperationWithBlock:^{
        NSMutableArray *todayNlms=[_plDB getNewListWithTimeType:@"0"];
        NSMutableArray *yesterdayNlms=[_plDB getNewListWithTimeType:@"1"];
        NSMutableArray *previousNlms=[_plDB getNewListWithTimeType:@"2"];
        
        [_nlmsGroups addObject:todayNlms];
        [_nlmsGroups addObject:yesterdayNlms];
        [_nlmsGroups addObject:previousNlms];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_table reloadData];
            
        });
        
    }];
}

#pragma mark 获取推送列表数据
-(void)getPushListWithisUp:(BOOL)isUp{
    XinWenHttpMgr *hmgr=[[XinWenHttpMgr alloc] init];
    hmgr.hh.cplvc=self;
    if (isUp) {//下拉刷新
        [hmgr pushNewListWithPushId:@"" order:@"0" addtime:@"0" isUp:isUp];
        return;
    }
    
    NSMutableArray *previousNlms=[_nlmsGroups objectAtIndex:2];
    
    if (!previousNlms||previousNlms.count<1) {//没有数据就不执行历史记录查询
        [self doneWithView:_footer];
        return;
    }
    
    //上拉查询历史记录
    NewListModel *nlm=[previousNlms objectAtIndex:previousNlms.count-1];

    //有数据刷新
    NSString *newListId=@"";
    NSInteger type=[nlm.type intValue];//类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广)
    switch (type) {
        case 0:
            newListId=nlm.articleId;
            break;
        case 1:
            newListId=nlm.articleId;
            break;
        case 2:
            newListId=nlm.specialId;
            break;
        case 3:
            newListId=nlm.picsId;
            break;
        case 4:
            newListId=nlm.videoId;
            break;
        case 5:
            newListId=nlm.adId;
            break;
        default:
            break;
    }
    
    [hmgr pushNewListWithPushId:newListId order:nlm.order addtime:nlm.addtime isUp:isUp];
}

#pragma mark 获取推送列表数据后的处理
-(void)getPushListHandle:(NSMutableArray *)nlmsGroups isUp:(BOOL)isUp{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (nlmsGroups&&nlmsGroups.count>0) {//有数据才执行下面的代码
            
            if (isUp) {//刷新全部替换数据
                _nlmsGroups=nlmsGroups;
                
                //储存数据
                [_dbQueue addOperationWithBlock:^{
                    NSMutableArray *todayNlms=[_nlmsGroups objectAtIndex:0];
                    NSMutableArray *yesterdayNlms=[_nlmsGroups objectAtIndex:1];
                    NSMutableArray *previousNlms=[_nlmsGroups objectAtIndex:2];
                    [_plDB deleteNdmWithTimeType:@"0"];
                    [_plDB deleteNdmWithTimeType:@"1"];
                    [_plDB deleteNdmWithTimeType:@"2"];
                    
                    for (int i=todayNlms.count-1; i>=0; i--) {
                        NewListModel *nlm=[todayNlms objectAtIndex:i];
                        [_plDB insertNlm:nlm timeType:@"0"];
                    }
                    for (int i=yesterdayNlms.count-1; i>=0; i--) {
                        NewListModel *nlm=[yesterdayNlms objectAtIndex:i];
                        [_plDB insertNlm:nlm timeType:@"1"];
                    }
                    for (int i=previousNlms.count-1; i>=0; i--) {
                        NewListModel *nlm=[previousNlms objectAtIndex:i];
                        [_plDB insertNlm:nlm timeType:@"2"];
                    }
                    
                }];
                // 刷新表格
                [_table reloadData];
            }else{  //插入到底部
                NSMutableArray *previousNlms=[_nlmsGroups objectAtIndex:2];
                NSMutableArray *previousNlms1=[nlmsGroups objectAtIndex:2];
                
                if (previousNlms1&&previousNlms1.count>0) {
                    NSIndexSet *indexSet=nil;
                    NSRange range = NSMakeRange(previousNlms.count, [previousNlms1 count]);
                    indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    [previousNlms insertObjects:previousNlms1 atIndexes:indexSet];
                    // 刷新表格
                    [_table reloadData];
                }else{
                    if (previousNlms) {
                        [[NoticeOperation getId] showAlertWithMsg:@"已无更多记录" imageName:@"error" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
                    }
                }
              
            }
            
            
            
        }
        
        if (isUp) {
            [self doneWithView:_header];
        }else{
            [self doneWithView:_footer];
        }
        
    });
}

#pragma mark 跳转到新闻详情页
-(void)turnToNewsDetailWithArticleId:(NSString *)articleId programId:(NSString *)programId{
    NewsDetailViewController *ndv=[[NewsDetailViewController alloc] initWithProgramId:programId articleId:articleId main:[[CommonOperation getId] getMain]];
    [self.navigationController pushViewController:ndv animated:YES];
}

#pragma mark 跳转到图片浏览页
-(void)turnToPicsWithPicsId:(NSString *)picsId followNum:(NSString *)followNum title:(NSString *)title programId:(NSString *)programId{
    
    MJPhotoBrowser *mpb=[[MJPhotoBrowser alloc] initWithProgramId:programId picsId:picsId followNum:followNum main:[[CommonOperation getId] getMain]];
    [self.navigationController pushViewController:mpb animated:YES];
    
}

#pragma mark 跳转到推广广告页
-(void)turnToAdWithAdId:(NSString *)adId type:(NSString *)type url:(NSString *)url{
    WebViewController *wv=[[WebViewController alloc] initWithAdId:adId type:type url:url];
    [self.navigationController pushViewController:wv animated:YES];
}

#pragma mark 跳转到专题页
-(void)turnToNpvWithSpecialID:(NSString *)specialID programId:(NSString *)programId{
    NewsSpecialViewController *npv=[[NewsSpecialViewController alloc] initWithProgramID:programId AndSpecialID:specialID];
    npv.main=[[CommonOperation getId] getMain];
    [self.navigationController pushViewController:npv animated:YES];
}


#pragma mark - ------------UITableView 的代理方法----------------

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ListHearderView *view = [[ListHearderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    view.tag=section;
    view.delegate=self;
    view.backgroundColor=UIColorFromRGB(0xe1e1e1);
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = CGRectMake(0, 0, self.view.frame.size.width, 50) ;
    lable.textAlignment=NSTextAlignmentCenter;
    lable.font=[UIFont systemFontOfSize:17];
    lable.textColor=UIColorFromRGB(0x555555);
    switch (section) {
        case 0:
            lable.text=[NSString stringWithFormat:@"今天"];
            break;
        case 1:
            lable.text=[NSString stringWithFormat:@"昨天"];
            break;
        case 2:
            lable.text=[NSString stringWithFormat:@"以往"];
            break;
        default:
            break;
    }
    [view addSubview:lable];

    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _nlmsGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSMutableArray *array=[_nlmsGroups objectAtIndex:section];
    
    BOOL isOpen = [[_isOpenDic objectForKey:[NSString stringWithFormat:@"%d",section]] boolValue];
    return isOpen ? array.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *pushCellIdentifier1 = kNewCell1;
    static NSString *pushCellIdentifier2 = kNewCell2;
    NewListCell *cell =nil;
    NSMutableArray *nlms=[_nlmsGroups objectAtIndex:indexPath.section];
    
    NewListModel *nlm=[nlms objectAtIndex:indexPath.row];
    
    NSInteger type=[nlm.type intValue];
    if (type==3) {//图集三张微缩图
        cell = [tableView dequeueReusableCellWithIdentifier:pushCellIdentifier2];
        if (!cell) {
            cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pushCellIdentifier2];
        }
        cell.dbQueue=_dbQueue;
        cell.nlrDB=_nlrDB;
        [cell setCell2:nlm];
    }else{//单张微缩图
        cell = [tableView dequeueReusableCellWithIdentifier:pushCellIdentifier1];
        if (!cell) {
            cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pushCellIdentifier1];
        }
        cell.dbQueue=_dbQueue;
        cell.nlrDB=_nlrDB;
        [cell setCell1:nlm];
    }
    
    return cell;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    NSMutableArray *nlms=[_nlmsGroups objectAtIndex:indexPath.section];
    NewListModel *nlm=[nlms objectAtIndex:indexPath.row];
    NSInteger type=[[NSString stringWithFormat:@"%@",nlm.type] intValue];
    if(type==3){
        return 135;
    }else{
        return 85;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *nlms=[_nlmsGroups objectAtIndex:indexPath.section];
    NewListModel *nlm=[nlms objectAtIndex:indexPath.row];
    [_dbQueue addOperationWithBlock:^{
        [_nlrDB insertWithNlm:nlm];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *indexArray=[NSArray arrayWithObject:indexPath];
            [tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:NO];
        });
        
        
    }];
    
    int type=[nlm.type integerValue];
    
    switch (type) {
        case 0://普通文章
            [self turnToNewsDetailWithArticleId:nlm.articleId programId:nlm.programId];
            break;
        case 1://原创文章
            [self turnToNewsDetailWithArticleId:nlm.articleId programId:nlm.programId];
            break;
        case 2://专题
            [self turnToNpvWithSpecialID:nlm.specialId programId:nlm.programId];
            break;
        case 3://图集
            [self turnToPicsWithPicsId:nlm.picsId followNum:nlm.followNum title:nlm.title programId:nlm.programId];
            break;
        case 4://视频
            
            break;
        case 5://推广
            [self turnToAdWithAdId:nlm.adId type:nlm.type url:nlm.adUrl];
            break;
        case 6://独家
            [self turnToNewsDetailWithArticleId:nlm.articleId programId:nlm.programId];
            break;
        case 7://活动
            [self turnToAdWithAdId:nlm.adId type:nlm.type url:nlm.adUrl];
            break;
        default:
            break;
    }
    // 取消选中某一行
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}


#pragma mark - ------------------MJTableView的方法---------------
- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _table;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //获取推送列表历史记录
        [self getPushListWithisUp:NO];
    };
    _footer = footer;
    _footer.activityView.color=K808080;
}

- (void)addHeader
{
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _table;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //刷新推送列表
        [self getPushListWithisUp:YES];
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
    //一启动就刷新
    //[header beginRefreshing];
    _header = header;
    _header.activityView.color=K808080;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

#pragma mark ListHearderView的代理方法
-(void)clickListHearderView:(ListHearderView *)view{
    BOOL isOpen = [[_isOpenDic objectForKey:[NSString stringWithFormat:@"%d",view.tag]] boolValue];
    [_isOpenDic setValue:[NSNumber numberWithBool:!isOpen] forKey:[NSString stringWithFormat:@"%d",view.tag]];
    [_table reloadSections:[NSIndexSet indexSetWithIndex:view.tag] withRowAnimation:UITableViewRowAnimationFade];
}
@end
