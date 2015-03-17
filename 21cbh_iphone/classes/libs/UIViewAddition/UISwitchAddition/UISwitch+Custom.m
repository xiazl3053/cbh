//
//  UISwitch+Custom.m
//   
//
//  Created by rannger on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UISwitch+Custom.h"
#define TAG_LEFT_LABEL 900
#define TAG_RIGHT_LABEL 901
@implementation UISwitch (Custom)

-(id)initWithLeftText:(NSString *)tag1 andRight:(NSString *)tag2
{    
    if (self=[super init]) 
    {
        UILabel* leftLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        UILabel* rightLable=[[UILabel alloc] initWithFrame:CGRectZero];
        [leftLabel setText:tag1];
        [rightLable setText:tag2];
        [leftLabel setTag:TAG_LEFT_LABEL];
        [rightLable setTag:TAG_RIGHT_LABEL];
        rightLable.backgroundColor=[UIColor clearColor];
        leftLabel.backgroundColor=[UIColor clearColor];
        [self addSubview:leftLabel];
        [self addSubview:rightLable];
        [leftLabel release];
        [rightLable release];
    }

    return self;
}

- (void)configFrame:(CGRect)frame
{
    UILabel* leftLabel=(UILabel*)[self viewWithTag:TAG_LEFT_LABEL];
    UILabel* rightLabel=(UILabel*)[self viewWithTag:TAG_RIGHT_LABEL];
    leftLabel.frame=CGRectMake(-frame.size.width/4, frame.origin.y/4, frame.size.width/2, frame.size.height/2);
    rightLabel.frame=CGRectMake(frame.size.width*5/6, frame.origin.y/4, frame.size.width/2, frame.size.height/2);
    [self setFrame:frame];
}
@end
