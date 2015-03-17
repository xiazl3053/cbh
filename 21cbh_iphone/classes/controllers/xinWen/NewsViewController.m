//
//  NewsViewController.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsListViewController.h"
#import "NewsListViewController2.h"
#import "PicListViewController.h"
#import "FileOperation.h"
#import "SettingsViewController.h"
#import "XHMenu.h"
#import "XHScrollMenu.h"
#import "CommonOperation.h"
#import "UIImageView+WebCache.h"
#import "MLNavigationController.h"
#import "UIImage+ZX.h"

@interface NewsViewController ()<XHScrollMenuDelegate, UIScrollViewDelegate>{
    
    BOOL _isFirstAdaptive;
    CGFloat _scrollWidth;
    __block UIImageView *_head;//头像
    __block CGSize _imgSize;
    MLNavigationController *_ml;
    NSString *_lastProgramName;
    NSInteger _index;//当前选中的item控制器
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) XHScrollMenu *scrollMenu;
@property (nonatomic, strong) NSMutableArray *menus;
@property (nonatomic, assign) BOOL shouldObserving;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *titiles;
@property (nonatomic, strong) NSMutableDictionary *types;
@property (nonatomic, strong) NSMutableDictionary *topTypes;
@property (nonatomic, strong)NSMutableDictionary *controllers;//存放控制器的字典
@property (nonatomic, strong)NSMutableArray *views;//scrollView里的子View
@property (nonatomic, strong) FileOperation *fo;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    //初始化数据
    [self initParams];
    //初始化视图
    [self initViews];
    //注册通知
    [self registerNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    if (_isFirst) {
        [self reloadPrograma];
    }
    self.main.delegate=self;
    //加载用户图片
    [self loadUserInfo];
}


-(void)viewDidAppear:(BOOL)animated{
    _ml.canDragBack=NO;
    _ml.isMoving=NO;
    if (!_isFirst) {
        [self selectItemHandle];
    }
    if (_isFirst) {
        _isFirst=NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    _ml.canDragBack=YES;
    _ml.isMoving=YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _lastProgramName=nil;
    _titiles=nil;
    _types=nil;
    _fo=nil;
    _controllers=nil;
    [self stopObservingContentOffset];
    //注销通知
    [self removeNotification];
}

#pragma mark - ------------自定义方法--------------------

#pragma mark 注册通知
-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadUserInfo) name:kNotifcationKeyForLogout object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectItemHandle) name:kNotifcationKeyForActive object:nil];
}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForLogout object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForActive object:nil];
}


-(void)getData{
    for (int i=0; i<_views.count; i++) {
        UIView *view=[_views objectAtIndex:i];
        [view removeFromSuperview];
    }
    
    [self.menus removeAllObjects];
    self.menus=nil;
    self.menus=[NSMutableArray array];
    
    for (int i = 0; i < _titiles.count; i ++) {
        XHMenu *menu = [[XHMenu alloc] init];
        
        NSString *title =[_titiles objectAtIndex:i];
        menu.title = title;
        
        menu.titleNormalColor = UIColorFromRGB(0x636363);
        menu.titleSelectedColor=UIColorFromRGB(0xe86e25);
        menu.titleFont = [UIFont fontWithName:kFontName size:18];
        
        [self.menus addObject:menu];
        
        UIViewController *item =[_controllers objectForKey:[_titiles objectAtIndex:i]];
        //初始化子控制器
        item=[self initItemWithItem:item index:i];
        item.view.frame = CGRectMake(i * CGRectGetWidth(_scrollView.bounds), 0, CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds));
        [_scrollView addSubview:item.view];
        [_views addObject:item.view];
        [self addChildViewController:item];
    }
    [_scrollView setContentSize:CGSizeMake(self.menus.count * CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds))];
    CGRect frame =_scrollMenu.scrollView.frame;
    //    frame.origin.x =_scrollMenu.scrollView.contentSize.width>self.view.frame.size.width?10.0:(self.view.frame.size.width-_scrollMenu.scrollView.contentSize.width)*0.5f;
    frame.origin.x=10;
    frame.size.width =_scrollMenu.scrollView.contentSize.width>self.view.frame.size.width?_scrollWidth:(_scrollWidth);
    //NSLog(@"_scrollMenu.scrollView.contentSize.width:%f",_scrollMenu.scrollView.contentSize.width);
    _scrollMenu.scrollView.frame=frame;
    _scrollMenu.menus = self.menus;
    //刷新数据
    [_scrollMenu reloadData];
    //设置左右提示线是否隐藏
    [_scrollMenu setStatus:_scrollMenu.scrollView];
}

