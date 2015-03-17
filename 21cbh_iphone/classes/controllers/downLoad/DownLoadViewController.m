//
//  DownLoadViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-5.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "DownLoadViewController.h"
#import "VoiceListModel.h"
#import "DownLoadCell.h"
#import "NSString+Date.h"
#import "NoticeOperation.h"
#import "DownLoadDB1.h"
#import "CommonOperation.h"
#import "PlayManager.h"
#import "DownLoadManagerViewController.h"
#import "DownLoadManager.h"


#define kQuanxuan @"全选"
#define kCancel @"取消"
#define kTwoDay @"最近2天"

@interface DownLoadViewController (){
    UIButton *_downLoadManagerBtn;//下载管理按钮    
    UITableView *_table;
    UIView *_btnsView;//底部按钮集View
    UIButton *_quanxuan_btn;//全选按钮
    UIButton *_download_btn;//下载按钮
    
    UIView *_alertView;//下载文件信息提醒view
    
    bool isQuanxuan;//全选控制
    NSOperationQueue *_dbQueue;//数据库操作队列
    
    BOOL isTemp;//存放临时选择数据
}


@property(strong,nonatomic)NSMutableArray *vlms;
@property(strong,nonatomic)NSMutableArray *tempArray;//存放临时选择数据
@property(strong,nonatomic)DownLoadDB1 *dlDB1;


@end

@implementation DownLoadViewController

-(id)initWithVoiceList:(NSMutableArray *)array{
    if (self=[super init]) {
        if(!array){
            array=[NSMutableArray array];
        }
        _vlms=[NSMutableArray array];
        [_vlms addObjectsFromArray:array];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //更新下载数据
    [self updateVlms];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self initTempArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    //移除通知
    [self removeNotification];
}


#pragma mark - --------------------------------代理方法--------------------------------
#pragma mark - ------------UITableView 的代理方法----------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _vlms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_vlms.count>0){//没数据就返回空
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.tintColor=UIColorFromRGB(0xe86e25);//设置打钩颜色
        return cell;
    }
    
    static NSString *downLoadCellIdentifier=kDownLoadCell;
    DownLoadCell *cell =nil;
    VoiceListModel *vlm=[_vlms objectAtIndex:indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:downLoadCellIdentifier];
    
    if (!cell) {        
        cell=[[DownLoadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:downLoadCellIdentifier];
        cell.tintColor=UIColorFromRGB(0xe86e25);//设置打钩颜色
    }
    
    //设置数据
   [cell setCell:vlm];
    
   return cell;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //更新所有的views
    [self updateViews];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //更新所有的views
    [self updateViews];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    VoiceListModel *vlm=[_vlms objectAtIndex:indexPath.row];
    return !(vlm.isExistDBlist);
    
}

#pragma mark - ------------自定义方法--------------------
#pragma mark 初始化数据
-(void)initParams{
    isQuanxuan=YES;
    _dbQueue=[[CommonOperation getId] getMain].dbQueue;
    _dlDB1=[[DownLoadDB1 alloc] init];
    _tempArray=[NSMutableArray array];
    isTemp=YES;
    //通知响应
    [self registerNotification];
}


