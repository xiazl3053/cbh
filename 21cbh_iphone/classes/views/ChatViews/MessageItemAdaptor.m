//
//  MessageItemAdaptor.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MessageItemAdaptor.h"
#import "NSDate+Custom.h"

@implementation MessageItemAdaptor

@synthesize message=messgae_;
@synthesize timeSpan=timeSpan_;

-(id)initWithMessage:(EMessages*)message
{
    if(self=[super init]){
        messgae_=message;
        self.height=0;
        self.width=320;
        self.contentHeight=0;
    }
    return self;
}

-(NSString *)timeSpan
{
    if(timeSpan_==nil||timeSpan_.length==0)
    {
        NSDate* date=[NSDate dateWithTimeIntervalSince1970:messgae_.time/1000];
        timeSpan_=[date intervalWithNow];
    }
    return timeSpan_;
}

@end
