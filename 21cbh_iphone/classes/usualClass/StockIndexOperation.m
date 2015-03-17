//
//  StockIndexOperation.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//



#import "StockIndexOperation.h"
#import "kLineModel.h"

@implementation StockIndexOperation

#pragma mark ----------------------------股票指数算法集合-------------------------
#pragma mark EMA算法
/**
 * @param list为收盘价集合 传昨天和今天的数据过来 共两个数据
 **/
+(double)getEXPMA:(NSArray*)list Number:(int)number {
    // 开始计算EMA值，
    double k = 2.0 / (number + 1.0);// 计算出序数  例如 十二日平滑系数（L12）=2/（12+1）=0.1538 二十六日平滑系数（L26）=2/（26+1）=0.0741
    kLineModel *ym = [list firstObject];
    double ema = [ym.MACD_12EMA floatValue];// 昨天ema
    if (number>12) {
        ema = [ym.MACD_26EMA floatValue];
    }
    if (ema<=0) {
        ema = [ym.closePrice floatValue]; // 如果无昨日ema则等于当天收盘价 这个一般是开盘第一天的ema值
    }
    ym = nil;
    // 第二天以后，当天收盘 收盘价乘以系数再加上昨天EMA乘以系数-1
    kLineModel *m = [list lastObject];
    // 加权平均指数（DI）=(当日最高指数+当日最低指数+2倍当日收盘指数)/4
    CGFloat DI = ([m.heightPrice floatValue] + [m.lowPrice floatValue] + 2*[m.closePrice floatValue])/4;
    
    // 十二日指数平均值（12日EMA）= L12×(当日DI值-昨日的12日EMA)+昨日的12日EMA
    ema = k*(DI-ema)+ema;
    if (number==12) {
        m.MACD_12EMA = [NSString stringWithFormat:@"%f",ema];
    }else{
        m.MACD_26EMA = [NSString stringWithFormat:@"%f",ema];
    }
    m = nil;
    return ema;
}

#pragma marl MACD算法
/**
 * calculate MACD values
 *
 * @param list
 *            :N日收盘价集合
 * @param shortPeriod
 *            :短期.
 * @param longPeriod
 *            :长期.
 * @param midPeriod
 *            :M.参数：SHORT(短期)、LONG(长期)、M天数，一般为12、26、9
 * @return 返回第N日的 MACD值
 */
+(NSMutableDictionary*)getMACD:(NSArray*)list andDays:(int)day DhortPeriod:(int)shortPeriod LongPeriod:(int)longPeriod MidPeriod:(int)midPeriod {
    NSMutableDictionary *macdData = [[NSMutableDictionary alloc] init];
    NSMutableArray *diffList = [[NSMutableArray alloc] init];
    double shortEMA = 0.0;
    double longEMA = 0.0;
    double dif = 0.0;
    double dea = 0.0;
    double macd = 0.0;
    if (day>0) {
        kLineModel *ym = [list objectAtIndex:day-1];
        NSArray *sublist = [list subarrayWithRange:NSMakeRange(day-1, 2)];
        shortEMA = [self getEXPMA:sublist Number:shortPeriod];
        longEMA = [self getEXPMA:sublist Number:longPeriod];
        // 每日的DIF值 收盘价短期、长期指数平滑移动平均线间的差
        dif = shortEMA - longEMA;
        [diffList addObject:[NSNumber numberWithDouble:dif]];
        sublist = nil;
        // 9日DIF的平均值(DEA)=最近9日的DIF之和/9
        if ((day+1)>=midPeriod) {
            CGFloat deatemp = 0;
            for (int i=day; i>=day+1-midPeriod; i--) {
                kLineModel *m = [list objectAtIndex:i];
                deatemp += [m.MACD_DIF floatValue];
                m = nil;
            }
            // DEA N日的DIF平均值
            dea = deatemp / midPeriod;
        }
//        kLineModel *ym = [list objectAtIndex:day-1];
//        dea = dif * 0.2 + [ym.MACD_DEA floatValue] * 0.8;
//        ym = nil;
        // MACD=(当日的DIF-昨日的DIF)×0.2+昨日的MACD
        macd = (dif-[ym.MACD_DIF floatValue])*2 + [ym.MACD_M floatValue];
        macd = (dif - dea)*2;
        ym = nil;
    }
    
    [macdData setObject:[NSNumber numberWithDouble:dif] forKey:@"DIF"];
    [macdData setObject:[NSNumber numberWithDouble:dea] forKey:@"DEA"];
    [macdData setObject:[NSNumber numberWithDouble:macd] forKey:@"M"];
    diffList = nil;
    return macdData;
}

#pragma mark KDJ算法
/**
 *  计算公式：rsv =（收盘价– n日内最低价）/（n日内最高价– n日内最低价）×100
 　　K = rsv的m天移动平均值
 　　D = K的m1天的移动平均值
 　　J = 3K - 2D
 　　rsv:未成熟随机值
    rsv天数默认值：9，K默认值：3，D默认值：3。
 **/
