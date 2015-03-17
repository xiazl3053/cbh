//
//  LoginInputView.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "LoginInputView.h"
#import "ZXTextFiled.h"
#import "UIImage+ZX.h"


#define KLoginInputViewWidth 290
#define KLoginInputViewHeight 43

@interface LoginInputView(){
    
}

@property(assign,nonatomic)UIImageView *imageView;
@property(copy,nonatomic)NSString *normalName;
@property(copy,nonatomic)NSString *highlightedName;
@property(strong,nonatomic)UIColor *normalColor;
@property(strong,nonatomic)UIColor *hightlightedColor;

@end


@implementation LoginInputView

- (id)initWithFrame:(CGRect)frame normalName:(NSString *)normalName highlightedName:(NSString *)highlightedName defaultText:(NSString *)defaultText normalColor:(UIColor *)normalColor hightlightedColor:(UIColor *)hightlightedColor
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.normalName=normalName;
        self.highlightedName=highlightedName;
        self.normalColor=normalColor;
        self.hightlightedColor=hightlightedColor;
        
        self.backgroundColor=UIColorFromRGB(0xffffff);
        
        CGRect frame=self.frame;
        frame.size.width=KLoginInputViewWidth;
        frame.size.height=KLoginInputViewHeight;
        self.frame=frame;
        self.layer.borderWidth = 1;
        self.layer.borderColor=[normalColor CGColor];
        
        UIImage *img=[[UIImage imageNamed:normalName] scaleToSize:CGSizeMake(21, 24)];
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, (KLoginInputViewHeight-img.size.height)*0.5f, img.size.width, img.size.height)];
        [imageView setImage:img];
        [self addSubview:imageView];
        self.imageView=imageView;
        
        ZXTextFiled *textFiled=[[ZXTextFiled alloc] initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+5, (KLoginInputViewHeight-20)*0.5f, KLoginInputViewWidth-(imageView.frame.origin.x+imageView.frame.size.width+1), 20)];
        textFiled.placeholderColor=K808080;
        textFiled.placeholder=defaultText;
        textFiled.font=[UIFont fontWithName:kFontName size:15];
        textFiled.textColor=UIColorFromRGB(0x000000);
        textFiled.textAlignment=NSTextAlignmentLeft;
        textFiled.delegate=self;        
        [self addSubview:textFiled];
        self.textFiled=textFiled;
    }
    return self;
}



#pragma mark - ---------------------UITextField的代理方法---------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    UIImage *img=[UIImage imageNamed:self.highlightedName];
    [self.imageView setImage:img];
    self.layer.borderColor=[self.hightlightedColor CGColor];
    
    if ([self.delegate respondsToSelector:@selector(clickTextFiled:)]) {
        [self.delegate clickTextFiled:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    UIImage *img=[UIImage imageNamed:self.normalName];
    [self.imageView setImage:img];
    self.layer.borderColor=[self.normalColor CGColor];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.delegate respondsToSelector:@selector(clickReturn:)]) {
        [self.delegate clickReturn:self];
    }
    
    return YES;
}


@end
