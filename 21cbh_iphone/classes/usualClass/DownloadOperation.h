//DownloadOperation.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-30.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  void (^DownloadCompletionBlock)(UIImage *image);

@interface DownloadOperation : NSOperation
// 图片的url地址
@property (nonatomic, copy) NSString *url;
// retain对block没有作用，只能用copy
@property (nonatomic, copy) DownloadCompletionBlock downloadCompletionBlock;
@end
