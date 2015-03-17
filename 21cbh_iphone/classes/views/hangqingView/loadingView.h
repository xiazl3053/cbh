//
//  loadingView.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loadingView : UIView
@property (nonatomic,retain) NSString *title;
-(id)initWithTitle:(NSString*)title Frame:(CGRect)frame;
-(id)initWithTitle:(NSString*)title Frame:(CGRect)frame IsFullScreen:(BOOL)fullScreen;
-(void)start;
-(void)stop;
-(void)setSelfTitle:(NSString*)title isSuccess:(BOOL)success andSecond:(int)second;
@end
