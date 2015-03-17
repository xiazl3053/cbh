//
//  UIViewController+NavigationItem.m
//   
//
//  Created by gzty1 on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Navigation.h"
#import "UIView+Custom.h"


@interface UIViewController (Navigation_Private)
- (UIButton*)navigationButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
- (UIButton*)navigationButtonWithImage:(UIImage*)img hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action;
- (UIButton*)navigationButtonWithTitle:(NSString*)title 
							titleColor:(UIColor*)titleColor
						 normalBgImage:(UIImage*)normalBgImage 
				   hightlightedBgImage:(UIImage*)hightlightedBgImage 
								target:(id)target 
								action:(SEL)action;
@end

@implementation UIViewController (Navigation)

- (void)setNavigationTitle:(NSString*)title 
{
    title=title?:@"";
	[self setNavigationTitle:title textColor:UIColor.whiteColor fontSize:20 shadowColor:nil shadowHeight:0];
}

- (void)setNavigationTitle:(NSString*)title 
				 textColor:(UIColor*)textColor 
				  fontSize:(int)fontSize 
			   shadowColor:(UIColor*)shadowColor
              shadowHeight:(int)shadowHeight
{
	[self setNavigationTitle:title
                   textColor:textColor
                        font:[UIFont systemFontOfSize:fontSize]
                 shadowColor:shadowColor
                shadowHeight:shadowHeight];
}

- (void)setNavigationTitle:(NSString*)title
				 textColor:(UIColor*)textColor
                      font:(UIFont*)font
			   shadowColor:(UIColor*)shadowColor
			  shadowHeight:(int)shadowHeight
{
    UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,45,45)] autorelease];
	label.backgroundColor=[UIColor clearColor];
	
	label.text = title;
	label.textColor = textColor;
	label.font = font;
	if(shadowColor)
	{
		label.shadowColor = shadowColor;
		label.shadowOffset = CGSizeMake(0, shadowHeight);
	}
	
	[label sizeToFit];
    self.title=title;
	self.navigationItem.titleView = label;
}

- (UIButton*)setNavigationLeftButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
	UIButton* button=[self navigationButtonWithTitle:title target:target action:action];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	[[self navigationItem] setLeftBarButtonItem:buttonItem];
	[buttonItem release];
    
    return button;
}

- (UIButton*)setNavigationLeftButtonWithTitle:(NSString*)title
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                                  offset:(CGPoint)offset
{
	return [self setNavigationLeftButtonWithTitle:title
                                titleColor:titleColor
                             normalBgImage:normalBgImage 
                       hightlightedBgImage:hightlightedBgImage  
                                    target:target 
                                    action:action
                                    offset:offset 
                               titleOffset:CGPointMake(0, 0)];
}

- (UIButton*)setNavigationLeftButtonWithTitle:(NSString*)title  
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                             titleOffset:(CGPoint)titleOffset
{
   	return [self setNavigationLeftButtonWithTitle:title
                                titleColor:titleColor
                             normalBgImage:normalBgImage 
                       hightlightedBgImage:hightlightedBgImage  
                                    target:target 
                                    action:action
                                    offset:CGPointMake(0, 0) 
                               titleOffset:titleOffset]; 
}

- (UIButton*)setNavigationLeftButtonWithTitle:(NSString*)title  
							  titleColor:(UIColor*)titleColor
						   normalBgImage:(UIImage*)normalBgImage 
					 hightlightedBgImage:(UIImage*)hightlightedBgImage  
								  target:(id)target 
								  action:(SEL)action
                                  offset:(CGPoint)offset 
                             titleOffset:(CGPoint)titleOffset 
{
	UIButton* button=[self navigationButtonWithTitle:title 
										  titleColor:titleColor
									   normalBgImage:normalBgImage 
								 hightlightedBgImage:hightlightedBgImage 
                                              target:target 
											  action:action];
    button.titleEdgeInsets=UIEdgeInsetsMake(titleOffset.y,titleOffset.x,0,0);
    
    UIBarButtonItem* spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                  target:nil action:nil] autorelease];
    spaceItem.width = offset.x;
	UIBarButtonItem* buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
	[[self navigationItem] setLeftBarButtonItems:[NSArray arrayWithObjects:spaceItem,buttonItem, nil]];
	
	//shadow，历史上默认成了白色投影
    if(titleColor!=[UIColor whiteColor])
    {
        button.titleLabel.shadowColor = [UIColor whiteColor];
        button.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return button;
}

- (UIButton*)setNavigationRightButtonWithTitle:(NSString*)title
                               titleColor:(UIColor*)titleColor
                            normalBgImage:(UIImage*)normalBgImage 
                      hightlightedBgImage:(UIImage*)hightlightedBgImage  
                                   target:(id)target 
                                   action:(SEL)action
                                   offset:(CGPoint)offset
{
	UIButton* button=[self setNavigationRightButtonWithTitle:title  
                                 titleColor:titleColor
                              normalBgImage:normalBgImage 
                        hightlightedBgImage:hightlightedBgImage  
                                     target:target 
                                     action:action
                                     offset:offset
                                titleOffset:CGPointMake(0, 0)];
    
    return button;
}

