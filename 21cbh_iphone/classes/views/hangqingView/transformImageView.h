//
//  transformImageView.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class transformImageView;
typedef void (^transformActionBlock)(transformImageView *transformView);

@interface transformImageView : UIImageView
{
    CGFloat angle; // 旋转角度
    BOOL isStop;
    NSTimer *time ;// 时间
}

@property (nonatomic,copy) transformActionBlock clickActionBlock; // 点击图片回调

-(void)start;
-(void)stop;

@end
