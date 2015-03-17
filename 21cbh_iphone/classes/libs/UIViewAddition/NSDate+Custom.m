//
//  NSDate+Custom.m
// 
//
//  Created by Liccon Chang on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Custom.h"

@implementation NSDate (Custom)

+(NSString*)currentDateTimeString
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SS"];
    NSString* str = [formatter stringFromDate:date];
    
    return str;
}

+ (NSString*)intervalSinceNowWithTimestamp:(NSString *)timestamp
{
    NSDate* d= [NSDate dateWithTimestamp:timestamp];
    return [d intervalSinceNow];
}

+ (NSString*)intervalSinceNow:(NSString *)theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    if (d == nil) { //注意：服务器在博客列表中返回的时间字符串格式为:"replyTime":"2012-7-16 17:26"
        [date setDateFormat:@"yyyy-MM-dd HH:mm"];
        d = [date dateFromString:theDate];
    }
    NSString *timeString=[d intervalSinceNow];
    [date release];
    return timeString;
}

- (NSString*)intervalSinceNow
{
    return [self getDateString:@"yyyy-MM-dd HH:mm"];
}

- (NSString*)intervalSinceNow:(NSString*)format
{
    return [self getDateString:format];
}

- (NSString*)intervalSinceNowDate:(NSString*)dataFormat
{
    NSTimeInterval late=[self timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    if (cha<60)
    {
        timeString=[NSString stringWithFormat:@"刚刚"];
    }
    else if (cha>=60 && cha<3600) 
    {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟 前", timeString];
        
    }
    else if (cha>=3600&&cha<86400) 
    {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时 前", timeString];
    }
    else
    {
        timeString=[self getDateString:dataFormat];
    }
    return timeString;    
}

- (NSString*)dateStringForShow
{
    NSDate* nowDate = [NSDate date];
    
    int nowYear = [nowDate getYear];
    int createYear = [self getYear];
    if (nowYear != createYear)//不是当年
    {
        return [self getDateString];
    }
    else
    {
        if ([nowDate getMonth] == [self getMonth])//同月
        {
            if ([nowDate getDay] == [self getDay])//同日
            {
                return [self getDateString:@"HH:mm"];//@"今天";
            }
            else if([nowDate getDay] - [self getDay] == 1)
            {
                return [NSString stringWithFormat:@"昨天 %@",[self getDateString:@"HH:mm"]];//@"昨天";
            }
        }
        return [self getDateString:@"MM-dd"];
    }
}

- (NSString*)dateStringForSessionShow
{
    NSDate* nowDate = [NSDate date];
    
    int nowYear = [nowDate getYear];
    int createYear = [self getYear];
    if (nowYear != createYear)//不是当年
    {
        return [self getDateString];
    }
    else
    {
        if ([nowDate getMonth] == [self getMonth])//同月
        {
            if ([nowDate getDay] == [self getDay])//同日
            {
                return [self getDateString:@"HH:mm"];//@"今天";
            }
            else if([nowDate getDay] - [self getDay] == 1)
            {
                //return [NSString stringWithFormat:@"昨天 %@",[self getDateString:@"HH:mm"]];//@"昨天";
                return [NSString stringWithFormat:@"昨天"];
            }
        }
        return [self getDateString:@"MM-dd"];
    }
}


+ (NSDate*)dateWithDateString:(NSString*)dateTimeString
{
    if (![dateTimeString isKindOfClass:[NSString class]] || [dateTimeString length]<10)
    {
        return nil;
    }
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    NSDate* retDate=nil;
    if ([dateTimeString length]>=19)
    {
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        retDate=[dateFormat dateFromString:[dateTimeString substringToIndex:19]];
    }
    else if ([dateTimeString length]>=16)
    {
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
        retDate=[dateFormat dateFromString:[dateTimeString substringToIndex:16]];
    }
    else
    {
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        retDate=[dateFormat dateFromString:[dateTimeString substringToIndex:10]];
    }
    [dateFormat release];
    return retDate;
}

+ (NSDate*)dateWithTimestamp:(NSString*)timestamp 
{
    NSString* newtimestamp = [NSString stringWithFormat:@"%@%@",timestamp,@"0000000000"];
    NSString* new_sec = [newtimestamp substringToIndex:10];
	NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * timeNumber = [formatter numberFromString:new_sec];
	[formatter release];

	return [NSDate dateWithTimeIntervalSince1970:[timeNumber doubleValue]];
}

- (NSString*)getDateString
{
    return [self getDateString:@"yyyy-MM-dd"];
}

- (NSString*)getDateString:(NSString*)format
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:usLocale];	
	NSString* dateString = [dateFormatter stringFromDate:self];
	[usLocale release];
	[dateFormatter release];
    return dateString;
}

- (NSString*)getTimeString
{
    return [self getTimeString:@"HH:mm:ss"];
}

- (NSString*)getTimeString:(NSString*)format
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:usLocale];	
	NSString* timeString = [dateFormatter stringFromDate:self];
	[usLocale release];
	[dateFormatter release];
    return timeString;
}

//获取日
- (NSUInteger)getDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit) fromDate:self];
    return [dayComponents day];
}
//获取月
- (NSUInteger)getMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit) fromDate:self];
    return [dayComponents month];
}
//获取年
- (NSUInteger)getYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit) fromDate:self];
    return [dayComponents year];
}
//获取小时
- (int)getHour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags =NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit|NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    NSInteger hour = [components hour];
    return (int)hour;
}
//获取分钟
- (int)getMinute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags =NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit|NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    NSInteger minute = [components minute];
    return (int)minute;
}

@end
