//
//  PicsListDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicsListModel.h"

@interface PicsListDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertPlm:(PicsListModel *)plm programId:(NSString *)programId;
#pragma mark 删除数据
-(void)deletePlmsWithProgramId:(NSString *)programId;
#pragma mark 查询数据
-(NSMutableArray *)getPlmsWithProgramId:(NSString *)programId;

@end
