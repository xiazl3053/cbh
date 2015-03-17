//
//  DCommon.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCommon : NSObject

#pragma mark 单位转换
+(NSString*)numToUnits:(float)num;
#pragma mark 单位整数转换
+(NSString*)numToIntString:(float)num;
#pragma mark 转换有E型表达式的值
+(CGFloat)changeEtoFloat:(NSString*)eString;
#pragma mark 字符转换为正确显示格式
+(NSString*)stringChange:(NSString*)string;
#pragma mark 返回document数据路径
+ (NSString *)documentsAppend:(NSString*)string;
#pragma mark 字符串中找数字
+(NSArray*)findNumFromStr:(NSString*)string;
#pragma mark 画跟横线吧
+(UIView*)drawLineWithSuperView:(UIView*)superView position:(BOOL)topOrBottom;
#pragma mark 设置自选股中心共享的是否先提交后更新参数
+(void)setIsSubmitThanUpdate:(BOOL)value;
#pragma mark 获取设置的是否先提交后更新参数
+(BOOL)getIsSubmitThanUpdate;
#pragma mark 底部导航栏伸缩改变高度
+(void)setChangeHeight:(float)value;
+(float)getChangeHeight;
#pragma mark 缓存K线图数据到本地
+(NSMutableArray*)setKLineToLocalWithDatas:(NSMutableArray*)data andKID:(NSString*)kId andType:(int)type andTimes:(NSString*)time andIsRestoration:(BOOL)isRestoration andIsGet:(BOOL)get;
#pragma mark 缓存行情数据
+(NSMutableArray*)setMarketToLocalWithDatas:(NSMutableArray*)data andPageIndex:(int)index andType:(int)type andIsGet:(BOOL)get;
#pragma mark 缓存K线图盘口数据
/**
 缓存规则为，每次都缓存最后一份数据，遇到无网络情况或者股市收盘则取缓存
 **/
+(NSMutableArray*)setPanKouToLocalWithDatas:(NSMutableArray*)data andkId:(NSString*)kId andkType:(int)type andIsGet:(BOOL)get;
#pragma mark 获取时间戳
+(NSString*)getTimestamp;
#pragma mark 纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
#pragma mark 自选股中心是否操作过
+(void)SetIsChanged:(BOOL)value;
+(BOOL)getIsChanged;

@end
