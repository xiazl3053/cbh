//
//  huShenViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hqBaseViewController.h"

@interface huShenViewController : hqBaseViewController
#pragma mark 初始化
-(id)initWithParent:(UIViewController*)controller andFrame:(CGRect)frame;
#pragma mark 接口返回
-(void)getHushenStocksIndexBundle:(NSDictionary*)hu andShen:(NSDictionary*)shen;
#pragma mark 请求接口
-(void)getHushenStocksIndex:(BOOL)isAsyn;
@end
