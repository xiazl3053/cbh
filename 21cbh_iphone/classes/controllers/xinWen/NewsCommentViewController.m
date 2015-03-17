//
//  NewsCommentViewController.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewsCommentViewController.h"
#import "CommentInfoModel.h"
#import "CommentFloorView.h"
#import "CommentToolView.h"
#import "CommentView.h"
#import "MJRefresh.h"
#import "CommentViewController.h"
#import "NCMConstant.h"
#import "ZXTabbarItem.h"
#import "CommentToolItem.h"
#import "OperationAlertView.h"
#import "PingLunHttpRequest.h"
#import "CommentInfoCollectDB.h"

#import "NSString+Date.h"
#import "ShareViewController.h"
#import "CommentThemeModel.h"
#import "UIImageView+WebCache.h"
#import "UserModel.h"
#import "CommentListCell.h"
#import "NoticeOperation.h"

NSString *const CellIdentifier=@"CommentListCell";
#define KCount 10

@interface NewsCommentViewController (){

    CommentToolView *_tool;
    BOOL _isOpenComment;
    NSString *_ProgramID;
    NSString *_commentTitle;
    NSString *_FollowID;
    int _Cursor;
    UIView *_top;
    int _selectSection;
    int _selectRow;
    CommentInfoModel *_selectCommentInfoModel;
    CommentThemeModel *_themeModel;
    CommentInfoModel *_sendCommentInfoModel;
    UITableView *_table;
    NSMutableArray *_headView;
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    BOOL _isUPLoad;
    BOOL _isUPData;
}

@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,strong) PingLunHttpRequest *request;

@end

@implementation NewsCommentViewController
-(void)dealloc{
  
    [self.data removeAllObjects];
    self.data=nil;
    self.request=nil;
    _top=nil;
    _headView=nil;
    _tool=nil;
    _selectCommentInfoModel=nil;
    _sendCommentInfoModel=nil;
    _themeModel=nil;
    [_table removeAllSubviews];
    [_footer free];
    _footer=nil;
    _table=nil;
    NSLog(@"-------NCM----------dealloc");
    
}

-(id)initWithProgramId:(NSString *)nProgramID andFollowID:(NSString *)nFollowID{
    
    if (self=[super init]) {
        _ProgramID=nProgramID;
       // _ProgramID=@"1000";
        _FollowID=nFollowID;
        _commentTitle=@"";
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.userInteractionEnabled=YES;
    [self initParams];
    [self initViews];
}

#pragma mark - 初始化View
-(void)initViews{
    UIView *top=[self Title:Nil returnType:1];
    _top=top;
    
    [self initWithHeadView];
    [self initWithTableView];
    [self initWithCommentView];
}

-(void)initParams{
    self.data=[NSMutableArray array];
    [self initWithData];
}
#pragma mark -初始化工具View
-(void)initWithTool{
    if (_tool) {
        [_tool removeFromSuperview];
    }
    CGRect rect=CGRectMake(0, 0, 300, 88);
    _selectCommentInfoModel.progarmID=_ProgramID;
    _selectCommentInfoModel.followID=_FollowID;
    CommentToolView *tool=[[CommentToolView alloc]initWithFrame:rect andCommentInfo:_selectCommentInfoModel];
    tool.delegate=self;
    _tool=tool;
}

#pragma mark -初始化HeadView
-(void)initWithHeadView{
    NSMutableArray *headView=[NSMutableArray array];
    UIImageView *imageView1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NewsComment_HotComment.png"]];
    imageView1.frame=CGRectMake(0, 12, 60, 20);
    UIButton *headView1=[[UIButton alloc]init];
    //[headView1 setTitle:@"热门评论" forState:UIControlStateNormal];
    headView1.backgroundColor=[UIColor clearColor];
    [headView1 addSubview:imageView1];
    
    UIButton *headView2=[[UIButton alloc]init];
    headView2.backgroundColor=KCommentContentBGColor;
    //[headView2 setTitle:@"最新评论" forState:UIControlStateNormal];
    UIImageView *imageView2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NewsComment_NewComment.png"]];
    imageView2.frame=CGRectMake(0, 12, 60, 20);
    headView2.backgroundColor=[UIColor clearColor];
    [headView2 addSubview:imageView2];
    
    [headView addObject:headView1];
    [headView addObject:headView2];
    _headView=headView;
}

#pragma mark - table方法
#pragma mark -初始化
-(void)initWithTableView{
    UIScreen *screen=[UIScreen mainScreen];
    //table列表
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0,_top.frame.size.height+_top.frame.origin.y, self.view.bounds.size.width, screen.bounds.size.height-44-_top.frame.size.height-22)];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor=KBgWitheColor;
    table.separatorStyle=UITableViewCellSeparatorStyleNone;
   // table.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:table];
    
    _table=table;
    
    // 3.集成刷新控件
    // 下拉刷新
    [self addFooter];
    [self addHeader];

}

