//
//  ChineseString.h
//  Chat
//
//  Created by qinghua on 14-6-10.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChineseString : NSObject
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *pinYin;
@property (nonatomic,copy)NSString *xing;
@property (nonatomic,copy)NSString *iconUrl;
@property (nonatomic,copy)NSString *jid;
@property (nonatomic,copy)NSString *nickName;
@property (nonatomic,copy)NSString *userName;
@property (nonatomic,assign)BOOL isFriend;
@property (nonatomic,assign)BOOL isShield;

@end
