//
//  GuideController
//
//  Created by gzty1 on 11-11-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GuideController.h"
#import "ScrollView.h"
#import "CellData.h"
#import "UIButton+Custom.h"

@interface GuideController(private)

-(void)showHelpViewsFinish;
-(void)gotoMainView;

@end

@implementation GuideController
@synthesize delegate=delegate_;
+(int)startCount
{
	NSString* version=(NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:APPVERSION];
    NSString* key=[NSString stringWithFormat:@"startcount_version%@",version];
    
    int startcount=[((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:key]) intValue];

    return startcount;
}

+(int)addStartCount
{
	NSString* version=(NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:APPVERSION];
    NSString* key=[NSString stringWithFormat:@"startcount_version%@",version];
    
    int startcount=[((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:key]) intValue];
    startcount++;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:startcount] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return startcount;
}

-(int)currentIndex
{
    return iScrollView.iCurrentIndex;
}
-(void)setCurrentIndex:(int)currentIndex
{
    [iScrollView setCurrentPageIndex:currentIndex];
}

-(void)checkShowGiveScoreDialog
{
	//n次启动并登录用户，提示地方应该是进入主界面之后，提示弹窗而出
    NSString* version=(NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:APPVERSION];
    NSString* scoregivedKey=[NSString stringWithFormat:@"scoregived_version%@",version];
    NSNumber* scoregivedNum=[[NSUserDefaults standardUserDefaults] objectForKey:scoregivedKey];
    if([scoregivedNum boolValue])
    {
        return;
    }
}

-(void)showGuideWithSuperView:(UIView*)superView
                       bounds:(CGRect)bounds
                      bgColor:(UIColor*)bgColor
                   imageArray:(NSArray*)imageArray
                bgContentMode:(UIViewContentMode)bgContentMode
                        index:(int)index
                     delegate:(id<GuideControllerDelegate>)delegate
                   buttonRect:(CGRect)buttonRect
                    closeRect:(CGRect)closeRect
                     animated:(BOOL)animated
{
    delegate_=delegate;
    superView_=superView;
    pageCount_=imageArray.count;
    
    /*
	UIView* view=[iCurrentView viewWithTag:0];
	if([view respondsToSelector:@selector(hideKeyBoard)])
	{
		[view performSelector:@selector(hideKeyBoard)];
	}	
     */
    
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        int temp=scrollViewRect.size.width;
        scrollViewRect.size.width=scrollViewRect.size.height;
        scrollViewRect.size.height=temp;
    }
     */

	//CGRect rect=CGRectMake(0, kStatusHeight, kScreenWidth, kScreenHeight-kStatusHeight);
	if(!iScrollView)
	{
		iScrollView=[[ScrollView alloc] initWithFrame:bounds];
		iScrollView.tag=10;
        if(animated)
        {
            iScrollView.alpha=0.0;
        }
        if(!bgColor)
        {
            bgColor=UIColor.clearColor;
        }
		iScrollView.backgroundColor=bgColor;
		iScrollView.scrollDirection=1;
		[iScrollView setColumns:1 rows:1 intervalV:0];
		iScrollView.delegate=self;
        
		NSMutableArray* cellDataArray=[[NSMutableArray alloc] initWithCapacity:[imageArray count]];
		for (UIImage* image in imageArray) 
        {
            CellData* cellData=[[CellData alloc] init];
            cellData.iBgImage=image;
            cellData.iBgImageContentMode=bgContentMode;
            [cellDataArray addObject:cellData];
        }
        
		[iScrollView setCellArray:cellDataArray delegate:nil];
	}
    [iScrollView removeFromSuperview];
    [superView addSubview:iScrollView];
    [iScrollView setCurrentPageIndex:index];
    
    float pageControlY=superView.bounds.size.height-40+20;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
    {
        pageControlY=superView.bounds.size.height-40;
    }
	[iScrollView showPageControlWithFrame:CGRectMake(0,pageControlY, superView.bounds.size.width,40) superView:superView];
    
    //动画
    if(animated)
    {            
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];  
        iScrollView.alpha = 1.0f;
        [UIView commitAnimations];
    }
    
    //引导完成
    if(buttonRect.size.width>0 && buttonRect.size.height>0)
    {
        buttonRect.origin.x+=bounds.size.width*([imageArray count]-1);
        UIButton* guideFinishButton=[UIButton buttonWithType:UIButtonTypeCustom];
        guideFinishButton.frame=buttonRect;
        [guideFinishButton addTarget:delegate_ action:@selector(handleGuideFinish:) forControlEvents:UIControlEventTouchUpInside];
        [iScrollView addSubview:guideFinishButton];
    }
    
    //关闭按钮
    if(closeRect.size.width>0 && closeRect.size.height>0)
    {
        CGRect tempRect=closeRect;
        for(int i=0;i<[imageArray count];i++)
        {
            closeRect.origin.x=tempRect.origin.x + bounds.size.width*i;
            UIButton* guideFinishButton=[UIButton buttonWithType:UIButtonTypeCustom];
            guideFinishButton.showsTouchWhenHighlighted=YES;
            guideFinishButton.frame=closeRect;
            [guideFinishButton addTarget:delegate_ action:@selector(handleGuideFinish:) forControlEvents:UIControlEventTouchUpInside];
            [iScrollView addSubview:guideFinishButton];
        }
    }
}

