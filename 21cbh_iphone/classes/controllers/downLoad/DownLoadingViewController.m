//
//  DownLoadingViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-12.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "DownLoadingViewController.h"
#import "NoticeOperation.h"
#import "CommonOperation.h"
#import "VoiceListModel.h"
#import "DownLoadCell2.h"

@interface DownLoadingViewController (){
    UITableView *_table;
    UIView *_btnsView;//底部按钮集View
    UIView *_alertView;//下载文件信息提醒view
    NSOperationQueue *_dbQueue;//数据库操作队列
}

@property(strong,nonatomic)NSMutableArray *vlms;

@end

@implementation DownLoadingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [DownLoadManager getId].delegate=nil;
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
    DownLoadCell2 *cell =nil;
    VoiceListModel *vlm=[_vlms objectAtIndex:indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:downLoadCellIdentifier];
    
    if (!cell) {
        cell=[[DownLoadCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:downLoadCellIdentifier];
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
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


#pragma mark 决定tableview的编辑模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark 提交编辑操作时会调用这个方法(删除，添加)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        VoiceListModel *vlm=[_vlms objectAtIndex:indexPath.row];        
        [_vlms removeObject:vlm];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[DownLoadManager getId] delSingleDownload:vlm];
        [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:[self getDownLoadFileInfo] alertView:_alertView];
        _alertView.hidden=(_vlms.count>0)?NO:YES;
    }
}


#pragma mark - ------------DownLoadManagerDelegate 的代理方法----------------

#pragma mark 列表刷新
-(void)reloadDelegate{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_vlms removeAllObjects];
        [_vlms addObjectsFromArray:[DownLoadManager getId].totalsNum];
        [_table reloadData];
        
        [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:[self getDownLoadFileInfo] alertView:_alertView];
        _alertView.hidden=(_vlms.count>0)?NO:YES;
        
    });
}

#pragma mark 下载开始
-(void)downloadStartreloadDelegate{
    
}

#pragma mark 下载失败
-(void)downloadFailedDelegate{
    
}

#pragma mark 下载ing
-(void)downloadingDelegate:(CGFloat)f vlm:(VoiceListModel *)vlm{
    NSArray *array=_table.visibleCells;
    for (int i=0; i<array.count; i++) {
        DownLoadCell2 *cell=(DownLoadCell2 *)[array objectAtIndex:i];
        if ([cell.vlm.voiceUrl isEqual:vlm.voiceUrl]) {            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setProgress:f];
            });
            
            break;
        }
    }
}

#pragma mark 下载完成
-(void)downloadCompletionDelegate{
    
}


#pragma mark - --------------------------------自定义方法--------------------------------
-(void)initParams{
    _dbQueue=[[CommonOperation getId] getMain].dbQueue;
    //获取未下载的数据
    _vlms=[NSMutableArray array];
    [_vlms addObjectsFromArray:[DownLoadManager getId].totalsNum];
    [DownLoadManager getId].delegate=self;
}

