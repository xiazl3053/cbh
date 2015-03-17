//
//  TextViewBackspaceController.m
//   HD
//
//  Created by gzty1 on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TextViewBackspaceController.h"

@interface TextViewBackspaceController ()

@end

@implementation TextViewBackspaceController

- (id)initWithTextView:(UITextView*)textView 
    textViewDelegate:(id<UITextViewDelegate>)textViewDelegate 
       backspaceButton:(UIButton*)backspaceButton 
{
	if (self = [super init]) 
	{
        textViewDelegate_=textViewDelegate;
        textView_=[textView retain];
        
        [backspaceButton addTarget:self action:@selector(onBackspaceButtonPressed) forControlEvents:UIControlEventTouchDown];
        [backspaceButton addTarget:self action:@selector(stopBackspace) forControlEvents:UIControlEventTouchUpInside];
        [backspaceButton addTarget:self action:@selector(stopBackspace) forControlEvents:UIControlEventTouchUpOutside];
	}
	return self;
}

-(void)backspaceTextView
{
    NSString* allText=textView_.text?:@"";
    if([allText length]>0)
    {
        int textCursorPos=textView_.selectedRange.location;
        
        //防护输入法未完成的情况
        if(textCursorPos>[allText length])
        {
            textCursorPos=[allText length];
        }
        
        if(textCursorPos>0)
        {
            NSString* newText=[allText stringByReplacingCharactersInRange:NSMakeRange(textCursorPos-1, 1) withString:@""];
            [textView_ setText:newText];
            
            textCursorPos-=1;
            textView_.selectedRange = NSMakeRange(textCursorPos,0);
            
            //主动通知文字改变事件
            if([textViewDelegate_ respondsToSelector:@selector(textViewDidChange:)])
            {
                [textViewDelegate_ textViewDidChange:textView_];
            }
        }  
    }
}

-(void)onBackspaceButtonPressed
{	
    [self backspaceTextView];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startBackspace) object:nil];
    [self performSelector:@selector(startBackspace) withObject:nil afterDelay:0.5];
}

-(void)startBackspace
{
    [self backspaceTextView];
    
    if(!scheduledTimer_)
    {
        scheduledTimer_=[[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(backspaceTextView) userInfo:nil repeats:YES] retain];
    }
}

-(void)stopBackspace
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startBackspace) object:nil];
	[scheduledTimer_ invalidate];
    [scheduledTimer_ release];
    scheduledTimer_=nil;
}

- (void)dealloc 
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [textView_ release];
    [scheduledTimer_ invalidate];
    [scheduledTimer_ release];
    [super dealloc];
}

@end
