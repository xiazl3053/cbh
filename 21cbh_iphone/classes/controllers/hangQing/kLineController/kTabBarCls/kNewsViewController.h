//
//  kNewsViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-1.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kBaseViewController.h"

@interface kNewsViewController : kBaseViewController
@property (nonatomic,retain) NSString *newsType;
@property (nonatomic,assign) int columnId;
// 数据返回处理
-(void)getKChartNewsListBundle:(NSMutableArray*)data;
@end
