//
//  UITextField+Custom.m
//   
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UITextField+Custom.h"


@implementation UITextField (Custom)

+(UITextField*)textFieldWithFrame:(CGRect)aFrame 
					  placeholder:(NSString*)aPlaceholder
						 delegate:(id<UITextFieldDelegate>)aDelegate
					returnKeyType:(UIReturnKeyType)aReturnKeyType;
{
	return [self textFieldWithFrame:aFrame 
						borderStyle:UITextBorderStyleRoundedRect
						   leftView:nil
						placeholder:aPlaceholder
						   delegate:aDelegate
					  returnKeyType:aReturnKeyType];
}

+(UITextField*)textFieldWithFrame:(CGRect)aFrame 
					  borderStyle:(UITextBorderStyle)borderStyle
						 leftView:(UIView*)leftView
					  placeholder:(NSString*)aPlaceholder
						 delegate:(id<UITextFieldDelegate>)aDelegate
					returnKeyType:(UIReturnKeyType)aReturnKeyType;
{
	return  [UITextField textFieldWithFrame:(CGRect)aFrame 
                                borderStyle:borderStyle
                                   leftView:leftView
                                placeholder:aPlaceholder
                                   delegate:aDelegate
                              returnKeyType:aReturnKeyType
                                paddingLeft:0 
                               paddingRight:0];
}

+(UITextField*)textFieldWithFrame:(CGRect)aFrame 
					  placeholder:(NSString*)aPlaceholder
						 delegate:(id<UITextFieldDelegate>)aDelegate
					returnKeyType:(UIReturnKeyType)aReturnKeyType
                      paddingLeft:(float)paddingLeft
                     paddingRight:(float)paddingRight
{
	return [self textFieldWithFrame:aFrame 
						borderStyle:UITextBorderStyleRoundedRect
						   leftView:nil
						placeholder:aPlaceholder
						   delegate:aDelegate
					  returnKeyType:aReturnKeyType 
                        paddingLeft:paddingLeft
                       paddingRight:paddingRight];
}

+(UITextField*)textFieldWithFrame:(CGRect)aFrame 
					  borderStyle:(UITextBorderStyle)borderStyle
						 leftView:(UIView*)leftView
					  placeholder:(NSString*)aPlaceholder
						 delegate:(id<UITextFieldDelegate>)aDelegate
					returnKeyType:(UIReturnKeyType)aReturnKeyType
                      paddingLeft:(float)paddingLeft
                     paddingRight:(float)paddingRight
{
	UITextField* textField=nil;
    if(paddingLeft>0 || paddingRight>0)
    {
        textField=[[[UITextFieldEx alloc] initWithFrame:aFrame] autorelease];
        [((UITextFieldEx*)textField) setPadding:YES top:0 right:paddingRight bottom:0 left:paddingLeft];
	}
    else 
    {
        textField=[[[UITextField alloc] initWithFrame:aFrame] autorelease];
    }
	textField.borderStyle=borderStyle;
	textField.delegate=aDelegate;
	textField.placeholder=aPlaceholder;
	//[textField addTarget:aDelegate action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
	//iUserNameTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	textField.returnKeyType = aReturnKeyType;
	//iUserNameTextField.returnKeyType=UIReturnKeyDone;
	textField.clearButtonMode=UITextFieldViewModeWhileEditing;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	if(leftView)
	{
		textField.leftViewMode = UITextFieldViewModeAlways; 
		textField.leftView=leftView;
	}
	
	return textField;
}

@end

@implementation UITextFieldEx

- (void)setPadding:(BOOL)enable top:(float)top right:(float)right bottom:(float)bottom left:(float)left 
{
    isEnablePadding = enable;
    paddingTop = top;
    paddingRight = right;
    paddingBottom = bottom;
    paddingLeft = left;
}

- (CGRect)textRectForBounds:(CGRect)bounds 
{
    if (isEnablePadding) 
    {
        return CGRectMake(bounds.origin.x + paddingLeft, 
                          bounds.origin.y + paddingTop, 
                          bounds.size.width - paddingRight-paddingLeft, bounds.size.height - paddingBottom-paddingTop);
    } 
    else 
    {
        return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
