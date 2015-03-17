//
//  ziXuanManageViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "ziXuanManageViewController.h"
#import "basehqCell.h"
#import "selfMarketModel.h"
#import "FMMoveTableView.h"
#import "FMMoveTableViewCell.h"
#import "zRemindViewController.h"
#import "OptionalViewController.h"
#import "dapanListModel.h"
#import "DCommon.h"
#import "UserModel.h"
#import "CommonOperation.h"
#import "ziXuanIndexViewController.h"
#import "selfMarketDB.h"
#import "selfMarketModel.h"
#import "PushNotificationHandler.h"

#define kTitleFont [UIFont fontWithName:kFontName size:15]
#define kTitleColor UIColorFromRGB(0x808080)
#define kTitleBackground UIColorFromRGB(0xf0f0f0)
#define kSmallFont [UIFont fontWithName:kFontName size:13]
#define kSmallFont10 [UIFont fontWithName:kFontName size:10]
#define kBigFont [UIFont fontWithName:kFontName size:16]
#define kBoldFont [UIFont fontWithName:kFontName size:16]

#define kRowNameOfMovie		0
#define kRowYearOfMovie		1
#define kD_SelfMarket_ToTop [UIImage imageNamed:@"D_SelfMarket_ToTop.png"]
#define kD_SelfMarket_ToTop_Hover [UIImage imageNamed:@"D_SelfMarket_ToTop_Hover.png"]
#define kD_SelfMarket_Remind [UIImage imageNamed:@"D_SelfMarket_Remind.png"]
#define kD_SelfMarket_Remind_Hover [UIImage imageNamed:@"D_SelfMarket_Remind_Hover.png"]
#define kD_SelfMarket_Order [UIImage imageNamed:@"D_SelfMarket_Order.png"]
#define kD_SelfMarket_Order_Hover [UIImage imageNamed:@"D_SelfMarket_Order_Hover.png"]

@interface ziXuanManageViewController ()<FMMoveTableViewDataSource,FMMoveTableViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate>
{
    UIView *_editView;// 编辑视图
    BOOL isFinish;// 是否完成刷新，防止频繁刷新表格
    selfMarketDB *_db;// 数据库
    NSOperationQueue *_queue;
    BOOL _isMove;// 是否是移动操作
}

@end

@implementation ziXuanManageViewController

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
    // 初始化参数
    [self initParams];
}


-(void)viewDidAppear:(BOOL)animated{
    //[self show];
    // 添加表格视图
	[self addTableView];
}