#pragma mark -添加上按钮
- (void)addFooter{
    __unsafe_unretained NewsCommentViewController *nlv = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _table;
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        nlv->_isUPLoad=YES;
        [nlv initWithData];
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    footer.endStateChangeBlock=^(MJRefreshBaseView *refreshView){
        [nlv performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:1.0];
    };
    footer.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
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
    _footer = footer;
    _footer.activityView.color=K808080;
}

#pragma mark -添加addHeader
- (void)addHeader
{
    __unsafe_unretained NewsCommentViewController *ncm = self;
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _table;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        ncm->_Cursor=0;
        ncm->_isUPData=YES;
        [ncm initWithData];
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        [ncm performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:1.0];
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
   // [_table reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

#pragma mark - table Delegate方法
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 44;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [_headView objectAtIndex:section];
    
};
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *rows=[self.data objectAtIndex:indexPath.section];
    CommentInfoModel *info=[rows objectAtIndex:indexPath.row];
    CommentListCell *cell= [[CommentListCell alloc]init];
    return [cell commentListCellRowHeightWith:info];
    
//   CommentListCell *cell= (CommentListCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//     //NSLog(@"row.Height====%f",cell.frame.size.height);
//    return cell.frame.size.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr=[self.data objectAtIndex:section];
    return arr.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    CommentListCell *cell=[[CommentListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
//    CommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell==nil) {
//        cell=[[CommentListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//
    NSArray *arr=[self.data objectAtIndex:indexPath.section];
    CommentInfoModel *model=[arr objectAtIndex:indexPath.row];
    [cell setCellValue:model andIndexPath:indexPath];
    
    //手势
    UITapGestureRecognizer *cellTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        cellTapGesture.numberOfTapsRequired=1;
        [cell addGestureRecognizer:cellTapGesture];
    cell.delegate=self;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_tool removeFromSuperview];
}

#pragma mark - 初始化评论View
-(void)initWithCommentView{

    //评论框
    UIView *commentView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-46, 320, 46)];
    commentView.backgroundColor=UIColorFromRGB(0xe3e3e3);
    commentView.layer.borderWidth = 1;
    commentView.layer.borderColor=[UIColorFromRGB(0x636363) CGColor];
    
    // 创建一个手势识别器
    UITapGestureRecognizer *tap=
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comment:)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [commentView addGestureRecognizer:tap];
    
//    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(10, 8, 300, 28)];
//    view.layer.borderColor=[UIColor grayColor].CGColor;
//    view.layer.borderWidth=1.0;
    
    UILabel *seplortor=[[UILabel alloc]init];
    seplortor.frame=CGRectMake(10, 8, 300, 30);
    [seplortor setText:@"  我要评论......"];
    [seplortor setFont:[UIFont fontWithName:kFontName size:12]];
   // [seplortor setTintColor:[UIColor grayColor]];
    seplortor.backgroundColor=UIColorFromRGB(0xffffff);
    seplortor.layer.borderWidth = 1;
    seplortor.layer.borderColor=[UIColorFromRGB(0x959595) CGColor];
    
    
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.frame=CGRectMake(20, 12, 20, 20);
    [imageView setImage:[UIImage imageNamed:@"newsDetail_comment.png"]];
    
    [commentView addSubview:seplortor];
   // [commentView addSubview:view];
   // [commentView addSubview:imageView];
    [self.view addSubview:commentView];
}