#pragma mark 初始化视图
-(void)initViews{
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    //信息提示view
    _alertView=[[NoticeOperation getId] showDownLoadViewAlert:[self getDownLoadFileInfo] frame:CGRectMake(0, 0, self.view.frame.size.width, 30) superView:self.view backColor:UIColorFromRGB(0xffffff)];
    _alertView.alpha=1.0f;
    UILabel *label=(UILabel *)[_alertView viewWithTag:2014];
    label.textColor=UIColorFromRGB(0xe86e25);
    label.font=[UIFont fontWithName:kFontName size:12];
    _alertView.hidden=(_vlms.count>0)?NO:YES;
    
    
    //table列表
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, _alertView.frame.origin.y+_alertView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-20-44-40-75-35)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor=[UIColor clearColor];
    _table.separatorColor=[UIColor clearColor];
    _table.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    [self.view addSubview:_table];
    
    
    //底部按钮集
    UIView *btnsView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-20-44-40-75, self.view.frame.size.width, 75)];
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
    //全部暂停
    UIButton *allStop_btn=[[UIButton alloc] initWithFrame:CGRectMake(interval1, interval2, btnWidth, btnHeight)];
    allStop_btn.layer.borderWidth=1.0f;
    allStop_btn.layer.cornerRadius=4;
    allStop_btn.layer.borderColor=[UIColorFromRGB(0xe86e25) CGColor];
    allStop_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    allStop_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [allStop_btn setTitle:[NSString stringWithFormat:@"全部暂停"]forState:UIControlStateNormal];
    [allStop_btn setTitle:[NSString stringWithFormat:@"全部暂停"]forState:UIControlStateHighlighted];
    [allStop_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateNormal];
    [allStop_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
    [allStop_btn addTarget:self action:@selector(clickAllStop_btn) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:allStop_btn];
    
    //全部开始
    UIButton *allStart_btn=[[UIButton alloc] initWithFrame:CGRectMake(interval1*2+allStop_btn.frame.size.width, interval2, btnWidth, btnHeight)];
    allStart_btn.backgroundColor=UIColorFromRGB(0xe86e25);
    allStart_btn.layer.borderWidth=1.0f;
    allStart_btn.layer.cornerRadius=4;
    allStart_btn.layer.borderColor=[UIColorFromRGB(0xe86e25) CGColor];
    allStart_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    allStart_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [allStart_btn setTitle:[NSString stringWithFormat:@"全部开始"]forState:UIControlStateNormal];
    [allStart_btn setTitle:[NSString stringWithFormat:@"全部开始"]forState:UIControlStateHighlighted];
    [allStart_btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [allStart_btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [allStart_btn addTarget:self action:@selector(clickAllStart_btn) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:allStart_btn];
    
    //清空列表
    UIButton *clear_btn=[[UIButton alloc] initWithFrame:CGRectMake(interval1*3+allStart_btn.frame.size.width*2, interval2, btnWidth, btnHeight)];
    clear_btn.layer.borderWidth=1.0f;
    clear_btn.layer.cornerRadius=4;
    clear_btn.layer.borderColor=[UIColorFromRGB(0xe86e25) CGColor];
    clear_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    clear_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [clear_btn setTitle:[NSString stringWithFormat:@"清空列表"]forState:UIControlStateNormal];
    [clear_btn setTitle:[NSString stringWithFormat:@"清空列表"]forState:UIControlStateHighlighted];
    [clear_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateNormal];
    [clear_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
    [clear_btn addTarget:self action:@selector(clickClear_btn) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:clear_btn];
}

#pragma mark 设置编辑状态
-(void)setEditStatus:(BOOL)b{
    [_table setEditing:b animated:YES];
}

#pragma mark 设置编辑相应动画
-(void)setEditAnimate:(BOOL)b{
    __block CGRect frame;
    if (b) {
        [UIView animateWithDuration:0.3 animations:^{
            frame=_btnsView.frame;
            frame.origin.y=self.view.frame.size.height-75;
            _btnsView.frame=frame;
            
            frame=_table.frame;
            frame.size.height=self.view.frame.size.height-75-frame.origin.y;
            _table.frame=frame;
            
        } completion:^(BOOL finished) {
            
            
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            frame=_btnsView.frame;
            frame.origin.y=self.view.frame.size.height;
            _btnsView.frame=frame;
            
            frame=_table.frame;
            frame.size.height=self.view.frame.size.height-frame.origin.y;
            _table.frame=frame;
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}

#pragma mark 点击全部暂停按钮
-(void)clickAllStop_btn{
    DownLoadManager *dlm=[DownLoadManager getId];
    if (dlm.downloadNum.count==0) {
        return;
    }
    [[DownLoadManager getId] cancelDownloads];
}

#pragma mark 点击全部开始按钮
-(void)clickAllStart_btn{
    DownLoadManager *dlm=[DownLoadManager getId];
    if (dlm.totalsNum.count==dlm.downloadNum.count) {
        return;
    }
    [[DownLoadManager getId] startDownloads];
}

#pragma mark 点击清空列表按钮
-(void)clickClear_btn{
     [[DownLoadManager getId] delDownloads];
}


#pragma mark 已经选中的文件信息
-(NSString *)getDownLoadFileInfo{
    double b=0;
    for (int i=0; i<_vlms.count; i++) {
        VoiceListModel *vlm=_vlms[i];
        
        b=b+[vlm.size doubleValue];
    }
    
    NSString *info=[NSString stringWithFormat:@"正在下载%i个文件,占用空间%.0fM,可用空间还有%@M",_vlms.count,b,[[CommonOperation getId] freeDiskSpaceInBytes]];
    
    
    return info;
}

@end
