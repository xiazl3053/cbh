//
//  SelectStockViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-8-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"
#import "SearchStocksViewController.h"

@interface SelectStockViewController : BaseViewController

@property (nonatomic,assign) CGFloat changeHeight;// 根据底部导航的隐藏与否来确定高度
@property (nonatomic,retain) UIButton *searchButton;//搜索按钮
@property (nonatomic,copy) SelectStockUserClick userSelectStockinfo;


@end
