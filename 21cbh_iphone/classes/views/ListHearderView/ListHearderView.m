//
//  ListHearderView.m
//  QQListTest
//
//  Created by 周晓 on 14-1-3.
//  Copyright (c) 2014年 shenjx. All rights reserved.
//

#import "ListHearderView.h"

@implementation ListHearderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.canDo=YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    self.canDo=NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.canDo) {
        if ([self.delegate respondsToSelector:@selector(clickListHearderView:)]) {
            [self.delegate clickListHearderView:self];
        }
    }
}
@end
