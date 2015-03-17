//
//  ziXuanManageViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hqBaseViewController.h"

@interface ziXuanManageViewController : hqBaseViewController
@property (nonatomic,retain) UITableView *editTableView;
@property (nonatomic,retain) NSMutableArray *data;
@property (nonatomic,retain) NSMutableArray *valueData;
@property (nonatomic,weak) id Parent;
@end