#pragma mark 刷新滑动栏目
-(void)reloadPrograma{
    //获取新数据
    [self getPlistData];
    [self getData];
}
#pragma mark 读取plist数据
-(void)getPlistData{
    //读取本地的plist
    _titiles=[[_fo getLocalPlistWithFileDirName:KPlistDirName fileName:KPlistName] objectForKey:KPlistKey0];
    if (!_titiles) {
        _titiles=kProgramTitles;
    }
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"21cbh" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    _types=[data objectForKey:KPlistKey1];
    _topTypes=[data objectForKey:KPlistKey11];
    data=nil;
}
#pragma mark 初始化数据
-(void)initParams{
    _isFirst=YES;
    _fo=[[FileOperation alloc] init];
    _controllers=[NSMutableDictionary dictionary];
    _views=[NSMutableArray array];
    if (!_menus) {
        _menus = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [self getPlistData];
    
    _ml=(MLNavigationController *)[[CommonOperation getId] getMain].navigationController;
}
#pragma mark 初始化视图
-(void)initViews{
    self.view.backgroundColor=UIColorFromRGB(0xf0f0f0);
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@" - ", @" + ", nil]];
    _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    //[_segmentedControl addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    CGRect segmentedControlFrame = _segmentedControl.frame;
    segmentedControlFrame.origin = CGPointMake(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(segmentedControlFrame), 0);
    _segmentedControl.frame = segmentedControlFrame;
    [self.view addSubview:self.segmentedControl];
    self.segmentedControl.hidden=YES;
    
    _scrollMenu = [[XHScrollMenu alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 45)];
    _scrollMenu.backgroundColor =UIColorFromRGB(0xf0f0f0);
    UIScrollView *scroll=_scrollMenu.scrollView;
    CGRect frame=scroll.frame;
    frame.size.width-=5;
    scroll.frame=frame;
    _scrollWidth=scroll.frame.size.width;
    
    UIImage *img=[UIImage imageNamed:@"settings"];
    _imgSize=img.size;
    frame=_scrollMenu.managerMenusButton.frame;
    frame.size.width=img.size.width;
    frame.size.height=img.size.height;
    frame.origin.y=(_scrollMenu.frame.size.height-img.size.height)*0.5f-2;
    frame.origin.x=_scrollMenu.frame.size.width-img.size.width-10;
    _head=[[UIImageView alloc] initWithFrame:frame];
    _head.layer.masksToBounds = YES;
    _head.layer.cornerRadius=12;
    //    // 圆角描边线的宽度
    //    _head.layer.borderWidth = 0.1;
    //    // 圆角描边线的颜色
    //    _head.layer.borderColor = [kffffff CGColor];
    [_head setImage:[[UIImage imageNamed:@"settings1"] scaleToSize:CGSizeMake(25, 25)]];
    [_scrollMenu addSubview:_head];
    [_scrollMenu bringSubviewToFront:_scrollMenu.managerMenusButton];
    
    
    //ios7适配
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        CGRect frame=_scrollMenu.frame;
        frame.origin.y+=20;
        _scrollMenu.frame=frame;
        
        UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        backView.backgroundColor=UIColorFromRGB(0xf0f0f0);
        [self.view addSubview:backView];
    }
    _scrollMenu.delegate = self;
    //    _scrollMenu.selectedIndex = 3;
    [self.view addSubview:self.scrollMenu];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollMenu.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(_scrollMenu.frame))];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    [self startObservingContentOffsetForScrollView:_scrollView];
    
    //顶部与内容之间的分割线
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, _scrollMenu.frame.origin.y+_scrollMenu.frame.size.height+0.5f, self.view.frame.size.width, 0.5f)];
    line.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [self.view addSubview:line];
}

#pragma mark 跳转到设置页面
-(void)clickSettings{
    SettingsViewController *settings=[[SettingsViewController alloc] init];
    settings.nc=self;
    settings.main=self.main;
    [self.main addChildViewController:settings];
    [self.main.view addSubview:settings.view];
}

#pragma mark 加载用户信息
-(void)loadUserInfo{
    NSString *token=[[CommonOperation getId] getToken];
    bool islogin=(token)?YES:NO;
    if (islogin) {//用户已登陆
        UserModel *um=[UserModel um];
        [_head setImageWithURL:[NSURL URLWithString:um.picUrl] placeholderImage:[[UIImage imageNamed:@"settings_selected1"] scaleToSize:CGSizeMake(25, 25)] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        }];
    }else{//用户没登陆
        [_head setImage:[[UIImage imageNamed:@"settings1"] scaleToSize:CGSizeMake(25, 25)]];
    }
}

