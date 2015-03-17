//
//  mainTableView.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "mainTableView.h"
#import "baseTableView.h"
#import "BaseViewController.h"
#import "MJRefresh.h"
#import "DCommon.h"

#define kTableTitleHeight 40
#define kTitleWidth self.frame.size.width/4
#define kTitleBackground UIColorFromRGB(0xf0f0f0);
#define kTitleFont [UIFont fontWithName:kFontName size:15]
#define kTitleColor UIColorFromRGB(0x808080)

@interface mainTableView(){
    UIImage *_dupImg;
    UIImage *_ddownImg;
    UIImageView *_arrowsView;
    CGFloat _leftX ;
    UILabel *_footerStateLabel; // 上啦刷新显示页码

}


@end

@implementation mainTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)dealloc{
    
    [self free];
}

-(void)free{
    self.baseController = nil;
    self.mainView = nil;
    [self.leftTableView removeAllSubviews];
    self.leftTableView = nil;
    self.leftTitleView = nil;
    self.rightView = nil;
    self.rightTitleView = nil;
    [self.rightTableView removeAllSubviews];
    self.rightTableView = nil;
    if (self.data) {
        if ([[self.data class] isSubclassOfClass:[NSMutableArray class]]) {
            [self.data removeAllObjects];
        }
    }
    if (self.titleData) {
        if ([[self.titleData class] isSubclassOfClass:[NSMutableArray class]]) {
            [self.titleData removeAllObjects];
        }
    }
    self.data = nil;
    self.titleData = nil;
    self.titleButtonClickBlock = nil;
    [_header free];
    [_footer free];
    _header = nil;
    _footer = nil;
    
}

-(void)clear{
    
}


#pragma mark ---------------------------------自定义方法----------------------------------

-(id)initWithController:(id)controller andFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = controller;
        self.dataSource = controller;
        _baseController = controller;
        // 初始化变量
        [self initParam];
        
    }
    return self;
}
#pragma mark 初始化并显示控件
-(void)show{
    // 封装数据
    [self initDatas];
    // 初始化控件
    [self initView];
    // 添加刷新下拉控件
    [self addHeader];
    // 添加刷新上啦控件
    [self addFooter];
}

#pragma mark 更新表格等控件
-(void)update{
    // 初始化控件
    [self updateView];
}

#pragma mark 初始化参数
-(void)initParam{
    self.backgroundColor = ClearColor;
    self.leftWidth = kTitleWidth;
    self.isScrollLeft = YES;
    self.listType = 0;
    self.isShowRefreshHeader = YES;
    self.isShowRefreshFooter = NO;
    self.buttonIndex = 1;
    self.isContainSelf = NO; // 默认不包含自己
    self.isClick=YES;
    _leftX = 0;
    _dupImg = [UIImage imageNamed:@"D_DOWNN.png"];
    _ddownImg = [UIImage imageNamed:@"D_UPP.png"];
    _arrowsView = [[UIImageView alloc] init];
    _buttonState = [[NSMutableArray alloc] init];
}

#pragma mark 封装数据
-(void)initDatas{
    switch (self.listType) {
        case 0:
        case 2:
        {
            self.titleData = [[NSMutableArray alloc] initWithObjects:
                              @"名称",
                              @"最新",
                              @"涨幅",
                              @"涨跌",
                              @"总手",
                              @"金额",
                              @"最高",
                              @"最低",
                              @"换手",
                              @"市盈",
                              @"总市值",
                              @"流通市值",
                              nil];
            break;
        }
            
        case 1:{
            self.titleData = [[NSMutableArray alloc] initWithObjects:
                              @"名称",
                              @"涨幅",
                              @"三日涨",
                              @"领涨股",
                              @"总额",
                              @"总手",
                              @"最新",
                              @"换手",
                              @"三日换",
                              @"总市值",
                              @"流通市值",
                              nil];
            break;
        }
        default:
            break;
    }
}


