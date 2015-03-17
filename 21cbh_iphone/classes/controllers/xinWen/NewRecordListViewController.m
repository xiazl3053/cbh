//
//  NewRecordListViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-7-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewRecordListViewController.h"
#import "NewListRecordDB.h"
#import "CommonOperation.h"
#import "NewListCell.h"

@interface NewRecordListViewController (){
    UITableView *_table;
    NewListRecordDB *_nlrDB;
    NSMutableArray *_nlms;//新闻列表信息
    NSOperationQueue *_dbQueue;//数据库操作队列
    BOOL isFirstLocal;
}

@end

@implementation NewRecordListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
    
}

-(void)viewDidAppear:(BOOL)animated{
    if (isFirstLocal) {
        //加载本地资源
        [self loadLocalData];
        isFirstLocal=NO;
    }
}

#pragma mark - ------------自定义方法--------------------
#pragma mark 初始化数据
-(void)initParams{
    _nlrDB=[[NewListRecordDB alloc] init];
    _dbQueue=[[CommonOperation getId] getMain].dbQueue;
    isFirstLocal=YES;
}
#pragma mark 初始化视图
-(void)initViews{
    //标题栏
    UIView *top=[self Title:@"最近浏览" returnType:2];
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    //table列表
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, top.frame.origin.y+top.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-top.frame.size.height)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor=[UIColor clearColor];
    _table.separatorColor=[UIColor clearColor];
    _table.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    [self.view addSubview:_table];
    
    
}

#pragma mark 加载本地资源
-(void)loadLocalData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_dbQueue addOperationWithBlock:^{
            //新闻列表本地资源
            _nlms=[_nlrDB getNewList];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (_nlms.count<1) {
                    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-20)*0.5f, self.view.frame.size.width, 20)];
                    label.backgroundColor=[UIColor clearColor];
                    label.textColor=[UIColor whiteColor];
                    label.font = [UIFont fontWithName:kFontName size:18];
                    label.textAlignment=NSTextAlignmentCenter;
                    label.text=@"您最近没有浏览任何资讯";
                    [self.view addSubview:label];
                }
                
                
                [_table reloadData];
            });
        }];
        
    });
    
}


#pragma mark - ------------UITableView 的代理方法----------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _nlms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_nlms.count>0){//没数据就返回空
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    static NSString *newListCellIdentifier1 = kNewCell1;
    static NSString *newListCellIdentifier2 = kNewCell2;
    NewListCell *cell =nil;
    NewListModel *nlm=[_nlms objectAtIndex:indexPath.row];
    NSInteger type=[[NSString stringWithFormat:@"%@",nlm.type] intValue];
    if (type==3) {//图集三张微缩图
        cell = [tableView dequeueReusableCellWithIdentifier:newListCellIdentifier2];
        if (!cell) {
            cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newListCellIdentifier2];
        }
        cell.dbQueue=_dbQueue;
        cell.nlrDB=_nlrDB;
        [cell setCell2:nlm];
    }else{//单张微缩图
        cell = [tableView dequeueReusableCellWithIdentifier:newListCellIdentifier1];
        if (!cell) {
            cell=[[NewListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newListCellIdentifier1];
        }
        cell.dbQueue=_dbQueue;
        cell.nlrDB=_nlrDB;
        [cell setCell1:nlm];
    }
    
    return cell;
}

#pragma mark 每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewListModel *nlm=[_nlms objectAtIndex:indexPath.row];
    NSInteger type=[[NSString stringWithFormat:@"%@",nlm.type] intValue];
    if(type==3){
        return 135;
    }else{
        return 77;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewListModel *nlm=[_nlms objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(getNewListModel:)]) {
        [self.delegate getNewListModel:nlm];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
