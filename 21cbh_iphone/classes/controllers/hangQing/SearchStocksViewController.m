//
//  SearchStocksViewController.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "SearchStocksViewController.h"
#import "basehqCell.h"
#import "mainTableView.h"
#import "hangqingHttpRequest.h"
#import "NumberKeyBoard.h"
#import "searchStocksModel.h"
#import "searchStocksDB.h"
#import "selfMarketDB.h"
#import "selfMarketModel.h"
#import "UserModel.h"
#import "DCommon.h"
#import "PushNotificationHandler.h"

#define kDSearchListSubPng @"D_searchListSub.png"
#define kDSearchListAddPng @"D_searchListAdd.png"
#define kDSearchTitleColor UIColorFromRGB(0x000000)

@interface SearchStocksViewController ()<UISearchBarDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,NumberKeyBoardDelegate>{
    UITableView *_tableView; // 表格
    NSMutableArray *_data; // 数据
    hangqingHttpRequest *_hqRequest; // 请求
    UISearchBar *_searchBar;// 搜索框
    NumberKeyBoard* keyboardView;// 自定义键盘视图
    UIView *_oldKeyView;
    UIButton *_b123;// 点击123键盘按钮
    BOOL isHide123;// 是否显示自定义123按钮
    searchStocksDB *_db;// 数据库
    selfMarketDB *_selfDb;// 自选数据库
    searchStocksModel *_model ;// 模型
    selfMarketModel *_selfModel ;// 自选模型
    NSOperationQueue *_queue ;// 队列
    NSString *_searchString;// 搜索文字
}

@end

@implementation SearchStocksViewController

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
    [self initParam];
	// 初始化视图
    [self initView];
    // 添加搜索框
    [self addSearchView];
    // 添加表格
    [self addTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.view = nil;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView = nil;
    _data = nil;
    _hqRequest = nil;
    _searchBar = nil;
    _db = nil;
    _model = nil;
    _selfDb = nil;
    _selfModel = nil;
}


#pragma mark 返回主视图
-(void)returnBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --------------------自定义方法------------------
#pragma mark 初始化视图
-(void)initView{
    [self initTitle:@"个股查询" returnType:0];
    self.view.backgroundColor = UIColorFromRGB(0xf0f0f0);
    // 移除一些按钮
    for (int i=0;i<self.topView.subviews.count-3;i++) {
            UIView *item = (UIView*)[self.topView.subviews objectAtIndex:i];
            [item removeFromSuperview];
    }
    [self.transformImage removeFromSuperview];
}
#pragma mark 显示视图
-(void)show{
    if (_tableView) {
        [_tableView reloadData];
    }
}
#pragma mark 初始化参数
-(void)initParam{
 
    _data = [[NSMutableArray alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    _db = [[searchStocksDB alloc] init];
    _selfDb = [[selfMarketDB alloc] init];
    _hqRequest = [[hangqingHttpRequest alloc] init];
    _hqRequest.errorRequest = ^(hangqingHttpRequest* request){
        NSLog(@"---DFM---网络异常");
        
    };
    isHide123 = YES;
    // 注册个键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
}

#pragma mark 添加搜索框
-(void)addSearchView{
    keyboardView = [[[NSBundle mainBundle] loadNibNamed:@"NumberKeyBoard" owner:nil options:nil ] objectAtIndex:0];
    keyboardView.backgroundColor = UIColorFromRGB(0xDDDDDD);
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,
                                                               self.topView.frame.origin.y+self.topView.frame.size.height,
                                                               self.view.frame.size.width,
                                                               40)];
   // _searchBar.backgroundColor = UIColorFromRGB(0x111111);
    // 改变cannel按钮的文字,7.0
    UIView *subView0 = _searchBar.subviews[0];
    if (kDeviceVersion<7) {
        subView0 = _searchBar;
    }
    NSLog(@"---DFM---searchBar:%@",_searchBar);
    if (kDeviceVersion>=6) {
        for (UIView *subView in subView0.subviews)
        {
            NSLog(@"---DFM---里面有什么子视图：%@",subView);
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                // 插入一个自定义背景
//                UIView *bg = [[UIView alloc] initWithFrame:subView.frame];
//                bg.backgroundColor = UIColorFromRGB(0xffffff);
//                [subView0 insertSubview:bg belowSubview:subView];
//                bg = nil;
//                // 删掉原来的背景
//                [subView removeFromSuperview];
            }
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                UITextField *text = (UITextField*)subView;
                //text.backgroundColor = UIColorFromRGB(0xFFFFFF);
                _oldKeyView = text.inputView;
                text.inputView = keyboardView;
                keyboardView.delegate = self;
                text = nil;
                
            }
        }
    }
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"请输入股票代码或拼音首字母"];
    [_searchBar becomeFirstResponder];
    // 添加跟线
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _searchBar.frame.size.height-0.5, _searchBar.frame.size.width,0.5)];
//    line.backgroundColor = UIColorFromRGB(0x333333);
//    [_searchBar addSubview:line];
    [self.view addSubview:_searchBar];
}
#pragma mark 设置搜索框的键盘视图
-(void)setSearchBarInputView:(UIView*)inputView{
    NSLog(@"---DFM---显示键盘视图");
    UIView *subView0 = _searchBar.subviews[0];
    if (kDeviceVersion<7) {
        subView0 = _searchBar;
    }
    if (kDeviceVersion>=6) {
        for (UIView *subView in subView0.subviews)
        {
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                UITextField *text = (UITextField*)subView;
                text.inputView = inputView;
                text = nil;
            }
        }
    }
}

