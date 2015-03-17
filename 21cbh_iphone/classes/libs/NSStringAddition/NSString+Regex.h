//
//  NSString+Regex.h
//  tianyaQingHD
//
//  Created by gzty1 on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Regex)
-(NSString*)fuzzySearchRegex;//本身作为模糊查找条件时的正则式
-(BOOL)isMatchedShortPinyinFuzzyByText:(NSString*)queryText;//是否匹配查询条件，同时做简拼模糊匹配
@end