-(void)viewWillDisappear:(BOOL)animated{
    // 界面离开保存当前的本地操作
    [self saveLocalDatasWhenLeave];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    _db = nil;
    _queue = nil;
}
#pragma mark ---------------------------------自定义方法-----------------------------------
#pragma mark 参数初始化
-(void)initParams{
    isFinish = YES;
    // 数据库初始化
    _db = [[selfMarketDB alloc] init];
    _queue = [[NSOperationQueue alloc] init];
}
#pragma mark 更新显示表格
-(void)show{
    if (_editTableView) {
        // 重新对数组按时间倒序排列
        self.data = [self startArraySort:self.data KeyString:@"timestamp" isAscending:NO];
        self.valueData = [self startArraySort:self.valueData KeyString:@"timestamp" isAscending:NO];
       // NSLog(@"rightdata=%@",self.data);
        // 底部导航栏致使高度发生变化
        CGFloat h = self.view.frame.size.height-70;
        if (h<100) {
            h = 200;
        }
        _editView.frame = CGRectMake(0,0,320,h+40);
        _editTableView.frame = CGRectMake(_editTableView.frame.origin.x, _editTableView.frame.origin.y, _editTableView.frame.size.width, h);
        [_editTableView setEditing:YES animated:YES];
        [_editTableView reloadData];
        NSLog(@"---DFM---刷新_editTableView，h=%f",h);
    }
}
#pragma mark 添加表格
-(void)addTableView{
    if (!_editView){
        // 编辑视图
        _editView = [[UIView alloc] initWithFrame:CGRectMake(0,0,
                                                             self.view.frame.size.width,
                                                             self.view.frame.size.height)];
        _editView.backgroundColor = kMarketBackground;
        
        // 加一个标题
        UIView *_editTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _editTitleView.backgroundColor = kTitleBackground;
        // 添加一根分割线
        UIView *line = [DCommon drawLineWithSuperView:_editTitleView position:NO];
        line.backgroundColor = UIColorFromRGB(0x8d8d8d);
        line = nil;
        // 添加一根分割线
        UIView *bline = [DCommon drawLineWithSuperView:_editTitleView position:YES];
        bline.backgroundColor = UIColorFromRGB(0x8d8d8d);
        bline = nil;
        [_editView addSubview:_editTitleView];
        
        // 标题
        NSArray *_editTitles = [[NSArray alloc] initWithObjects:@"名称代码",@"设置提醒",@"置顶",@"拖动排序", nil];
        CGFloat x = 0;
        CGFloat oneWidth = 120;
        CGFloat btWidth = (_editTitleView.frame.size.width-oneWidth)/(_editTitles.count-1);
        CGFloat btHeight = _editTitleView.frame.size.height;
        for (int i = 0; i<_editTitles.count; i++) {
            UIButton *itemButton = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, i==0?oneWidth:btWidth, btHeight)];
            [itemButton setTitle:[_editTitles objectAtIndex:i] forState:UIControlStateNormal];
            [itemButton setTitleColor:kTitleColor forState:UIControlStateNormal];
            itemButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            itemButton.titleLabel.font = kTitleFont;
            [_editTitleView addSubview:itemButton];
            itemButton = nil;
            x += i==0?oneWidth:btWidth;
        }
        _editTitles = nil;
        
        // 编辑表格
        _editTableView = [[FMMoveTableView alloc] initWithFrame:CGRectMake(0,
                                                                       _editTitleView.frame.size.height,
                                                                       self.view.frame.size.width,
                                                                       self.view.frame.size.height-70)];
        _editTableView.delegate = self;
        _editTableView.dataSource = self;
        _editTableView.scrollEnabled = YES;
        _editTableView.backgroundColor = ClearColor;
        _editTableView.separatorColor = UIColorFromRGB(0xe1e1e1);
        _editTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        if (kDeviceVersion>=7) {
            _editTableView.separatorInset = UIEdgeInsetsZero;
        }
        [_editView addSubview:_editTableView];
        [self.view addSubview:_editView];
        
    }else{
        [_editTableView reloadData];
    }
    
    
}

#pragma mark 重新排序
-(NSMutableArray*)startArraySort:(NSMutableArray*)datas KeyString:(NSString *)keystring isAscending:(BOOL)isAscending
{
    NSMutableArray *destinationArry=[[NSMutableArray alloc]init];
    NSSortDescriptor* sortByA = [NSSortDescriptor sortDescriptorWithKey:keystring ascending:isAscending];
    //[ self.sourceArry sortUsingDescriptors:[NSArray arrayWithObject:sortByA]];
    //destinationArry 排序后的数组 sourceArry 源数据
    destinationArry = [[NSMutableArray alloc]initWithArray:[datas sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByA]]];
    return destinationArry;
}

