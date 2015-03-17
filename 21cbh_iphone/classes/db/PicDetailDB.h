//
//  PicDetailDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicDetailModel.h"

@interface PicDetailDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertPdm:(PicDetailModel *)pdm hostPicsId:(NSString *)hostPicsId;
#pragma mark 删除数据
-(void)deletePdmWithHostPicsId:(NSString *)hostPicsId;
#pragma mark 查询数据
-(NSMutableArray *)getPdmsWithHostPicsId:(NSString *)hostPicsId;

@end
