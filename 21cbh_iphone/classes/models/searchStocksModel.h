//
//  searchStocksModel.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface searchStocksModel : NSObject
@property (nonatomic,retain) NSString *rowid;
@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *market;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,retain) NSString *pinyin;
@property (nonatomic,retain) NSString *name;
-(id)initWithDic:(NSDictionary *)dic;
@end
