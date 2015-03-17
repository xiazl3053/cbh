//
//  XLCycleScrollView.m
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import "ZXCycleScrollView.h"
#import "NSTimer+Addition.h"

@implementation ZXCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_scrollView release];
    [_pageControl release];
    [_reusableCells removeAllObjects];
    [_reusableCells release];
    [_curViews removeAllObjects];
    [_curViews release];
    [super dealloc];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{

    return [super pointInside:point withEvent:event];
}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    if (animationDuration > 0.0) {
        _animationDuration = animationDuration;
//        _timer = [NSTimer scheduledTimerWithTimeInterval:(_animationDuration = animationDuration) target:self selector:@selector(animationTimerDidFired:) userInfo:nil repeats:YES];
//        [_timer pauseTimer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        //头图栏目条
//        UIView *topBar=[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-27, self.frame.size.width, 27)];
//        topBar.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0/255.0 blue:0/255.0 alpha:0.45f];
//        [self addSubview:topBar];
//        self.topBar=topBar;
//        topBar.hidden=YES;
        
        CGRect rect = self.bounds;
        rect.origin.y = 0;
        rect.origin.x=15;
        rect.size.width=65;
        rect.size.height =27;
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = UIColorFromRGB(0x808080);
        _pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0xe86e25);
        
        [self addSubview:_pageControl];
        
        _curPage = 0;
        _reusableCells=[[NSMutableSet alloc]init];
        
//        UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-0.5f, self.frame.size.width, 0.5f)];
//        line.backgroundColor=UIColorFromRGB(0x808080);
//        [self addSubview:line];
    }
    return self;
}

- (void)setDataource:(id<ZXCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages];
    if (_totalPages == 0) {
        return;
    }
    _pageControl.numberOfPages = _totalPages;
    [self loadData];
}

- (void)loadData
{
    _pageControl.currentPage = _curPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        //[subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [subViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[CWPCycleView class]])
            {
                [self queueReusableCell:(CWPCycleView*)obj];
            }
            [obj removeFromSuperview];
        }];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 3; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [v addGestureRecognizer:singleTap];
        [singleTap release];
        //v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        CGRect rect=v.frame;
        rect.origin.x=v.frame.size.width * i;
        v.frame=rect;
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

- (void)queueReusableCell:(CWPCycleView *)view
{
    if (view)
    {
        [view cleanData];
        [_reusableCells addObject:view];
    }
}

//循环利用View机制 write by Franky
- (CWPCycleView *)dequeueReusableCell
{
    CWPCycleView *view = [_reusableCells anyObject];
    
    if (view)
    {
        [_reusableCells removeObject:view];
    }
    
    return view;
}

- (void)getDisplayImagesWithCurpage:(int)page {
    
    int pre = [self validPageValue:_curPage-1];
    int last = [self validPageValue:_curPage+1];
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:[_datasource pageAtIndex:pre scrollView:(ZXCycleScrollView*)self]];
    [_curViews addObject:[_datasource pageAtIndex:page scrollView:(ZXCycleScrollView*)self]];
    [_curViews addObject:[_datasource pageAtIndex:last scrollView:(ZXCycleScrollView*)self]];
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _totalPages - 1;
    if(value == _totalPages) value = 0;
    
    return value;
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    //[self stopAnimation];
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage) {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 3; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [v addGestureRecognizer:singleTap];
            [singleTap release];
            v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
            [_scrollView addSubview:v];
        }
    }
}

- (void)startAnimation
{
    if(_timer){
        [_timer resumeTimerAfterTimeInterval:_animationDuration];
    }else{
        _timer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration target:self selector:@selector(animationTimerDidFired:) userInfo:nil repeats:YES];
    }
}

- (void)stopAnimation
{
    if(_timer){
        //[_timer pauseTimer];
        [_timer invalidate];
        _timer=nil;
    }
}

- (void)resetAndStopAnimation
{
    if(_timer){
        [_timer pauseTimer];
    }
    _curPage=0;
    [self loadData];
}

#pragma mark 自动滚动方法,默认往下翻
-(void)animationTimerDidFired:(NSTimer *)timer
{
    CGPoint newOffset = CGPointMake(_scrollView.contentOffset.x + CGRectGetWidth(_scrollView.frame), _scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    int x = aScrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*self.frame.size.width)) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadData];
    }
    
    //往上翻
    if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    //[_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_timer pauseTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_timer resumeTimerAfterTimeInterval:_animationDuration];
}

@end
