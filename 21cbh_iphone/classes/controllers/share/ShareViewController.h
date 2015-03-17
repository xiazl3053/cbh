//
//  ShareViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ShareViewController : BaseViewController

-(id)initWithTitle:(NSString *)title url:(NSString *)url icon:(NSString *)icon controller:(UIViewController *)controller;

@end
