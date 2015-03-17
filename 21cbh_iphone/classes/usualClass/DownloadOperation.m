//
//  DownloadOperation.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-30.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "DownloadOperation.h"

@implementation DownloadOperation

#pragma mark 在这里添加想要执行的操作
- (void)main {
    // main方法可能在异步线程调用，这样就不恩能够访问主线程的自动释放池
    // 因此，在这里新建一个属于当前线程的自动释放池
    @autoreleasepool {
        // 取消操作发生在任何时刻都有可能，因此在执行任何操作之前，先检测该操作是否已经被取消
        if (self.isCancelled) {
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.url]];
        // 执行了比较耗时的操作后也需要检测该操作是否已经被取消
        if (self.isCancelled) {
            return;
        }
        
        // 调用Block，传递图片出去
        if (_downloadCompletionBlock) {
            UIImage *image = [UIImage imageWithData:data];
            
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_sync(queue, ^{
                _downloadCompletionBlock(image);
            });
         }
    }
}

- (void)dealloc {
    [_url release];
    [_downloadCompletionBlock release];
    [super dealloc];
}
@end