+(NSMutableDictionary*)getKDJMap:(NSArray*)m_kData{
    // 默认随机值
    int m_iParam[] = {9, 3, 3};
    int n1 = m_iParam[0];
    int n2 = m_iParam[1];
    int n3 = m_iParam[2];
    if(m_kData == nil || n1 > m_kData.count || n1 < 1)
        return nil;
    // 初始化数组
    NSMutableArray *kvalue = [[NSMutableArray alloc] init];
    NSMutableArray *dvalue = [[NSMutableArray alloc] init];
    NSMutableArray *jvalue = [[NSMutableArray alloc] init];
    // 给初值
    for (id item in m_kData) {
        [kvalue addObject:[NSNumber numberWithInt:0]];
        [dvalue addObject:[NSNumber numberWithInt:0]];
        [jvalue addObject:[NSNumber numberWithInt:0]];
    }
    n2 = n2 > 0 ? n2 : 3;
    n3 = n3 > 0 ? n3 : 3;
    // 第九天的k线图数据单例
    kLineModel *model = (kLineModel*)[m_kData objectAtIndex:(n1-1)];
    // 计算N日内的最低最高价
    float maxhigh = [model.heightPrice floatValue]; // 最高价
    float minlow = [model.lowPrice floatValue]; // 最低价
    for(int j = n1 - 1; j >= 0; j--) {
        kLineModel *m = (kLineModel*)[m_kData objectAtIndex:(j)];
        if(maxhigh < [m.heightPrice floatValue])
            maxhigh = [m.heightPrice floatValue];
        if(minlow < [m.lowPrice floatValue])
            minlow = [m.lowPrice floatValue];
        m = nil;
    }
    // 计算RSV值
    float rsv;
    if(maxhigh <= minlow)
        rsv = 50.0f;
    else
        rsv = (([model.closePrice floatValue] - minlow) / (maxhigh - minlow)) * 100.0f;
    float prersv;
    prersv = rsv;
    [jvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    [dvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    [kvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    for(int i = 0; i < n1; i++) {
        [jvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
        [dvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
        [kvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
    }
    
    for(int i = n1; i < m_kData.count; i++) {
        kLineModel *m = (kLineModel*)[m_kData objectAtIndex:i];
        maxhigh = [m.heightPrice floatValue];
        minlow = [m.lowPrice floatValue];
        for(int j = i - 1; j > i - n1; j--) {
            kLineModel *mm = (kLineModel*)[m_kData objectAtIndex:j];
            if(maxhigh < [mm.heightPrice floatValue])
                maxhigh = [mm.heightPrice floatValue];
            if(minlow > [mm.lowPrice floatValue])
                minlow = [mm.lowPrice floatValue];
        }
        
        if(maxhigh <= minlow) {
            rsv = prersv;
        } else {
            prersv = rsv;
            rsv = (([m.closePrice floatValue] - minlow) / (maxhigh - minlow)) * 100.0f;
        }
        // 计算K值
        CGFloat newK = ([[kvalue objectAtIndex:i-1] floatValue] * (float)(n2 - 1)) / (float)n2 + rsv / (float)n2;
        [kvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newK]];
        // 计算D值
        CGFloat newD = [[kvalue objectAtIndex:i] floatValue] / (float)n3 + ([[dvalue objectAtIndex:i-1] floatValue] * (float)(n3 - 1)) / (float)n3;
        [dvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newD]];
        // 计算J值
        CGFloat newJ = [[kvalue objectAtIndex:i] floatValue] * 3.0f - 2.0f*[[dvalue objectAtIndex:i] floatValue];
        [jvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newJ]];

    }
    // 封装好返回
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:kvalue forKey:@"K"];
    [dic setObject:dvalue forKey:@"D"];
    [dic setObject:jvalue forKey:@"J"];
    return dic;
}
#pragma mark 计算MA均线值
+(void)CalculateMA:(NSMutableArray*)data{
    int m_iParam[] = {
        5, 10, 20
    };
    if(data == nil || data.count == 0)
        return;
    for(int i = 0; i < 3; i++) {
        [self AverageClose:m_iParam[i] Datas:data];
    }
}
#pragma mark 计算MA的均线值
+(void)AverageClose:(int)iParam Datas:(NSMutableArray*)data{
    int n = iParam;
    if(n > data.count || n < 1)
        return;
    float preClose = 0.0F; // K线图均线N1天的值
    double sum = 0.0; // K线图N天的总和
    float preVolume = 0.0f; // 成交量均线N1的值
    double volSum = 0.0; // 成交量均线的总和
    // MA线前N天收盘价总和
    for(int i = 0; i < n - 1; i++){
        kLineModel *m = (kLineModel*)[data objectAtIndex:i];
        sum += [m.closePrice floatValue];
        volSum += [m.volume floatValue];
        m = nil;
    }
    
    for(int i = n - 1; i < data.count; i++) {
        kLineModel *m = (kLineModel*)[data objectAtIndex:i];
        sum -= preClose;
        volSum -= preVolume;
        // 此处SUM相当于N天的收盘价之和
        sum += [m.closePrice floatValue];
        volSum += [m.volume floatValue];
        CGFloat MAValue = (float)(sum / (double)n);
        CGFloat volMAValue = (float)(volSum / (double)n);
        if (n==5) {
            m.MA5 = [[NSString alloc] initWithFormat:@"%.2f",MAValue];
            m.volMA5 = [[NSString alloc] initWithFormat:@"%.2f",volMAValue];
        }
        if (n==10) {
            m.MA10 = [[NSString alloc] initWithFormat:@"%.2f",MAValue];
            m.volMA10 = [[NSString alloc] initWithFormat:@"%.2f",volMAValue];
        }
        if (n==20) {
            m.MA20 = [[NSString alloc] initWithFormat:@"%.2f",MAValue];
        }
        // N天均线的起始天数的收盘价
        kLineModel *startM = (kLineModel*)[data objectAtIndex:(i - n) + 1];
        preClose = [startM.closePrice floatValue];
        preVolume = [startM.volume floatValue];
        startM = nil;
        m = nil;
    }
    
}


@end
