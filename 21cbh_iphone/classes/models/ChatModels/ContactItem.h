//
//  ContactItem.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-23.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EFriends.h"

@interface ContactItem : NSObject

@property (nonatomic,retain) NSString* userName;
@property (nonatomic,retain) NSString* userPhone;
@property (nonatomic,retain) NSArray* phoneArray;
@property (nonatomic,retain) NSString* uuid;
@property (nonatomic,retain,readonly) NSString* xing;
@property (nonatomic,retain,readonly) NSString* pinyin;
@property (nonatomic) BOOL isUsed;
@property (nonatomic) BOOL isAdded;
@property (nonatomic,retain) EFriends* frirend;

@end
