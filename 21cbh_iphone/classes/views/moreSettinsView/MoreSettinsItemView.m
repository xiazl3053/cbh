//
//  MoreSettinsItemView.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-18.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MoreSettinsItemView.h"
#import "UIImage+ZX.h"

#define kMoreSettinsItemViewHeight 42

@implementation MoreSettinsItemView

- (id)initWithArray:(NSMutableArray *)array
{
    self = [super init];
    if (self) {
        [self initMoreSettinsItemView:array];
    }
    return self;
}



-(void)initMoreSettinsItemView:(NSArray *)array{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, kMoreSettinsItemViewHeight);
    self.backgroundColor=UIColorFromRGB(0xffffff);
    self.tag=[[array objectAtIndex:0] intValue];
    
    self.canResponse=YES;
    
    //图像
    UIImage *img=[[UIImage imageNamed:[array objectAtIndex:2]] scaleToSize:CGSizeMake(20, 23)];
    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake(15, (self.frame.size.height-img.size.height)*0.5f, img.size.width, img.size.height)];
    [iv setImage:img];
    [self addSubview:iv];
    
    //说明
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(iv.frame.origin.x+iv.frame.size.width+21, (self.frame.size.height-20)*0.5f, 150, 20)];
    lable.backgroundColor=[UIColor clearColor];
    lable.textAlignment=NSTextAlignmentLeft;
    lable.text=[array objectAtIndex:1];
    lable.font=[UIFont systemFontOfSize:15];
    lable.textColor=UIColorFromRGB(0x000000);
    [self addSubview:lable];
    
    //进标志
    UIImage *img1=[[UIImage imageNamed:@"ms_in"] scaleToSize:CGSizeMake(7, 13)];
    UIImageView *iv1=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-15-img1.size.width, (self.frame.size.height-img1.size.height)*0.5f, img1.size.width, img1.size.height)];
    [iv1 setImage:img1];
    [self addSubview:iv1];
    self.inTag=iv1;
    
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5f, self.frame.size.width, 0.5f)];
    line.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [self addSubview:line];
    _line=line;
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canResponse) {
        return;
    }
    self.backgroundColor=UIColorFromRGB(0xaaaaaa);
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canResponse) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor=UIColorFromRGB(0xffffff);
    }];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canResponse) {
        return;
    }
   [UIView animateWithDuration:0.5 animations:^{
       self.backgroundColor=UIColorFromRGB(0xffffff);
   }];
    //NSLog(@"点击了moreSetting的item");
    if ([self.delegate respondsToSelector:@selector(clickMoreSettinsItem:)]) {
        [self.delegate clickMoreSettinsItem:self];
    }
    
}

@end
