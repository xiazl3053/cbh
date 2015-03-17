//
//  UITextView+Custom.m
//   HD
//
//  Created by gzty1 on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UITextView+Custom.h"

@implementation UITextView (Custom)

-(void)insertText:(NSString *)text textViewDelegate:(id<UITextViewDelegate>)textViewDelegate
{	    
	NSString* allText=self.text?:@"";
    
    //textCursorPos
    int textCursorPos=self.selectedRange.location;
    
    //防护输入法未完成的情况
	if(textCursorPos>[allText length])
	{
		textCursorPos=[allText length];
	}
	
    //根据textCursorPos， 插入aText
    NSString* newText=[NSString stringWithFormat:@"%@%@%@",
                       [allText substringToIndex:textCursorPos],
                       text,
                       [allText substringFromIndex:textCursorPos]];
	[self setText:newText];
    
    //更新textCursorPos
	textCursorPos+=[text length];
    self.selectedRange = NSMakeRange(textCursorPos,0);
	
	//主动通知文字改变事件
	if([textViewDelegate respondsToSelector:@selector(textViewDidChange:)])
    {
        [textViewDelegate textViewDidChange:self];
    }
}

//for ios7
-(void)rectifyContentOffsetWhenTextDidChange
{
    UITextView* textView=self;
    
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 )
    {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

@end
