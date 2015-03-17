//
//  FaceView.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "FaceView.h"
#import "UIImage+Custom.h"
#import "FileOperation.h"

#define ItemCountOfPage 21
#define Column 7
#define FaceSize 32

@implementation FaceView

@synthesize delegate;
@synthesize faceDictionary=faceDictionary_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        facePath_=@"face";
        NSString* file=[[NSBundle mainBundle] pathForResource:@"FaceViewList" ofType:@"plist"];
        faceDictionary_=[NSDictionary dictionaryWithContentsOfFile:file];
        faceNameArray_ = [[NSArray alloc]initWithObjects:@"[不说话]",@"[不相信]",@"[吃惊]",@"[大汗]",@"[呆]",@"[大哭]",@"[飞吻]",@"[鬼脸]",@"[害怕]",@"[可爱]",@"[咧嘴笑]",@"[流汗]",@"[难过]",@"[怒]",@"[亲]",@"[微笑]",@"[眨眼]",@"[自负]",@"[ok]",@"[赞]",@"",@"[触底反弹]",@"[打老虎]",@"[大涨]",@"[跌了]",@"[地命海心]",@"[高大上]",@"[高级黑]",@"[够神秘]",@"[关联交易]",@"[老鼠仓]",@"[利益链条]",@"[你懂的]",@"[乔布斯]",@"[天雷滚滚]",@"[网络思维]",@"[又要刺激]",@"[又要涨价]",@"[中南海心]",@"[资金紧张]",nil];
        pageNum=faceNameArray_.count/ItemCountOfPage+1;
        
        [self initViews];
        
    }
    
    return self;
}

-(void)initViews
{
    scrollView_=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-70)];
    scrollView_.contentSize=CGSizeMake(320*pageNum, self.frame.size.height-70);
    scrollView_.pagingEnabled = YES;
    scrollView_.scrollEnabled = YES;
    scrollView_.showsVerticalScrollIndicator = NO;
    scrollView_.showsHorizontalScrollIndicator = NO;
    scrollView_.userInteractionEnabled = YES;
    scrollView_.minimumZoomScale = 1;
    scrollView_.maximumZoomScale = 1;
    scrollView_.decelerationRate = 0.01f;
    scrollView_.backgroundColor = [UIColor clearColor];
    scrollView_.delegate=self;
    [self addSubview:scrollView_];
    
    for (int i=0; i<faceNameArray_.count; i++)
    {
        if(i+1>=ItemCountOfPage&&(i+1)%ItemCountOfPage==0)
        {
            continue;
        }
        else
        {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=[self cellFrameWithNum:i];
            button.tag=i;
            [button addTarget:self action:@selector(itemSelectEvent:)forControlEvents:UIControlEventTouchUpInside];
            
            NSString* key=[faceNameArray_ objectAtIndex:i];
            NSString* imgName=[faceDictionary_ objectForKey:key];
            if([imgName hasSuffix:@".png"])
            {
                UIImage* image=[UIImage imageNamed:imgName];
                [button setBackgroundImage:image forState:UIControlStateNormal];
            }
            [scrollView_ addSubview:button];
        }
    }
    
    for (int i=0; i<pageNum; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=[self cellFrameWithNum:(i+1)*ItemCountOfPage-1];
        button.tag=999;
        [button addTarget:self action:@selector(deletePressEvent:)forControlEvents:UIControlEventTouchUpInside];
        UIImage* image=[UIImage imageNamed:@"emotion_del_normal.png"];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [scrollView_ addSubview:button];
    }
    
    if(pageNum>1)
    {
        pageControl_=[[UIPageControl alloc]initWithFrame:CGRectMake(100, self.frame.size.height-70, 120, 30)];
        pageControl_.numberOfPages=pageNum;
        [pageControl_ addTarget:self action:@selector(changePageEvent) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pageControl_];
    }
    
    sendButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton_ setFrame:CGRectMake(self.frame.size.width-60, self.frame.size.height-45, 55, 40)];
    [sendButton_ setBackgroundColor:[UIColor blueColor]];
    [sendButton_ setTitle:@"发送" forState:UIControlStateNormal];
    sendButton_.layer.cornerRadius=5;
    [sendButton_ addTarget:self action:@selector(sendPressEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton_];
}

-(CGRect)cellFrameWithNum:(int)num
{
    CGRect rect =CGRectMake(0, 0, FaceSize, FaceSize);
    
    rect.origin.x=6+num%Column*(FaceSize+6*2)+num/ItemCountOfPage*320;
    rect.origin.y=9+num%ItemCountOfPage/Column*(FaceSize+9*2);
    
    return rect;
}

-(void)deletePressEvent:(UIView*)sender
{
    if(sender.tag!=999) return;
    if(delegate&&[delegate respondsToSelector:@selector(deleteClickEvent)])
    {
        [delegate deleteClickEvent];
    }
}

-(void)sendPressEvent:(id)sender
{
    if(delegate&&[delegate respondsToSelector:@selector(sendClickEvent)])
    {
        [delegate sendClickEvent];
    }
}

-(void)itemSelectEvent:(UIView*)sender
{
    int i=sender.tag;
    NSString* str=[faceNameArray_ objectAtIndex:i];
    if(delegate&&[delegate respondsToSelector:@selector(itemClickEvent:)])
    {
        [delegate itemClickEvent:str];
    }
}

-(void)changePageEvent
{
    scrollView_.contentOffset = CGPointMake(320*pageControl_.currentPage, 0.0f);
    [pageControl_ setNeedsDisplay];
}

-(void)dealloc
{
    faceNameArray_=nil;
    faceDictionary_=nil;
    facePath_=nil;
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x/320;
    int mod   = fmod(scrollView.contentOffset.x,320);
    if( mod >= 160)
        index++;
    pageControl_.currentPage = index;
}

@end
