//
//  PushListDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewListModel.h"

@interface PushListDB : NSObject

//timeType(0:今天  1:昨天  2:以往)

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertNlm:(NewListModel *)nlm timeType:(NSString *)timeType;
#pragma mark 删除数据
-(void)deleteNdmWithTimeType:(NSString *)timeType;
#pragma mark 查询数据
-(NSMutableArray *)getNewListWithTimeType:(NSString *)timeType;


@end
