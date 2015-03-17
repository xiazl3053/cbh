//
//  NewsSepcialViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewsSpecialViewController.h"
#import "MJRefresh.h"
#import "NewListCell.h"
#import "NewListModel.h"
#import "PicsListCell.h"
#import "PicsListModel.h"
#import "UIImageView+WebCache.h"
#import "PingLunHttpRequest.h"
#import "NCMConstant.h"
#import "AppDelegate.h"
#import "NewListRecordDB.h"
#import "ShareViewController.h"
#import "ResponseJsonParseModel.h"
#import "NewsDetailViewController.h"
#import "MJPhotoBrowser.h"

@interface NewsSpecialViewController (){

    UIView *_top;
    UIView *_tableHeadView;
    UILabel *_desc;
    UILabel *_title;
    UIView *_infoView;
    UIImageView *_imageView;
    NewListModel *_specialInfo;
    NSString *_specialID;
    NSString *_program;
    UITableView *_table;
    MJRefreshHeaderView *_header;
    NewListRecordDB *_nlmDB;

}

//@property (nonatomic,strong) MJRefreshFooterView *footer;
//@property (nonatomic,strong) MJRefreshHeaderView *header;
@property (nonatomic,strong) NSArray *data;
@property (nonatomic,strong) PingLunHttpRequest *request;

@end



@implementation NewsSpecialViewController

-(void)dealloc{
    
    [_header free];
   // [_footer free];
    
    self.data=nil;
    self.request=nil;
    _header=nil;
    _top=nil;
    _tableHeadView=nil;
    _desc=nil;
    _title=nil;
    _infoView=nil;
    _imageView=nil;
    _specialInfo=nil;
    _table=nil;
    _nlmDB=nil;
    NSLog(@"-------NSP----------dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -初始化方法
-(id)initWithProgramID:(NSString *)programID AndSpecialID:(NSString *)specialID{

    if (self=[super init]) {
        _specialID=specialID;
      //  _specialID=@"8";
        _program=programID;
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self initParams];
   
}


#pragma mark -初如化参数
-(void)initParams{
    [self initDB];
    [self initData];
    
}

-(void)initDB{
    _nlmDB=[[NewListRecordDB alloc] init];
}

#pragma mark -初如化参数
-(void)initData{
    //先加载本地数据
    [self loadLocalData];

}

-(void)queryNewsSpecialData{
    if (!self.request) {
        self.request=[[PingLunHttpRequest alloc]init];
    }
    [self.request querySepcialNSP:self andProgramID:[_program integerValue] andSepcial:[_specialID integerValue]];

}

#pragma mark -加载本地数据
-(void)loadLocalData{
    ResponseJsonParseModel *model=[[ResponseJsonParseModel alloc]init];
   BOOL isData=[model loadLocalSpecialWithCacheVC:self andSepcialID:_specialID];
    if (!isData) {
        [self queryNewsSpecialData];
    }
}

#pragma mark - 初始化View
-(void)initViews{
    [self initNaviagetionBar];
    [self initWithTableHeadView];
    [self initWithTableView];
    
    
    UIButton* shareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame=CGRectMake(_top.frame.size.width-40, 5, 40, 40);
    shareBtn.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
    [shareBtn setImage:[UIImage imageNamed:@"newsDetail_forward"] forState:UIControlStateNormal];
    [shareBtn setImage:[UIImage imageNamed:@"newsDetail_forward"] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    [_top addSubview:shareBtn];
}

#pragma mark - 初始化NaviagetionBar
-(void)initNaviagetionBar{
    UIView *top=[self Title:@"21世纪专题" returnType:1];
    _top=top;

}

#pragma mark - table方法

#pragma mark -初始化
-(void)initWithTableView{
    
    UIScreen *screen=[UIScreen mainScreen];
    
    //table列表
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0,_top.frame.size.height+_top.frame.origin.y, self.view.bounds.size.width, screen.bounds.size.height-_top.frame.size.height-20)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor=UIColorFromRGB(0xf0f0f0);
    table.separatorColor=[UIColor clearColor];
    table.tableHeaderView=_tableHeadView;
    table.separatorStyle=UITableViewCellSeparatorStyleNone;
   // table.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"table"];
    [self.view addSubview:table];
    _table=table;
    
    // 3.集成刷新控件
    // 下拉刷新
   // [self addFooter];
    
    [self addHeader];
}

#pragma mark -初始化TableHeadView
-(void)initWithTableHeadView{
    
    UIView *headView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KSpecialTopHieght+50)];
    
    //图片
    UIImageView *BGview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KSpecialTopHieght)];
   // [BGview setImage:[UIImage imageNamed:KSpecialTopDefaultImageName]];
    
    //信息
    UIView *infoView=[[UIView alloc]initWithFrame:CGRectMake(0, KSpecialTopHieght-30, 320, 80)];
   // infoView.backgroundColor=KSpecialTopShowTitleBGColor;
    //infoView.alpha=0.6;
    infoView.backgroundColor=[UIColor clearColor];
    
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 320, 30)];
    [title setTextColor:UIColorFromRGB(0x000000)];
    title.backgroundColor=[UIColor clearColor];
    [title setFont:[UIFont fontWithName:kFontName size:15]];
    
    UILabel *desc=[[UILabel alloc]initWithFrame:CGRectMake(10, title.bottom+5, 300, 40)];
    desc.numberOfLines=2;
    [desc setFont:[UIFont fontWithName:kFontName size:KCommentContentFontSize]];
    [desc setTextColor:UIColorFromRGB(0x8d8d8d)];
    desc.backgroundColor=[UIColor clearColor];
    
    [infoView addSubview:title];
    [infoView addSubview:desc];
    
    [headView addSubview:BGview];
    [headView addSubview:infoView];

    _infoView=infoView;
    _title=title;
    _desc=desc;
    _imageView=BGview;
    _tableHeadView=headView;


}