#pragma mark 初始化控件
-(void)initView{
    [self addTableTitleView];
    // 添加标题
    CGFloat btWidth = kTableViewCellRowWidth;
    CGFloat rightWidth = (self.titleData.count-1)*btWidth;
    if ((int)rightWidth<(int)self.frame.size.width-self.leftWidth) {
        rightWidth = self.frame.size.width-self.leftWidth;
    }
    // 主视图
    self.mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                   kTableTitleHeight,
                                                                   self.frame.size.width,
                                                                   self.frame.size.height-kTableTitleHeight
                                                                   )];
    self.mainView.backgroundColor = ClearColor;
    self.mainView.scrollEnabled = YES;
    self.mainView.bounces = YES;
    self.mainView.contentSize = CGSizeMake(self.frame.size.width, self.mainView.frame.size.height+1);
    self.mainView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self addSubview:self.mainView];
    if (self.selfTitleView && self.isContainSelf) {
        self.mainView.frame = CGRectMake(0, kTableTitleHeight+self.selfTitleView.frame.size.height,
                                         self.selfTitleView.frame.size.width,
                                         self.selfTitleView.frame.size.height-self.selfTitleView.frame.size.height);
    }
    // 有数据才加上表格
    // 左边表格视图
    
    self.leftTableView = [[baseTableView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         self.leftWidth,
                                                                         self.mainView.frame.size.height)];
    self.leftTableView.delegate = self.delegate;
    self.leftTableView.dataSource = self.dataSource;
    self.leftTableView.scrollEnabled = NO;
    if (kDeviceVersion>=7) {
        //self.leftTableView.separatorInset = UIEdgeInsetsMake(0, 13, 0, 0);
    }
    
    // 右边表格盒子视图
    self.rightView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.leftWidth,
                                                                    0,
                                                                    self.frame.size.width-self.leftWidth,
                                                                    self.mainView.frame.size.height)];
    self.rightView.backgroundColor = ClearColor;
    
    self.rightView.scrollEnabled = self.isScrollLeft;
    self.rightView.contentSize = CGSizeMake(rightWidth, self.mainView.frame.size.height);
    self.rightView.alwaysBounceHorizontal = NO;
    self.rightView.showsHorizontalScrollIndicator = NO;
    self.rightView.bounces = NO;
    self.rightView.delegate = self;
    //self.rightView.contentOffset = CGPointMake(_leftX, self.rightView.contentOffset.y);
    // 右边表格视图
    self.rightTableView = [[baseTableView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          rightWidth,
                                                                          self.mainView.frame.size.height)];
    self.rightTableView.delegate = self.delegate;
    self.rightTableView.dataSource = self.dataSource;
    self.rightTableView.scrollEnabled = NO;
    if (kDeviceVersion>=7) {
        //self.rightTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 13);
    }

}
#pragma mark 更新表格等视图
-(void)updateView{
    if (self.data.count>0) {
        // 添加视图
        if (!self.leftTableView.superview) {
            [self.mainView addSubview:self.leftTableView];
            [self.rightView addSubview:self.rightTableView];
            [self.mainView addSubview:self.rightView];
        }
        
        if (_footer) {
            if (self.page>0) {
                int page = self.page+1;
                if (page>=self.pageCount) {
                    page = self.pageCount;
                }
                _footerStateLabel.text = [[NSString alloc] initWithFormat:@"查看第%d页/共%d页",page,self.pageCount<self.page?self.page:self.pageCount];
            }
        }
        if (_header) {
            if (self.page>0) {
                
                _header.lastUpdateTimeLabel.text = [[NSString alloc] initWithFormat:@"当前第%d页/共%d页",self.page,self.pageCount<self.page?self.page:self.pageCount];
            }
        }
    }
}
#pragma mark 根据数据量重设表格的高度
-(void)SetTableHeight:(CGFloat)height{
    // 主视图改变了高度 主要是由于底部tab隐藏和显示引起
    CGFloat newheight = [DCommon getChangeHeight];
    CGFloat marketTabButtonHeight = self.mainHeight; // 中间区域高度
    CGFloat defaultSelfHeight = marketTabButtonHeight+newheight;
    CGFloat mainHeight = defaultSelfHeight - 25 - kTableTitleHeight;
    if (height==mainHeight) {
        height --;
    }
    // 相应的改变各个视图的高度以适应框架
    self.leftTableView.frame = CGRectMake(self.leftTableView.frame.origin.x, 0, self.leftTableView.frame.size.width, height);
    self.rightTableView.frame = CGRectMake(self.rightTableView.frame.origin.x, 0, self.rightTableView.frame.size.width, height);
    self.rightView.frame = CGRectMake(self.rightView.frame.origin.x, 0, self.rightView.frame.size.width, height);
    self.rightView.contentSize = CGSizeMake(self.rightView.contentSize.width, height);
    self.mainView.contentSize = CGSizeMake(self.mainView.contentSize.width, (int)height<(int)self.mainView.frame.size.height?self.frame.size.height+1:height);

    // 主视图在原有的基础上变化高度
    self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width,mainHeight);
    // 表格是否有标题
    if (self.selfTitleView && self.isContainSelf){
        self.selfTitleView.frame = CGRectMake(self.selfTitleView.frame.origin.x, self.selfTitleView.frame.origin.y, self.rightTableView.frame.size.width, self.selfTitleView.frame.size.height);
    }
    // NSLog(@"maintableView的高度：%@，里面的mainView高度：%@",self,self.mainView);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, defaultSelfHeight);

}