#pragma mark - 初始化评论弹窗
-(void)comment:(UIGestureRecognizer *)tap{
    
    [_tool removeFromSuperview];
    //自创回复
    if (tap!=nil) {
        _sendCommentInfoModel=nil;
    }
    CommentViewController *cvc=[[CommentViewController alloc] initWithProgarmID:_ProgramID andArticleID:_themeModel.articleId andPicsID:_themeModel.picsId andFollowID:_selectCommentInfoModel.commentID];
    _selectCommentInfoModel=nil;
    cvc.delegate=self;
    [self addChildViewController:cvc];
    [self.view addSubview:cvc.view];
}

#pragma mark - 初始化Test数据
-(void)initWithData{
    if (!self.request) {
        self.request=[[PingLunHttpRequest alloc]init];
    }
   // [_request queryCommentNCM:self andProgramId:1140 andFollowListID:316 andCursor:_Cursor andCount:KCount];
    [_request queryCommentNCM:self andProgramId:[_ProgramID integerValue] andFollowListID:[_FollowID integerValue] andCursor:_Cursor andCount:KCount];
}

#pragma mark - 自定义代理方法
#pragma mark -显示所有楼层
-(void)userShowAllComment:(NSIndexPath *)indexpath{
   // NSLog(@"newsCommentView------showAllComment---indexpath=%@",indexpath);
   NSArray *arr= [self.data objectAtIndex:indexpath.section];
    CommentInfoModel *model=[arr objectAtIndex:indexpath.row];
    model.isOpenComment=YES;
    [_table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -cell点击tap
-(void)tap:(UIGestureRecognizer *)tap{
    NSIndexPath *indexPath = [_table indexPathForCell:((UITableViewCell *)tap.view)];
    NSArray *arr= [self.data objectAtIndex:indexPath.section];
    CommentInfoModel *info=[arr objectAtIndex:indexPath.row];
    _selectCommentInfoModel=info;
    _selectCommentInfoModel.progarmID=_ProgramID;
    _selectCommentInfoModel.followID=_FollowID;
    _selectRow=indexPath.row;
    _selectSection=indexPath.section;
    NSLog(@"selcetContent===%@,contentID==%@,progarmID=%@",_selectCommentInfoModel.commentContent,_selectCommentInfoModel.commentID,_selectCommentInfoModel.progarmID);
    CGPoint tapRect=[tap locationInView:self.view];
    
    
    
    NSMutableArray *floor=[NSMutableArray array];
    
    for (int i=0; i<info.commentFollows.count; i++) {
        CommentInfoModel *mod=[info.commentFollows objectAtIndex:i];
        // temp.number-=1;
        // [floor addObject:temp];
        
        CommentInfoModel *m=[mod mutableCopy];
        m.number=info.commentFollows.count-i;
        [floor addObject:m];
        NSLog(@"复制前------%@，复制后---------%@",mod,m);
        
    }
    
//    for (CommentInfoModel *obj in info.commentFollows) {
//        obj.number+=1;
//        [floor addObject:obj];
//    }
    
    
    [floor addObject:[_selectCommentInfoModel mutableCopy]];
    CommentInfoModel *send=[[CommentInfoModel alloc]init];
    send.commentFollows=floor;
    _sendCommentInfoModel=send;
    if (info.commentID) {
        [self initWithTool];
        _tool.frame=CGRectMake(10, tapRect.y-88, 300, 88);
        [self.view addSubview:_tool];
    }
}

#pragma mark -添加Tool
-(void)userSeclectCellInView:(UIGestureRecognizer *)tap andHeight:(float)fHeight
{
    CGPoint point = [tap locationInView:self.view];
    NSLog(@"View里面的Y=%f",point.y);
    //获取用户点击信息
    CommentView *view=(CommentView *)tap.view;
    //获取对应Cell内容
    NSArray *arr=[self.data objectAtIndex:view.nSection];
    CommentInfoModel *info=[arr objectAtIndex:view.nRow];
    NSLog(@"用户选中Section=%i,Row=%i,floor=%i",view.nSection,view.nRow,view.tag);
    int nIdex = 0;
    if (info.commentFollows.count>kMaxFloor) {
        if (info.isOpenComment) {
            nIdex=info.commentFollows.count - view.tag-1;
        }else{
            switch (view.tag) {
                case 0:
                {
                    nIdex=info.commentFollows.count-1;
                }break;
                case 2:{
                    nIdex=1;
                }break;
                case 3:{
                    
                    nIdex=0;
                }break;
                    
                default:
                    break;
            }
        }
    }else{
        nIdex=info.commentFollows.count-view.tag-1;
    }
    CommentInfoModel *cur= [info.commentFollows objectAtIndex:nIdex];
    cur.commentUserHeadUrl=@"";
    cur.commentTopNum=@"";
    cur.commentTime=@"";
    cur.progarmID=_ProgramID;
    _selectCommentInfoModel=cur;
    NSLog(@"selcetContent===%@,contentID==%@,progarmID=%@",_selectCommentInfoModel.commentContent,_selectCommentInfoModel.commentID,_selectCommentInfoModel.progarmID);
    NSMutableArray *floor=[NSMutableArray array];
    for (int i=0; i<=nIdex; i++) {
        CommentInfoModel *mod=[info.commentFollows objectAtIndex:i];
       // temp.number-=1;
       // [floor addObject:temp];
        
        CommentInfoModel *m=[mod mutableCopy];
        m.number=nIdex-i;
        [floor addObject:m];
        NSLog(@"复制前------%@，复制后---------%@",mod,m);

    }
    CommentInfoModel *send=[[CommentInfoModel alloc]init];
    send.commentFollows=floor;
    _sendCommentInfoModel=send;
    if (info.commentID) {
        [self initWithTool];
        CGFloat toolY= point.y-88;
        _tool.frame = CGRectMake(10,toolY, 300, 88);
        [self.view addSubview:_tool];
    }
}

#pragma mark -用户点击ToolBtn响应事件
-(void)userSelectToolBarIndex:(UIButton *)btn{
    switch (btn.tag) {
            //顶贴
        case 100:
        {
            _selectCommentInfoModel.commentTopNum=[NSString stringWithFormat:@"%i",[_selectCommentInfoModel.commentTopNum integerValue]+1];
            NSIndexPath *indexpath=[NSIndexPath indexPathForRow:_selectRow inSection:_selectSection];
            [_table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexpath,nil] withRowAnimation:UITableViewRowAnimationNone];
            _selectCommentInfoModel.isTop=YES;
            [_request sendCommenDingtNCM:self andProgarmID:[_ProgramID integerValue] andArticleID:[_themeModel.articleId integerValue] andPicsID:[_themeModel.picsId integerValue] andFollowID:[_selectCommentInfoModel.commentID integerValue]];
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-40)*.5, _tool.frame.origin.y, 40, 40)];
            label.text=@"+1";
            label.backgroundColor=[UIColor clearColor];
            [label setTextColor:[UIColor redColor]];
            [label setFont:[UIFont systemFontOfSize:24]];
            [self.view addSubview:label];
            
            [UIView animateWithDuration:1 animations:^{
                CGRect rect=label.frame;
                rect.origin.y-=30;
                label.frame=rect;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
            
        }break;
            //回复
        case 101:{
            [self comment:nil];
        } break;
            //分享
        case 102:{
            ShareViewController *share=[[ShareViewController alloc]initWithTitle:_themeModel.title url:_themeModel.shareUrl icon:_themeModel.sharePic controller:self];
            [self addChildViewController:share];
            [self.view addSubview:share.view];
        }break;
            //收藏
        case 103:{
            [self collectOperation];
        }break;
            //复制
        case 104:{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string=_selectCommentInfoModel.commentContent;
//            OperationAlertView *copyView=[[OperationAlertView alloc]initWithFrame:CGRectMake(320, KAlertCoordinateY, 100, 100) andTitle:@"复制成功" andImageName:@"NewsComment_CollectSuccee"];
//            [copyView addInview:self.view];
            NoticeOperation *notice=[[NoticeOperation alloc]init];
            [notice showAlertWithMsg:@"复制成功" imageName:@"NewsComment_CopySuccee" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        }break;
        default:
            break;
    }
}
#pragma mark -收藏操作
-(void)collectOperation{
    CommentInfoCollectDB *db=[[CommentInfoCollectDB alloc]init];
    _selectCommentInfoModel.progarmID=_ProgramID;
    _selectCommentInfoModel.commentTitle=_themeModel.title;
    _selectCommentInfoModel.followID=_FollowID;
    if ([db isExistCim:_selectCommentInfoModel]) {
//        OperationAlertView *collectView=[[OperationAlertView alloc]initWithFrame:CGRectMake(320, KAlertCoordinateY, 100, 100) andTitle:@"已取消收藏" andImageName:@"NewsComment_CopySuccee"];
//        [collectView addInview:self.view];
        NoticeOperation *notice=[[NoticeOperation alloc]init];
        [notice showAlertWithMsg:@"已取消收藏" imageName:@"alert_collect_cancel" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        [db deleteCim:_selectCommentInfoModel];
    }else{
//        OperationAlertView *collectView=[[OperationAlertView alloc]initWithFrame:CGRectMake(320, KAlertCoordinateY, 100, 100) andTitle:@"收藏成功" andImageName:@"NewsComment_CopySuccee"];
//        [collectView addInview:self.view];
        NoticeOperation *notice=[[NoticeOperation alloc]init];
        [notice showAlertWithMsg:@"收藏成功" imageName:@"NewsComment_CollectSuccee" toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        [db insertCim:_selectCommentInfoModel];
    }
}

#pragma mark -------------网络请求数据回调方法-------------
#pragma mark -评论列表
-(void)getCommentInfo:(NSArray *)data andTheme:(CommentThemeModel *)model isSuccess:(BOOL)success{
    [_footer endRefreshing];
    [_header endRefreshing];
    _themeModel=model;
    
    if (_isUPData) {
        [self.data removeAllObjects];
        _isUPData=NO;
    }
    
    if (success) {
        NSArray *temp=[data objectAtIndex:1];
        if (temp.count==0&&_isUPLoad) {
            NoticeOperation *notice=[[NoticeOperation alloc]init];
            [notice showAlertWithMsg:KNoticeNoMoreDataTitle imageName:KNoticeNoMoreDataIcon toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
        }else{
            if (self.data.count==0) {
                self.data=(NSMutableArray *)data;
            }else{
                NSArray *temp=[data objectAtIndex:1];
                NSMutableArray *arr=[self.data objectAtIndex:1];
                for (CommentInfoModel *obj in temp) {
                    [arr addObject:obj];
                }
            }
            //成功后改变游标
            _Cursor+=KCount;
            [_table reloadData];
                   }
    }else{
        NoticeOperation *notice=[[NoticeOperation alloc]init];
        [notice showAlertWithMsg:KNoticeLoadCommentFailTitle imageName:KNoticeLoadCommentFailIcon toView:self.view autoDismiss:YES viewUserInteractionEnabled:NO];
    }
}
#pragma mark -点赞接口
-(void)getCommmentDingInfo:(NSDictionary *)dic{
    NSString *result=[dic objectForKey:@"result"];
    NSString *resultInfo=[dic objectForKey:@"resultInfo"];
    NSLog(@"result=%@,resultInfo＝%@",result,resultInfo);
}

#pragma mark -发送成功回调
-(void)sendSuccessWithContent:(NSString *)content andUserLocaton:(NSString *)userLocaton{
    NSDate *date=[NSDate date];
    NSTimeInterval time=[date timeIntervalSince1970];
    UserModel *user=[UserModel um];
    //没有选中
    if (_sendCommentInfoModel==nil) {
        _sendCommentInfoModel=[[CommentInfoModel alloc]init];
    }
    _sendCommentInfoModel.commentContent=content;
    _sendCommentInfoModel.commentUserNickName=user.nickName;
    _sendCommentInfoModel.commentUserHeadUrl=user.picUrl;
    _sendCommentInfoModel.commentUserLocation=userLocaton;
    _sendCommentInfoModel.commentTime=[NSString stringWithFormat:@"%f",time];
    _sendCommentInfoModel.isOpenComment=YES;
   
   
    //插入新回复
    NSMutableArray *data=[self.data objectAtIndex:1];
    [data insertObject:_sendCommentInfoModel atIndex:0];
    NSArray *arr=[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]];
    [_table insertRowsAtIndexPaths:arr withRowAnimation:NO];
    [_table reloadRowsAtIndexPaths:arr withRowAnimation:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
