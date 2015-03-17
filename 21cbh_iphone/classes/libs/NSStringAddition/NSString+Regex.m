//
//  NSString+Regex.m
//  tianyaQingHD
//
//  Created by gzty1 on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Regex.h"
#import "ChineseToPinyin.h"
#import "RegexKitLite.h"

@implementation NSString(Regex)

-(NSString*)fuzzySearchRegex
{
    int length=[self length];
    NSMutableString* regex = [[[NSMutableString alloc] initWithCapacity:(length+1)*2+length] autorelease];
    [regex appendString:@".*"];
    for (int i=0; i<length; i++) 
    {
        [regex appendFormat:@"%@.*", [self substringWithRange:NSMakeRange(i, 1)]];
    }
    
    return regex;
}

-(BOOL)isMatchedShortPinyinFuzzyByText:(NSString*)queryText
{
    NSString* regex=[[queryText uppercaseString] fuzzySearchRegex];   
    NSString* shortPinyin=[ChineseToPinyin shortPinyinOfString:self];
    
    if([self isMatchedByRegex:regex] || [shortPinyin isMatchedByRegex:regex])                    
    {
        return YES;
    }
    return NO;
}

@end
