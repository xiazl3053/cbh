//
//  mainTableView.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "BaseViewController.h"
#import "hqBaseViewController.h"
@class mainTableView;
@class baseTableView;
@protocol mainTableViewDelegate <NSObject>
@optional
// 开始进入刷新状态就会调用
- (void)mainTableBeginRefreshing:(MJRefreshBaseView*)refreshView;
// 刷新完毕就会调用
- (void)mainTableEndRefreshing:(MJRefreshBaseView*)refreshView;
// 刷新加载更多
-(void)mainTableMoreRefreshing:(MJRefreshBaseView*)refreshView;

@end

// 添加一个点击按钮的Block
typedef void(^titleButtonClickActionBlock)(mainTableView *maintable);

@interface mainTableView : UIView<UIScrollViewDelegate,MJRefreshBaseViewDelegate>

@property (nonatomic,retain) MJRefreshHeaderView *header;
@property (nonatomic,retain) MJRefreshFooterView *footer;
@property (nonatomic,retain) hqBaseViewController *baseController;
@property (nonatomic,strong) UIScrollView *mainView; // 主视图
@property (nonatomic,strong) UITableView *leftTableView; // 左边的表格
@property (nonatomic,strong) UIScrollView *rightView; // 右边的视图
@property (nonatomic,strong) UITableView *rightTableView; // 右边的表格
@property (nonatomic,strong) UIView *leftTitleView; // 左边的标题视图
@property (nonatomic,strong) UIView *rightTitleView; // 右边的标题视图
@property (nonatomic,strong) UIView *selfTitleView; // 在表格上，标题下显示一个固定的视图
@property (nonatomic,retain) NSMutableArray *data; // 表格数据
@property (nonatomic,retain) NSMutableArray *titleData; // 标题数据
@property (nonatomic,assign) CGFloat leftWidth; // 左边表格的宽度
@property (nonatomic,assign) id<UITableViewDelegate> delegate; // 表格的代理
@property (nonatomic,assign) id<UITableViewDataSource> dataSource;// 表格的代理
@property (nonatomic,assign) id<mainTableViewDelegate> refreshDelegate; // 本身代理
@property (nonatomic,assign) BOOL isScrollLeft; // 右边视图是否滚动;
@property (nonatomic,assign) BOOL isShowRefreshHeader; // 是否显示上啦刷新
@property (nonatomic,assign) BOOL isShowRefreshFooter; // 是否显示下啦刷新
@property (nonatomic,assign) int listType; // 0为个股列表 1为板块列表 2为行业板块个股列表
@property (nonatomic,copy) titleButtonClickActionBlock titleButtonClickBlock; // 点击按钮
@property (nonatomic,retain) NSMutableArray *buttonState; // 保存按钮的状态
@property (nonatomic,assign) BOOL isContainSelf;// 是否包含自己 如果包含就会在表格上显示一个自己的标题
@property (nonatomic,retain) transformImageView *transformImage;
@property (nonatomic,assign) int page ; // 当前页码
@property (nonatomic,assign) int pageCount; // 总页数
@property (nonatomic,assign) CGFloat changeHeight;//视图动态改变高度
@property (nonatomic,assign) int buttonIndex;// 按钮位置
@property (nonatomic,assign) int orderBy;// 排序类型 0=降序 1=升序
@property (nonatomic,assign) CGFloat mainHeight; // 主视图高度
@property (nonatomic,assign) BOOL isClick;//数据返回可点击


// 初始化方法
-(id)initWithController:(id)controller andFrame:(CGRect)frame;
-(void)show;
-(void)update;
// 释放资源
-(void)free;
-(void)clear;
// 刷新tableView
-(void)reloadData;
// 重设tableview的高度
-(void)SetTableHeight:(CGFloat)height;
@end


