//
//  AppDelegate.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-30.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(weak,nonatomic)UIViewController *currentController;
@property(weak,nonatomic)MainViewController *main;

#pragma mark 注册苹果推送服务
-(void)registerApplePush;

@end