- (UIButton*)setNavigationRightButtonWithTitle:(NSString*)title
                               titleColor:(UIColor*)titleColor
                            normalBgImage:(UIImage*)normalBgImage 
                      hightlightedBgImage:(UIImage*)hightlightedBgImage  
                                   target:(id)target 
                                   action:(SEL)action
                              titleOffset:(CGPoint)titleOffset
{
    return [self setNavigationRightButtonWithTitle:title
                                         titleColor:titleColor
                                      normalBgImage:normalBgImage 
                                hightlightedBgImage:hightlightedBgImage  
                                             target:target 
                                             action:action
                                             offset:CGPointMake(0, 0)
                                        titleOffset:titleOffset];
}
- (UIButton*)setNavigationRightButtonWithTitle:(NSString*)title  
                               titleColor:(UIColor*)titleColor
                            normalBgImage:(UIImage*)normalBgImage 
                      hightlightedBgImage:(UIImage*)hightlightedBgImage  
                                   target:(id)target 
                                   action:(SEL)action
                                   offset:(CGPoint)offset
                              titleOffset:(CGPoint)titleOffset
{
    UIButton* button=[self navigationButtonWithTitle:title 
										  titleColor:titleColor
									   normalBgImage:normalBgImage 
								 hightlightedBgImage:hightlightedBgImage 
											  target:target 
											  action:action];
    button.titleEdgeInsets=UIEdgeInsetsMake(titleOffset.y,0,0,titleOffset.x);
    
	UIBarButtonItem* spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil action:nil] autorelease];
    spaceItem.width = -offset.x;
	UIBarButtonItem* buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
	[[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:spaceItem,buttonItem,nil]];

    //shadow，历史上默认成了黑色投影
    if(titleColor!=[UIColor blackColor])
    {
        button.titleLabel.shadowColor = [UIColor blackColor];
        button.titleLabel.shadowOffset = CGSizeMake(0, 1);
        [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    return button;
}

- (void)setNavigationLeftButtonWithTitle:(NSString*)title  
                               titleColor:(UIColor*)titleColor
                            normalBgImage:(UIImage*)normalBgImage 
                      hightlightedBgImage:(UIImage*)hightlightedBgImage  
                                   target:(id)target 
                                   action:(SEL)action
{
    [self setNavigationLeftButtonWithTitle:title  
                                 titleColor:titleColor
                              normalBgImage:normalBgImage 
                        hightlightedBgImage:hightlightedBgImage  
                                     target:target 
                                     action:action offset:CGPointMake(0, 0)];
}

- (void)setNavigationRightButtonWithTitle:(NSString*)title  
                               titleColor:(UIColor*)titleColor
                            normalBgImage:(UIImage*)normalBgImage 
                      hightlightedBgImage:(UIImage*)hightlightedBgImage  
                                   target:(id)target 
                                   action:(SEL)action
{
    [self setNavigationRightButtonWithTitle:title  
                                 titleColor:titleColor
                              normalBgImage:normalBgImage 
                        hightlightedBgImage:hightlightedBgImage  
                                     target:target 
                                     action:action offset:CGPointMake(0, 0)];
}

- (UIButton*)setNavigationRightButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
	UIButton* button=[self navigationButtonWithTitle:title target:target action:action];
	UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	[[self navigationItem] setRightBarButtonItem:buttonItem];
	[buttonItem release];
    
    return button;
}

- (UIButton*)setNavigationLeftButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action
{
    return [self setNavigationLeftButtonWithImage:image hightlightedImage:hightlightedImage target:target action:action offset:CGPointMake(0, 0)];
}

- (UIButton*)setNavigationRightButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action
{
    return [self setNavigationRightButtonWithImage:image hightlightedImage:hightlightedImage target:target action:action offset:CGPointMake(0, 0)];
}

- (UIButton*)setNavigationLeftButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action offset:(CGPoint)offset
{
	UIButton* button=[self navigationButtonWithImage:image hightlightedImage:hightlightedImage target:target action:action];
    
    UIBarButtonItem* spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil action:nil] autorelease];
    spaceItem.width = offset.x;
	UIBarButtonItem* buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
	[[self navigationItem] setLeftBarButtonItems:[NSArray arrayWithObjects:spaceItem,buttonItem, nil]];
    
    return button;
}

- (UIButton*)setNavigationRightButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action offset:(CGPoint)offset
{
	UIButton* button=[self navigationButtonWithImage:image hightlightedImage:hightlightedImage target:target action:action];
    
    UIBarButtonItem* spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil action:nil] autorelease];
    spaceItem.width = -offset.x;
	UIBarButtonItem* buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
	[[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:spaceItem,buttonItem,nil]];
    
    return button;
}

