//
//  CommentCollectViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentCollectViewController.h"
#import "CommentInfoCollectDB.h"
#import "CommentCollectListCell.h"
#import "NewsCommentViewController.h"
#import "NSString+LineHeight.h"

@interface CommentCollectViewController (){

    CommentInfoCollectDB *_cmDB;
    NSMutableArray *_cmdata;
}

@end

@implementation CommentCollectViewController

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

#pragma mark 获取本地资源
-(void)loadLocalData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dbQueue addOperationWithBlock:^{
            _cmdata=[_cmDB getCims];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }];
    });
    
}

#pragma mark - ------------自定义方法--------------------
#pragma mark 初始化数据
-(void)initParams{
    _cmDB=[[CommentInfoCollectDB alloc] init];
    _cmdata=[NSMutableArray array];
}
#pragma mark 初始化视图
-(void)initViews{
    self.tableView.backgroundColor=KBgWitheColor;
    self.tableView.separatorColor=[UIColor clearColor];
}

#pragma mark 设置编辑状态
-(void)setEditStatus:(BOOL)b{
    [self.tableView setEditing:b animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cmdata.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

//    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    
    CommentInfoModel *model=[_cmdata objectAtIndex:indexPath.row];
    
    return [self heightWithRow:model];
}


-(CGFloat)heightWithRow:(CommentInfoModel *)nlm{

    CGSize size=[nlm.commentContent boundingRectWithSize:CGSizeMake(280, 1000) withTextFont:[UIFont systemFontOfSize:15] withLineSpacing:5];
    
    return size.height+2*20+4*8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentCollectListCell";
    CommentCollectListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CommentInfoModel *model=[_cmdata objectAtIndex:indexPath.row];
    if (cell==nil) {
        cell=[[CommentCollectListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setCell:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CommentInfoModel *model= [_cmdata objectAtIndex:indexPath.row];
    NewsCommentViewController *NCM=[[NewsCommentViewController alloc]initWithProgramId:model.progarmID andFollowID:model.followID];
    [self.navigationController pushViewController:NCM animated:YES];
}

#pragma mark 提交编辑操作时会调用这个方法(删除，添加)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除数据库的数据
        [self.dbQueue addOperationWithBlock:^{
            [_cmDB deleteCim:[_cmdata objectAtIndex:indexPath.row]];
            // 1.删除数据
            if (_cmdata.count==1) {
                [_cmdata removeAllObjects];
            }else{
                [_cmdata removeObjectAtIndex:indexPath.row];
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
