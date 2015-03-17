//
//  MoreAppAdModel.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoreAppOtherInfoModel : NSObject

@property (nonatomic,strong) NSString *advImageUrl;
@property (nonatomic,strong) NSString *adActionUrl;
@property (nonatomic,strong) NSString *pageCount;

-(id)initWithNSDictonary:(NSDictionary *)dic;

@end
