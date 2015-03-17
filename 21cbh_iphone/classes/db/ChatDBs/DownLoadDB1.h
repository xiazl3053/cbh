//
//  DownLoadDB1.h  音频下载列表
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-7.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceListModel.h"

@interface DownLoadDB1 : NSObject

#pragma mark 打开数据库
- (void)openDB;
#pragma mark 关闭数据库
-(void)closeDB;
#pragma mark 插入数据
-(void)insert:(VoiceListModel *)vlm;
#pragma mark 删除数据
-(void)delete:(VoiceListModel *)vlm;
#pragma mark 更新下载数据
-(void)update:(VoiceListModel *)vlm;
#pragma mark 获取总的下载数据(正在下载和下载完成的)
-(NSMutableArray *)getVlms;
#pragma mark 获取指定下载数据tag(0:未下载完 1:下载完)
-(NSMutableArray *)getVlmsWithTag:(NSString *)tag;
#pragma mark 查看数据是否存在
-(BOOL)isExist:(VoiceListModel *)vlm;

@end
