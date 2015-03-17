//
//  MessageItemAdaptor.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMessages.h"

@interface MessageItemAdaptor : NSObject
{
    EMessages* messgae_;
    NSString* timeSpan_;
}

@property (nonatomic,retain) EMessages* message;
@property (nonatomic,retain) NSString* timeSpan;
@property (nonatomic,retain) UIFont* font;
@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) int contentHeight;
@property (nonatomic) BOOL isHideTime;


@end
