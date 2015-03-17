//
//  ContactBaseViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-6-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#define KContactCellHeight 56

@interface ContactBaseViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic,strong)NSMutableArray *tempA;
@property (nonatomic,strong)NSMutableSet *xingset;
@property (nonatomic,strong)NSMutableArray *xingarray;
@property (nonatomic,strong)NSMutableDictionary *studic;
@property (nonatomic,strong)NSMutableArray *keyarray;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UISearchDisplayController *searchDisplayVC;
@property (nonatomic,strong)NSMutableArray *results;
@property (nonatomic,strong)NSMutableArray *searchData;
@property (nonatomic,strong)UISearchBar *searchBar;
@property (nonatomic,strong)UIView *searchBarView;
@property (nonatomic,assign)BOOL isSearching;


-(NSMutableArray *)zhongWenPaiXu:(NSMutableArray *)newArray;//默认传入一个存名字的数组
-(void)initSearchBar;
-(void)initTableView;
-(void)initData;

@end
