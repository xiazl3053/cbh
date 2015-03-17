//
//  SettingsViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsViewController.h"
#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController<UIAlertViewDelegate>

@property(weak,nonatomic)NewsViewController *nc;
@property(weak,nonatomic)MainViewController *main;
#pragma mark 加载用户信息
-(void)loadUserInfo;
@end
