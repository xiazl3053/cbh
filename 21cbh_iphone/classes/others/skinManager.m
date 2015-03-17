//
//  ImageManager.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "skinManager.h"

static skinManager* sharedInstance_;


@implementation skinManager

+(skinManager *)sharedInstance
{
    @synchronized(self){
        if(sharedInstance_ == nil){
            sharedInstance_ = [[skinManager alloc] init];
        }
    }
    return sharedInstance_;
}

-(id)init
{
    if(self=[super init]){
        
    }
    return self;
}

@end
