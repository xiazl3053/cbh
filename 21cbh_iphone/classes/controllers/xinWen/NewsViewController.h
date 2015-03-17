//
//  NewsViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface NewsViewController : UIViewController<MainDelegate>
@property(weak,nonatomic)MainViewController *main;

@property(assign,nonatomic)BOOL isFirst;

#pragma mark 刷新滑动栏目
-(void)reloadPrograma;
#pragma mark 加载用户信息
-(void)loadUserInfo;
@end
