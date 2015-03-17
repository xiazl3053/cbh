//
//  DCommon.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "DCommon.h"
#import "FileOperation.h"
#import "kLineModel.h"
#import "timeShareChartModel.h"

@implementation DCommon

#pragma mark 单位转换
+(NSString*)numToUnits:(float)num{
    float value;
    float v=0;
    NSString *units = @"";
    value = num/10000;
    if (value>10) {
        units = @"万";
        v = value;
    }
    value = num/100000000;
    if (value>1) {
        units = @"亿";
        v = value;
    }
    if (v==0) {
        return [[NSString alloc] initWithFormat:@"%0.0f",num];
    }
    if (v>1000) {
        return [[NSString alloc] initWithFormat:@"%0.0f%@",v,units];
    }
    return [[NSString alloc] initWithFormat:@"%0.2f%@",v,units];
}
#pragma mark 单位整数转换
+(NSString*)numToIntString:(float)num{
    float value;
    float v=0;
    NSString *units = @"";
    value = num/10000;
    if (value>10) {
        units = @"万";
        v = value;
    }
    value = num/100000000;
    if (value>1) {
        units = @"亿";
        v = value;
    }
    if (v==0) {
        return [[NSString alloc] initWithFormat:@"%0.0f",num];
    }
    if (v>1000) {
        return [[NSString alloc] initWithFormat:@"%0.0f%@",v,units];
    }
    return [[NSString alloc] initWithFormat:@"%0.0f%@",v,units];
}
#pragma mark 字符转换为正确显示格式
+(NSString*)stringChange:(NSString*)string{
    if (string==nil || [string isEqualToString:@""]) {
        return @"--";
    }
    CGFloat fl = [string floatValue];
    if (fl>0) {
        return [[NSString alloc] initWithFormat:@"%0.2f",fl];
    }
    return @"--";
}

#pragma mark 转换有E型表达式的值
+(CGFloat)changeEtoFloat:(NSString*)eString{
    CGFloat mainIn = 0.0;
    NSRange rang = [eString rangeOfString:@"E"];
    if (rang.length>0) {
        mainIn = [[eString substringToIndex:rang.location] floatValue];
        int E = [[eString substringFromIndex:rang.location+1] intValue];
        mainIn *= powf(10, E);
    }
    return mainIn;
}
#pragma mark 返回document数据路径
+ (NSString *)documentsAppend:(NSString*)string {
    //文档路径
    //Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //文件夹起名(多级文件名)
    NSString *fileDir = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"21cbh"] stringByAppendingPathComponent:@"db"];
    //判断文件夹是否存在,不存在就创建
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool isexit=[fileManager fileExistsAtPath:fileDir];
    if (!isexit) {// 如果不存在
        //创建文件夹路径
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [fileDir stringByAppendingPathComponent:string];
}
#pragma mark 字符串中分离数字和拼音
+(NSArray*)findNumFromStr:(NSString*)string
{
    NSMutableString *originalString = [[NSMutableString alloc] initWithString:string];
    NSMutableString *numberString = [[NSMutableString alloc] init];
    NSString *tempStr;
    // 扫描
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (![scanner isAtEnd]) {
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        // Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&tempStr];
        if (tempStr) {
            [numberString appendString:tempStr];
        }
        
        tempStr = @"";
    }
    
    NSRange rang = [originalString rangeOfString:numberString];
    if (rang.location<originalString.length) {
        [originalString replaceCharactersInRange:rang withString:@""];
    }
    // 输出
    NSArray *tempArray = [[NSArray alloc] initWithObjects:numberString,originalString, nil];
    return tempArray;
}
#pragma mark 画跟横线吧
+(UIView*)drawLineWithSuperView:(UIView*)superView position:(BOOL)topOrBottom{
    CGRect frame = CGRectMake(0, 0, superView.frame.size.width, 0.5);
    if (!topOrBottom) {
        frame = CGRectMake(0, superView.frame.size.height-0.5, superView.frame.size.width, 0.5);
    }
    UIView *line = [[UIView alloc] initWithFrame:frame];
    [superView addSubview:line];
    return line;
}


#pragma mark 设置自选股中心共享的是否先提交后更新参数
+(void)setIsSubmitThanUpdate:(BOOL)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 1=先提交后更新 0=先更新后提交
    [defaults setObject:[NSNumber numberWithBool:value] forKey:kSelfMarketIsSubmitThanUpdate];
    defaults = nil;
}
+(BOOL)getIsSubmitThanUpdate{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 1=先提交后更新 0=先更新后提交
    return [[defaults valueForKey:kSelfMarketIsSubmitThanUpdate] boolValue];
}

#pragma mark 设置自选股中心管理功能是否操作过
+(void)SetIsChanged:(BOOL)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:value] forKey:@"kSelfMarketIsChanged"];
    defaults = nil;
}

+(BOOL)getIsChanged{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isChange = [[defaults valueForKey:@"kSelfMarketIsChanged"] boolValue];
    defaults = nil;
    return isChange;
}

