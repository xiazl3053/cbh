//
//  NSString+strlength.m
//  21cbh_iphone
//
//  Created by qinghua on 14-4-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NSString+strlength.h"

@implementation NSString (Strlength)

+(int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
    
}

@end
