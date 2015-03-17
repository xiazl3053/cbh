//
//  TopBar.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-3-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "TopBar.h"

@interface TopBar(){
    UIColor *_btnTexNormalColor;
    UIColor *_btnTextSelectedColor;
    NSMutableArray *_btns;

}

@end

@implementation TopBar

- (id)initWithFrame:(CGRect)frame array:(NSArray *)array btnTexNormalColor:(UIColor *)btnTexNormalColor btnTextSelectedColor:(UIColor *)btnTextSelectedColor
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!array||array.count<1) {
            return nil;
        }
        
        _btnTexNormalColor=btnTexNormalColor;
        _btnTextSelectedColor=btnTextSelectedColor;
        _btns=[NSMutableArray array];
        _currentIndex=0;
        
        int count=array.count;
        
        CGFloat btnWidth=self.frame.size.width/count;
        CGFloat btnHeight=self.frame.size.height;
        
        for (int i=0; i<count; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(btnWidth*i, 0, btnWidth, btnHeight)];
            btn.titleLabel.text=[array objectAtIndex:i];
            btn.titleLabel.textAlignment=NSTextAlignmentCenter;
            btn.titleLabel.font=[UIFont systemFontOfSize:16];
            btn.tag=i;
            [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitle:[array objectAtIndex:i] forState:UIControlStateHighlighted];
            
            [btn setTitleColor:_btnTexNormalColor forState:UIControlStateNormal];
            [btn setTitleColor:_btnTextSelectedColor forState:UIControlStateHighlighted];
            
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [_btns addObject:btn];
        }
        
        UIView *line1=[[UIView alloc] initWithFrame:CGRectMake(0, btnHeight-0.5, self.frame.size.width, 0.5)];
        line1.backgroundColor=K808080;
       // [self addSubview:line1];
        
        UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, btnHeight-3, btnWidth, 3)];
        line.backgroundColor=UIColorFromRGB(0xee5909);
        [self addSubview:line];
        _line=line;
        
        
        self.currentIndex=0;//默认选中第一个
        
    }
    
    return self;
}



-(void)btnClick:(UIButton *)btn{
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame=_line.frame;
        frame.origin.x=btn.frame.origin.x;
        _line.frame=frame;
    } completion:^(BOOL finished) {
        
    }];
    
    _currentIndex=btn.tag;
    for (int i=0; i<_btns.count; i++) {
        UIButton *btn=[_btns objectAtIndex:i];
        if (i==_currentIndex) {
            [btn setTitleColor:_btnTextSelectedColor forState:UIControlStateNormal];
            [btn setTitleColor:_btnTextSelectedColor forState:UIControlStateHighlighted];
        }else{
            [btn setTitleColor:_btnTexNormalColor forState:UIControlStateNormal];
            [btn setTitleColor:_btnTextSelectedColor forState:UIControlStateHighlighted];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(topBarclickBtn:)]) {
        [self.delegate topBarclickBtn:btn];
    }
}


-(void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex=currentIndex;
    for (int i=0; i<_btns.count; i++) {
        UIButton *btn=[_btns objectAtIndex:i];
        if (i==_currentIndex) {
            [btn setTitleColor:_btnTextSelectedColor forState:UIControlStateNormal];
            [btn setTitleColor:_btnTextSelectedColor forState:UIControlStateHighlighted];
            if ([self.delegate respondsToSelector:@selector(topBarclickBtn:)]) {
                [self.delegate topBarclickBtn:btn];
            }
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame=_line.frame;
                frame.origin.x=btn.frame.origin.x;
                _line.frame=frame;
            } completion:^(BOOL finished) {
                
            }];
        }else{
            [btn setTitleColor:_btnTexNormalColor forState:UIControlStateNormal];
            [btn setTitleColor:_btnTextSelectedColor forState:UIControlStateHighlighted];
        }
    }

}

@end
