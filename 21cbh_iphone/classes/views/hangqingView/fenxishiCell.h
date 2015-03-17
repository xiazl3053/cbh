//
//  fenxishiCell.h
//  21cbh_iphone
//
//  Created by 21tech on 14-3-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class hqBaseViewController;
@interface fenxishiCell : UITableViewCell
{
    UIView *cellView;
}

@property (nonatomic,retain) NSMutableArray *data;
@property (nonatomic) CGFloat height;
@property (nonatomic,retain) id controller;

-(void)updateCell;
-(void)show;

@end
