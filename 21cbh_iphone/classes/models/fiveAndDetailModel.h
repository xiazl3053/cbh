//
//  fiveAndDetailModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fiveAndDetailModel : NSObject
@property (nonatomic,retain) NSString *one;
@property (nonatomic,retain) NSString *two;
@property (nonatomic,retain) NSString *three;
@property (nonatomic,retain) NSString *priceType;
-(id)initWithDic:(NSDictionary *)dic;
@end
