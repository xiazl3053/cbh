//
//  NewsDetailDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsDetailModel.h"

@interface NewsDetailDB : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertNdm:(NewsDetailModel *)ndm;
#pragma mark 删除数据
-(void)deleteNdm:(NSString *)articleId;
#pragma mark 查询数据
-(NewsDetailModel *)getNdmWith:(NSString *)articleId;

@end
