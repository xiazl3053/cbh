//
//  AdBarModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-11.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdBarModel : NSObject//广告栏实体类

@property(copy,nonatomic)NSString *adId;//广告id
@property(copy,nonatomic)NSString *picUrl;//广告栏图片地址
@property(copy,nonatomic)NSString *adUrl;//广告网页地址



- (id)initWithDict:(NSDictionary *)dict;
@end
