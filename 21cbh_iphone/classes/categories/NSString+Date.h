//
//  NSString+Date.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)

+(NSString *) compareCurrentTime:(NSString*) compareDate;
+(NSString *) compareCurrentTime2:(NSString*) compareDate;
#pragma mark 时间戳转换成时间
+(NSString *)addtimeTurnToTimeString:(NSString *)addtime;
#pragma mark 获取当前时间戳
+(NSString *)getCurrentTimeString;

@end
