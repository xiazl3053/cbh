//
//  AdBarDB.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdBarModel.h"

@interface AdBarDB : NSObject


#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertWithAdBar:(AdBarModel *)adBar;
#pragma mark 删除数据
-(void)deleteAdBar:(AdBarModel *)adBar;
#pragma mark 查看广告栏的广告是否存在
-(BOOL)isExistAdBar:(AdBarModel *)adBar;
@end
