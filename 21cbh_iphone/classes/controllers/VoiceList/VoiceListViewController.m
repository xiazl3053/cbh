//
//  SongListViewController.m
//  Player
//
//  Created by qinghua on 14-12-23.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import "VoiceListViewController.h"
#import "VoiceListCell.h"
#import "VoiceListModel.h"
#import "PlayManager.h"
#import "YLGIFImage.h"
#import "YLImageView.h"
#import "PlayManager.h"
#import "MJRefresh.h"
#import "RequestManager.h"
#import "NoticeOperation.h"
#import "VoiceListRecordDB.h"

#define KMainScreenSize [UIScreen mainScreen].bounds.size

@interface VoiceListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    //NSArray *_voiceList;
    UIView *_top;
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
}
@property (nonatomic,strong) NSMutableArray *voiceList;
@property (nonatomic,strong) NSMutableArray *tempData;
@end

@implementation VoiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initParams];
    [self initViews];
}

-(void)initParams{
    [self initData];
    [self initNotification];
}

-(void)initData{
    self.voiceList=[NSMutableArray array];
}

-(void)initViews{
    [self initNaviagetionBar];
    [self initTableView];
    [self setCacheData];
}

-(void)setCacheData{
    NSMutableArray *voiceList=[[VoiceListRecordDB sharedInstance]getVoiceList];
    NSSortDescriptor *addtime = [NSSortDescriptor sortDescriptorWithKey:@"addtime" ascending:NO];
    NSArray *descs = [NSArray arrayWithObjects:addtime, nil];
    NSArray *sortList = [voiceList sortedArrayUsingDescriptors:descs];
    [self.voiceList addObjectsFromArray:sortList];
    [_tableView reloadData];
}
#pragma mark -observer Voice的改变
-(void)initNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(voiceChange:) name:KNotificationPlayManagerVoiceChange object:nil];
}
#pragma mark -refreshtableView
-(void)voiceChange:(NSNotification *)aNotification{
    [_tableView reloadData];
}

#pragma mark -初始化NaviagetionBar
-(void)initNaviagetionBar{
    UIView *top=[self Title:@"听闻-财经好声音" returnType:1];
    _top=top;
    
}
#pragma mark -test Data
//-(void)initTestData{
//    
//    VoiceListModel *model=[[VoiceListModel alloc]init];
//    model.title=@"曲目2-1:地震-四川";
//    model.addtime=@"17个小时前";
//    model.duration=@"长度:01:00:02";
//    model.voiceUrl=@"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4";
//    
//    VoiceListModel *model1=[[VoiceListModel alloc]init];
//    model1.title=@"曲目2-2:知足-五月天";
//    model1.addtime=@"22个小时前";
//    model1.duration=@"长度:00:00:02";
//    model1.voiceUrl=@"http://y1.eoews.com/assets/ringtones/2012/5/17/34016/eeemlurxuizy6nltxf2u1yris3kpvdokwhddmeb0.mp3";
//    
//    VoiceListModel *model2=[[VoiceListModel alloc]init];
//    model2.title=@"曲目2-3:橘子香水-任贤齐";
//    model2.addtime=@"1天前";
//    model2.duration=@"长度:00:10:04";
//    model2.voiceUrl=@"http://y1.eoews.com/assets/ringtones/2012/6/29/36195/mx8an3zgp2k4s5aywkr7wkqtqj0dh1vxcvii287a.mp3";
//    
//    NSArray *arr=[NSArray arrayWithObjects:model,model1,model2, nil];
//    _voiceList=arr;
//    
//}

