//
//  NewListCollectDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewListModel.h"

@interface NewListCollectDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertNlm:(NewListModel *)nlm;
#pragma mark 更新数据
-(void)updateNlm:(NewListModel *)nlm;
#pragma mark 删除数据
-(void)deleteNlm:(NewListModel *)nlm;
#pragma mark 查询数据
-(NSMutableArray *)getNewList;
#pragma mark 查看数据否存在
-(BOOL)isExistNlmWithArticleId:(NSString *)articleId programId:(NSString *)programId;

@end
