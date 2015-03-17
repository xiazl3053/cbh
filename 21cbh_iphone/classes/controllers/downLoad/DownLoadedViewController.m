//
//  DownLoadedViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-12.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "DownLoadedViewController.h"
#import "CommonOperation.h"
#import "DownLoadDB1.h"
#import "DownLoadCell3.h"
#import "FileOperation.h"
#import "PlayManager.h"

@interface DownLoadedViewController (){
    UITableView *_table;
    UIView *_btnsView;//底部按钮集View
    UIButton *_quanxuan_btn;//全选按钮
    UIButton *_del_btn;//删除按钮
    UIView *_alertView;//下载文件信息提醒view
    UIView *_alertView2;//下载文件信息提醒view2
    NSOperationQueue *_dbQueue;//数据库操作队列
}

@property(strong,nonatomic)NSMutableArray *vlms;
@property(strong,nonatomic)NSMutableArray *tempArray;//存放临时选择数据
@property(strong,nonatomic)DownLoadDB1 *dlDB1;

@end

@implementation DownLoadedViewController


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
    //更新数据
    [self updateData];
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
    DownLoadCell3 *cell =nil;
    VoiceListModel *vlm=[_vlms objectAtIndex:indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:downLoadCellIdentifier];
    
    if (!cell) {
        cell=[[DownLoadCell3 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:downLoadCellIdentifier];
        cell.tintColor=UIColorFromRGB(0xe86e25);//设置打钩颜色
    }
    
    //设置数据
    [cell setCell:vlm isEditing:tableView.allowsSelectionDuringEditing];
    
    return cell;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.allowsSelectionDuringEditing) {
        //更新所有的views
        [self updateViews];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.allowsSelectionDuringEditing) {
        //更新所有的views
        [self updateViews];
    }else{
        [[PlayManager sharedPlayManager] setPlayerListWithNSArray:_vlms withNumber:indexPath.row isExternal:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark - ---------------UIAlertView代理方法----------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==100){//注销提醒alert
        switch (buttonIndex) {
            case 0:
            {
                NSArray *selectedRows=[_table indexPathsForSelectedRows];
                [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:@"正在删除文件..." alertView:_alertView2];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    [_dbQueue addOperationWithBlock:^{
                        NSMutableArray *array=[NSMutableArray array];
                        for (int i=selectedRows.count-1; i>=0; i--) {
                            NSIndexPath *indexPath = selectedRows[i];
                            VoiceListModel *vlm=[_vlms objectAtIndex:indexPath.row];
                            [_dlDB1 delete:vlm];
                            [[FileOperation getId] delRadio:vlm.voiceUrl];
                            [array addObject:vlm];
                        }
                        for (int i=0; i<array.count; i++) {
                            VoiceListModel *vlm=[array objectAtIndex:i];
                            [_vlms removeObject:vlm];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _alertView.hidden=(_vlms.count>0)?NO:YES;
                            [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:[self getDownLoadFileInfo] alertView:_alertView];
                            [_table reloadData];
                            [_del_btn setTitle:[NSString stringWithFormat:@"删除(0)"]forState:UIControlStateNormal];
                            [_del_btn setTitle:[NSString stringWithFormat:@"删除(0)"]forState:UIControlStateHighlighted];
                            [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:@"删除成功!" alertView:_alertView2];
                            [[NoticeOperation getId] closeDownLoadViewAlert:_alertView2];
                            _alertView2=nil;
                        });
                        
                    }];
                    
                });
            }
            case 1:
                
                break;
            default:
                break;
        }
    }
}

