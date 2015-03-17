//
//  FileController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "FileOperation.h"

static FileOperation *_fo;

@implementation FileOperation

+(FileOperation *)getId{
    if (_fo) {
        return _fo;
    }
    _fo=[[FileOperation alloc] init];
    return _fo;
}

#pragma mark 获取本地文件夹存储路径
-(NSString *)getFileDirWithFileDirName:(NSString *)FileDirName{
    //文档路径
    //Caches
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //文件夹起名(多级文件名)
    NSString *fileDir = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"21cbh"] stringByAppendingPathComponent:FileDirName];
    //判断文件夹是否存在,不存在就创建
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool isexit=[fileManager fileExistsAtPath:fileDir];
    if (!isexit) {// 如果不存在
        //创建文件夹路径
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileDir;
}

#pragma mark 获取图片绝对路径
-(NSString *)getFilePathWithURL:(NSString *)picUrl FileDirName:(NSString *)FileDirName{
    NSArray *array=[picUrl componentsSeparatedByString: @"/"];
    NSString *picName=[array objectAtIndex:array.count-1];
    //NSLog(@"本地取出的图片名字为%@",picName);
    NSString *imageDir = [self getFileDirWithFileDirName:FileDirName];
    /*读出图片*/
    //帮文件起个名
    NSString *uniquePath=[imageDir stringByAppendingPathComponent:picName];
    return uniquePath;
}


#pragma mark 判断某个文件是否存在
-(BOOL)isFileExistWithFileDirName:(NSString *)fileDir fileName:(NSString *)file {
    //获取文件夹路径
    fileDir=[self getFileDirWithFileDirName:fileDir];
    //帮文件起个名
    file=[fileDir stringByAppendingPathComponent:file];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool isexit=[fileManager fileExistsAtPath:file];
    return isexit;
}


#pragma mark 图片存本地
-(void)savePicToLocalWithUIImage:(UIImage *)img picUrl:(NSString *)picUrl FileDirName:(NSString *)FileDirName isPng:(BOOL)isPng{
    NSArray *array=[picUrl componentsSeparatedByString: @"/"];
    NSString *picName=[array objectAtIndex:array.count-1];
    NSString *imageDir = [self getFileDirWithFileDirName:FileDirName];
    /*写入图片*/
    //帮文件起个名
    NSString *uniquePath=[imageDir stringByAppendingPathComponent:picName];
    //将图片写到Documents文件中
    if(isPng){
        [UIImagePNGRepresentation(img)writeToFile: uniquePath  atomically:YES];
    }else{
       [UIImageJPEGRepresentation(img, 10)writeToFile: uniquePath  atomically:YES];
    }
    
    
}

#pragma mark 获取本地图片
-(UIImage *)getLocalPicWithURL:(NSString *)picUrl FileDirName:(NSString *)FileDirName{
    NSArray *array=[picUrl componentsSeparatedByString: @"/"];
    NSString *picName=[array objectAtIndex:array.count-1];
    //NSLog(@"本地取出的图片名字为%@",picName);
    NSString *imageDir = [self getFileDirWithFileDirName:FileDirName];
    /*读出图片*/
    //帮文件起个名
    NSString *uniquePath=[imageDir stringByAppendingPathComponent:picName];
    /*读取入图片*/
    //因为拿到的是个路径，所以把它加载成一个data对象
    NSData *data=[NSData dataWithContentsOfFile:uniquePath];
    //NSLog(@"data:%@",data);
    //直接把该图片读出来
    if (data) {
        UIImage *image=[UIImage imageWithData:data];
        return image;
        
    }else{
        return nil;
    }
    
}

