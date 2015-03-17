//
//  kChartNewsListModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface kChartNewsListModel : NSObject

@property (nonatomic,retain) NSString *ids;
@property (nonatomic,retain) NSString *programId;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *time;
-(id)initWithDic:(NSDictionary *)dic;
@end
