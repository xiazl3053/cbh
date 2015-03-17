//
//  ResponseJsonParseModel.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-14.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NewsSpecialViewController;
@interface ResponseJsonParseModel : NSObject
-(BOOL)loadLocalSpecialWithCacheVC:(NewsSpecialViewController *)vc andSepcialID:(NSString *)specialID;
-(void)saveJson:(NSString *)data andFileName:(NSString *)name;
-(void)readJsonWithFileName:(NSString *)name;

@end
