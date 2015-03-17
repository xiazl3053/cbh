//
//  DownLoadManager.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-14.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "DownLoadManager.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "FileOperation.h"
#import "DownLoadDB1.h"
#import "CommonOperation.h"


static DownLoadManager *_dlm;

@interface DownLoadManager(){
    
    __block long long _receiveSize;
    __block VoiceListModel *_vlm;//当前下载的文件对象
    BOOL cancelDownloads;//控制频繁点击全部取消下载按钮
    BOOL startDownloads;//控制频繁点击全部开始下载按钮
}

@property(strong,nonatomic)ASIHTTPRequest *request;
@property(strong,nonatomic)DownLoadDB1 *dlDB1;

@end

@implementation DownLoadManager


+(DownLoadManager *)getId{
    if (_dlm) {
        return _dlm;
    }
    
    _dlm=[[DownLoadManager alloc] init];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //初始化变量
        [_dlm initParams];
    });
    
    return _dlm;
}

-(void)dealloc{
    //移除通知
    [self removeNotification];
}


-(void)initParams{
    //初始化变量
    self.totalsNum=[NSMutableArray array];
    self.downloadNum=[NSMutableArray array];
    self.dlDB1=[[DownLoadDB1 alloc] init];
    cancelDownloads=YES;
    startDownloads=YES;
    //注册通知
    [_dlm initNotification];
    
    //从数据库获取下载数据
    [[[CommonOperation getId] getMain].dbQueue addOperationWithBlock:^{
        NSMutableArray *array=[_dlDB1 getVlmsWithTag:@"0"];
        [_totalsNum addObjectsFromArray:array];
        [_downloadNum addObjectsFromArray:array];
        
         //开始下载
        [self startdownload];
    }];
    
}

#pragma mark 添加下载队列(tag 0:全部添加 1:只添加到_downloadNum)
-(void)addDownloadArray:(NSMutableArray *)array tag:(NSInteger)tag{

    //更新数据库下载列表
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(tag==0){
            [_totalsNum addObjectsFromArray:array];
        }
        [_downloadNum addObjectsFromArray:array];
        
        [[[CommonOperation getId] getMain].dbQueue addOperationWithBlock:^{
            for (int i=array.count-1; i>=0; i--) {
                VoiceListModel *vlm=[array objectAtIndex:i];
                BOOL b=[_dlDB1 isExist:vlm];
                if (!b) {
                    [_dlDB1 insert:vlm];
                }
                vlm.downloadstus=2;
            }
            
            //开始下载
            [self startdownload];
        }];
    });
}


#pragma mark 开始下载
-(void)startdownload{
    
    if (!_downloadNum.count>0) {//没任务就不下载
        return;
    }
    
    //监听代理,刷新列表
    if (self.delegate &&[self.delegate respondsToSelector:@selector(reloadDelegate)]) {
        [self.delegate reloadDelegate];
    }
    
    if (_vlm&&_vlm.downloadstus==1) {//有任务在下载就不开新任务
        return;
    }
    
    _receiveSize=0;
    
    _vlm=[_downloadNum objectAtIndex:0];
    
    NSURL *url = [ NSURL URLWithString : _vlm.voiceUrl];
    NSArray *array=[_vlm.voiceUrl componentsSeparatedByString: @"/"];
    NSString *fileName=[array objectAtIndex:array.count-1];
    NSString *filePath=[[FileOperation getId] getFileWithFileDirName:@"sound" fileName:fileName];
    NSString *fileTemPath=[[FileOperation getId] getFileWithFileDirName:@"soundTem" fileName:fileName];
    
    __block ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
    _request=request;
    request.allowResumeForFileDownloads=YES;
    [request setTemporaryFileDownloadPath:fileTemPath];
    [request setDownloadDestinationPath :filePath];
    [request startAsynchronous];

    
    //下载开始
    [self downloadStart];
    
    _receiveSize=[[FileOperation getId] fileSizeAtPath:fileTemPath];
    NSLog(@"DownLoadManager开始下载");
    
    //获取头文件
    [request setHeadersReceivedBlock:^(NSDictionary *responseHeaders) {
        NSLog(@"DownLoadManager收到头文件信息,开始下载,要下载的文件大小为:%@",[responseHeaders valueForKey:@"Content-Length"]);
        
    }];
    
    
    //下载失败
    [request setFailedBlock:^{
        NSLog(@"DownLoadManager下载失败");
        [self downloadFailed];
    }];
    
    
    //下载ing
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        //NSLog(@"DownLoadManager下载ing");
        [self downloading:total fileTemPath:fileTemPath];
        
    }];
    
    
    //下载完成
    [request setCompletionBlock:^{
        NSLog(@"DownLoadManager下载完成");
        [self downloadCompletion];
    }];
    
}



