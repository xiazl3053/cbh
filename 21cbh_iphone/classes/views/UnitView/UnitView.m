/*!
 @header    UnitView.m
 @abstract  添加成员animationView
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import "UnitView.h"
#import "UnitCell.h"
#import "EFriends.h"

#define defaultWidth  40      // 每一个unitCell的默认宽度
#define defaultPace   8       // unitCell之间的间距
#define duration      0     // 动画执行时间
#define defaultVisibleCount 6 //默认显示的unitCell的个数

@interface UnitView ()<UnitCellDelegate, UIScrollViewDelegate>



/*
   @abstract 默认显示的占位图
 */
@property (nonatomic, strong) UnitCell       *defaultUnit;

/*
   @abstract 判断是否有删除操作
 */
@property (nonatomic, assign) BOOL           hasDelete;

/*
   @abstract 判断删除操作unitCell的移动方向
 */
@property (nonatomic, assign) BOOL           frontMove;

/*
   @abstract 统计删除操作总共移动的次数
 */
@property (nonatomic, assign) int            moveCount;

@end

@implementation UnitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setProperty];
    }
    return self;
}
/*
 *   @method
 *   @function
 *   初始化_scrollView等
 */
- (void) setProperty
{
    _unitList = [[NSMutableArray alloc] init];
    _hasDelete = NO;
    _moveCount = 0;

//    UILabel *topline = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
//    topline.backgroundColor = [UIColor lightGrayColor];
//    [self addSubview:topline];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.frame = CGRectMake(0, (self.bounds.size.height - defaultWidth)/2.0, self.bounds.size.width+defaultWidth, defaultWidth);
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.scrollEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    _scrollView.contentSize = [self contentSizeForUIScrollView:0];
    [self addSubview:_scrollView];

//    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50, 0.5, 50, self.bounds.size.height-1)];
//    rightView.backgroundColor = [UIColor lightGrayColor];
//    rightView.alpha = 0.5;
//    [self addSubview:rightView];

    _defaultUnit = [[UnitCell alloc] initWithFrame:CGRectMake(defaultPace, 0, defaultWidth, defaultWidth) andIcon:@"1.png" andName:@""];
    //[_scrollView addSubview:_defaultUnit];
    [self scrollViewAbleScroll];
}

/*
 *  @method
 *  @function
 *  根据index获取UIScrollView的ContentSize
 */
- (CGSize)contentSizeForUIScrollView:(int)index
{
    float width = (defaultPace + defaultWidth) * index;
    if (width < _scrollView.bounds.size.width)
        width = _scrollView.bounds.size.width;
    return CGSizeMake(width, defaultWidth);
}

/*
 *  @method
 *  @function
 *  根据_unitList.count
 *  设置scrollView是否可以滚动
 *  设置scrollView的ContentSize
 *  设置scrollView的VisibleRect
 */
- (void)scrollViewAbleScroll
{
//    _scrollView.scrollEnabled = (((_unitList.count + 1) * (defaultPace + defaultWidth)) > _scrollView.frame.size.width) ? YES : NO;
      _scrollView.contentSize = [self contentSizeForUIScrollView:(_unitList.count + 1)];
      [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentSize.width - defaultWidth, 0, defaultWidth, self.frame.size.height) animated:YES];
}

/*
 *  @method
 *  @function
 *  新增一个unitCell
 *  _defaultUnit向后移动并伴随动画效果
 *  newUnitCell渐变显示
 */

