//
//  PicCollectViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicCollectViewController.h"
#import "PicsListCell.h"
#import "PicsListCollectDB.h"
#import "MJPhotoBrowser.h"

@interface PicCollectViewController (){
    PicsListCollectDB *_plcDB;
    NSMutableArray *_plms;
}

@end

@implementation PicCollectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    //获取本地数据
    [self loadLocalData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ------------自定义方法--------------------
#pragma mark 初始化数据
-(void)initParams{
    _plcDB=[[PicsListCollectDB alloc] init];
    _plms=[NSMutableArray array];
}
#pragma mark 初始化视图
-(void)initViews{
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorColor=[UIColor clearColor];
    
}

#pragma mark 设置编辑状态
-(void)setEditStatus:(BOOL)b{
    [self.tableView setEditing:b animated:YES];
}


#pragma mark 获取本地资源
-(void)loadLocalData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dbQueue addOperationWithBlock:^{
            _plms=[_plcDB getPlms];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }];
    });
    
}


#pragma mark 跳转到图集详情页
-(void)turnToPicsDetailWithPlm:(PicsListModel *)plm{
    MJPhotoBrowser *mpb=[[MJPhotoBrowser alloc] init];
    mpb.main=self.main;
    mpb.plm=plm;
    [self.mcv.navigationController pushViewController:mpb animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _plms.count;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    return 179;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消选中某一行
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //跳转到图集详情页
    [self turnToPicsDetailWithPlm:[_plms objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_plms.count>0){//没数据就返回空
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    static NSString *cellIdentifier1 = kPicCell1;
    static NSString *cellIdentifier2 = kPicCell2;
    static NSString *cellIdentifier3 = kPicCell3;
    
    PicsListCell *cell =nil;
    PicsListModel *plm=[_plms objectAtIndex:indexPath.row];
    NSInteger type=[plm.type intValue];
    
    if (type==0) {//大
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (!cell) {
            
            cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        }
        [cell setCell1:plm];
    }else if(type==1){//大小小
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (!cell) {
            cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        
        [cell setCell2:plm];
        
    }else if(type==2){//小小大
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
        if (!cell) {
            cell=[[PicsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
        }
        
        [cell setCell3:plm];
    }
    
    return cell;
}

#pragma mark 提交编辑操作时会调用这个方法(删除，添加)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除数据库的数据
        [self.dbQueue addOperationWithBlock:^{
            [_plcDB deletePlm:[_plms objectAtIndex:indexPath.row]];
            // 1.删除数据
            if (_plms.count==1) {
                [_plms removeAllObjects];
            }else{
                [_plms removeObjectAtIndex:indexPath.row];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 2.更新UITableView UI界面
                // [tableView reloadData];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
            
        }];
        
    }
}

#pragma mark 决定tableview的编辑模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}



@end
