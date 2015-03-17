//
//  SetFontView.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "SetFontView.h"
#import "UIImage+ZX.h"
#define kMoreSettinsItemViewHeight 42

@interface SetFontView(){
    
}

@end

@implementation SetFontView

- (id)initWithDic:(NSMutableDictionary *)dic
{
    self = [super init];
    if (self) {
        // Initialization code
        UIScreen *MainScreen = [UIScreen mainScreen];
        CGSize size = [MainScreen bounds].size;
        self.frame=CGRectMake(0, 0, size.width, kMoreSettinsItemViewHeight);
        self.backgroundColor=UIColorFromRGB(0xffffff);
        
        //说明
        UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(40, (self.frame.size.height-20)*0.5f, 150, 20)];
        lable.backgroundColor=[UIColor clearColor];
        lable.textAlignment=NSTextAlignmentLeft;
        lable.text=[dic objectForKey:@"text"];
        lable.font=[UIFont systemFontOfSize:[[dic objectForKey:@"fontSize"] floatValue]];
        lable.textColor=UIColorFromRGB(0x000000);
        [self addSubview:lable];
        
        //勾选标志
        UIImage *img=[[UIImage imageNamed:@"comment_yes_selected"] scaleToSize:CGSizeMake(21, 17)];
        UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-15-img.size.width, (self.frame.size.height-img.size.height)*0.5f, img.size.width, img.size.height)];
        [iv setImage:img];
        [self addSubview:iv];
        iv.hidden=YES;
        _iv=iv;
        
        UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
        line.backgroundColor=UIColorFromRGB(0xcccccc);
        [self addSubview:line];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    self.backgroundColor=UIColorFromRGB(0xaaaaaa);
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor=UIColorFromRGB(0xffffff);
    }];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor=UIColorFromRGB(0xffffff);
    }];
    
    if ([self.delegate respondsToSelector:@selector(clickSetFontViewItem:)]) {
        [self.delegate clickSetFontViewItem:self];
    }
    
}


@end
