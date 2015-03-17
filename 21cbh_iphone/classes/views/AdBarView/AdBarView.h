//
//  AdBarView.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdBarViewDelegate;

@interface AdBarView : UIView

@property(assign,nonatomic)id<AdBarViewDelegate>delegate;

- (id)initWithPicUrl:(NSString *)picUrl location_y:(CGFloat)location_y;
#pragma mark 设置广告图片
-(void)adBarSetPic;
@end

@protocol AdBarViewDelegate <NSObject>
-(void)clickImage;
-(void)clickBtn;
-(void)finishImage;
@end