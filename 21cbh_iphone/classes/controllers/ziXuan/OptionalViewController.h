//
//  Information ViewController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "transformImageView.h"

@class ziXuanIndexViewController;

@interface OptionalViewController : BaseViewController<MainDelegate>

@property (strong,nonatomic) transformImageView *transformImage ;// 刷新状态图片
@property (nonatomic,retain) ziXuanIndexViewController *zixuan;
@property (nonatomic,assign) CGFloat changeHeight;// 根据底部导航的隐藏与否来确定高度
@property (nonatomic,retain) UIButton *searchButton;//搜索按钮
#pragma mark 按钮状态的改变
-(void)changeButtonViews;
-(void)clickEditButtonAction:(UIButton*)button;
@end
