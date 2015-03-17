//
//  BindingMobileCheckCodeViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-7-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"

@interface BindingMobileCheckCodeViewController : BaseViewController

-(id)initWithPhoneNum:(NSString *)phoneNum;


#pragma mark 绑定手机号码的处理
-(void)bindPhoneHandleWithMsg:(NSString *)msg error:(NSInteger)error;

@end
