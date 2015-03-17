//
//  hqBaseViewController.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MarketViewController.h"
#import "transformImageView.h"
@interface hqBaseViewController : BaseViewController
@property (nonatomic,weak) MarketViewController *market;
@property (nonatomic,retain) NSString *kId;
@property (nonatomic,retain) NSString *kName;
@property (nonatomic,assign) int kType;// 类型 0=大盘 1=沪股 2=深股
@property (nonatomic,retain) UIView *topView;
@property (nonatomic,retain) transformImageView *transformImage;// 添加刷新旋转图片
@property (nonatomic,retain) UIButton *searchButton;// 添加搜索按钮
@property (nonatomic,assign) int returnType;
@property (nonatomic,assign) CGFloat changeHeight;// 改变的高度

-(void)initTitle:(NSString *)title returnType:(int)returnType;
-(void)pushKlineController;
-(void)show;// 显示视图
-(void)clear;// 清除视图
-(void)free;// 清除对象
@end
