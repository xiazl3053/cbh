//
//  EAddFriends.h
//  DFMMessage
//
//  Created by 21tech on 14-6-6.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EAddFriends : NSObject

@property (nonatomic, assign) double  acceptTime;
@property (nonatomic, assign) BOOL  isDelete;
@property (nonatomic, retain) NSString * myJID;
@property (nonatomic, assign) double time;
@property (nonatomic, retain) NSString * subscription;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * userPhones;
@property (nonatomic, assign) int type;

@end
