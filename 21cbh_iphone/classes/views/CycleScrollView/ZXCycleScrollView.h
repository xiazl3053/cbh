//
//  XLCycleScrollView.h
//  21cbh_iphone
//
//  Created by 周晓 on 13-12-31.
//  Copyright (c) 2013年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWPCycleView.h"

@protocol ZXCycleScrollViewDelegate;
@protocol ZXCycleScrollViewDatasource;

@interface ZXCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    id<ZXCycleScrollViewDelegate> _delegate;
    id<ZXCycleScrollViewDatasource> _datasource;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
    NSMutableSet* _reusableCells;
    
    NSTimer* _timer;
    NSTimeInterval _animationDuration;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,readonly) UIPageControl *pageControl;
//@property (nonatomic,assign) UIView *topBar;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign,setter = setDataource:) id<ZXCycleScrollViewDatasource> datasource;
@property (nonatomic,assign,setter = setDelegate:) id<ZXCycleScrollViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;
//循环利用View机制
- (CWPCycleView *)dequeueReusableCell;
- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;
- (void)startAnimation;
- (void)stopAnimation;
- (void)resetAndStopAnimation;

@end

@protocol ZXCycleScrollViewDelegate <NSObject>

@optional
- (void)didClickPage:(ZXCycleScrollView *)csView atIndex:(NSInteger)index;

@end

@protocol ZXCycleScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages;
- (UIView *)pageAtIndex:(NSInteger)index scrollView:(ZXCycleScrollView*)scrollView;

@end