#pragma mark -添加addHeader
- (void)addHeader
{
    __unsafe_unretained NewsSpecialViewController *nsp = self;
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _table;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [nsp queryNewsSpecialData];
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        [nsp performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:1.0];
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
   // [header beginRefreshing];
    _header = header;
    _header.activityView.color=K808080;
}

#pragma mark -完成刷新
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    //[_table reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
   // [[SDImageCache sharedImageCache] clearMemory];
    [refreshView endRefreshing];
}


#pragma mark -添加上按钮
- (void)addFooter{
    __unsafe_unretained NewsSpecialViewController *nlv = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _table;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //获取新闻列表信息
        // [self getNewsListWithisUp:NO];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是footer
        [nlv performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:1.0];
        // NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
   // _footer = footer;
}

#pragma mark -GroupView初始化方法
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [name setTextAlignment:NSTextAlignmentCenter];
    name.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [name setFont:KSpecialSectionViewTitleFontSize];
    [name setTextColor:UIColorFromRGB(0x000000)];
    NSDictionary  *dic=[self.data objectAtIndex:section];
    [name setText:[dic objectForKey:@"groupName"]];
    
    UIView *top=[[UIView alloc]initWithFrame:CGRectMake(0, -0.5, self.view.frame.size.width, 0.5)];
    top.backgroundColor=UIColorFromRGB(0x8d8d8d);
    UIView *tom=[[UIView alloc]initWithFrame:CGRectMake(0, name.frame.size.height, self.view.frame.size.width, 0.5)];
    tom.backgroundColor=UIColorFromRGB(0x8d8d8d);
    
    [name addSubview:top];
    [name addSubview:tom];
    
    

    
    return name;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

//    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//    
//    return cell.frame.size.height;
    NSDictionary *dic=[self.data objectAtIndex:indexPath.section];
    switch ([[dic objectForKey:@"grouptype"]integerValue]) {
        case 0:
        {
            NSArray *temp=[dic objectForKey:@"content"];
            NewListModel *new=[temp objectAtIndex:indexPath.row];
            NSInteger type=[[NSString stringWithFormat:@"%@",new.type] intValue];
            if(type==3){
                return 135;
            }else{
                return 77;
            }
        }
        case 1:
        {
            return 179;
        }
            break;
        default:
            return 0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSDictionary *dic=[self.data objectAtIndex:section];
    NSArray *temp=[dic objectForKey:@"content"];
    return temp.count;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.data.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    NSDictionary *dic=[self.data objectAtIndex:indexPath.section];
    switch ([[dic objectForKey:@"grouptype"]integerValue]) {
        case 0:
        {
            NSArray *temp=[dic objectForKey:@"content"];
            NewListModel *new=[temp objectAtIndex:indexPath.row];
            new.followNum=[NSString stringWithFormat:@"%@",new.followNum];
            NewListCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewCell1];
            if (!cell) {
                cell=[[NewListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNewCell1];
            }
            
            AppDelegate *delegate=[UIApplication sharedApplication].delegate;
            cell.dbQueue=delegate.main.dbQueue;
            cell.nlrDB=_nlmDB;
            [cell setCell1:new];
//            switch ([new.type integerValue]) {
//                case 0:
//                {
//                    [cell setCell1:new];
//                }break;
//                case 1:{
//                    [cell setCell1:new];
//                }break;
//                default:
//                break;
//            }
            return cell;
        } break;
        case 1:{
            NSArray *temp1=[dic objectForKey:@"content"];
            PicsListModel *pic=[temp1 objectAtIndex:indexPath.row];
            NSLog(@"pic.picUrls==%@",pic.picUrls);
            
            PicsListCell *cell = nil;
            switch ([pic.type intValue]) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:kPicCell1];
                    if (!cell) {
                        cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPicCell1];
                    }
                    [cell setCell1:pic];
                }break;
                case 1:{
                    cell = [tableView dequeueReusableCellWithIdentifier:kPicCell2];
                    if (!cell) {
                        cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPicCell2];
                    }
                    [cell setCell2:pic];
                }break;
                case 2:{
                    cell = [tableView dequeueReusableCellWithIdentifier:kPicCell3];
                    if (!cell) {
                        cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPicCell3];
                    }
                    [cell setCell3:pic];
                }break;
                default:{
                    
                }break;
            }
            
            return cell;
        }break;

            
        default:{
            return [[UITableViewCell alloc]init];
        }break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //百度专题列表点击统计
    [[Frontia getStatistics]logEvent:@"news_click" eventLabel:[NSString stringWithFormat:@"%@:专题列表:%i",[self queryProgramName],indexPath.row+1]];
    
    
    NSDictionary  *dic=[self.data objectAtIndex:indexPath.section];
    switch ([[dic objectForKey:@"grouptype"]integerValue]) {
        case 0:
        {
            NSArray *temp=[dic objectForKey:@"content"];
            NewListModel *new=[temp objectAtIndex:indexPath.row];
            //添加不同类型文章统计
            [self addNewsTypeStatictics:[new.type integerValue]];
            AppDelegate *delegate=[UIApplication sharedApplication].delegate;
            NSOperationQueue *dbQueue=delegate.main.dbQueue;
            [dbQueue addOperationWithBlock:^{
                [_nlmDB insertWithNlm:new];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *indexArray=[NSArray arrayWithObject:indexPath];
                    [tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:NO];
                });
            }];
            NewsDetailViewController *detail=[[NewsDetailViewController alloc]initWithProgramId:new.programId articleId:new.articleId main:self.main];
            NSLog(@"self.main===%@",self.main);
            [self.main.navigationController pushViewController:detail animated:YES];
        } break;
        case 1:{
            NSArray *temp=[dic objectForKey:@"content"];
            PicsListModel *pic=[temp objectAtIndex:indexPath.row];
            //添加图集统计
            [[Frontia getStatistics]logEvent:@"news_newstype" eventLabel:[NSString stringWithFormat:@"%@:%@",[self queryProgramName],@"图集"]];
            MJPhotoBrowser *detail=[[MJPhotoBrowser alloc]initWithProgramId:pic.programId picsId:pic.picsId followNum:pic.followNum main:self.main];
            [self.main.navigationController pushViewController:detail animated:YES];
        }break;
        default:
            break;
    }
}