#pragma mark 改变或者交换数组的值
-(void)changeDatasWithOldIndex:(int)old andNewIndex:(int)new{
    if (old>=self.data.count) {
        return;
    }
    id object = [self.data objectAtIndex:old];
    
    // 置顶动作先删掉自己
    if (new==0 && old>0) {
        // 删除自身
        [self.data removeObjectAtIndex:old];
    }

    // 往上移动
    if (old>new) {
        // 删除自身
        if (new>0) {
            [self.data removeObjectAtIndex:old];
        }
        // 当前值插入到新行的前面
        [self.data insertObject:object atIndex:new];
    }else{
        // 当前值插入到新行的后面
        new ++ ;
        if (new>=self.data.count) {
            [self.data addObject:object];
        }else{
            [self.data insertObject:object atIndex:new];
        }
        if (new>0) {
            // 删除自身
            [self.data removeObjectAtIndex:old];
        }
        
    }
    
    if (new==0 && old>0) {
        // 置顶提示
        UITableViewCell *cell = [_editTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:old inSection:0]];
        [self moveUpTipViewWithCell:cell];
        cell = nil;
    }
    
    // 设置为已经操作过
    [DCommon SetIsChanged:YES];
    
    // 重新加载
    [_editTableView reloadData];
}
#pragma mark 点击置顶按钮
-(void)clickCellMoveUp:(UIButton*)button{
    _isMove = NO;
    int tag = button.tag;
    if (tag>=_data.count) {
        tag = _data.count-1;
    }
    NSIndexPath *moveRowIndexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    // 改变值
    [self changeDatasWithOldIndex:moveRowIndexPath.row andNewIndex:toIndexPath.row];
    // 移动置顶
    [_editTableView moveRowAtIndexPath:moveRowIndexPath toIndexPath:toIndexPath];
    
}

#pragma mark 点击提醒按钮
-(void)clickCellRemindBt:(UIButton*)button{
    NSLog(@"---DFM---点击提醒按钮");
    [button setImage:kD_SelfMarket_Remind_Hover forState:UIControlStateNormal];
    [_queue addOperationWithBlock:^{
        // 检查登陆了没有
        UserModel *user = [UserModel um];
        if (user.userId>0) {
            int index = button.tag;
            __block zRemindViewController *remind = [[zRemindViewController alloc] init];
            selfMarketModel *m = (selfMarketModel*)[_data objectAtIndex:index];
            remind.marketName = m.marketName;
            remind.marketId = m.marketId;
            remind.marketType = m.marketType;
            remind.newsValue = @"";
            remind.changeRate = @"";
            m = nil;
            if (_valueData.count>0) {
                // 查找对应的值
                for (dapanListModel *item in _valueData) {
                    if ([item.marketId isEqualToString:remind.marketId] && [item.type isEqualToString:remind.marketType]) {
                        remind.newsValue = item.newestValue;
                        remind.changeRate = item.changeRate;
                        break;
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:remind animated:YES];
                remind = nil;
            });
            
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                // 没登陆就弹出登陆提示
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆提示" message:@"自选股服务需要登陆才可使用，请先登陆。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登陆", nil];
                [alert show];
            });
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [button setImage:kD_SelfMarket_Remind forState:UIControlStateNormal];
        });
    }];
    
}

#pragma mark 跳到登陆界面
-(void)gotoLogin{
    [CommonOperation goTOLogin];
}

#pragma mark 点击确定登陆按钮
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        // 设置共享标志
        [DCommon setIsSubmitThanUpdate:NO];
        OptionalViewController *ov = (OptionalViewController*)self.Parent;
        ov.zixuan.userState = NO;
        ov = nil;
        [self gotoLogin];
    }
}