#pragma mark 添加表格
-(void)addTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                              _searchBar.frame.size.height+_searchBar.frame.origin.y,
                                                              self.view.frame.size.width,
                                                              self.view.frame.size.height-_searchBar.frame.size.height-_searchBar.frame.origin.y) style:UITableViewStylePlain];
    _tableView.backgroundColor = ClearColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = UIColorFromRGB(0xcccccc);
    _tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    if (kDeviceVersion>=7) {
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    [self.view addSubview:_tableView];
}
#pragma mark 隐藏键盘
-(void)hideKeyborad{
    // 显示自定义键盘
    [self setSearchBarInputView:keyboardView];
    // 隐藏键盘
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

#pragma mark 查询本地数据
-(void)searchLocalDatas{
    _searchString = _searchBar.text;
    // 查询本地数据
    if (![_searchString isEqualToString:@""]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            _data = [_db searchStocksWithWhere:_searchString];
            //NSLog(@"---DFm---%@",_data);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 搜索完毕更新表格
                [_tableView reloadData];
            });
            
        });
        
    }
    
}
#pragma mark 判断是否已加进自选
-(BOOL)isSelfMarketWithId:(NSString*)ids andType:(NSString*)type{
    UserModel *user = [UserModel um];
    BOOL isSelf;
    selfMarketModel *m = [[selfMarketModel alloc] init];
    m.marketId = ids;
    m.marketType = type;
    m.userId = user.userId;
    isSelf = [_selfDb isExistSelfMarket:m];
    m = nil;
    user = nil;
    return isSelf;
}
#pragma mark 点击添加删除按钮
-(void)clickListButtonAction:(UIButton*)button{
    UserModel *user = [UserModel um];
    __block NSString* userid = user.userId;
    user = nil;
   // basehqCell *cell = (basehqCell *)[[button superview] superview];
    
    basehqCell *cell = (basehqCell *)[button superview];
    if (kDeviceVersion<7) {
        cell = (basehqCell *)[button superview];
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSLog(@"---DFM---点击了添加删除按钮%d",indexPath.row);
    // 得到当前图标
    UIImageView *img = (UIImageView*)[[cell.contentView subviews] lastObject];
    if (indexPath.row<_data.count) {
        searchStocksModel *m = (searchStocksModel*)[_data objectAtIndex:indexPath.row];
        // 插入数据
        [_queue addOperationWithBlock:^{
//            NSLog(@"kDSearchListAddPng===%@,img=%@",[UIImage imageNamed:kDSearchListAddPng],img.image);
            //if (img.image == [UIImage imageNamed:kDSearchListAddPng])
            if ([img.image isEqual:[UIImage imageNamed:kDSearchListAddPng]]) {
                // 插入
                selfMarketModel *model = [[selfMarketModel alloc]init];
                model.marketId = m.code;
                model.marketName = m.name;
                model.marketType = m.type;
                if (userid>0) {
                    model.userId = userid;
                }else{
                    model.userId = @"";
                }
                
                model.isSyn = NO;
                model.timestamp = [DCommon getTimestamp];
                model.heightPrice = @"";
                model.lowPrice = @"";
                model.todayChangeRate = @"";
                model.isNotice = @"";
                model.isNews = @"";
                [_selfDb insertWithSelfMarket:model];
                model = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 当前cell的图标变为减号
                    img.image = [UIImage imageNamed:kDSearchListSubPng];
                });
            }else{
                // 删除
                selfMarketModel *model = [[selfMarketModel alloc]init];
                model.marketId = m.code;
                model.marketType = m.type;
                [_selfDb deleteSelfMarket:model];
                NSString *marketId = model.marketId;
                NSString *marketType = model.marketType;
                model = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 当前cell的图标变为加好
                    img.image = [UIImage imageNamed:kDSearchListAddPng];
                    // 删除分组
                    [[PushNotificationHandler instance] deletePushTags:[NSString stringWithFormat:@"stock_%@_%@",marketId,marketType]];
                    [[PushNotificationHandler instance] savePushTags];
                });
            }
            // 设置为先提交后更新
            [DCommon setIsSubmitThanUpdate:YES];
            // 设置为已经操作过
            [DCommon SetIsChanged:YES];
        
        }];
    }
    
    
}