#pragma mark 下载开始
-(void)downloadStart{
    _vlm.downloadstus=1;
    
    //监听代理,下载开始
    if (self.delegate &&[self.delegate respondsToSelector:@selector(downloadStartreloadDelegate)]) {
        [self.delegate downloadStartreloadDelegate];
    }
    
    //监听代理,刷新列表
    if (self.delegate &&[self.delegate respondsToSelector:@selector(reloadDelegate)]) {
        [self.delegate reloadDelegate];
    }
}

#pragma mark 下载失败
-(void)downloadFailed{
    _vlm.downloadstus=3;
    [_downloadNum removeObject:_vlm];
    //继续下载队列里的新任务
    [self startdownload];
    
    //监听代理,下载失败
    if (self.delegate &&[self.delegate respondsToSelector:@selector(downloadFailedDelegate)]) {
        [self.delegate downloadFailedDelegate];
    }
    
    //监听代理,刷新列表
    if (self.delegate &&[self.delegate respondsToSelector:@selector(reloadDelegate)]) {
        [self.delegate reloadDelegate];
    }
}


#pragma mark 下载ing
-(void)downloading:(unsigned long long) total fileTemPath:(NSString *)fileTemPath{
    _receiveSize=[[FileOperation getId] fileSizeAtPath:fileTemPath];
    float f=(float)_receiveSize/total;
//    NSLog(@"long long _receiveSize:%lld",_receiveSize);
//    NSLog(@"long long total:%lld",total);
//    NSLog(@"收到下载数据大小:%.1f%%",f*100);
    
    //监听代理,下载ing
    if (self.delegate &&[self.delegate respondsToSelector:@selector(downloadingDelegate:vlm:)]) {
        [self.delegate downloadingDelegate:f vlm:_vlm];
    }
}


#pragma mark 下载完成
-(void)downloadCompletion{
    _vlm.isDownLoad=@"1";
    [_dlDB1 update:_vlm];
    [_downloadNum removeObject:_vlm];
    [_totalsNum removeObject:_vlm];
    _vlm=nil;
    //继续下载队列里的新任务
    [self startdownload];
    
    //监听代理,下载完成
    if (self.delegate &&[self.delegate respondsToSelector:@selector(downloadCompletionDelegate)]) {
        [self.delegate downloadCompletionDelegate];
    }
    
    //监听代理,刷新列表
    if (self.delegate &&[self.delegate respondsToSelector:@selector(reloadDelegate)]) {
        [self.delegate reloadDelegate];
    }
    
    //发送下载完成通知
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotifcationKeyForDownloadComplete
                                                       object:nil
                                                     userInfo:nil];
}


#pragma mark 取消单个下载
-(void)cancelSingleDownload{
    if (_request) {
        [_request cancel];
    }
}