#pragma mark -网络请求数据回调
-(void)getSpecialBack:(NSArray *)data andSpecialInfo:(NewListModel *)info isSuccess:(BOOL)b errro:(NSDictionary *)dic{
    [_header endRefreshing];
    if (b) {
        if (data&&info) {
            _data=data;
            _specialInfo=info;
            [self reloadTableHeadView];
            [_table reloadData];
        }
    }else{
        
        NoticeOperation *notice=[[NoticeOperation alloc]init];
        [notice showAlertWithMsg:[dic objectForKey:KServerBackMsgKey] imageName:KNoticeErrotImage toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        
    }
}

#pragma mark -刷新界面
-(void)reloadTableHeadView{
    [_imageView setImage:[UIImage imageNamed:KSpecialTopDefaultImageName]];
    //信息
    _infoView.backgroundColor=UIColorFromRGB(0xffffff);
    [_title setText:_specialInfo.title];
    [_desc setText:_specialInfo.desc];
    NSURL *url=[NSURL URLWithString:[_specialInfo.picUrls objectAtIndex:0]];
    [_imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"picture_large.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

    }];
}

#pragma mark 百度不同类型统计
-(void)addNewsTypeStatictics:(NSInteger )type{
    
    NSString *typeName;
    
    switch (type) {
        case 0://普通文章
            typeName=@"普通文章";
            break;
        case 1://原创文章
            typeName=@"原创文章";
            break;
        case 2://专题
            typeName=@"专题";
            break;
        case 3://图集
            typeName=@"图集";
            break;
        case 4://视频
            typeName=@"视频";
            break;
        case 5://推广
            typeName=@"推广";
            break;
        case 6://独家
            typeName=@"独家";
            break;
        default:
            break;
    }
    
    [[Frontia getStatistics]logEvent:@"news_newstype" eventLabel:[NSString stringWithFormat:@"%@:%@",[self queryProgramName],typeName]];
}

#pragma mark -获取栏目名称
-(NSString *)queryProgramName{
    NSString *filePath=[[NSBundle mainBundle]pathForResource:@"21cbh" ofType:@"plist"];
    NSDictionary *dic=[NSDictionary dictionaryWithContentsOfFile:filePath];
    NSDictionary *programDic=[dic objectForKey:@"Type"];
    NSArray *keys=[programDic allKeys];
    NSMutableDictionary *temp=[NSMutableDictionary dictionary];
    for (NSString *str in keys) {
        [temp setObject:str forKey:[programDic objectForKey:str]];
    }
    return [temp objectForKey:_program];
    
}

#pragma mark 分享
-(void)shareBtn{
    
    NSString *sharePic=nil;
    if (_specialInfo.picUrls&&_specialInfo.picUrls.count>1) {
        sharePic=[_specialInfo.picUrls objectAtIndex:1];
    }
    
    ShareViewController *svc=[[ShareViewController alloc] initWithTitle:_specialInfo.title  url:_specialInfo.adUrl icon:sharePic controller:self];
    [self addChildViewController:svc];
    [self.view addSubview:svc.view];
}

@end
