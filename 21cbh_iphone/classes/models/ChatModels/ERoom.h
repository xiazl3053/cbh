//
//  GroupModel.h
//  21cbh_iphone
//
//  Created by qinghua on 14-7-30.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERoom : NSObject

@property (nonatomic,copy) NSString *desc;  
@property (nonatomic,copy) NSString *jid;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString *myJID;
@property (nonatomic,assign) BOOL isShield;

-(id)initWithNSDictionary:(NSDictionary *)dic;

@end
