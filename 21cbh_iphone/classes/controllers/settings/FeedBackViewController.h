//
//  FeedBackViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "BaseViewController.h"

@interface FeedBackViewController : BaseViewController<UITextViewDelegate>

-(void)feedBackSubmitInfoBack:(NSDictionary *)dic isSuccess:(BOOL)success;

@end
