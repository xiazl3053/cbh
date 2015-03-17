//
//  CommentInfoDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommentInfoModel.h"

@interface CommentInfoCollectDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertCim:(CommentInfoModel *)cim;
#pragma mark 删除数据
-(void)deleteCim:(CommentInfoModel *)cim;
#pragma mark 查询数据
-(NSMutableArray *)getCims;
#pragma mark 查看数据否存在
-(BOOL)isExistCim:(CommentInfoModel *)cim;

@end
