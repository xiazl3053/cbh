//
//  VoiceListRecordDB.h
//  21cbh_iphone
//
//  Created by qinghua on 15-1-6.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VoiceListModel;

@interface VoiceListRecordDB : NSObject
+(VoiceListRecordDB *)sharedInstance;
#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insertWithVoiceModel:(VoiceListModel *)nlm;
#pragma mark 删除数据
-(void)deleteAll;
#pragma mark 查看数据是否存在
-(BOOL)isExistVoiceModel:(VoiceListModel *)nlm;
#pragma mark 查询数据
-(NSMutableArray *)getVoiceList;

@end