#pragma mark 设置底部伸缩改变值
+(void)setChangeHeight:(float)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithFloat:value] forKey:@"kButtonChangeHeight"];
    defaults = nil;
}
+(float)getChangeHeight{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat changeHeight = [[defaults valueForKey:@"kButtonChangeHeight"] floatValue];
    return changeHeight;
}

#pragma mark 缓存K线图数据到本地
/**
 缓存规则为 每天只缓存一次K线数据，第二天会清空后再缓存
 */
+(NSMutableArray*)setKLineToLocalWithDatas:(NSMutableArray*)data andKID:(NSString*)kId andType:(int)type andTimes:(NSString*)time andIsRestoration:(BOOL)isRestoration andIsGet:(BOOL)get{
    NSMutableArray *newData;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyyMMdd";
    NSString *dataStr = [df stringFromDate:[NSDate date]];
    // 组装名称  kId+type+date
    NSString *fileName = [[NSString alloc] initWithFormat:@"/%@%d.dat",time,isRestoration];
    FileOperation *_fo = [[FileOperation alloc] init];
    // 股票ID文件夹
    NSString *kidFolder = [[NSString alloc] initWithFormat:@"%@/%@%d/",kLineCacheFolder,kId,type];
    kidFolder = [_fo getFileDirWithFileDirName:kidFolder];
    _fo = nil;
    NSString *folder = kidFolder;
    // 当前日期
    folder = [folder stringByAppendingPathComponent:dataStr];
    // 日期文件夹
    NSString *dateFolder = folder;
    // 缓存文件路径
    fileName = [folder stringByAppendingString:fileName];
    // 文件操作
    NSFileManager *file = [NSFileManager defaultManager];
    if (get) {
        if ([file fileExistsAtPath:fileName]) {
            // 加载对象
            newData = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        }
    }else{
        // 今天的缓存是否存在 不存在就先删掉股票ID下的文件夹，然后再写入，存在就获取
        if (![file fileExistsAtPath:dateFolder]) {
            // 删除股票ID所有缓存文件夹，相当于此K线清理旧的缓存
            [file removeItemAtPath:kidFolder error:nil];
            [file createDirectoryAtPath:dateFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        // 写入新缓存 对象归档
        [NSKeyedArchiver archiveRootObject:data toFile:fileName];
    }
    return newData;
}

#pragma mark 缓存行情数据到本地
/**
 缓存规则为，每次都缓存最后一份数据，遇到无网络情况或者股市收盘则取缓存
 **/
+(NSMutableArray*)setMarketToLocalWithDatas:(NSMutableArray*)data andPageIndex:(int)index andType:(int)type andIsGet:(BOOL)get{

    NSMutableArray *newData;
    NSString *fileName = [[NSString alloc] initWithFormat:@"/market_pageindex%d_type%d.dat",index,type];
    FileOperation *_fo = [[FileOperation alloc] init];
    // 缓存文件夹
    NSString *cacheFolder = [[NSString alloc] initWithFormat:@"%@/",kMarketCacheFolder];
    cacheFolder = [_fo getFileDirWithFileDirName:cacheFolder];
    _fo = nil;
    // 缓存文件路径
    fileName = [cacheFolder stringByAppendingString:fileName];
    // 文件操作
    NSFileManager *file = [NSFileManager defaultManager];
    if (get) {
        if ([file fileExistsAtPath:fileName]) {
            // 加载对象
            newData = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        }
    }else{
        // 写入新缓存 对象归档
        if ([file fileExistsAtPath:fileName]) {
            [file removeItemAtPath:fileName error:nil];
        }
        if (data.count>0) {
            [NSKeyedArchiver archiveRootObject:data toFile:fileName];
        }
        
    }
    return newData;
}


#pragma mark 缓存K线图盘口数据
/**
 缓存规则为，每次都缓存最后一份数据，遇到无网络情况或者股市收盘则取缓存
 **/
+(NSMutableArray*)setPanKouToLocalWithDatas:(NSMutableArray*)data andkId:(NSString*)kId andkType:(int)type andIsGet:(BOOL)get{
    
    NSMutableArray *newData;
    NSString *fileName = [[NSString alloc] initWithFormat:@"/pankou_kid%@_type%d.dat",kId,type];
    FileOperation *_fo = [[FileOperation alloc] init];
    // 缓存文件夹
    NSString *cacheFolder = [[NSString alloc] initWithFormat:@"%@/%@%d/",kLineCacheFolder,kId,type];
    cacheFolder = [_fo getFileDirWithFileDirName:cacheFolder];
    _fo = nil;
    // 缓存文件路径
    fileName = [cacheFolder stringByAppendingString:fileName];
    // 文件操作
    NSFileManager *file = [NSFileManager defaultManager];
    if (get) {
        if ([file fileExistsAtPath:fileName]) {
            // 加载对象
            newData = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        }
    }else{
        // 写入新缓存 对象归档
        if ([file fileExistsAtPath:fileName]) {
            [file removeItemAtPath:fileName error:nil];
        }
        if (data.count>0) {
            [NSKeyedArchiver archiveRootObject:data toFile:fileName];
        }
        
    }
    return newData;
}



#pragma mark 获取时间戳
+(NSString*)getTimestamp{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return [[NSString alloc] initWithFormat:@"%llu",totalMilliseconds];
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
