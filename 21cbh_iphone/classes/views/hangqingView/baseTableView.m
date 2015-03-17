//
//  baseTableView.m
//  21cbh_iphone
//
//  Created by 21tech on 14-2-19.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "baseTableView.h"

@implementation baseTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ClearColor;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.separatorColor = UIColorFromRGB(0x333333);
        
        if (kDeviceVersion>=7) {
            self.separatorInset = UIEdgeInsetsZero;
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
