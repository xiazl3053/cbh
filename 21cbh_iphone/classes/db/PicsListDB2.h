//
//  PicsListDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//该表的操作用于图集详情页理的关联列表

#import <Foundation/Foundation.h>
#import "PicsListModel.h"

@interface PicsListDB2 : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertPlm:(PicsListModel *)plm hostPicsId:(NSString *)hostPicsId;
#pragma mark 删除数据
-(void)deletePlmWithHostPicsId:(NSString *)hostPicsId;
#pragma mark 查询数据
-(NSMutableArray *)getPlmsWithHostPicsId:(NSString *)hostPicsId;

@end
