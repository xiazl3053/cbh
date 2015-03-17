//
//  PicInfoModelDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-4-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicInfoModel.h"

@interface PicInfoModelDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertPim:(PicInfoModel *)pim;
#pragma mark 删除数据
-(void)deletePim:(PicInfoModel *)pim;
#pragma mark 查询数据
-(NSMutableArray *)getPimWithProgramId:(NSString *)programId picsId:(NSString *)picsId;

@end
