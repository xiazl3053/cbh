//
//  WebBarBaseController.m
//  21cbh_iphone
//
//  Created by Franky on 14-4-9.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "WebBarBaseController.h"
#import "CellData.h"
#import "CellImageView.h"
#import "UIImage+Custom.h"

@interface WebBarBaseController(private)
-(void)setButtonInteractions;
@end

@implementation WebBarBaseController

@synthesize iPageBar=iParBar_;
@synthesize pageNum=_pageNum;
@synthesize pageCount=_pageCount;

-(id)initWithFrame:(CGRect)frame delegate:(id<PageBarDelegate>)delegate
{
    self = [super init];
    if (self)
	{
		delegate_=delegate;
		_pageNum=_pageCount=1;
        [self constructScrollView:frame];
		[self setEnable:YES];
    }
    return self;
}

- (void)constructScrollView:(CGRect)frame
{
    const int columnCount=5;
    
    NSMutableArray* cellDataArray = [[NSMutableArray alloc] initWithCapacity:columnCount];
    
    //上一页
    CellData* cellData=[[CellData alloc] init];
    cellData.iImage=[[UIImage imageNamed:@"pre_page@2x.png"] scaleToSize:CGSizeMake(40, 40)];
    cellData.iId=0;
    [cellDataArray addObject:cellData];
    
    //下一页
    cellData=[[CellData alloc] init];
    cellData.iImage=[[UIImage imageNamed:@"next_page@2x.png"] scaleToSize:CGSizeMake(40, 40)];
    cellData.iId=1;
    [cellDataArray addObject:cellData];
    
    cellData=[[CellData alloc] init];
    cellData.iId=2;
    [cellDataArray addObject:cellData];
    
    cellData=[[CellData alloc] init];
    cellData.iId=3;
    [cellDataArray addObject:cellData];
    
    //刷新
    cellData=[[CellData alloc] init];
    cellData.iImage=[[UIImage imageNamed:@"D_Refresh.png"] scaleToSize:CGSizeMake(40, 40)];
    cellData.iId=4;
    [cellDataArray addObject:cellData];
    
    iParBar_=[[ScrollView alloc] initWithFrame:frame];
    [iParBar_ setColumns:columnCount rows:1];
    [iParBar_ setCellArray:cellDataArray delegate:self];
    
    preButton_=[iParBar_ cellViewAtIndex:0];
    nextButton_=[iParBar_ cellViewAtIndex:1];
    freshButton_=[iParBar_ cellViewAtIndex:4];
}

- (void)setFrame:(CGRect)frame
{
    iParBar_.frame=frame;
}

- (CGRect)frame
{
    return iParBar_.frame;
}

+(int)height
{
	return 44;
}
//设置工具栏在上面还是下面
-(void)slide:(int)aDirection
{
	CGPoint center=iParBar_.center;
	if(aDirection==0)//向下
	{
		center.y+=iParBar_.bounds.size.height+kNavHeight+kStatusHeight;
	}
	else //向上
	{
		center.y-=iParBar_.bounds.size.height+kNavHeight+kStatusHeight;
	}
	iParBar_.center=center;
}

-(void)setAlpha:(float)alpha
{
	iParBar_.alpha=alpha;
}

//设置按钮是否可用
-(void)setButtonInteractions
{
    if(_pageNum<=1){
        [freshButton_ setUserInteractionEnabled:NO];
    }else{
        [freshButton_ setUserInteractionEnabled:YES];
    }
    
    if(_pageNum>=_pageCount){
        [nextButton_ setUserInteractionEnabled:NO];
    }else{
        [nextButton_ setUserInteractionEnabled:YES];
    }
    [freshButton_ setUserInteractionEnabled:YES];
}

-(void)setEnable:(BOOL)aEnabled
{
	if(aEnabled)
	{
		[self setButtonInteractions];
	}
}

//刷新当前页面
-(void)switchCurPage
{
    if(delegate_&&[delegate_ respondsToSelector:@selector(refreshPageEvent)]){
        [delegate_ refreshPageEvent];
    }
}

//上一页
-(void)switchPrePage
{
    if(delegate_&&[delegate_ respondsToSelector:@selector(pageGoBackEvent)]){
        [delegate_ pageGoBackEvent];
    }
}

//下一页
-(void)switchNextPage
{
    if(delegate_&&[delegate_ respondsToSelector:@selector(pageGoForWardEvent)]){
        [delegate_ pageGoForWardEvent];
    }
}

#pragma mark - CellViewDelegate

-(void)handleCellEvent:(CellView *)aSender cellData:(CellData *)aCellData
{
    int idd=aCellData.iId;
	
	switch(idd)
	{
		case 0:  //上一页
        {
            [self switchPrePage];
        }
			break;
        case 1:  //下一页
        {
            [self switchNextPage];
        }
            break;
        case 4:  //刷新
        {
            [self switchCurPage];
        }
            break;
        default:
        {
            if(delegate_&&[delegate_ respondsToSelector:@selector(pageBarController:didSelectIndex:selected:)])
            {
                [delegate_ pageBarController:self didSelectIndex:idd selected:aSender.isSelected];
            }
        }
            break;
	}
}

-(void)handleCellTouchDownEvent:(CellView *)aSender cellData:(CellData *)aCellData
{
    int idd = aCellData.iId;
    if (delegate_ && [delegate_ respondsToSelector:@selector(pageBarController:didTouched:)]) {
        [delegate_ pageBarController:self didTouched:idd];
    }
}

@end