#pragma mark 初始化视图
-(void)initViews{
    //标题栏
    UIView *top=[self Title:@"批量下载" returnType:1];
    top.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.backView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    self.lable.textColor=UIColorFromRGB(0x000000);
    
    //编辑按钮
    UIButton *downLoadManagerBtn=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-64-15, (top.frame.size.height-25)*0.5f, 64, 25)];
    downLoadManagerBtn.backgroundColor=UIColorFromRGB(0xffffff);
    downLoadManagerBtn.layer.borderWidth=0.5f;
    downLoadManagerBtn.layer.borderColor=[UIColorFromRGB(0xcccccc) CGColor];
    downLoadManagerBtn.titleLabel.font=[UIFont systemFontOfSize:12];
    downLoadManagerBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [downLoadManagerBtn setTitle:[NSString stringWithFormat:@"下载管理"]forState:UIControlStateNormal];
    [downLoadManagerBtn setTitle:[NSString stringWithFormat:@"下载管理"]forState:UIControlStateHighlighted];
    [downLoadManagerBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateNormal];
    [downLoadManagerBtn setTitleColor:UIColorFromRGB(0x636363) forState:UIControlStateHighlighted];
    
    [downLoadManagerBtn addTarget:self action:@selector(downLoadManagerClick) forControlEvents:UIControlEventTouchUpInside];
    [top addSubview:downLoadManagerBtn];
    _downLoadManagerBtn=downLoadManagerBtn;
    

    //底部按钮集
    UIView *btnsView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-75, self.view.frame.size.width, 75)];
    btnsView.backgroundColor=UIColorFromRGB(0xf0f0f0);
    [self.view addSubview:btnsView];
    _btnsView=btnsView;
    
    //按钮集的分割线
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 0.5f)];
    line.backgroundColor=UIColorFromRGB(0x808080);
    [btnsView addSubview:line];
    
    
    CGFloat btnWidth=90;
    CGFloat btnHeight=43;
    CGFloat interval1=(self.view.frame.size.width-3*btnWidth)*0.25;
    CGFloat interval2=(btnsView.frame.size.height-btnHeight)*0.5;
    //全选按钮
    UIButton *quanxuan_btn=[[UIButton alloc] initWithFrame:CGRectMake(interval1, interval2, btnWidth, btnHeight)];
    quanxuan_btn.layer.borderWidth=1;
    quanxuan_btn.layer.cornerRadius=4;
    quanxuan_btn.layer.borderColor=[UIColorFromRGB(0xe86e25) CGColor];
    quanxuan_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    quanxuan_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [quanxuan_btn setTitle:[NSString stringWithFormat:kQuanxuan]forState:UIControlStateNormal];
    [quanxuan_btn setTitle:[NSString stringWithFormat:kQuanxuan]forState:UIControlStateHighlighted];
    [quanxuan_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateNormal];
    [quanxuan_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
    [quanxuan_btn addTarget:self action:@selector(clickQuanxuan) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:quanxuan_btn];
    _quanxuan_btn=quanxuan_btn;
    
    //最近2天按钮
    UIButton *twoday_btn=[[UIButton alloc] initWithFrame:CGRectMake(interval1*2+quanxuan_btn.frame.size.width, interval2, btnWidth, btnHeight)];
    twoday_btn.layer.borderWidth=1;
    twoday_btn.layer.cornerRadius=4;
    twoday_btn.layer.borderColor=[UIColorFromRGB(0xe86e25) CGColor];
    twoday_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    twoday_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [twoday_btn setTitle:[NSString stringWithFormat:kTwoDay]forState:UIControlStateNormal];
    [twoday_btn setTitle:[NSString stringWithFormat:kTwoDay]forState:UIControlStateHighlighted];
    [twoday_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateNormal];
    [twoday_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
    [twoday_btn addTarget:self action:@selector(clickTwoday) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:twoday_btn];
    
    //下载按钮
    UIButton *download_btn=[[UIButton alloc] initWithFrame:CGRectMake(interval1*3+quanxuan_btn.frame.size.width*2, interval2, btnWidth, btnHeight)];
    download_btn.backgroundColor=UIColorFromRGB(0xe86e25);
    download_btn.layer.cornerRadius=4;
    download_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    download_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [download_btn setTitle:[NSString stringWithFormat:@"下载(0)"]forState:UIControlStateNormal];
    [download_btn setTitle:[NSString stringWithFormat:@"下载(0)"]forState:UIControlStateHighlighted];
    [download_btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [download_btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [download_btn addTarget:self action:@selector(clickDownload) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:download_btn];
    _download_btn=download_btn;
    
    
    //table列表
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-top.frame.size.height-btnsView.frame.size.height-20)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor=[UIColor clearColor];
    _table.separatorColor=[UIColor clearColor];
    _table.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    _table.allowsMultipleSelectionDuringEditing=YES;
    [_table setEditing:YES animated:NO];
    [self.view addSubview:_table];
    

}


#pragma mark 全选点击
-(void)clickQuanxuan{
    if (isQuanxuan) {
        
        [_quanxuan_btn setTitle:[NSString stringWithFormat:kCancel]forState:UIControlStateNormal];
        [_quanxuan_btn setTitle:[NSString stringWithFormat:kCancel]forState:UIControlStateHighlighted];
        
        for (int row=0; row<_vlms.count; row++) {
            VoiceListModel *vlm=[_vlms objectAtIndex:row];
            if (!vlm.isExistDBlist){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [_table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
        }
        
        NSArray *selectedRows=[_table indexPathsForSelectedRows];
        if (selectedRows.count<1) {
            [_quanxuan_btn setTitle:[NSString stringWithFormat:kQuanxuan]forState:UIControlStateNormal];
            [_quanxuan_btn setTitle:[NSString stringWithFormat:kQuanxuan]forState:UIControlStateHighlighted];
            return;
        }
        
        isQuanxuan=!isQuanxuan;
        
    }else{
        
        [_quanxuan_btn setTitle:[NSString stringWithFormat:kQuanxuan]forState:UIControlStateNormal];
        [_quanxuan_btn setTitle:[NSString stringWithFormat:kQuanxuan]forState:UIControlStateHighlighted];
        for (int row=0; row<_vlms.count; row++) {
            VoiceListModel *vlm=[_vlms objectAtIndex:row];
            if (!vlm.isExistDBlist){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [_table deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
        
       isQuanxuan=!isQuanxuan;
    }
    
    //更新所有的views
    [self updateViews];
    
}

#pragma mark 点击最近两天
-(void)clickTwoday{
    double b=[[NSString getCurrentTimeString] doubleValue]-2*24*60*60;
    for (int row=0; row<_vlms.count; row++) {
        VoiceListModel *vlm=[_vlms objectAtIndex:row];
        
        if ([vlm.addtime doubleValue]-b>0) {
            
            if (!vlm.isExistDBlist) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [_table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        
    }
    //更新所有的views
    [self updateViews];
}


#pragma mark 点击下载按钮
-(void)clickDownload{
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    if (selectedRows.count<1) {
        return;
    }
    
    isTemp=NO;
    
    [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:@"正在添加文件到下载..." alertView:_alertView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [_dbQueue addOperationWithBlock:^{
            NSMutableArray *array=[NSMutableArray array];
            for (int i=selectedRows.count-1; i>=0; i--) {
                NSIndexPath *indexPath = selectedRows[i];
                VoiceListModel *vlm=[_vlms objectAtIndex:indexPath.row];
                vlm.isExistDBlist=YES;
                [array addObject:vlm];
                
            }
            //下载
            [[DownLoadManager getId] addDownloadArray:array tag:0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_table reloadData];
                [_download_btn setTitle:[NSString stringWithFormat:@"下载(0)"]forState:UIControlStateNormal];
                [_download_btn setTitle:[NSString stringWithFormat:@"下载(0)"]forState:UIControlStateHighlighted];
                [self updateQuanxuanBtn];
                [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:@"添加成功!" alertView:_alertView];
                [[NoticeOperation getId] closeDownLoadViewAlert:_alertView];
                _alertView=nil;
            });
            
        }];
        
        
        
    });
    
}

#pragma mark 点击下载管理按钮
-(void)downLoadManagerClick{
    DownLoadManagerViewController *dlmv=[[DownLoadManagerViewController alloc] init];
    [self.navigationController pushViewController:dlmv animated:YES];
}

#pragma mark 更新下载按钮的数字
-(void)updateDownLoadBtn{
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    NSInteger count=selectedRows.count;
    
    [_download_btn setTitle:[NSString stringWithFormat:@"下载(%i)",count]forState:UIControlStateNormal];
    [_download_btn setTitle:[NSString stringWithFormat:@"下载(%i)",count]forState:UIControlStateHighlighted];
    
    if (selectedRows.count>99) {
        [_download_btn setTitle:[NSString stringWithFormat:@"下载(99+)"]forState:UIControlStateNormal];
        [_download_btn setTitle:[NSString stringWithFormat:@"下载(99+)"]forState:UIControlStateHighlighted];
    }
}


#pragma mark 下载文件信息提醒view
-(void)showDownLoadAlertView{
    
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    
    if (!selectedRows.count>0) {
        
        if (_alertView) {
            [[NoticeOperation getId] closeDownLoadViewAlert:_alertView];
            _alertView=nil;
        }
        
        [self updateQuanxuanBtn];
        
        return;
    }
    
    NSString *info=[self getDownLoadFileInfo];
    if (!_alertView) {
        _alertView=[[NoticeOperation getId] showDownLoadViewAlert:info frame:CGRectMake(0, self.view.frame.size.height-_btnsView.frame.size.height-30, self.view.frame.size.width, 30) superView:self.view backColor:UIColorFromRGB(0x000000)];
    }else{
        [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:info alertView:_alertView];
    }
}

#pragma mark 已经选中的文件信息
-(NSString *)getDownLoadFileInfo{
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    double b=0;
    for (int i=0; i<selectedRows.count; i++) {
        NSIndexPath *indexPath = selectedRows[i];
        VoiceListModel *vlm=[_vlms objectAtIndex:indexPath.row];
        
        b=b+[vlm.size doubleValue];
    }
    
    NSString *info=[NSString stringWithFormat:@"已选中%i个文件,共%.2fM",selectedRows.count,b];
    
    
    return info;
}

#pragma mark 更新所有的view
-(void)updateViews{
    //更新下载按钮的数字
    [self updateDownLoadBtn];
    //显示文件信息提醒view
    [self showDownLoadAlertView];
}


#pragma mark 查询下载数据库表是否有该对象
-(void)checkVlm:(NSInteger)interger{
    VoiceListModel *vlm=[_vlms objectAtIndex:interger];
    bool b=[_dlDB1 isExist:vlm];
    vlm.isExistDBlist=b;
}


#pragma mark 更新下载标识
-(void)updateVlms{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_dbQueue addOperationWithBlock:^{
            isTemp=YES;
            for (int i=0; i<_vlms.count; i++) {
                //查询下载数据库表是否有该对象
                [self checkVlm:i];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_table reloadData];
                for (int i=0; i<_tempArray.count; i++) {
                    NSIndexPath *indexPath = [_tempArray objectAtIndex:i];
                     [_table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
                [self updateViews];
            });
            
        }];
    });
}

#pragma mark 更新全选按钮
-(void)updateQuanxuanBtn{
    [_quanxuan_btn setTitle:[NSString stringWithFormat:kQuanxuan]forState:UIControlStateNormal];
    [_quanxuan_btn setTitle:[NSString stringWithFormat:kQuanxuan]forState:UIControlStateHighlighted];
    isQuanxuan=YES;
}


#pragma mark 页面即将消失时的选中下载数据
-(void)initTempArray{
    if (_tempArray) {
        [_tempArray removeAllObjects];
    }
    
    if (!isTemp) {
        return;
    }
    
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    if (selectedRows.count<1) {
        return;
    }
    
    [_tempArray addObjectsFromArray:selectedRows];
    
}

#pragma mark 通知响应
-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playManagerVoiceChange:) name:KNotificationPlayManagerVoiceChange object:nil];
}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationPlayManagerVoiceChange object:nil];
}

#pragma mark 监听音频切换
-(void)playManagerVoiceChange:(NSNotification *)notification{
    [_table reloadData];
}

@end
