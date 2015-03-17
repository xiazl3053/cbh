//
//  UIResponder+Custom.m
//   
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIResponder+Custom.h"

@interface UIResponder(private)
-(id)traverseResponderChainForUIViewController:(id)aId;
@end

@implementation UIResponder(UIViewController)

-(UIViewController*)firstViewController;
{
    return (UIViewController*)[self traverseResponderChainForUIViewController:self];
}

@end

@implementation UIResponder(private)
-(id)traverseResponderChainForUIViewController:(id)aId
{
    id nextResponder = [aId nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) 
	{
        return nextResponder;
    } 
	else if ([nextResponder isKindOfClass:[UIView class]]) 
	{
        return [self traverseResponderChainForUIViewController:nextResponder];
    } 
	else 
	{
        return nil;
    }
}

@end
