//
//  quanquiViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hqBaseViewController.h"
#import "mainTableView.h"
@interface quanquiViewController : hqBaseViewController<UITableViewDataSource,UITableViewDelegate,mainTableViewDelegate>
-(void)pushKlineController;
-(void)getGlobalMarketListBundle:(NSMutableArray*)data isRefresh:(BOOL)refresh;
@end
