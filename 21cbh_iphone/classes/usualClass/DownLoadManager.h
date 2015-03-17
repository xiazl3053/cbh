//
//  DownLoadManager.h
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-14.
//  Copyright (c) 2015年 ZX. All rights reserved.
//  下载管理器

#import <Foundation/Foundation.h>
#import "VoiceListModel.h"

@protocol DownLoadManagerDelegate;

@interface DownLoadManager : NSObject

+(DownLoadManager *)getId;


@property(strong,nonatomic)NSMutableArray *totalsNum;//总的下载列表
@property(strong,nonatomic)NSMutableArray *downloadNum;//下载列表
@property(assign,nonatomic)id<DownLoadManagerDelegate>delegate;

#pragma mark 添加下载队列(tag 0:全部添加 1:只添加到_downloadNum)
-(void)addDownloadArray:(NSMutableArray *)array tag:(NSInteger)tag;
#pragma mark 取消单个下载
-(void)cancelSingleDownload;
#pragma mark 取消全部下载
-(void)cancelDownloads;
#pragma mark 全部开始下载任务
-(void)startDownloads;
#pragma mark 删除单个任务
-(void)delSingleDownload:(VoiceListModel *)vlm;
#pragma mark 删除(清空)全部下载任务
-(void)delDownloads;

@end

@protocol DownLoadManagerDelegate <NSObject>

#pragma mark 列表刷新
-(void)reloadDelegate;
#pragma mark 下载开始
-(void)downloadStartreloadDelegate;
#pragma mark 下载失败
-(void)downloadFailedDelegate;
#pragma mark 下载ing
-(void)downloadingDelegate:(CGFloat)f vlm:(VoiceListModel *)vlm;
#pragma mark 下载完成
-(void)downloadCompletionDelegate;


@end