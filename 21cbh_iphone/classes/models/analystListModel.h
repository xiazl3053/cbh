//
//  analystListModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface analystListModel : NSObject
@property (nonatomic,retain) NSString *ids;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *pdf;
@property (nonatomic,retain) NSString *comeFrom;
@property (nonatomic,retain) NSString *date;
@property (nonatomic,retain) NSString *author;
@property (nonatomic,retain) NSString *area;
@property (nonatomic,retain) NSString *level;
@property (nonatomic,retain) NSString *levelChange;
@property (nonatomic,retain) NSString *targetPrice;
@property (nonatomic,retain) NSString *content;
@property (nonatomic,retain) NSString *hits;

-(id)initWithDic:(NSDictionary *)dic;
@end
