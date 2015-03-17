//
//  NSString+Date.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)


#pragma mark - 时间转换

+(NSString *) compareCurrentTime:(NSString*) compareDate
{
    long long  time=[compareDate longLongValue];
    
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
    
    NSTimeInterval  timeInterval = [date timeIntervalSinceNow];
    timeInterval = -timeInterval;
    int temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%d分前",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%d小时前",temp];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%d天前",temp];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%d月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%d年前",temp];
    }
    
    return  result;
}


+(NSString *) compareCurrentTime2:(NSString*) compareDate
{
    long long  time=[compareDate longLongValue];
    
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
    
    NSTimeInterval  timeInterval = [date timeIntervalSinceNow];
    timeInterval = -timeInterval;
    int temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        
        result = [NSString stringWithFormat:@"%d分前",temp];
        
    }
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%d小时前",temp];
        
    }else{
        
        result=[NSString addtimeTurnToTimeString:compareDate];
        
    }
    
    return  result;
}

#pragma mark 时间戳转换成时间
+(NSString *)addtimeTurnToTimeString:(NSString *)addtime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[addtime doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSArray *array=[confromTimespStr componentsSeparatedByString:@"-"];
    NSString *string=[NSString stringWithFormat:@"%@月%@日",array[0],array[1]];
    return string;
}

#pragma mark 获取当前时间戳
+(NSString *)getCurrentTimeString{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    return timeString;
}

@end
