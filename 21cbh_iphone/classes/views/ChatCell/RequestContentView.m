//
//  RequestContentView.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "RequestContentView.h"

@implementation RequestContentView

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)startRequest
{
    //子类继承
}

-(void)cancelAndClean
{
    self.delegate=nil;
    self.tag=0;
    if(currentRequest){
        [currentRequest clearDelegatesAndCancel];
        [currentRequest setCompletionBlock:nil];
        [currentRequest setFailedBlock:nil];
        currentRequest=nil;
    }
    
}

-(void)dealloc
{
    [self cancelAndClean];
}

@end
