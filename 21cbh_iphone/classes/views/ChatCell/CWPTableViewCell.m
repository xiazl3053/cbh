//
//  CWPTableViewCell.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CWPTableViewCell.h"

@implementation CWPTableViewCell

+(int)currentCellHeight:(MessageItemAdaptor*)adaptor
{
    return 0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        timeLabel_=[[UILabel alloc]init];
        timeLabel_.textColor=[UIColor whiteColor];
        timeLabel_.font=[UIFont systemFontOfSize:12];
        timeLabel_.textAlignment=NSTextAlignmentCenter;
        timeLabel_.layer.cornerRadius=5;
        timeLabel_.layer.backgroundColor=UIColorFromRGB(0x262626).CGColor;
        timeLabel_.alpha=0.5;
        [self.contentView addSubview:timeLabel_];
    }
    return self;
}

-(void)reloadTimeWithString:(NSString *)time hidden:(BOOL)hidden
{
    timeLabel_.text=time;
    timeLabel_.hidden=hidden;
}

-(void)fillWithData:(MessageItemAdaptor*)adaptor
{
    [self cleanData];
    adaptor_=adaptor;
    [self reloadTimeWithString:adaptor_.timeSpan hidden:adaptor_.isHideTime];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size=[adaptor_.timeSpan sizeWithFont:adaptor_.font];
    timeLabel_.frame=CGRectMake((320-size.width)/2, 5, size.width, 25);
}

-(void)cleanData
{
}

-(void)dealloc
{
    timeLabel_=nil;
    [self cleanData];
}

@end