- (UIButton*)navigationButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
	const int KLeftWidth=25;
	UIImage* image=[[UIImage imageNamed:@"bar_button.png"] stretchableImageWithLeftCapWidth:KLeftWidth topCapHeight:0];
	UIImage* hightlightedImage=[[UIImage imageNamed:@"bar_button_pressed.png"] stretchableImageWithLeftCapWidth:KLeftWidth topCapHeight:0];
	UIButton* button=[self navigationButtonWithTitle:(NSString*)title 
                                          titleColor:UIColor.whiteColor
                                       normalBgImage:image 
                                 hightlightedBgImage:hightlightedImage 
                                              target:target 
                                              action:action];
	if (hightlightedImage==nil)
    {
        //当没有点击图片时,才使用该效果
        button.showsTouchWhenHighlighted=YES;
    }
	return button;
}

- (UIButton*)navigationButtonWithTitle:(NSString*)title 
							titleColor:(UIColor*)titleColor
						 normalBgImage:(UIImage*)normalBgImage 
				   hightlightedBgImage:(UIImage*)hightlightedBgImage 
								target:(id)target 
								action:(SEL)action

{
	UIButton* button=[UIButton buttonWithOrigin:CGPointMake(0,0) 
										  title:title 
									  titleFont:[UIFont systemFontOfSize:15]
									 titleColor:titleColor
									normalImage:normalBgImage 
							  hightlightedImage:hightlightedBgImage  
								  selectedImage:nil];
	if (hightlightedBgImage==nil)
    {
        //当没有点击图片时,才使用该效果
        button.showsTouchWhenHighlighted=YES;
    }
	[button expandWidthAsTitleWithPaddingH:10];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (UIButton*)navigationButtonWithImage:(UIImage*)image hightlightedImage:(UIImage*)hightlightedImage target:(id)target action:(SEL)action
{
	UIButton* button=[UIButton buttonWithOrigin:CGPointMake(0,0) 
									normalImage:image 
							  hightlightedImage:hightlightedImage 
								  selectedImage:nil
								   asBackground:YES];
    if (hightlightedImage==nil) { //当没有点击图片时,才使用该效果
        button.showsTouchWhenHighlighted=YES;
    }
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)updateNavigationRightButtonTitle:(NSString*)title
{
	UIView* customView=[self navigationItem].rightBarButtonItem.customView;
	if([customView isKindOfClass:[UIButton class]])
	{
		[(UIButton*)customView setTitle:title forState:UIControlStateNormal];
	}
}

- (void)setNavigationBackButton
{
	[self setNavigationBackButtonWithText:@"" normalBgImage:nil];
}

- (void)setNavigationBackButtonWithText:(NSString*)aText normalBgImage:(UIImage*)normalBgImage
{
	int count=[[self.navigationController viewControllers] count];//被添加到Nav中后，才能取到值。
	if(count>=2)
	{
		if(!aText)
		{
			aText=[[[self.navigationController viewControllers] objectAtIndex:count-2] navigationItem].title;
		}
		const int KLeftWidth=25;
        if(!normalBgImage)
        {
            normalBgImage=[[UIImage imageNamed:@"back.png"] stretchableImageWithLeftCapWidth:KLeftWidth topCapHeight:0];
        }
		UIImage* hightlightedImage=nil;
		
		UIFont* font=[UIFont systemFontOfSize:15];
		CGSize stringSize = [aText sizeWithFont:font];
		CGFloat textWidth = stringSize.width+KLeftWidth;
		
		UIButton* button=[UIButton buttonWithOrigin:CGPointMake(0,0) 
											  title:aText 
										  titleFont:font 
										 titleColor:UIColor.blackColor 
										normalImage:normalBgImage 
								  hightlightedImage:hightlightedImage  
									  selectedImage:nil];
		if (hightlightedImage==nil)
        {
            //当没有点击图片时,才使用该效果
            button.showsTouchWhenHighlighted=YES;
        }
		//button.titleLabel.font=font;
		//button.titleEdgeInsets=UIEdgeInsetsMake(0,10,0,0);
		if([aText length]>0)
		{
			CGRect rect=button.frame;
			rect.size.width=textWidth;
			button.frame=rect;
		}
		UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
		[button addTarget:self action:@selector(onNavigationBackPressed) forControlEvents:UIControlEventTouchUpInside];
		[[self navigationItem] setLeftBarButtonItem:buttonItem];
		[buttonItem release];
	}
}

- (void)removeNavigationBackButton
{
	[[self navigationItem] setLeftBarButtonItem:nil];
	self.navigationItem.hidesBackButton=YES;
}

-(void)onNavigationBackPressed
{
	BOOL modal=NO;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=5.0)
    {
        if(self.presentingViewController || self.navigationController.presentingViewController)
        {
            modal=YES;
        }
    }
    else
    {
        if(self.navigationController)
        {
            if([self.navigationController.viewControllers count]==1)
            {
                modal=YES;
            }
        }
        else
        {
            modal=YES;
        }
    }
    
    if(modal)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)dismissModalViewControllerAnimated
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