#pragma mark 取消全部下载
-(void)cancelDownloads{
    if (!cancelDownloads) {
        return;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        cancelDownloads=NO;
        [_downloadNum removeAllObjects];
        
        if (_request) {
            [_request cancel];
        }
        
        sleep(1);
        
        for (int i=0;i<_totalsNum.count; i++) {
            VoiceListModel *vlm=[_totalsNum objectAtIndex:i];
            vlm.downloadstus=3;
        }
        //监听代理,刷新列表
        if (self.delegate &&[self.delegate respondsToSelector:@selector(reloadDelegate)]) {
            [self.delegate reloadDelegate];
        }
        cancelDownloads=YES;
    });
    
}


#pragma mark 全部开始下载任务
-(void)startDownloads{
    
    if (!startDownloads) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        startDownloads=NO;
        [_downloadNum removeAllObjects];
        
        if (_request) {
            [_request cancel];
        }
        
        sleep(1);
        
        [_downloadNum addObjectsFromArray:_totalsNum];
        
        for (int i=0;i<_totalsNum.count; i++) {
            VoiceListModel *vlm=[_totalsNum objectAtIndex:i];
            vlm.downloadstus=2;
        }
        //监听代理,刷新列表
        if (self.delegate &&[self.delegate respondsToSelector:@selector(reloadDelegate)]) {
            [self.delegate reloadDelegate];
        }
        //开始下载
        [self startdownload];
        
        startDownloads=YES;
    });
    
}

#pragma mark 删除单个任务
-(void)delSingleDownload:(VoiceListModel *)vlm{
    
    //更新数据库下载列表
    __block VoiceListModel *vlm1=vlm;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (_vlm&&[vlm.voiceUrl isEqual:_vlm.voiceUrl]&&_request) {
            sleep(1);//骗下用户,让删除动画执行完毕再开始下面的业务
            [_request cancel];
        }else{
            [_downloadNum removeObject:vlm];
        }
        
        [_totalsNum removeObject:vlm];
        
        [[[CommonOperation getId] getMain].dbQueue addOperationWithBlock:^{
            [_dlDB1 delete:vlm1];
            //删除临时音频文件
            [self delTempRadio:vlm1];
        }];
    });
    
    
}

#pragma mark 删除(清空)全部下载任务
-(void)delDownloads{
    if (_totalsNum.count<1) {
        return;
    }
    
    __block NSMutableArray *array=[NSMutableArray array];
    [array addObjectsFromArray:_totalsNum];
    [_totalsNum removeAllObjects];
    [_downloadNum removeAllObjects];
    
    
    if (_request) {
        [_request cancel];
    }
    
    //监听代理,刷新列表
    if (self.delegate &&[self.delegate respondsToSelector:@selector(reloadDelegate)]) {
        [self.delegate reloadDelegate];
    }
    
    //更新数据库下载列表
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[[CommonOperation getId] getMain].dbQueue addOperationWithBlock:^{
            for (int i=0; i<array.count; i++) {
                 VoiceListModel *vlm=[array objectAtIndex:i];
                [_dlDB1 delete:vlm];
                //删除临时音频文件
                [self delTempRadio:vlm];
            }
        }];
    });
}


#pragma mark app进入后台的处理
-(void)didAppEnterGround:(NSNotification*)notification{
    NSLog(@"DownLoadManager进入后台");
    //下载停止
    [self cancelDownloads];
}

#pragma mark app进入前台
-(void)didAppActive:(NSNotification*)notification{
    
    NSLog(@"DownLoadManager激活");
    //继续下载
    [self startDownloads];
}

#pragma mark 通知响应
-(void)initNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAppActive:) name:kNotifcationKeyForActive object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAppEnterGround:) name:kNotifcationKeyForEnterGround object:nil];
}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForActive object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifcationKeyForEnterGround object:nil];
}


#pragma mark 删除临时音频文件
-(void)delTempRadio:(VoiceListModel *)vlm{
    NSArray *array=[vlm.voiceUrl componentsSeparatedByString: @"/"];
    NSString *fileName=[array objectAtIndex:array.count-1];
    NSString *fileTemPath=[[FileOperation getId] getFileWithFileDirName:@"soundTem" fileName:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileTemPath error:nil];
}

@end
