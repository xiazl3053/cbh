//
//  UITextField+Custom.h
//   
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UITextField (Custom)

+(UITextField*)textFieldWithFrame:(CGRect)aFrame 
					  placeholder:(NSString*)aPlaceholder
						 delegate:(id<UITextFieldDelegate>)aDelegate
					returnKeyType:(UIReturnKeyType)aReturnKeyType;
+(UITextField*)textFieldWithFrame:(CGRect)aFrame 
					  borderStyle:(UITextBorderStyle)borderStyle
						 leftView:(UIView*)leftView
					  placeholder:(NSString*)aPlaceholder
						 delegate:(id<UITextFieldDelegate>)aDelegate
					returnKeyType:(UIReturnKeyType)aReturnKeyType;
+(UITextField*)textFieldWithFrame:(CGRect)aFrame 
					  placeholder:(NSString*)aPlaceholder
						 delegate:(id<UITextFieldDelegate>)aDelegate
					returnKeyType:(UIReturnKeyType)aReturnKeyType
                      paddingLeft:(float)paddingLeft
                     paddingRight:(float)paddingRight;
+(UITextField*)textFieldWithFrame:(CGRect)aFrame 
					  borderStyle:(UITextBorderStyle)borderStyle
						 leftView:(UIView*)leftView
					  placeholder:(NSString*)aPlaceholder
						 delegate:(id<UITextFieldDelegate>)aDelegate
					returnKeyType:(UIReturnKeyType)aReturnKeyType
                      paddingLeft:(float)paddingLeft
                     paddingRight:(float)paddingRight;

@end

@interface UITextFieldEx : UITextField 
{
    BOOL isEnablePadding;
    float paddingLeft;
    float paddingRight;
    float paddingTop;
    float paddingBottom;
}

- (void)setPadding:(BOOL)enable top:(float)top right:(float)right bottom:(float)bottom left:(float)left;
@end
