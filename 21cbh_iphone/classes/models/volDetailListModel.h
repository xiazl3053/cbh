//
//  volDetailListModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface volDetailListModel : NSObject

@property (nonatomic,retain) NSString *time;
@property (nonatomic,retain) NSString *price;
@property (nonatomic,retain) NSString *vol;

-(id)initWithDic:(NSDictionary *)dic;
@end