#pragma mark 添加表格标题
-(void)addTableTitleView{
    if (!self.leftTitleView) {
        CGFloat btWidth = kTableViewCellRowWidth;
        CGFloat rightWidth = (self.titleData.count-1)*btWidth;
        if ((int)rightWidth<(int)self.frame.size.width-self.leftWidth) {
            rightWidth = self.frame.size.width-self.leftWidth;
        }
        // 加一个上下箭头
        _arrowsView.frame = CGRectMake(0,(kTableTitleHeight-_dupImg.size.height)/2, _dupImg.size.width,_dupImg.size.height);

        // 左边标题
        self.leftTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.leftWidth, kTableTitleHeight)];
        self.leftTitleView.backgroundColor = kTitleBackground;
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.leftWidth, kTableTitleHeight)];
        [leftButton setTitle:[self.titleData objectAtIndex:0] forState:UIControlStateNormal];
        [leftButton setTitleColor:kTitleColor forState:UIControlStateNormal];
        leftButton.tag = 0;
        [leftButton addTarget:self action:@selector(clickButonAction:) forControlEvents:UIControlEventTouchUpInside];
        leftButton.titleLabel.font = kTitleFont;
        [self.leftTitleView addSubview:leftButton];
        // 添加一根分割线
        UIView *line = [DCommon drawLineWithSuperView:self.leftTitleView position:NO];
        line.backgroundColor = UIColorFromRGB(0x808080);
        // 右边标题
        self.rightTitleView = [[UIView alloc] initWithFrame:CGRectMake(self.leftWidth,
                                                                       0 ,
                                                                       rightWidth,
                                                                       kTableTitleHeight)];
        self.rightTitleView.backgroundColor = kTitleBackground;
        // 添加一根分割线
        UIView *rline = [DCommon drawLineWithSuperView:self.rightTitleView position:NO];
        rline.backgroundColor = UIColorFromRGB(0x808080);
        // 添加按钮
        [_buttonState addObject:[NSNumber numberWithBool:NO]];
        CGFloat x = 0;
        for (int i = 1; i<self.titleData.count; i++) {
            UIButton *itemButton = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, btWidth, kTableTitleHeight)];
            [itemButton setTitle:[self.titleData objectAtIndex:i] forState:UIControlStateNormal];
            [itemButton setTitleColor:kTitleColor forState:UIControlStateNormal];
            itemButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            itemButton.titleLabel.font = kTitleFont;
            itemButton.showsTouchWhenHighlighted = YES;
            itemButton.tag = i;
            [itemButton addTarget:self action:@selector(clickButonAction:) forControlEvents:UIControlEventTouchUpInside];
            // 如果要默认某个按钮
            if (self.buttonIndex>1 && self.buttonIndex==i) {
                [itemButton setTitleColor:kBrownColor forState:UIControlStateNormal];
                [_buttonState addObject:[NSNumber numberWithInt:self.orderBy]];
                // 箭头
                _arrowsView.image = self.orderBy==0?_dupImg:_ddownImg;
                CGFloat x = itemButton.frame.origin.x;
                CGFloat tx = itemButton.titleLabel.frame.origin.x+itemButton.titleLabel.frame.size.width+3;
                CGFloat imgX = x+tx;
                _arrowsView.frame = CGRectMake(imgX, _arrowsView.frame.origin.y, _arrowsView.frame.size.width, _arrowsView.frame.size.height);
            }else{
                [_buttonState addObject:[NSNumber numberWithBool:YES]];// 按钮默认状态为升序
            }
            [self.rightTitleView addSubview:itemButton];
            itemButton = nil;
            x += btWidth;
        }
        
        [self.rightTitleView addSubview:_arrowsView];
        
        [self addSubview:self.rightTitleView];
        [self addSubview:self.leftTitleView];
    }
    // 创建一个固定的标题视图
    if (self.isContainSelf && !self.selfTitleView) {
        self.selfTitleView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     self.leftTitleView.frame.size.height+self.leftTitleView.frame.origin.y,
                                                                     self.frame.size.width,
                                                                     self.leftTitleView.frame.size.height)];
        self.selfTitleView.backgroundColor = kBackgroundcolor;
        UIView *selfline = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   self.selfTitleView.frame.size.height-1,
                                                                   self.selfTitleView.frame.size.width,
                                                                   1)];
        selfline.backgroundColor = UIColorFromRGB(0x999999);
        [self.selfTitleView addSubview:selfline];
        [self addSubview:self.selfTitleView];
        
    }
}
#pragma mark 点击标题
-(void)clickButonAction:(UIButton*)button{
    
    if (!self.isClick) {
        NSLog(@"=======数据没有返回不可点击==========");
        return ;
    }
    
    CGFloat x = button.frame.origin.x;
    CGFloat tx = button.titleLabel.frame.origin.x+button.titleLabel.frame.size.width+3;
    CGFloat imgX = x+tx;
    if (button.tag>0) {
        _arrowsView.hidden = NO;
        _arrowsView.frame = CGRectMake(imgX, _arrowsView.frame.origin.y, _arrowsView.frame.size.width, _arrowsView.frame.size.height);
        if ([[_buttonState objectAtIndex:button.tag] boolValue]) {
            _arrowsView.image = _dupImg;
            [_buttonState replaceObjectAtIndex:button.tag withObject:[NSNumber numberWithBool:NO]]; // 设置按钮状态为降序
        }else{
            _arrowsView.image = _ddownImg;
            [_buttonState replaceObjectAtIndex:button.tag withObject:[NSNumber numberWithBool:YES]]; // 设置按钮状态为升序
        }
    }else{
        _arrowsView.hidden = YES;
    }
    
    
    // 所有按钮恢复原来的颜色
    for (UIView *item in self.rightTitleView.subviews) {
        if ([item class]==[UIButton class]) {
            UIButton *itemButton = (UIButton*)item;
            [itemButton setTitleColor:kTitleColor forState:UIControlStateNormal];
            if (itemButton.tag!=button.tag) {
                [_buttonState replaceObjectAtIndex:itemButton.tag withObject:[NSNumber numberWithBool:YES]]; // 设置按钮状态为升序
            }
        }
    }
    
    UIButton *firstButton = [[self.leftTitleView subviews] objectAtIndex:0];
    [firstButton setTitleColor:kTitleColor forState:UIControlStateNormal];
    firstButton = nil;
    
    // 当前按钮变色
    [button setTitleColor:kBrownColor forState:UIControlStateNormal];
    
    self.buttonIndex = button.tag;
    // 回调block
    if (self.titleButtonClickBlock) {
        self.titleButtonClickBlock(self);
    }
}
#pragma mark 刷新表格数据
-(void)reloadData{
    if (self.leftTableView) {
        [self.leftTableView reloadData];
    }
    if (self.rightTableView) {
        [self.rightTableView reloadData];
    }
}

