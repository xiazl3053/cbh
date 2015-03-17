//
//  basehqCell.h
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hqBaseViewController.h"
@interface basehqCell : UITableViewCell
{
    UIView *cellView;
}

@property (nonatomic,retain) NSMutableArray *data;
@property (nonatomic,retain) NSMutableArray *oldData;
@property (nonatomic) CGFloat height;
@property (nonatomic,weak) hqBaseViewController *controller;
@property (nonatomic,retain) NSString *kId;
@property (nonatomic,retain) NSString *kName;
@property (nonatomic,assign) int rowCount; // 列数
@property (nonatomic,assign) int startIndex;// 起始位置
@property (nonatomic,assign) CGFloat leftWidth; // 左边宽度
@property (nonatomic,assign) BOOL cellType; // cell的类型，0默认，1左边图片
@property (nonatomic,retain) NSMutableArray *fileds; // 字段名称数组
@property (nonatomic,retain) NSMutableArray *values; // 字段值数组

-(void)updateCell;
-(void)show;
@end
