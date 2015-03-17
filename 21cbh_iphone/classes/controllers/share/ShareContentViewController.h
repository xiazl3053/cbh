//
//  ShareContentViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ShareContentViewController : BaseViewController<UITextViewDelegate>


-(id)initWithTitle:(NSString *)title url:(NSString *)url shareName:(NSString *)shareName shareIcon:(NSString *)shareIcon shareType:(NSInteger)shareType controller:(UIViewController *)controller;

@end