#pragma mark -获取VoiceList
-(void)queryVoiceListWithTimestamp:(NSString *)time{
    RequestManager *manager=[RequestManager shareRequestManager];
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:@"voiceList",KSubInterface,@"voice",KMainInterface,time,@"addtime",nil];
    __unsafe_unretained UITableView *__tableView=_tableView;
    [manager addRequestWithParameter:dic completion:^(NSDictionary *dic, ReposeStausCode code) {
        switch (code) {
            case ReposeStausCode_Success:
            {
                NSString *error=[dic objectForKey:KResponseError];
                switch ([error integerValue]) {
                    case 0:
                    {
                        NSDictionary *data=[dic objectForKey:KResponseData];
                        NSArray *list=[data objectForKey:@"voiceList"];
                        NSMutableArray *voiceList=[NSMutableArray array];
                        if (list.count>0) {
                            for (NSDictionary *dic in list) {
                                VoiceListModel *model=[[VoiceListModel alloc]initWithDict:dic];
                                [voiceList addObject:model];
                                [[VoiceListRecordDB sharedInstance]insertWithVoiceModel:model];
                                
                            }
                            if ([[data objectForKey:KResponseAddtime]integerValue]==0) {
                                [self sortFromReposeData:voiceList isDownRefresh:YES];
                            }else{
                                [self sortFromReposeData:voiceList isDownRefresh:NO];
                            }
                            [__tableView reloadData];
                        }else{
                        [[NoticeOperation getId] showAlertWithMsg:@"无更多数据了" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
                        }
                    }break;
                    default:{
                        [[NoticeOperation getId] showAlertWithMsg:[dic objectForKey:KResponseMsg] imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
                    }break;
                }
            }break;
            case ReposeStausCode_TimerOut:{
                [[NoticeOperation getId] showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
            }break;
            case ReposeStausCode_NetWorkError:{
                [[NoticeOperation alloc]showAlertWithMsg:@"网络不给力" imageName:@"alert_tanhao.png" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
            }break;
                
            default:
                break;
        }
        [_header endRefreshing];
        [_footer endRefreshing];
    }];

}

#pragma mark -初始化TableView
-(void)initTableView{
    CGRect rect=CGRectMake(0, _top.bottom, KMainScreenSize.width, KMainScreenSize.height-_top.bottom);
    UITableView *tableView=[[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    [self.view addSubview:tableView];
    _tableView=tableView;
    [self addHeader];
    [self addFooter];
}

#pragma mark -tableView.delegate Method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _voiceList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"VoiceListCell";
    VoiceListCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[VoiceListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    VoiceListModel *model=[_voiceList objectAtIndex:indexPath.row];
    [cell setValueWithVoiceModel:model];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    VoiceListCell *cell=(VoiceListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stop];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    VoiceListCell *cell=(VoiceListCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell play];
    VoiceListModel *model=[_voiceList objectAtIndex:indexPath.row];
    if (![[[PlayManager sharedPlayManager]getNowVoiceModel].articleId isEqualToString:model.articleId]) {
        self.selectChapterModelblock(_voiceList,indexPath.row);
    }
   // [self dismissViewController];
}

#pragma mark -addHeader
- (void)addHeader
{
    __unsafe_unretained VoiceListViewController *__self = self;
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
        [__self downRefresh];
       // [__self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:1.0];
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
    [header beginRefreshing];
    header.activityView.color=K808080;
    _header=header;
}

#pragma mark -addfooter
- (void)addFooter{
    __unsafe_unretained VoiceListViewController *__self = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [__self upRefresh];
        //获取新闻列表信息
        // [self getNewsListWithisUp:NO];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是footer
        //[__self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:1.0];
        // NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer = footer;
}

#pragma mark -doneFresh
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    //[_table reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    // [[SDImageCache sharedImageCache] clearMemory];
    [refreshView endRefreshing];
}

-(void)downRefresh{
    [self queryVoiceListWithTimestamp:@"0"];
}

-(void)upRefresh{
    VoiceListModel *model=[_voiceList lastObject];
    [self queryVoiceListWithTimestamp:model.addtime];
    NSLog(@"model.addtime===%@",model.addtime);
}

-(void )sortFromReposeData:(NSArray *)data isDownRefresh:(BOOL)b{
    if (b){
        [self sortWithSourceData:data];
    }else{
        NSMutableArray *temp=[NSMutableArray arrayWithArray:self.voiceList];
        [temp addObjectsFromArray:data];
        [self sortWithSourceData:temp];
        NSLog(@"sortFromReposeData.[NSThread currentThread]==%@,",[NSThread currentThread]);
    }
}

-(void )sortWithSourceData:(NSArray *)sourceData{
    NSLog(@"sortWithSourceData.[NSThread currentThread]==%@,",[NSThread currentThread]);
    NSSortDescriptor *addtime = [NSSortDescriptor sortDescriptorWithKey:@"addtime" ascending:NO];
    NSArray *descs = [NSArray arrayWithObjects:addtime, nil];
    NSArray *new= [sourceData sortedArrayUsingDescriptors:descs];
    [self.voiceList removeAllObjects];
    [self.voiceList addObjectsFromArray:new];
}

#pragma -mark -dismissViewController
-(void)dismissViewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)dealloc{
    [_header free];
    [_footer free];
    _voiceList=nil;
    _top=nil;
    _footer=nil;
    _header=nil;
    _tableView=nil;
    NSLog(@"%s",__FUNCTION__);
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerVoiceChange object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)returnBack{
    [self dismissViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
