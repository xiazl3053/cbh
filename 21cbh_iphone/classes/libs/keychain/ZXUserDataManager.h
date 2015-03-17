//
//  ZXUserDataManager.h
//  keychain的使用
//
//  Created by 周晓 on 14-6-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXUserDataManager : NSObject

/**
 *  @brief  存储设备标识
 *
 *  @param  identifierNumber   设备标识内容
 */
+(void)saveIdentifierNumber:(NSString *)identifierNumber;

/**
 *  @brief  读取设备标识
 *
 *  @return 设备标识内容
 */
+(id)readIdentifierNumber;

/**
 *  @brief  删除设备标识数据
 */
+(void)deleteIdentifierNumber;

@end
