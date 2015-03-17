//
//  LoginInputView.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
//haha
@protocol LoginInputViewDelegate;
@interface LoginInputView : UIView<UITextFieldDelegate>

@property(assign,nonatomic)UITextField *textFiled;

- (id)initWithFrame:(CGRect)frame normalName:(NSString *)normalName highlightedName:(NSString *)highlightedName defaultText:(NSString *)defaultText normalColor:(UIColor *)normalColor hightlightedColor:(UIColor *)hightlightedColor;

@property(assign,nonatomic)id<LoginInputViewDelegate>delegate;
@end


@protocol LoginInputViewDelegate <NSObject>
- (void)clickReturn:(LoginInputView *)loginInputView;
- (void)clickTextFiled:(LoginInputView *)loginInputView;

@end