#pragma mark 初始化子控制器
-(UIViewController *)initItemWithItem:(UIViewController *)item index:(NSInteger)i{
    
    NSString *programName=[_titiles objectAtIndex:i];
    if([programName isEqualToString:@"图片"]){
        PicListViewController *plv=(PicListViewController *)item;
        if (!plv) {
            plv =[[PicListViewController alloc] init];
            plv.main=self.main;
            plv.programId=[_types objectForKey:[_titiles objectAtIndex:i]];
            plv.programName=[_titiles objectAtIndex:i];
            [_controllers setObject:plv forKey:[_titiles objectAtIndex:i]];
            item=plv;
        }
        
    }else if ([programName isEqualToString:@"推荐"]){
        NewsListViewController2 *nlv2=(NewsListViewController2 *)item;
        if (!nlv2) {
            nlv2 =[[NewsListViewController2 alloc] init];
            nlv2.main=self.main;
            nlv2.nvc=self;
            nlv2.programId=[_types objectForKey:[_titiles objectAtIndex:i]];
            nlv2.topProgramId=[_topTypes objectForKey:[_titiles objectAtIndex:i]];
            nlv2.programName=[_titiles objectAtIndex:i];
            [_controllers setObject:nlv2 forKey:[_titiles objectAtIndex:i]];
            item=nlv2;
        }
        
    }else{
        NewsListViewController *nlv=(NewsListViewController *)item;
        if (!nlv) {
            nlv =[[NewsListViewController alloc] init];
            nlv.main=self.main;
            nlv.nvc=self;
            nlv.programId=[_types objectForKey:[_titiles objectAtIndex:i]];
            nlv.topProgramId=[_topTypes objectForKey:[_titiles objectAtIndex:i]];
            nlv.programName=[_titiles objectAtIndex:i];
            [_controllers setObject:nlv forKey:[_titiles objectAtIndex:i]];
            item=nlv;
        }
        
    }
    return item;
}

#pragma mark 调整子控制器的table位置
-(void)adjustItemTableWithHeight:(CGFloat)height item:(UIViewController *)item{
    if ([item isKindOfClass:[NewsListViewController class]]) {
        NewsListViewController *nlv=(NewsListViewController *)item;
        [nlv setTableHeight:height];
    }else if([item isKindOfClass:[PicListViewController class]]){
        PicListViewController *plv=(PicListViewController *)item;
        [plv setTableHeight:height];
    }else if([item isKindOfClass:[NewsListViewController2 class]]){
        NewsListViewController2 *nlv2=(NewsListViewController2 *)item;
        [nlv2 setTableHeight:height];
    }
}

#pragma mark 开始当前界面百度统计
-(void)startBaiduStatisticsWithProgramName:(NSString *)programName{
    //结束旧的统计
    if (_lastProgramName) {
        //  NSLog(@"pageviewEndWithName===%@",_lastProgramID);
        [[Frontia getStatistics]pageviewEndWithName:_lastProgramName];
    }
    //开始新的统计
    _lastProgramName=programName;
    // NSLog(@"pageviewStartWithName===%@",programID);
    [[Frontia getStatistics]pageviewStartWithName:programName];
}

#pragma mark 子控制器刷新
-(void)itemRefreshWithItem:(UIViewController *)item{
    if ([item isKindOfClass:[NewsListViewController class]]) {
        NewsListViewController *nlv=(NewsListViewController *)item;
        [nlv refreshView];
        [self startBaiduStatisticsWithProgramName:nlv.programName];
    }else if([item isKindOfClass:[PicListViewController class]]){
        PicListViewController *plv=(PicListViewController *)item;
        [plv refreshView];
        [self startBaiduStatisticsWithProgramName:plv.programName];
    }else if([item isKindOfClass:[NewsListViewController2 class]]){
        NewsListViewController2 *nlv2=(NewsListViewController2 *)item;
        [nlv2 refreshView];
        [self startBaiduStatisticsWithProgramName:nlv2.programName];
    }
}

#pragma mark 停止刷新上一个控制器
-(void)endRefreshOtherItemWith:(NSInteger)index{
    if (index>_titiles.count-1) {
        index=0;
    }
    UIViewController *item =[_controllers objectForKey:[_titiles objectAtIndex:index]];
    if ([item isKindOfClass:[NewsListViewController class]]) {
        NewsListViewController *nlv=(NewsListViewController *)item;
        [nlv endRefreshView];
    }else if([item isKindOfClass:[PicListViewController class]]) {
        PicListViewController *plv=(PicListViewController *)item;
        [plv endRefreshView];
    }else if([item isKindOfClass:[NewsListViewController2 class]]) {
        NewsListViewController2 *nlv2=(NewsListViewController2 *)item;
        [nlv2 endRefreshView];
    }
}

#pragma mark 选中某个item控制器时的处理
-(void)selectItemHandle{
    UIViewController *item =[_controllers objectForKey:[_titiles objectAtIndex:_index]];
    //刷新选中子控制器界面
    [self itemRefreshWithItem:item];
}


