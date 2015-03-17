//
//  MarketStatisticsViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "transformImageView.h"
#import "tabButton.h"
@interface MarketViewController : BaseViewController<MainDelegate>

@property (strong,nonatomic) transformImageView *transformImage ;// 刷新状态图片
@property (nonatomic,strong) tabButton *tabButtonView;
@property (nonatomic,assign) CGFloat changeHeight;// 根据底部导航的隐藏与否来确定高度
@property (nonatomic,retain) UIButton *searchButton;//搜索按钮
@end