#pragma mark 置顶提示
-(void)moveUpTipViewWithCell:(UITableViewCell*)cell{
    if (!_isMove) {
        UILabel *one = [[cell.contentView subviews] objectAtIndex:0];
        CGFloat w = 150;
        CGFloat h = 30;
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-w)/2, (self.view.frame.size.height-h)/2, w, h)];
        tipView.backgroundColor = UIColorFromRGB(0xDDDDDD);
        // 文字
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0,0, w, h)];
        l.text = [[NSString alloc] initWithFormat:@"%@   已置顶",one.text];
        l.textAlignment = NSTextAlignmentCenter;
        [tipView addSubview:l];
        l = nil;
        [self.view addSubview:tipView];
        [UIView animateWithDuration:0.8 animations:^{
            tipView.alpha = 0;
        } completion:^(BOOL isFinish){
            [tipView removeFromSuperview];
        }];
    }
    
}
#pragma mark 界面离开时候保存一下
-(void)saveLocalDatasWhenLeave{
    if ([DCommon getIsChanged]) {
        // 先清空原有记录
        [_db deleteAllSelfMarket];
        // 添加新记录
        for (int i=self.data.count-1;i>=0;i--) {
            selfMarketModel *m = (selfMarketModel*)[_data objectAtIndex:i];
            selfMarketModel *model = [[selfMarketModel alloc] init];
            model.marketId = m.marketId;
            model.marketName = m.marketName;
            model.marketType = m.marketType;
            model.timestamp = [DCommon getTimestamp];
            model.isSyn = @"1";
            model.userId = @"";
            UserModel *user = [UserModel um];
            if (user.userId>0) {
                model.userId = user.userId;
            }
            user = nil;
            model.heightPrice = m.heightPrice;
            model.lowPrice = m.lowPrice;
            model.todayChangeRate = m.todayChangeRate;
            model.isNotice = m.isNotice;
            model.isNews = m.isNews;
            // 更新本地数据库
            [_db insertWithSelfMarket:model];
            model = nil;
            m = nil;
        }
        [_editTableView reloadData];
    }
    
    
}