#pragma mark 添加刷新控件头部
-(void)addHeader{
    if (self.isShowRefreshHeader) {
        __unsafe_unretained mainTableView *bc = self;
        _header = [MJRefreshHeaderView header];
        _header.scrollView = self.mainView;
        _header.activityView.color=K808080;
        // 开始刷新Block
        _header.beginRefreshingBlock = ^(MJRefreshBaseView* refreshView){
            //[bc.transformImage start];
            //[bc beginRefreshTableView:refreshView];
            [bc performSelector:@selector(beginRefreshTableView:) withObject:refreshView afterDelay:0];
        };
        // 结束刷新Block
        _header.endStateChangeBlock = ^(MJRefreshBaseView* refreshView){
            //[bc.transformImage stop];
            //[bc endRefreshTableView:refreshView];
            [bc performSelector:@selector(endRefreshTableView:) withObject:refreshView afterDelay:0];
        };
    }
}

#pragma mark 添加刷新控件尾部
-(void)addFooter{
    if (self.isShowRefreshFooter) {
        __unsafe_unretained mainTableView *bc = self;
        _footer = [MJRefreshFooterView footer];
        _footer.scrollView = self.mainView;
        _footer.activityView.color=K808080;
        if (!_footerStateLabel) {
            _footerStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(_footer.bounds.origin.x,
                                                                          _footer.statusLabel.frame.size.height+_footer.statusLabel.frame.origin.y,
                                                                          _footer.frame.size.width,
                                                                          30)];
            _footerStateLabel.font = _header.lastUpdateTimeLabel.font;
            _footerStateLabel.textColor = _header.lastUpdateTimeLabel.textColor;
            _footerStateLabel.textAlignment = NSTextAlignmentCenter;
            _footerStateLabel.backgroundColor = ClearColor;
            [_footer addSubview:_footerStateLabel];
        }
        // 开始刷新Block
        _footer.beginRefreshingBlock = ^(MJRefreshBaseView* refreshView){
            //[bc.transformImage start];
            //[bc moreRefreshTableView:refreshView];
            [bc performSelector:@selector(moreRefreshTableView:) withObject:refreshView afterDelay:0];
        };
        // 结束刷新Block
        _footer.endStateChangeBlock = ^(MJRefreshBaseView* refreshView){
            //[bc.transformImage stop];
            //[bc endRefreshTableView:refreshView];
            [bc performSelector:@selector(endRefreshTableView:) withObject:refreshView afterDelay:0];
        };
    }
}

