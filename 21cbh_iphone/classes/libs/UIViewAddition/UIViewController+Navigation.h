//
//  UIViewController+Navigation.h
//   
//
//  Created by gzty1 on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  操作self.navigationItem或self.navigationController

#import <Foundation/Foundation.h>

@interface UIViewController (Navigation)

//在loadView中调用
- (void)setNavigationTitle:(NSString*)title;
- (void)setNavigationTitle:(NSString*)title 
				 textColor:(UIColor*)textColor 
				  fontSize:(int)fontSize 
			   shadowColor:(UIColor*)shadowColor
			  shadowHeight:(int)shadowHeight;
- (void)setNavigationTitle:(NSString*)title
				 textColor:(UIColor*)textColor
                      font:(UIFont*)font
			   shadowColor:(UIColor*)shadowColor
			  shadowHeight:(int)shadowHeight;

- (UIButton*)setNavigationLeftButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
- (UIButton*)setNavigationRightButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
- (UIButton*)setNavigationLeftButtonWithTitle:(NSString*)title
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                                  offset:(CGPoint)offset;
- (UIButton*)setNavigationLeftButtonWithTitle:(NSString*)title  
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                                  titleOffset:(CGPoint)titleOffset;
/*
 offset 导航按钮偏移量
 titleOffset 导航按钮上的文字的偏移量
 */
- (UIButton*)setNavigationLeftButtonWithTitle:(NSString*)title  
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                                  offset:(CGPoint)offset
                             titleOffset:(CGPoint)titleOffset;
- (void)setNavigationLeftButtonWithTitle:(NSString*)title  
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action;

- (UIButton*)setNavigationRightButtonWithTitle:(NSString*)title  
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                                  offset:(CGPoint)offset;
- (void)setNavigationRightButtonWithTitle:(NSString*)title  
                               titleColor:(UIColor*)titleColor
                            normalBgImage:(UIImage*)normalBgImage 
                      hightlightedBgImage:(UIImage*)hightlightedBgImage  
                                   target:(id)target 
                                   action:(SEL)action;
- (UIButton*)setNavigationRightButtonWithTitle:(NSString*)title
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                             titleOffset:(CGPoint)titleOffset;
- (UIButton*)setNavigationRightButtonWithTitle:(NSString*)title  
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                                  offset:(CGPoint)offset
                             titleOffset:(CGPoint)titleOffset;

- (UIButton*)setNavigationLeftButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action offset:(CGPoint)offset;
- (UIButton*)setNavigationRightButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action offset:(CGPoint)offset;
- (UIButton*)setNavigationLeftButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action;
- (UIButton*)setNavigationRightButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action;

- (void)updateNavigationRightButtonTitle:(NSString*)title;
- (void)setNavigationBackButton;
- (void)setNavigationBackButtonWithText:(NSString*)aText normalBgImage:(UIImage*)normalBgImage;
- (void)removeNavigationBackButton;

//重写以处理返回事件
- (void)onNavigationBackPressed;
- (void)dismissModalViewControllerAnimated;

@end