#pragma mark - --------------------------------自定义方法--------------------------------
-(void)initParams{
    _dlDB1=[[DownLoadDB1 alloc] init];
    _vlms=[_dlDB1 getVlmsWithTag:@"1"];
    _dbQueue=[[CommonOperation getId] getMain].dbQueue;
    _tempArray=[NSMutableArray array];
    //注册通知
    [self initNotification];
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
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, _alertView.frame.origin.y+_alertView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(_alertView.frame.origin.y+_alertView.frame.size.height))];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor=[UIColor clearColor];
    _table.separatorColor=[UIColor clearColor];
    _table.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    [self.view addSubview:_table];
    
    //底部按钮集
    UIView *btnsView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-20-44-40, self.view.frame.size.width, 75)];
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
    quanxuan_btn.layer.borderWidth=1.0f;
    quanxuan_btn.layer.cornerRadius=4;
    quanxuan_btn.layer.borderColor=[UIColorFromRGB(0xe86e25) CGColor];
    quanxuan_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    quanxuan_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [quanxuan_btn setTitle:[NSString stringWithFormat:@"全选"]forState:UIControlStateNormal];
    [quanxuan_btn setTitle:[NSString stringWithFormat:@"全选"]forState:UIControlStateHighlighted];
    [quanxuan_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateNormal];
    [quanxuan_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
    [quanxuan_btn addTarget:self action:@selector(clickQuanxuan_btn) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:quanxuan_btn];
    
    //取消按钮
    UIButton *cancel_btn=[[UIButton alloc] initWithFrame:CGRectMake(interval1*2+quanxuan_btn.frame.size.width, interval2, btnWidth, btnHeight)];
    cancel_btn.layer.borderWidth=1.0f;
    cancel_btn.layer.cornerRadius=4;
    cancel_btn.layer.borderColor=[UIColorFromRGB(0xe86e25) CGColor];
    cancel_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    cancel_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [cancel_btn setTitle:[NSString stringWithFormat:@"取消"]forState:UIControlStateNormal];
    [cancel_btn setTitle:[NSString stringWithFormat:@"取消"]forState:UIControlStateHighlighted];
    [cancel_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateNormal];
    [cancel_btn setTitleColor:UIColorFromRGB(0xe86e25) forState:UIControlStateHighlighted];
    [cancel_btn addTarget:self action:@selector(clickCancel_btn) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:cancel_btn];
    
    //删除按钮
    UIButton *del_btn=[[UIButton alloc] initWithFrame:CGRectMake(interval1*3+quanxuan_btn.frame.size.width*2, interval2, btnWidth, btnHeight)];
    del_btn.layer.cornerRadius=4;
    del_btn.backgroundColor=UIColorFromRGB(0xe86e25);
    del_btn.titleLabel.font=[UIFont systemFontOfSize:15];
    del_btn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [del_btn setTitle:[NSString stringWithFormat:@"删除(0)"]forState:UIControlStateNormal];
    [del_btn setTitle:[NSString stringWithFormat:@"删除(0)"]forState:UIControlStateHighlighted];
    [del_btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [del_btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateHighlighted];
    [del_btn addTarget:self action:@selector(clickDel_btn) forControlEvents:UIControlEventTouchUpInside];
    [btnsView addSubview:del_btn];
    _del_btn=del_btn;
}

#pragma mark 设置编辑状态
-(void)setEditStatus:(BOOL)b{
    if (!b) {
        if (_alertView2) {
            [[NoticeOperation getId] closeDownLoadViewAlert:_alertView2];
            _alertView2=nil;
        }
    }
    _table.allowsMultipleSelectionDuringEditing=b;
    [_table setEditing:b animated:YES];
    [self setEditAnimate:b];
    
    NSArray *array=_table.visibleCells;
    for (int i=0; i<array.count; i++) {
        DownLoadCell3 *cell=(DownLoadCell3 *)[array objectAtIndex:i];
        [cell setCell:cell.vlm isEditing:_table.allowsMultipleSelectionDuringEditing];
    }
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


#pragma mark 点击全选按钮
-(void)clickQuanxuan_btn{
    for (int row=0; row<_vlms.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [_table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    //更新所有的views
    [self updateViews];
}

#pragma mark 点击取消按钮
-(void)clickCancel_btn{
    for (int row=0; row<_vlms.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [_table deselectRowAtIndexPath:indexPath animated:NO];
    }
    //更新所有的views
    [self updateViews];
}

#pragma mark 点击删除按钮
-(void)clickDel_btn{
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    if (selectedRows.count<1) {
        return;
    }
    
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"确定删除?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"删除"
                                          otherButtonTitles:@"取消",nil];
    alert.tag=100;
    [alert show];
}


#pragma mark 已经选中的文件信息
-(NSString *)getDownLoadFileInfo{
    double b=0;
    for (int i=0; i<_vlms.count; i++) {
        VoiceListModel *vlm=_vlms[i];
        
        b=b+[vlm.size doubleValue];
    }
    
    NSString *info=[NSString stringWithFormat:@"已下载%i个文件,占用空间%.0fM,可用空间还有%@M",_vlms.count,b,[[CommonOperation getId] freeDiskSpaceInBytes]];
    
    
    return info;
}

#pragma mark 已经选中的文件信息2
-(NSString *)getDownLoadFileInfo2{
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


#pragma mark 更新下载按钮的数字
-(void)updateDownLoadBtn{
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    NSInteger count=selectedRows.count;
    
    [_del_btn setTitle:[NSString stringWithFormat:@"删除(%i)",count]forState:UIControlStateNormal];
    [_del_btn setTitle:[NSString stringWithFormat:@"下载(%i)",count]forState:UIControlStateHighlighted];
    
    if (selectedRows.count>99) {
        [_del_btn setTitle:[NSString stringWithFormat:@"删除(99+)"]forState:UIControlStateNormal];
        [_del_btn setTitle:[NSString stringWithFormat:@"删除(99+)"]forState:UIControlStateHighlighted];
    }
}


#pragma mark 下载文件信息提醒view
-(void)showDownLoadAlertView{
    
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    
    if (!selectedRows.count>0) {
        
        if (_alertView2) {
            [[NoticeOperation getId] closeDownLoadViewAlert:_alertView2];
            _alertView2=nil;
        }
        
        return;
    }
    
    NSString *info=[self getDownLoadFileInfo2];
    if (!_alertView2) {
        _alertView2=[[NoticeOperation getId] showDownLoadViewAlert:info frame:CGRectMake(0, _btnsView.frame.origin.y-30, self.view.frame.size.width, 30) superView:self.view backColor:UIColorFromRGB(0x000000)];
    }else{
        [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:info alertView:_alertView2];
    }
}

#pragma mark 更新所有的view
-(void)updateViews{
    //更新下载按钮的数字
    [self updateDownLoadBtn];
    //显示文件信息提醒view
    [self showDownLoadAlertView];
}


#pragma mark 刷新数据
-(void)updateData{
    _vlms=[_dlDB1 getVlmsWithTag:@"1"];
    [_table reloadData];
    _alertView.hidden=(_vlms.count>0)?NO:YES;
    [[NoticeOperation getId] UpdateDownLoadViewAlertInfo:[self getDownLoadFileInfo] alertView:_alertView];
}


#pragma mark 通知响应
-(void)initNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateData) name:kNotifcationKeyForDownloadComplete object:nil];

}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForDownloadComplete object:nil];
}


#pragma mark 页面即将消失时的选中下载数据
-(void)initTempArray{
    if (_tempArray) {
        [_tempArray removeAllObjects];
    }
    
    
    NSArray *selectedRows=[_table indexPathsForSelectedRows];
    if (selectedRows.count<1) {
        return;
    }
    
    [_tempArray addObjectsFromArray:selectedRows];
    
}

#pragma mark 更新下载标识
-(void)updateVlms{
    
    if (_table.allowsSelectionDuringEditing) {
        for (int i=0; i<_tempArray.count; i++) {
            NSIndexPath *indexPath = [_tempArray objectAtIndex:i];
            [_table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        [self updateViews];
    }
}

@end
