//
//  dropDownMenu.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-27.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class dropDownMenu;

typedef enum {
    DrowDownState = 0, // 向下
    DrowUpState = 1 // 向上
    } dropState;
typedef void (^clickDropMenuBlock)(dropDownMenu *dropMenu);
typedef void (^dropDownBlock)(dropDownMenu *dropMenu);

@interface dropDownMenu : UIView

@property (nonatomic,retain) NSArray *titles;
@property (nonatomic,assign) CGFloat btHeight;
@property (nonatomic,assign) CGFloat time;
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,retain) UIColor *color;
@property (nonatomic,retain) UIColor *defaultBackgroundColor;
@property (nonatomic,retain) UIColor *changeColor;
@property (nonatomic,retain) UIColor *changeBackgroundColor;
@property (nonatomic,retain) UIColor *oldBackgroundColor;
@property (nonatomic,copy) clickDropMenuBlock dropMenuBlock;
@property (nonatomic,copy) dropDownBlock dropDownBlocks;
@property (nonatomic,assign) dropState dropState;
@property (nonatomic,assign) int clickIndex;
-(void)dropDown;
@end
