//
//  kTabbarController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-28.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kBaseViewController.h"
#import "KLineViewController.h"

@interface kTabbarController : kBaseViewController

@property (nonatomic,retain) UIView *butonView; // 股吧等按钮视图
@property (nonatomic,retain) KLineViewController *kLineView;

#pragma mark 界面准备好开始加载数据
-(void)startRun;
@end