#pragma mark -----------------------------mainTableViewDelegate刷新代理通知------------------------------

#pragma mark 开始刷新通知代理
-(void)beginRefreshTableView:(MJRefreshBaseView*)refreshView{
    
    // 通知代理
    NSLog(@"---DFM---beginRefreshTableView");
    if([_refreshDelegate respondsToSelector:@selector(mainTableBeginRefreshing:)])
    {
        [_refreshDelegate mainTableBeginRefreshing:refreshView];
    }
    //[refreshView endRefreshing];
}

#pragma mark 刷新加载更多通知代理
-(void)moreRefreshTableView:(MJRefreshBaseView*)refreshView{
    // 通知代理
    NSLog(@"---DFM---mainTableMoreRefreshing");
    if([_refreshDelegate respondsToSelector:@selector(mainTableMoreRefreshing:)])
    {
        [_refreshDelegate mainTableMoreRefreshing:refreshView];
    }
    //[refreshView endRefreshing];
}

#pragma mark 结束刷新通知代理
-(void)endRefreshTableView:(MJRefreshBaseView*)refreshView{
    // 通知代理
    NSLog(@"---DFM---endRefreshTableView");
    if([_refreshDelegate respondsToSelector:@selector(mainTableEndRefreshing:)])
    {
        [_refreshDelegate mainTableEndRefreshing:refreshView];
    }

}


#pragma mark ------------------------------scrollview 代理实现----------------------------------
#pragma mark 同步移动标题
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat x = scrollView.bounds.origin.x;
    self.rightTitleView.frame = CGRectMake(self.leftWidth-x,
                                           self.rightTitleView.frame.origin.y,
                                           self.rightTitleView.frame.size.width,
                                           self.rightTitleView.frame.size.height);
    _leftX = -x; // 保存右边表格的x轴
}
@end