#pragma mark -------------------------滚动视图代理实现--------------------------------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"---DFM---scrollViewDidScroll");
    // 隐藏键盘
    [self hideKeyborad];
}
#pragma mark ---------------------------键盘代理实现---------------------------------

-(void)numberKeyBoardInput:(NSString*)buttonVlaue{
    if ([buttonVlaue isEqualToString:@"隐藏"]) {
        // 隐藏键盘
        [self hideKeyborad];
        return;
    }
    if ([buttonVlaue isEqualToString:@"清空"]) {
        _searchBar.text = @"";
        return;
    }
    if ([buttonVlaue isEqualToString:@"确定"]) {
        // 隐藏键盘
        [self hideKeyborad];
        return;
    }
    if ([buttonVlaue isEqualToString:@"ABC"]) {
        [self hideKeyborad];
        // 显示拼音键盘
        isHide123 = NO;// 显示自定义数字键
        [self setSearchBarInputView:_oldKeyView];
        _searchBar.keyboardType = UIKeyboardAppearanceDefault ;
        [_searchBar becomeFirstResponder];
        
        return;
    }
    // 删除键
    if ([buttonVlaue isEqualToString:@""] || !buttonVlaue) {
        NSMutableString* mutableString = [[NSMutableString alloc] initWithFormat:@"%@", _searchBar.text];
        if ([mutableString length] > 0) {
            NSRange tmpRange;
            tmpRange.location = [mutableString length] - 1;
            tmpRange.length = 1;
            [mutableString deleteCharactersInRange:tmpRange];
        }
        _searchBar.text = mutableString;
        [self searchLocalDatas];
        return;
    }
    NSString *oldText = _searchBar.text;
    _searchBar.text = [oldText stringByAppendingString:buttonVlaue];
    // 搜索数据
    [self searchLocalDatas];
}

#pragma mark 键盘显示后
-(void)keyboardDidShow:(NSNotification*)notification{
    // 自定义个123按钮
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    if (!_b123) {
        // 搞个自定义的123按钮盖住原来的
        _b123 = [[UIButton alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height-40, 70, 35)];
        _b123.backgroundColor = ClearColor;
        [_b123 addTarget:self action:@selector(clickButton123Action:) forControlEvents:UIControlEventTouchUpInside];
        // 这里直接加到window上
        if (_b123.superview == nil)
        {
            [tempWindow addSubview:_b123];
        }
    }else{
        [tempWindow bringSubviewToFront:_b123];
    }
    _b123.hidden = isHide123;
}

#pragma mark 点击自定义数字键123
-(void)clickButton123Action:(UIButton*)button{
    [_searchBar resignFirstResponder];
    isHide123 = YES;
    // 显示自定义键盘
    [self setSearchBarInputView:keyboardView];
    [_searchBar becomeFirstResponder];
}


#pragma mark ---------------------------搜索框代理实现方法-----------------------------
#pragma mark 开始搜索
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSLog(@"---DFm---搜索那:%d",searchBar.keyboardType);
    // 搜索数据
    [self searchLocalDatas];
}

