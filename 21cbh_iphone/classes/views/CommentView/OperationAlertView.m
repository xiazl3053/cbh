//
//  CommentOperationHintView.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-7.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "OperationAlertView.h"
#import "NCMConstant.h"

@implementation OperationAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andTitle:(NSString *)titleName andImageName:(NSString *)imageName{


    if (self=[super initWithFrame:frame]) {
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(20, frame.size.height-30, frame.size.width-20,20)];
        [label setText:titleName];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:16]];
        
        
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake((self.frame.size.width-28)*.5, 20, 28, 28)];
        imageView.image=[UIImage imageNamed:imageName];
        
        
        
        self.backgroundColor=UIColorFromRGB(0x464646);
        [self addSubview:label];
        [self addSubview:imageView];
        
        
        
    }
    
    return self;

}

-(void)addInview:(UIView *)view{
    
    [view addSubview:self];

    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.frame=CGRectMake(220, KAlertCoordinateY, 180, 100);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 delay:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.frame=CGRectMake(320, KAlertCoordinateY, 180, 100);
            
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
            
        }];
    }];

}

-(void)dealloc{

    NSLog(@"---------commentoperationview------delloc------");

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