-(void)addNewUnit:(EFriends *)item{
    __block UnitCell *newUnitCell;
    CGFloat x = (_unitList.count) * (defaultPace + defaultWidth) + defaultPace;
    newUnitCell = [[UnitCell alloc] initWithFrame:CGRectMake(x, 0, defaultWidth, defaultWidth) andIcon:item.iconUrl andName:item.nickName];
    newUnitCell.friend=item;
    newUnitCell.alpha = 0.1;
    newUnitCell.delegate = self;
    [_unitList addObject:newUnitCell];
    [_scrollView addSubview:newUnitCell];
    [self scrollViewAbleScroll];
    _defaultUnit.alpha = 0.5;

    [UIView animateWithDuration:duration animations:^(){
        CGRect rect = _defaultUnit.frame;
        rect.origin.x += (defaultPace + defaultWidth);
        _defaultUnit.frame = rect;
        _defaultUnit.alpha = 1.0;
        newUnitCell.alpha = 0.8;

    } completion:^(BOOL finished){
        newUnitCell.alpha = 1.0;

    }];

}

/*
 *  @method
 *  @function
 *  unitCell被点击代理，需要执行删除操作
 */
- (void)unitCellTouched:(UnitCell *)unitCell
{
    NSLog(@"self.delegate=%@",self.delegate);
    [self.delegate UnitViewUserDellUnit:unitCell];
    _hasDelete = YES;
    int index = (int)[_unitList indexOfObject:unitCell];

    // step_1: 设置相关unitCell的透明度
    unitCell.alpha = 0.8;

    // 判断其余cell的移动方向（从前向后移动/从后向前移动）
    _frontMove = NO;
    if (_unitList.count - 1 > defaultVisibleCount
            && (_unitList.count - index - 1) <= defaultVisibleCount) {
        _frontMove = YES;
    }
    if (index == _unitList.count - 1 && !_frontMove)
        _defaultUnit.alpha = 0.5;

    [UIView animateWithDuration:duration animations:^(){

        // step_2: 其余unitCell依次移动
        if (_frontMove)
        {
            // 前面的向后移动
            for (int i = 0; i < index; i++) {
                UnitCell *cell = [_unitList objectAtIndex:(NSUInteger) i];
                CGRect rect = cell.frame;
                rect.origin.x += (defaultPace + defaultWidth);
                cell.frame = rect;
            }
            _moveCount++;
        }
        else
        {
            // 后面的向前移动
            for (int i = index + 1; i < _unitList.count; i++) {
                UnitCell *cell = [_unitList objectAtIndex:(NSUInteger)i];
                CGRect rect = cell.frame;
                rect.origin.x -= (defaultPace + defaultWidth);
                cell.frame = rect;
            }

            // step_3: _defaultUnit向前移动
            CGRect rect = _defaultUnit.frame;
            rect.origin.x -= (defaultPace + defaultWidth);
            _defaultUnit.frame = rect;
            _defaultUnit.alpha = 1.0;

        }
        unitCell.alpha = 0.0;

    } completion:^(BOOL finished){

        // step_4: 删除被点击的unitCell
        [unitCell removeFromSuperview];
        [_unitList removeObject:unitCell];

        if (_unitList.count <= defaultVisibleCount)
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];

        if (_frontMove) {
            [self isNeedResetFrame];
        }
    }];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self isNeedResetFrame];
}

/*
 *  @method
 *  @function
 *  当删除操作是前面的unitCell向后移动时
 *  做滚动操作或者添加操作需要重新设置每个unitCell的frame
 */
- (void)isNeedResetFrame
{
    if (_frontMove && _moveCount > 0) {

        for (int i = 0; i < _unitList.count; i++) {
            UnitCell *cell = [_unitList objectAtIndex:(NSUInteger) i];
            CGRect rect = cell.frame;
            rect.origin.x -= (defaultPace + defaultWidth) * _moveCount;
            cell.frame = rect;
        }

        CGRect rect = _defaultUnit.frame;
        rect.origin.x -= (defaultPace + defaultWidth) * _moveCount;
        _defaultUnit.frame = rect;

        _frontMove = NO;
        _moveCount = 0;
    }

    if (_hasDelete)
    {
        _scrollView.contentSize = [self contentSizeForUIScrollView:(_unitList.count + 1)];
        _hasDelete = !_hasDelete;
    }
}
@end