#pragma mark -------------------------表格代理实现--------------------------------
#pragma mark 表格行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}
#pragma mark 表格每行内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"searchcell";// [[NSString alloc] initWithFormat:@"dpcell_%d",row];
    basehqCell *cell = (basehqCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[basehqCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // 名称
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, cell.frame.size.width, cell.frame.size.height)];
        lb.textAlignment = NSTextAlignmentLeft;
        lb.textColor = kDSearchTitleColor;
        lb.backgroundColor = ClearColor;
        lb.font = [UIFont fontWithName:kFontName size:14];
        lb.font = [UIFont fontWithName:kFontName size:14];
        [cell.contentView addSubview:lb];
        lb = nil;
        // 代号
        UILabel *dh = [[UILabel alloc] initWithFrame:CGRectMake(105, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
        dh.textAlignment = NSTextAlignmentLeft;
        dh.textColor = kDSearchTitleColor;
        dh.backgroundColor = ClearColor;
        dh.font = [UIFont fontWithName:kFontName size:14];
        [cell.contentView addSubview:dh];
        dh = nil;
        // 是否已选
        UILabel *ys = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width-25, cell.frame.size.height)];
        ys.textAlignment = NSTextAlignmentRight;
        ys.textColor = kDSearchTitleColor;
        ys.font = [UIFont fontWithName:kFontName size:14];
        ys.backgroundColor = ClearColor;
        [cell.contentView addSubview:ys];
        ys = nil;
        // 添加删除图标
        NSString *path=[[NSBundle mainBundle]pathForResource:@"D_searchListAdd@2x" ofType:@"png"];
        UIImage *addimg = [UIImage imageWithContentsOfFile:path];
        NSLog(@"%@",NSStringFromCGSize(addimg.size));
        UIImageView *imageview = [[UIImageView alloc] initWithImage:addimg];
        UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, addimg.size.width+10, cell.frame.size.height)];
        imageview.frame = CGRectMake((bt.width-addimg.size.width)/2, (cell.frame.size.height-addimg.size.height)/2, addimg.size.width, addimg.size.height);
        bt.backgroundColor = ClearColor;
        [cell addSubview:bt];
        // 点击
        [bt addTarget:self action:@selector(clickListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        bt = nil;
        [cell.contentView addSubview:imageview];
        
    }
    if (indexPath.row<_data.count) {
        
        searchStocksModel *m = (searchStocksModel*)[_data objectAtIndex:indexPath.row];
        NSArray *views = [cell.contentView subviews];
        int one = 1;
        int two = 2;
        int three = 3;
        int four = 4;
        if (views.count<5) {
            one = 0;
            two = 1;
            three = 2;
            four = 3;
        }
        UILabel *lb = (UILabel*)[[cell.contentView subviews] objectAtIndex:one];
        lb.text = m.code;
        
        lb = nil;
        UILabel *dh = (UILabel*)[[cell.contentView subviews] objectAtIndex:two];
        dh.text = m.name;
        dh = nil;
        // 是否已选
        UILabel *ys = (UILabel*)[[cell.contentView subviews] objectAtIndex:three];
        
        UIImageView *img = (UIImageView*)[[cell.contentView subviews] objectAtIndex:four];
        if ([self isSelfMarketWithId:m.code andType:m.type]) {
            ys.text = @"已加入自选";
            img.image = [UIImage imageNamed:kDSearchListSubPng];
        }else{
            ys.text = @"";
            img.image = [UIImage imageNamed:kDSearchListAddPng];
        }
        img = nil;
        ys = nil;
        m = nil;
    }
    
    
    return cell;
}

#pragma mark 点击表格
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row<_data.count) {
        searchStocksModel *m = (searchStocksModel*)[_data objectAtIndex:indexPath.row];
        if (_type==888888) {
            if (self.userSelectStockinfo) {
                self.userSelectStockinfo(m.code,m.type,m.name);
                [self returnBack];
            }
        }
        KLineViewController *kline = [[KLineViewController alloc] initWithIsBack:YES KId:m.code KType:[m.type intValue] KName:m.name];
        [self.navigationController pushViewController:kline animated:YES];
        kline = nil;
    }
}
@end
