//
//  UISwitch+Custom.h
//   
//
//  Created by rannger on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISwitch (Custom)

-(id)initWithLeftText:(NSString *)tag1 andRight:(NSString *)tag2;
- (void)configFrame:(CGRect)frame;
@end