#pragma mark 判断本地图片是都存在
-(BOOL)isExistPicWithURL:(NSString *)picUrl FileDirName:(NSString *)FileDirName{
    NSArray *array=[picUrl componentsSeparatedByString: @"/"];
    NSString *picName=[array objectAtIndex:array.count-1];
    //NSLog(@"本地取出的图片名字为%@",picName);
    NSString *imageDir = [self getFileDirWithFileDirName:FileDirName];
    /*读出图片*/
    //帮文件起个名
    NSString *uniquePath=[imageDir stringByAppendingPathComponent:picName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL b=[fileManager fileExistsAtPath:uniquePath isDirectory:NO];
    return b;
}


#pragma mark 将plist文件保存到本地
-(void)savePlistToLocalWithNSMutableDictionary:(NSMutableDictionary *)data FileDirName:(NSString *)fileDirName fileName:(NSString *)fileName{
    //文件夹路径
    NSString *fileDir = [self getFileDirWithFileDirName:fileDirName];
    //文件名
    NSString *file=[fileDir stringByAppendingPathComponent:fileName];
    //写到本地
    [data writeToFile:file atomically:YES];
}

#pragma mark 读取本地plist文件
-(NSMutableDictionary *)getLocalPlistWithFileDirName:(NSString *)fileDirName fileName:(NSString *)fileName{
    //文件夹路径
    NSString *fileDir = [self getFileDirWithFileDirName:fileDirName];
    //文件名
    NSString *file=[fileDir stringByAppendingPathComponent:fileName];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
    return data;
}

#pragma mark 将html存储到本地
-(void)saveHtmlWithData:(NSData *)data FileDirName:(NSString *)fileDirName fileName:(NSString *)fileName {
    //获取文件夹路径
    NSString *fileDir=[self getFileDirWithFileDirName:fileDirName];
    //帮文件起个名
    fileName=[fileDir stringByAppendingPathComponent:fileName];
    //将NSData类型对象data写入文件，文件名为FileName
    [data writeToFile:fileName atomically:YES];
    data=nil;
}

#pragma mark 读取html
-(NSString *)getHtmlWithFileDirName:(NSString *)FileDirName  fileName:(NSString *)fileName{
    //获取文件夹路径
    NSString *fileDir=[self getFileDirWithFileDirName:FileDirName];
    //获取html文件的路径
    fileName=[fileDir stringByAppendingPathComponent:fileName];
    NSData *data=[NSData dataWithContentsOfFile:fileName options:0 error:NULL];
    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    data=nil;
    return result;
}

#pragma mark 计算文件大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

#pragma mark 计算文件夹大小
- (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

#pragma mark 删除文件夹下的文件或直接某个文件(路径决定)
-(void)deleteFolderWithPath:(NSString *)fileDir{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileDir error:nil];
}

#pragma mark 删除文件夹下指定类型的文件
-(void)deleteFileWithfileDir:(NSString *)fileDir fileType:(NSString *)fileType{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:fileDir error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [fileDir stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        if ([fullPath hasSuffix:fileType]) {//如果包含此类型文件就删除掉
            [self deleteFolderWithPath:fullPath];
        }
        
    }
}


#pragma mark 获取本地文件绝对路径
-(NSString *)getFileWithFileDirName:(NSString *)FileDirName fileName:(NSString *)fileName{
    NSString *fileDir = [self getFileDirWithFileDirName:FileDirName];
    NSString *filePath=[fileDir stringByAppendingPathComponent:fileName];
    return filePath;
}


#pragma mark 判断某个文件是否存在
-(BOOL)isFileExistWithFilePath:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool isexit=[fileManager fileExistsAtPath:filePath];
    return isexit;
}

#pragma mark 根据音频的url获取本地播放地址(没有文件则返回nil)
-(NSString *)getRadioLocalUrl:(NSString *)url{
    NSArray *array=[url componentsSeparatedByString: @"/"];
    NSString *fileName=[array objectAtIndex:array.count-1];
    NSString *filePath=[self getFileWithFileDirName:@"sound" fileName:fileName];
    //NSLog(@"============================:file:/%@",filePath);

    if ([self isFileExistWithFilePath:filePath]) {
        return [NSString stringWithFormat:@"file:/%@",filePath];
    }else{
        return nil;
    }

}

#pragma mark 获取正在下载的音频size
-(CGFloat)getFileTemPathSize:(NSString *)url{
    NSArray *array=[url componentsSeparatedByString: @"/"];
    NSString *fileName=[array objectAtIndex:array.count-1];
    NSString *fileTemPath=[[FileOperation getId] getFileWithFileDirName:@"soundTem" fileName:fileName];
    
    return (CGFloat)[self fileSizeAtPath:fileTemPath];
}

#pragma mark 删除音频文件
-(void)delRadio:(NSString *)url{
    NSString *path=[self getRadioLocalUrl:url];
    if (path) {
        path=[path substringFromIndex:5];
        [self deleteFolderWithPath:path];
    }
}

@end
