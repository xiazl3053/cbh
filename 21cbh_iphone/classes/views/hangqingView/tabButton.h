//
//  tabButton.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MarketViewController;
@interface tabButton : UIView

@property (strong,nonatomic) NSMutableArray *controllers;
@property (strong,nonatomic) MarketViewController *marketController;
@property (nonatomic,assign) NSInteger currentTag; // 当前点击的按钮tag
#pragma mark 控件初始化
-(id)initWithSuperController:(MarketViewController*)market andFrame:(CGRect)frame;
#pragma mark 点击指定tag的按钮
-(void)clickButtonWithTag:(NSInteger)tag;
#pragma mark 控制视图frame变化
-(void)changeViewFrameWithTag:(int)tag;
@end
