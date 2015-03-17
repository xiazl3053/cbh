//
//  UITextView+Custom.h
//   HD
//
//  Created by gzty1 on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextView (Custom)
-(void)insertText:(NSString *)text textViewDelegate:(id<UITextViewDelegate>)textViewDelegate;
//for ios7
-(void)rectifyContentOffsetWhenTextDidChange;
@end
