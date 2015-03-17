//
//  UIWebView+Cookie.h
//   V2
//
//  Created by MrZhou on 14-3-19.
//  Copyright (c) 2014年 tianya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (Cookie)

- (void)addCookies:(NSString*)domain withCookies:(NSArray*)cookieArray;

@end
