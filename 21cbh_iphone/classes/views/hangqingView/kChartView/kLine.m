//
//  kLine.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-21.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "kLine.h"
#import "UIColor+helper.h"
#import "colorModel.h"

@implementation kLine

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSet];
    }
    return self;
}

-(void)dealloc{
    if (self.points) {
        [self.points removeAllObjects];
    }
    self.points = nil;
    [self removeAllSubviews];
}

#pragma mark 初始化参数
-(void)initSet{
    self.backgroundColor = [UIColor clearColor];
    self.startPoint = self.frame.origin;
    self.endPoint = self.frame.origin;
    self.color = UIColorFromRGB(0x000000);
    self.lineWidth = 1.0f;
    self.isK = NO;
    self.isVol = NO;
}


-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();// 获取绘图上下文
    if (self.isK || (self.isTimeShare && self.isVol) || self.isMACDM) {
        // 画k线
        for (NSArray *item in self.points) {
            // 转换坐标
            CGPoint heightPoint,lowPoint,openPoint,closePoint;
            heightPoint = CGPointFromString([item objectAtIndex:0]);
            lowPoint = CGPointFromString([item objectAtIndex:1]);
            openPoint = CGPointFromString([item objectAtIndex:2]);
            closePoint = CGPointFromString([item objectAtIndex:3]);

            [self drawKWithContext:context height:heightPoint Low:lowPoint open:openPoint close:closePoint width:self.lineWidth];
        }
        
    }else{
        // 画连接线
        [self drawLineWithContext:context];
    }
    context = NULL;
    CGContextRelease(context);
    free(context);
}

#pragma mark -------------------------------自定义方法-----------------------------

#pragma mark 画连接线
-(void)drawLineWithContext:(CGContextRef)context{
    CGContextSetLineWidth(context, self.lineWidth);
    //NSLog(@"---DFM---self.lineWidth:%f",self.lineWidth);
    CGContextSetShouldAntialias(context, YES);
    // 设置颜色
    [self.color setStroke];
    
    if (self.points.count>0) {
        [self.color setStroke];
        // 定义多个个点 画多点连线
        for (id item in self.points) {
            CGPoint currentPoint = CGPointFromString(item);
            if ((int)currentPoint.y<(int)self.frame.size.height && currentPoint.y>=0) {
                if ([self.points indexOfObject:item]==0) {
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                    continue;
                }
                CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
                //NSLog(@"---DFM---点：%@",item);
                CGContextStrokePath(context); //开始画线
                if ([self.points indexOfObject:item]<self.points.count) {
                    CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                }
                
            }
        }
    }else{
        // 如果是虚线
        if (self.isDash) {
            //float lengths[] = {2,3};
            CGFloat lengths[] = {2,3};
            CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
        }
        // 定义两个点 画两点连线
        const CGPoint points[] = {self.startPoint,self.endPoint};
        CGContextStrokeLineSegments(context, points, 2);  // 绘制线段（默认不绘制端点）
    }
}

#pragma mark 画一根K线
-(void)drawKWithContext:(CGContextRef)context height:(CGPoint)heightPoint Low:(CGPoint)lowPoint open:(CGPoint)openPoint close:(CGPoint)closePoint width:(CGFloat)width{
    CGContextSetShouldAntialias(context, YES);
    // 首先判断是绿的还是红的，根据开盘价和收盘价的坐标来计算
    BOOL isKong = NO;
    //设置红色的线宽为1
    CGFloat lWidth = 1;
    if (self.lineWidth<=2) {
        lWidth = 0.5; // 红色实体的宽度
    }
    // 如果开盘价坐标在收盘价坐标上方 则为绿色 即空
    if (openPoint.y<closePoint.y) {
        isKong = YES;
    }
    // 如果是分时线的成交量
    if (self.isTimeShare) {
        CGContextSetShouldAntialias(context, YES);
        CGContextSetBlendMode(context, kCGBlendModeSoftLight);
        CGContextSetLineWidth(context, self.lineWidth);
       // NSLog(@"---DFM---分时线成交量的宽度：%f",self.lineWidth);
        if (openPoint.y<closePoint.y) {
            // 画绿色
            [kGreenColor setStroke];
        }else{
            // 画红色
            [kRedColor setStroke];
        }
        const CGPoint points[] = {CGPointMake(heightPoint.x, heightPoint.y),CGPointMake(lowPoint.x, lowPoint.y)};
        CGContextStrokeLineSegments(context, points, 2);
        
    }else{
        // 首先画一个垂直的线包含上影线和下影线
        if (!self.isVol) {
            CGContextSetLineWidth(context, 1); // 上下阴影线的宽度
            if (self.lineWidth<=2) {
                CGContextSetShouldAntialias(context, NO);
                CGContextSetLineWidth(context, 0.5); // 上下阴影线的宽度
            }
            //CGContextSetLineWidth(context, 0.5);
            if (openPoint.y<closePoint.y) {
                // 画空线的上下影线
                // 设置线条颜色
                [kGreenColor setStroke];
                const CGPoint points[] = {CGPointMake(heightPoint.x, heightPoint.y),CGPointMake(lowPoint.x, lowPoint.y)};
                CGContextStrokeLineSegments(context, points, 2);

            }else{
                // 画多线的上下影线
                // 设置线条颜色
                [kRedColor setStroke];
                const CGPoint points[] = {CGPointMake(heightPoint.x, heightPoint.y),CGPointMake(lowPoint.x, lowPoint.y)};
                CGContextStrokeLineSegments(context, points, 2);
            }
        }else{
            if (openPoint.y<=0) {
                return;
            }
        }
        // 纠正实体的中心点为当前坐标
        openPoint = CGPointMake(openPoint.x, openPoint.y);
        closePoint = CGPointMake(closePoint.x, closePoint.y);
        if (self.isVol) {
            openPoint = CGPointMake(heightPoint.x, heightPoint.y);
            closePoint = CGPointMake(lowPoint.x, lowPoint.y);
        }
        // 开始画实体
        if (isKong) {
            // 画空线
            // 设置线条颜色
            [kGreenColor setStroke];
            CGContextSetLineWidth(context, width);
            const CGPoint point[] = {openPoint,closePoint};
            CGContextStrokeLineSegments(context, point, 2);  // 绘制
        }else{
            // 画多线
            //设置线条颜色
            [kRedColor setStroke];
            CGContextSetLineWidth(context, width);
            const CGPoint point[] = {openPoint,closePoint};
            CGContextStrokeLineSegments(context, point, 2);  // 绘制
            
        }
    }
    
    
    
}


@end
