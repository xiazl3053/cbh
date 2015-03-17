//
//  MoreAppModel.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoreAppModel : NSObject

@property (nonatomic,strong) NSString *iconUrl;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *scheme;
@property (nonatomic,strong) NSString *ID;

-(id)initWithNSDictionary:(NSDictionary *)dic;

@end
