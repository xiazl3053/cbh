//
//  ImageContentView.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "RequestContentView.h"

@interface ImageContentView : RequestContentView

#pragma mark - 接收方获取图片信息调用
-(id)initDownLoadWithFrame:(CGRect)frame imageDic:(NSDictionary*)dic;
#pragma mark - 发送方上传图片调用
-(id)initUpLoadWithFrame:(CGRect)frame imageUrl:(NSString*)url;

@end
