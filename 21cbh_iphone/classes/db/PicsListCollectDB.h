//
//  PicsListCollectDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicsListModel.h"

@interface PicsListCollectDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertPlm:(PicsListModel *)plm;
#pragma mark 删除数据
-(void)deletePlm:(PicsListModel *)plm;
#pragma mark 删除数据
-(void)deletePlm2:(PicsListModel *)plm;
#pragma mark 查询数据
-(NSMutableArray *)getPlms;
#pragma mark 查看数据否存在
-(BOOL)isExistPlmWithPicsId:(NSString *)picsId programId:(NSString *)programId;
#pragma mark 查看数据否存在
-(BOOL)isExistPlmWithTitle:(NSString *)title;
@end