#pragma mark - -----------------XHScrollMenu的代理方法-------------------
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
}

- (void)stopObservingContentOffset
{
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.scrollView = nil;
    }
}

- (void)scrollMenuDidSelected:(XHScrollMenu *)scrollMenu menuIndex:(NSUInteger)selectIndex {
    
    // NSLog(@"selectIndex : %d", selectIndex);
    self.shouldObserving = NO;
    [self menuSelectedIndex:selectIndex];
    
}

- (void)scrollMenuDidManagerSelected:(XHScrollMenu *)scrollMenu {
    //NSLog(@"scrollMenuDidManagerSelected");
    [self clickSettings];
}

- (void)menuSelectedIndex:(NSUInteger)index {
    if (index>_titiles.count-1) {
        index=0;
    }
    CGRect visibleRect = CGRectMake(index * CGRectGetWidth(self.scrollView.bounds), 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    [self.scrollView scrollRectToVisible:visibleRect animated:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.scrollView scrollRectToVisible:visibleRect animated:NO];
    } completion:^(BOOL finished) {
        self.shouldObserving = YES;
        //停止刷新上一个的子控制器
        [self endRefreshOtherItemWith:_index];
        _index=index;
        //选中某个item控制器时的处理
        [self selectItemHandle];
        
    }];
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    int currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.scrollMenu setSelectedIndex:currentPage animated:YES calledDelegate:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"] && self.shouldObserving) {
        //每页宽度
        CGFloat pageWidth = self.scrollView.frame.size.width;
        //根据当前的坐标与页宽计算当前页码
        NSUInteger currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (currentPage > self.menus.count - 1)
            currentPage = self.menus.count - 1;
        
        CGFloat oldX = currentPage * CGRectGetWidth(self.scrollView.frame);
        if (oldX != self.scrollView.contentOffset.x) {
            BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
            NSInteger targetIndex = (scrollingTowards) ? currentPage + 1 : currentPage - 1;
            if (targetIndex >= 0 && targetIndex < self.menus.count) {
                CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
                CGRect previousMenuButtonRect = [self.scrollMenu rectForSelectedItemAtIndex:currentPage];
                CGRect nextMenuButtonRect = [self.scrollMenu rectForSelectedItemAtIndex:targetIndex];
                CGFloat previousItemPageIndicatorX = previousMenuButtonRect.origin.x;
                CGFloat nextItemPageIndicatorX = nextMenuButtonRect.origin.x;
                
                /* this bug for Memory
                 UIButton *previosSelectedItem = [self.scrollMenu menuButtonAtIndex:currentPage];
                 UIButton *nextSelectedItem = [self.scrollMenu menuButtonAtIndex:targetIndex];
                 [previosSelectedItem setTitleColor:[UIColor colorWithWhite:0.6 + 0.4 * (1 - fabsf(ratio))
                 alpha:1.] forState:UIControlStateNormal];
                 [nextSelectedItem setTitleColor:[UIColor colorWithWhite:0.6 + 0.4 * fabsf(ratio)
                 alpha:1.] forState:UIControlStateNormal];
                 */
                CGRect indicatorViewFrame = self.scrollMenu.indicatorView.frame;
                
                if (scrollingTowards) {
                    indicatorViewFrame.size.width = CGRectGetWidth(previousMenuButtonRect) + (CGRectGetWidth(nextMenuButtonRect) - CGRectGetWidth(previousMenuButtonRect)) * ratio+20;
                    indicatorViewFrame.origin.x = previousItemPageIndicatorX + (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio-10;
                } else {
                    indicatorViewFrame.size.width = CGRectGetWidth(previousMenuButtonRect) - (CGRectGetWidth(nextMenuButtonRect) - CGRectGetWidth(previousMenuButtonRect)) * ratio+20;
                    indicatorViewFrame.origin.x = previousItemPageIndicatorX - (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio-10;
                }
                
                self.scrollMenu.indicatorView.frame = indicatorViewFrame;
            }
        }
    }
}

#pragma mark - --------------------main的代理方法---------------------------
-(void)bottomDown:(UIView *)bottom{
    
    for (int i=0; i<_titiles.count; i++) {
        UIViewController *item =[_controllers objectForKey:[_titiles objectAtIndex:i]];
        [self adjustItemTableWithHeight:61 item:item];
    }
    
    
}


-(void)bottomUp:(UIView *)bottom{
    
    for (int i=0; i<_titiles.count; i++) {
        UIViewController *item =[_controllers objectForKey:[_titiles objectAtIndex:i]];
        [self adjustItemTableWithHeight:-61 item:item];
    }
}

@end
