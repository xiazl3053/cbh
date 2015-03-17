//
//  RegisterBtnViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LoginInputView.h"
#import "LoginViewController.h"

@interface RegisterViewController : BaseViewController<LoginInputViewDelegate>

@property(weak,nonatomic)LoginViewController *lvc;
@property(assign,nonatomic)NSInteger platformId;//平台类型(0-本平台（21世纪网）, 1-腾讯QQ, 2-新浪微博)
@property(copy,nonatomic)NSString *platformUserId;//第三方平台用户ID

#pragma mark 登陆后的处理
-(void)getRegisterHandleWithMsg:(NSString *)msg error:(NSInteger)error;

@end
