//
//  CWPHttpRequest.h
//  21cbh_iphone
//
//  Created by Franky on 14-5-7.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

typedef void (^httpCompleteBlock)(NSDictionary* dic,BOOL isSuccess);

@interface CWPHttpRequest : NSObject

#pragma mark IOS提交设备信息接口
+(ASIHTTPRequest*)postPushInfoRequest:(NSString *)deviceToken userId:(NSString*)userId channelId:(NSString*)channelId tagName:(NSString*)tagName;
#pragma mark 私聊上传图片接口
+(ASIHTTPRequest*)postPictureRequest:(NSString *)path progressBlock:(ASIProgressBlock)progressBlock completionBlock:(httpCompleteBlock)completionBlock;
#pragma mark 通讯录匹配上传接口
+(ASIHTTPRequest*)postMatchContactsRequest:(NSString*)phone completionBlock:(httpCompleteBlock)completionBlock;
#pragma mark 聊天界面股票接口
+(ASIHTTPRequest*)postStockInformationRequest:(NSString*)marketId markType:(NSString*)type completionBlock:(httpCompleteBlock)completionBlock;
@end
