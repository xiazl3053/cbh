//
//  NewListRecordDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewListModel.h"

@interface NewListRecordDB : NSOperation

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertWithNlm:(NewListModel *)nlm;
#pragma mark 删除数据
-(void)deleteAll;
#pragma mark 查看数据是否存在
-(BOOL)isExistNlm:(NewListModel *)nlm;
#pragma mark 查询数据
-(NSMutableArray *)getNewList;
@end
