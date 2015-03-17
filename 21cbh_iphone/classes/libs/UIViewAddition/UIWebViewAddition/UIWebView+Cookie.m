//
//  UIWebView+Cookie.m
//   V2
//
//  Created by MrZhou on 14-3-19.
//  Copyright (c) 2014年 tianya. All rights reserved.
//

#import "UIWebView+Cookie.h"

@implementation UIWebView (Cookie)

- (void)addCookies:(NSString*)domain withCookies:(NSArray*)cookieArray
{
    //清除cookies
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    NSHTTPCookie* cookie = nil;
    NSDictionary* properties =  nil;
    NSString* cookieStr = nil;
    for (int i=0; i<[cookieArray count]; i++)
    {
        cookieStr = [cookieArray objectAtIndex:i];
        NSRange range = [cookieStr rangeOfString:@"="];
        if(range.location != NSNotFound)
        {
            properties = [NSDictionary dictionaryWithObjectsAndKeys: [cookieStr substringToIndex:range.location],NSHTTPCookieName,
                          [cookieStr substringFromIndex:range.location+range.length],NSHTTPCookieValue,
                          @"/" , NSHTTPCookiePath,
                          domain ,NSHTTPCookieDomain, nil];
        }
        cookie = [NSHTTPCookie cookieWithProperties:properties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

@end
