//
//  BaseViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface BaseViewController : UIViewController<MainDelegate>

@property(weak,nonatomic)MainViewController *main;
@property(assign,nonatomic)NSInteger returnType;
@property(assign,nonatomic)UIView *backView;//标题栏顶部背景蒙版
@property(assign,nonatomic)UILabel *lable;//标题栏的标题
@property(assign,nonatomic)UIView *topLine;//top的底部分割线
@property(assign,nonatomic)UIButton *returnBtn;//返回键

#pragma mark 初始化top栏和返回按钮
-(UIView *)Title:(NSString *)title returnType:(NSInteger) type;
#pragma mark 返回主界面
-(void)returnBack;

@end
