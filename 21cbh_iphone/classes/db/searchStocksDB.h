//
//  searchStocksDB.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class searchStocksModel;
@interface searchStocksDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 查询本地数据
-(NSMutableArray *)searchStocksWithWhere:(NSString*)str;
@end
