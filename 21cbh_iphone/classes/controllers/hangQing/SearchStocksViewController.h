//
//  SearchStocksViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "hqBaseViewController.h"

typedef void(^SelectStockUserClick)(NSString *markID,NSString *markType,NSString* markName);

@interface SearchStocksViewController : hqBaseViewController

@property (nonatomic,copy) SelectStockUserClick userSelectStockinfo;
@property (nonatomic,assign) NSInteger type;

@end
