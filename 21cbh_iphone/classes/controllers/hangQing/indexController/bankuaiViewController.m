//
//  bankuaiViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "bankuaiViewController.h"
#import "FileOperation.h"
#import "baseTableView.h"
#import "basehqCell.h"
#import "baseMarketListViewController.h"

@interface bankuaiViewController ()
{
    baseTableView *_tableView;
}

@property (strong,nonatomic) NSMutableArray *bktitles;
@property (strong,nonatomic) FileOperation *fo;
@end

@implementation bankuaiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// 初始化数据
    [self getPlistData];
    // 初始化视图
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated{
    // 延迟加载视图
    [self initDidView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _tableView = nil;
    self.fo = nil;
    self.bktitles = nil;
}

#pragma mark --------------------自定义方法------------------
#pragma mark 显示视图
-(void)show{
    
}
#pragma mark 清除视图
-(void)clear{
    
}
#pragma mark 初始化视图
-(void)initView{
    self.view.backgroundColor = kBackgroundcolor;
}

#pragma mark 延迟加载视图
-(void)initDidView{
    // 添加tableview
    _tableView = [[baseTableView alloc] initWithFrame:CGRectMake(0, 0,
                                                                 self.view.frame.size.width,
                                                                 self.bktitles.count*44)];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
}

#pragma mark 读取plist数据
-(void)getPlistData{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"hangqing" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.bktitles=[data objectForKey:KPlistKey3]; // 板块分类标题集合
    data=nil;
    NSLog(@"--DFM--%@",self.bktitles);
}


#pragma mark -------------------UITableViewDelegate代理实现--------------------

#pragma mark 表格每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bktitles.count;
}

#pragma mark 表格行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = [[NSString alloc] initWithFormat:@"bkcell_%d",row];
    basehqCell *cell = (basehqCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[basehqCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        //cell.backgroundColor = [UIColor whiteColor];
    }
    NSString *cellTitle = [self.bktitles objectAtIndex:row];
    cell.textLabel.text = cellTitle;
    cell.textLabel.textColor = UIColorFromRGB(0x222222);
    NSLog(@"---DFM---%@=%d",cellTitle,row);
    
    return cell;
}

#pragma mark 点击Cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    basehqCell *cell = (basehqCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"---DFM---点击：%@",cell.textLabel.text);
    baseMarketListViewController *basemarrketList = [[baseMarketListViewController alloc] init];
    basemarrketList.title = cell.textLabel.text;
    basemarrketList.kType = 3;
    [self.market.navigationController pushViewController:basemarrketList animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
