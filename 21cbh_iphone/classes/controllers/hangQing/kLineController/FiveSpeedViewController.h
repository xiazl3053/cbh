//
//  FiveSpeedViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kBaseViewController.h"

@interface FiveSpeedViewController : kBaseViewController

#pragma mark 初始化控制器
-(id)initWithFrame:(CGRect)frame;
#pragma mark 数据返回
-(void)getFiveAndDetailBundle:(NSMutableArray*)data;
@end
