//
//  NSString+File.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "NSString+File.h"

@implementation NSString (File)
- (NSString *)documentsAppend {
    //文档路径
    //Caches
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //文件夹起名(多级文件名)
    NSString *fileDir = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"21cbh"] stringByAppendingPathComponent:@"db"];
    //判断文件夹是否存在,不存在就创建
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool isexit=[fileManager fileExistsAtPath:fileDir];
    if (!isexit) {// 如果不存在
        //创建文件夹路径
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [fileDir stringByAppendingPathComponent:self];
}

- (NSString *)tmpAppend {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:self];
}
@end
