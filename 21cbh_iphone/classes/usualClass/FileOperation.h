//
//  FileController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileOperation : NSObject

+(FileOperation *)getId;

#pragma mark 获取本地文件夹存储路径
-(NSString *)getFileDirWithFileDirName:(NSString *)FileDirName;
#pragma mark 判断某个文件是否存在
-(BOOL)isFileExistWithFileDirName:(NSString *)fileDir fileName:(NSString *)file;
#pragma mark 获取图片绝对路径
-(NSString *)getFilePathWithURL:(NSString *)picUrl FileDirName:(NSString *)FileDirName;
#pragma mark 图片存本地
-(void)savePicToLocalWithUIImage:(UIImage *)img picUrl:(NSString *)picUrl FileDirName:(NSString *)FileDirName isPng:(BOOL)isPng;
#pragma mark 判断本地图片是都存在
-(BOOL)isExistPicWithURL:(NSString *)picUrl FileDirName:(NSString *)FileDirName;
#pragma mark 获取本地图片
-(UIImage *)getLocalPicWithURL:(NSString *)picUrl FileDirName:(NSString *)FileDirName;
#pragma mark 将plist文件保存到本地
-(void)savePlistToLocalWithNSMutableDictionary:(NSMutableDictionary *)data FileDirName:(NSString *)fileDirName fileName:(NSString *)fileName;
#pragma mark 将html存储到本地
-(void)saveHtmlWithData:(NSData *)data FileDirName:(NSString *)fileDirName fileName:(NSString *)fileName;
#pragma mark 读取html
-(NSString *)getHtmlWithFileDirName:(NSString *)FileDirName  fileName:(NSString *)fileName;
#pragma mark 读取本地plist文件
-(NSMutableDictionary *)getLocalPlistWithFileDirName:(NSString *)fileDirName fileName:(NSString *)fileName;
#pragma mark 计算文件大小
- (long long) fileSizeAtPath:(NSString*) filePath;
#pragma mark 计算文件夹大小
- (float ) folderSizeAtPath:(NSString*) folderPath;
#pragma mark 删除文件夹下的文件或直接某个文件(路径决定)
-(void)deleteFolderWithPath:(NSString *)fileDir;
#pragma mark 删除文件夹下指定类型的文件
-(void)deleteFileWithfileDir:(NSString *)fileDir fileType:(NSString *)fileType;
#pragma mark 获取本地文件绝对路径
-(NSString *)getFileWithFileDirName:(NSString *)FileDirName fileName:(NSString *)fileName;
#pragma mark 判断某个文件是否存在
-(BOOL)isFileExistWithFilePath:(NSString *)filePath;
#pragma mark 根据音频的url获取本地播放地址(没有文件则返回nil)
-(NSString *)getRadioLocalUrl:(NSString *)url;
#pragma mark 获取正在下载的音频size
-(CGFloat)getFileTemPathSize:(NSString *)url;
#pragma mark 删除音频文件
-(void)delRadio:(NSString *)url;
@end
