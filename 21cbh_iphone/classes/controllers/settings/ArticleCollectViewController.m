//
//  ArticleCollectViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ArticleCollectViewController.h"
#import "NewListCell.h"
#import "NewListCollectDB.h"
#import "NewsDetailViewController.h"

@interface ArticleCollectViewController (){
    NewListCollectDB *_nlcDB;
    NSMutableArray *_nlms;
}

@end

@implementation ArticleCollectViewController


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
    _nlcDB=[[NewListCollectDB alloc] init];
    _nlms=[NSMutableArray array];
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
            _nlms=[_nlcDB getNewList];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }];
    });

}


#pragma mark 跳转到新闻详情页
-(void)turnToNewsDetailWithProgramId:(NSString *)programId articleId:(NSString *)articleId {
    NewsDetailViewController *ndv=[[NewsDetailViewController alloc] init];
    ndv.main=self.main;
    ndv.programId=programId;
    ndv.articleId=articleId;
    [self.mcv.navigationController pushViewController:ndv animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _nlms.count;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
    return 85;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消选中某一行
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NewListModel *nlm=[_nlms objectAtIndex:indexPath.row];
    [self turnToNewsDetailWithProgramId:nlm.programId articleId:nlm.articleId];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_nlms.count>0){//没数据就返回空
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NewListModel *nlm=[_nlms objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = kNewCell3;
    NewListCell *cell = (NewListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];;
    if (!cell) {
        cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setCell3:nlm];
    
    return cell;
}

#pragma mark 提交编辑操作时会调用这个方法(删除，添加)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除数据库的数据
        [self.dbQueue addOperationWithBlock:^{
            [_nlcDB deleteNlm:[_nlms objectAtIndex:indexPath.row]];
            // 1.删除数据
            if (_nlms.count==1) {
                [_nlms removeAllObjects];
            }else{
                [_nlms removeObjectAtIndex:indexPath.row];
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

//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
//    
// 
//}
@end
