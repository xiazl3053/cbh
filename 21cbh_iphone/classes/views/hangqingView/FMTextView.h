//
//  FMTextView.h
//  Liuxue
//
//  Created by zhaomingxi on 14-1-30.
//  Copyright (c) 2014年 zhaomingxi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMTextView : UITextView
@property (nonatomic,assign) CGSize fmDefaultImageSize; // 图片默认大小
@property (nonatomic,retain) NSMutableDictionary *fmImages;// 对外暴露内容中的图片字典
@property (nonatomic,assign) BOOL isStrHeight;// 是否计算文本高度，用来防止死循环
@property (nonatomic,assign) CGFloat lineHeight;// 行高
@property (nonatomic,assign) CGPoint currentPoint;// 在循环绘制中当期的坐标值，一般用来指定下一个坐标的开始值
@end
