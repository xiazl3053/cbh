//
//  selfMarketMessageModel.h
//  21cbh_iphone
//
//  Created by Franky on 14-4-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface selfMarketMessageModel : NSObject

@property(nonatomic,strong) NSString* msgId;
@property(nonatomic,strong) NSString* type;
@property(nonatomic,strong) NSString* title;
@property(nonatomic,strong) NSString* date;
@property(nonatomic,strong) NSString* time;
@property(nonatomic,strong) NSString* marketId;
@property(nonatomic,strong) NSString* marketName;
@property(nonatomic,strong) NSString* marketType;
@property(nonatomic,strong) NSString* isRead;
@property(nonatomic,strong) NSString* newsId;
@property(nonatomic,strong) NSString* programId;

-(id)initWithNSDictonary:(NSDictionary *)dic;

@end
