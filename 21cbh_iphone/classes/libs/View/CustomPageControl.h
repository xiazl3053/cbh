//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPageControl : UIPageControl
{
    UIImage* activeImage_;
    UIImage* inactiveImage_;
}

-(id) initWithFrame:(CGRect)frame activeImage:(UIImage*)activeImage inactiveImage:(UIImage*)inactiveImage;

@end
