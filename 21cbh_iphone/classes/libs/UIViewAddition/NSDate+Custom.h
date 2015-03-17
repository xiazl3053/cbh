//
//  NSDate+Custom.h
// 
//
//  Created by Liccon Chang on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(Custom)

+ (NSString*)intervalSinceNowWithTimestamp:(NSString *)timestamp;
+ (NSString*)intervalSinceNow:(NSString *)theDate;
+ (NSDate*)dateWithDateString:(NSString*)dateTimeString;
+ (NSDate*)dateWithTimestamp:(NSString*)timestamp;
+ (NSString*)currentDateTimeString;

- (NSString*)intervalSinceNow;
- (NSString*)intervalSinceNowDate:(NSString*)dataFormat;
- (NSString*)getDateString;
- (NSString*)getDateString:(NSString*)format;
- (NSString*)getTimeString;
- (NSString*)getTimeString:(NSString*)format;

- (NSString*)intervalSinceNow:(NSString*)format;
- (NSString*)dateStringForShow;
- (NSString*)dateStringForSessionShow;
- (NSUInteger)getDay;
- (NSUInteger)getMonth;
- (NSUInteger)getYear;
- (int)getHour;
- (int)getMinute;

@end
