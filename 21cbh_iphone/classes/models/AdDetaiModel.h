//
//  AdDetaiModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdDetaiModel : NSObject

- (id)initWithDict:(NSDictionary *)dict ;

@property(copy,nonatomic)NSString *adId;//广告id(这包括推广id和活动id)
@property(copy,nonatomic)NSString *sharePic;//分享微缩图
@property(copy,nonatomic)NSString *adTitle;//分享标题
@property(copy,nonatomic)NSString *adUrl;//3g页面链接
@property(copy,nonatomic)NSString *type;//广告类型(5:推广 7:活动)

@end