#pragma mark -------------------UITableViewDelegate代理实现--------------------
#pragma mark 表格每组行数
-(NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return self.data.count;
}
-(CGFloat)tableView:(FMMoveTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
#pragma mark 表格行
-(UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [[NSString alloc] initWithFormat:@"dpcell_%d",indexPath.row];
    FMMoveTableViewCell *cell = (FMMoveTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSLog(@"---DFM---刷新CELL");
    //NSLog(@"rightcell=%@",self.data);
    if (cell==nil) {
        cell = [[FMMoveTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = kMarketBackground;
        CGFloat cellHeight = cell.frame.size.height;
        CGFloat cellWidth = 100;
        // 股票名称
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight/3*2)];
        title.font = kBigFont;
        title.textAlignment = NSTextAlignmentLeft;
        title.textColor = UIColorFromRGB(0x000000);
        title.backgroundColor = ClearColor;
        [cell.contentView addSubview:title];
        title = nil;
        // 股票ID
        UILabel *kid = [[UILabel alloc] initWithFrame:CGRectMake(0, cellHeight/3, cellWidth, cellHeight/3*2)];
        kid.font = kSmallFont10;
        kid.textAlignment = NSTextAlignmentLeft;
        kid.textColor = UIColorFromRGB(0x898989);
        kid.backgroundColor = ClearColor;
        [cell.contentView addSubview:kid];
        kid = nil;
        // 添加一个向上移动的按钮
        UIButton *moveUp = [[UIButton alloc] initWithFrame:CGRectMake(cellWidth+50, 0, 70, cellHeight)];
        [moveUp setImage:kD_SelfMarket_ToTop forState:UIControlStateNormal];
        [moveUp setImage:kD_SelfMarket_ToTop_Hover forState:UIControlStateHighlighted];
        moveUp.backgroundColor = ClearColor;
        [cell.contentView addSubview:moveUp];
        [moveUp addTarget:self action:@selector(clickCellMoveUp:) forControlEvents:UIControlEventTouchUpInside];
        moveUp = nil;
        // 设置提醒按钮
        UIButton *remindBt = [[UIButton alloc] initWithFrame:CGRectMake(90, 0, 70, cellHeight)];
        [remindBt setImage:kD_SelfMarket_Remind forState:UIControlStateNormal];
        [remindBt setImage:kD_SelfMarket_Remind_Hover forState:UIControlStateHighlighted];
        remindBt.backgroundColor = ClearColor;
        [cell.contentView addSubview:remindBt];
        [remindBt addTarget:self action:@selector(clickCellRemindBt:) forControlEvents:UIControlEventTouchUpInside];
        remindBt = nil;
        // 加一个拖动的按钮在右边
        UIButton *moveBt = [[UIButton alloc] initWithFrame:CGRectMake(240, 7, 50, cellHeight/3*2)];
        [moveBt setImage:kD_SelfMarket_Order forState:UIControlStateNormal];
        [moveBt setImage:kD_SelfMarket_Order_Hover forState:UIControlStateHighlighted];
        remindBt.backgroundColor = ClearColor;
        [cell.contentView addSubview:moveBt];
        moveBt = nil;
    }
    if ([tableView indexPathIsMovingIndexPath:indexPath])
	{
		[cell prepareForMove];
	}
	else
	{
        if (indexPath.row<self.data.count) {
            selfMarketModel *model = (selfMarketModel*)[self.data objectAtIndex:indexPath.row];
            // 股票名称
            UILabel *one = [[cell.contentView subviews] objectAtIndex:0];
            one.text = model.marketName;
            one = nil;
            // 股票id值
            UILabel *two = [[cell.contentView subviews] objectAtIndex:1];
            two.text = model.marketId;
            two = nil;
            // 置顶按钮
            UIButton *mUp = (UIButton *)[[cell.contentView subviews] objectAtIndex:2];
            mUp.tag = indexPath.row;
            mUp = nil;
            // 提醒按钮
            UIButton *reb = (UIButton *)[[cell.contentView subviews] objectAtIndex:3];
            reb.tag = indexPath.row;
            // 如果有提醒数据则高亮提醒按钮
            if ([model.heightPrice floatValue]>0 || [model.lowPrice floatValue]>0 || [model.todayChangeRate floatValue]>0 || [model.isNews boolValue] || [model.isNotice boolValue]) {
                [reb setImage:kD_SelfMarket_Remind_Hover forState:UIControlStateNormal];
            }else{
                [reb setImage:kD_SelfMarket_Remind forState:UIControlStateNormal];
            }
            reb = nil;
            model = nil;
            // 完成刷新
            if (model==self.data.lastObject) {
                isFinish = YES;
            }
        }
        [cell setShouldIndentWhileEditing:NO];
        [cell setShowsReorderControl:NO];
    }
    return cell;
}


//#pragma mark 设置为可移动
//-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//#pragma mark 这个方法就是执行移动操作的
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
//    if (sourceIndexPath != destinationIndexPath) {
//        NSLog(@"---DFM---移动完成");
//        [self.data exchangeObjectAtIndex:destinationIndexPath.row withObjectAtIndex:sourceIndexPath.row];
//    }
//}
//
//#pragma mark 设置单元格为编辑模式
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleNone;
//}
#pragma mark 点击删除按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"df");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除本地记录
        int index = indexPath.row;
        selfMarketModel *selfMarket = [self.data objectAtIndex:index];
        // 删除分组
        [[PushNotificationHandler instance] deletePushTags:[NSString stringWithFormat:@"stock_%@_%@",selfMarket.marketId,selfMarket.marketType]];
        [[PushNotificationHandler instance] savePushTags];
        // 删除本地数据
        [_db deleteSelfMarket:selfMarket];
        
        // 删除页面数据
        [self.data removeObjectAtIndex:index];
        // 删除单元格
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewAutomaticDimension];
        // 设置为已经操作过
        [DCommon SetIsChanged:YES];
        
        // 如果删除完自动返回首页
        if (self.data.count==0) {
            [self.Parent performSelector:@selector(clickEditButtonAction:) withObject:nil afterDelay:0.5];
        }
    }
}
#pragma mark 删除按钮
- (NSString *)tableView:(FMMoveTableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0){
    return @"删除";
}

////#pragma mark Table view delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//	NSLog(@"Did select row at %@", indexPath);
//}
//
//#pragma mark -
//#pragma mark Table view data source
//
- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    _isMove = YES;
	// 改变值
    [self changeDatasWithOldIndex:fromIndexPath.row andNewIndex:toIndexPath.row];
}

//
//
- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if ([sourceIndexPath section] != [proposedDestinationIndexPath section]) {
		proposedDestinationIndexPath = sourceIndexPath;
	}
	
	return proposedDestinationIndexPath;
}



@end
