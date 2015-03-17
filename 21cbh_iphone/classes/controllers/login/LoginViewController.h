//
//  LoginViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LoginInputView.h"


@interface LoginViewController : BaseViewController<LoginInputViewDelegate>


#pragma mark 登陆后的处理
-(void)getLoginHandleWithMsg:(NSString *)msg error:(NSInteger)error;
#pragma mark sso登录后的处理
-(void)getLoginSSOHandleWithMsg:(NSString *)msg error:(NSInteger)error isFirst:(NSInteger)isFirst;
@end
