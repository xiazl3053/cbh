//
//  TextViewBackspaceController.h
//   HD
//
//  Created by gzty1 on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextViewBackspaceController : NSObject
{
    UITextView* textView_;
    id<UITextViewDelegate> textViewDelegate_;
    
    NSTimer* scheduledTimer_;
}

- (id)initWithTextView:(UITextView*)textView 
      textViewDelegate:(id<UITextViewDelegate>)textViewDelegate 
       backspaceButton:(UIButton*)backspaceButton;

@end
