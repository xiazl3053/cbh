//
//  WebBarBaseController.h
//  21cbh_iphone
//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScrollView.h"

#define kNavHeight 44.0
#define kStatusHeight 20.0

@protocol PageBarDelegate;

@interface WebBarBaseController : NSObject<CellViewDelegate>
{
    ScrollView* iParBar_;
    CellView* preButton_;
    CellView* freshButton_;
    CellView* nextButton_;
    id<PageBarDelegate> delegate_;
}

@property (nonatomic,retain) ScrollView* iPageBar;
@property (nonatomic,readonly) int pageNum;
@property (nonatomic,readonly) int pageCount;

-(id)initWithFrame:(CGRect)frame delegate:(id<PageBarDelegate>)delegate;
-(void)setFrame:(CGRect)frame;
-(CGRect)frame;
+(int)height;
-(void)slide:(int)aDirection;//设置工具栏在上面还是下面
-(void)setAlpha:(float)alpha;
//刷新
-(void)switchCurPage;
//上一页
-(void)switchPrePage;
//下一页
-(void)switchNextPage;

//protected
-(void)constructScrollView:(CGRect)frame;
-(void)setButtonInteractions;//设置工具栏在上面还是下面
-(void)setEnable:(BOOL)aEnabled;

@end

@protocol PageBarDelegate<NSObject>

@optional
-(void)pageGoBackEvent;
-(void)pageGoForWardEvent;
-(void)refreshPageEvent;
-(void)pageBarController:(WebBarBaseController*)pageBarController didTouched:(int)index;
-(void)pageBarController:(WebBarBaseController*)pageBarController didSelectIndex:(int)index selected:(BOOL)selected;

@end