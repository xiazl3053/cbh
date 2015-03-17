//
//  CWPTableViewCell.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CWPTableViewCell.h"

@implementation CWPTableViewCell

+(int)currentCellHeight:(MessageItemAdaptor*)message
{
    return 0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        
        timeLabel_=[[UILabel alloc]init];
        timeLabel_.textColor=[UIColor whiteColor];
        timeLabel_.font=[UIFont systemFontOfSize:12];
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

-(void)fitWithData:(MessageItemAdaptor*)message
{
    message_=message;
    [self reloadTimeWithString:message.timeSpan hidden:message.isHideTime];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size=[message_.timeSpan sizeWithFont:message_.font];
    timeLabel_.frame=CGRectMake((320-size.width)/2, 10, size.width+15, size.height+10);
}

-(void)dealloc
{
    timeLabel_=nil;
}

@end