-(void)showGuideWithSuperView:(UIView*)superView
{
    superView_=superView;
    CGRect bounds=superView.bounds;//[UIScreen mainScreen].bounds;
    BOOL animated=YES;
    
    UIScrollView* scrollView=[[UIScrollView alloc] initWithFrame:bounds];
    if(animated)
    {
        scrollView.alpha=0.0;
    }

    UIImage* image=[UIImage imageNamed:@"timeline.jpg"];
    UIImageView* bgImageView=[[UIImageView alloc] initWithImage:image];
    bgImageView.userInteractionEnabled=YES;
    [scrollView addSubview:bgImageView];
    [scrollView setContentSize:image.size];
    scrollView.bounces=NO;
    [superView addSubview:scrollView];

    CGRect buttonRect=CGRectMake(30, image.size.height-128, bounds.size.width-60, 50);
    UIButton* button1=[UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame=buttonRect;
    [button1 addTarget:delegate_ action:@selector(handleGuideFinish:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:button1];

    buttonRect=CGRectMake(30, image.size.height-78, bounds.size.width-60, 50);
    UIButton* button2=[UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame=buttonRect;
    [button2 addTarget:delegate_ action:@selector(handleGuideFinish2:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:button2];

    if(animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        scrollView.alpha = 1.0f;
        [UIView commitAnimations];
    }
}

-(void)showGuideWithSuperView:(UIView*)superView
                videoFilePathName:(NSString*)videoFilePathName
                     delegate:(id<GuideControllerDelegate>)delegate
                    buttonRect:(CGRect)buttonRect
{
    delegate_=delegate;
    superView_=superView;
    
    moviePlayerController_ = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoFilePathName]];
    CGRect bounds=superView.bounds;
    //rect.size.height=rect.size.height/2;
    moviePlayerController_.view.frame = bounds;
    moviePlayerController_.controlStyle = MPMovieControlStyleNone;
    //[moviePlayerController_ setFullscreen:YES];
    moviePlayerController_.movieSourceType=MPMovieSourceTypeFile;//本地文件播放要设置视频资源为文件类型资源，若设置为stream 则会错误
    [moviePlayerController_ prepareToPlay];
    [moviePlayerController_ play];
    [superView addSubview:moviePlayerController_.view];
    
    moviePlayerController_.view.alpha=0.0;
    BOOL animated=YES;
    if(animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        moviePlayerController_.view.alpha = 1.0f;
        [UIView commitAnimations];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    if(buttonRect.size.width>0 && buttonRect.size.height>0)
    {
        UIButton* guideFinishButton=[UIButton buttonWithType:UIButtonTypeCustom];
        guideFinishButton.frame=buttonRect;
        [guideFinishButton addTarget:self action:@selector(playbackDidFinish:) forControlEvents:UIControlEventTouchUpInside];
        [superView addSubview:guideFinishButton];
    }
}

-(void)playbackDidFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [delegate_ handleGuideFinish:nil];
}

-(void)showInSuper
{
    [superView_ addSubview:iScrollView];
}

-(void)hideFromSuper
{
    [iScrollView removeFromSuperview];
}

-(void)hideGuide
{
    [iScrollView removeFromSuperview];
	iScrollView=nil;
}

-(void)hideGuideAnimated
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	//[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideGuide)];
	iScrollView.alpha = 0.0f;
	[UIView commitAnimations];
}

-(void)dealloc
{
	[iScrollView removeFromSuperview];
    
    if (SKSVC_)
    {
        SKSVC_.delegate = self;
        SKSVC_ = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+(void)openAppStoreGiveScore
{
	NSString* appleid=@"";//本软件的apple id
    NSString* str=[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleid];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

-(void)showAppInApp:(NSString *)appId withParentViewController:(UIViewController*)parentViewController
{
    Class storeVC = NSClassFromString(@"SKStoreProductViewController");
    if (storeVC != nil)
    {
        if (SKSVC_==nil)
        {
            SKSVC_ = [[SKStoreProductViewController alloc] init];
            SKSVC_.delegate = self;
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
        [SKSVC_ loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: appId}
                          completionBlock:^(BOOL result, NSError *error) {
                              [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                              if (result)
                              {
                                  [parentViewController presentViewController:SKSVC_ animated:YES completion:nil];
                              }
                              else
                              {
                                  NSLog(@"%@",error);
                              }
                          }];
    }
    else
    {
        //低于iOS6没有这个类
        NSString *_idStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8",appId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_idStr]];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionSheetDelegate UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* vcode=(NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"vcode"];
    NSString* key=[NSString stringWithFormat:@"scoregived_version%@",vcode];
    
	switch (buttonIndex)
    {
		case 0:
			{
				[[self class] openAppStoreGiveScore];
			}
            //break; 代码继续向下走
        case 2:
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:key];
				[[NSUserDefaults standardUserDefaults] synchronize];
            }
			break;
	}    
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentIndex=iScrollView.iCurrentIndex;
    [iScrollView scrollViewDidScroll:scrollView];
    if(currentIndex!=iScrollView.iCurrentIndex)
    {
        [delegate_ handleGuidePageChanged:self];
    }
    
	if(delegate_&&!flag)
	{
		CGPoint offset = scrollView.contentOffset;
		if(offset.x-320*(pageCount_-1)>=320/5)
		{
            flag=YES;
			[delegate_ handleGuideFinish:nil];
		}
	}
}
@end
