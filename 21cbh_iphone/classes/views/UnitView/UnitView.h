/*!
 @header    UnitView.h
 @abstract  添加成员animationView
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import <UIKit/UIKit.h>
@class EFriends;
@class UnitCell;

@protocol UnitViewDelegate <NSObject>

-(void)UnitViewUserDellUnit:(UnitCell *)cell;

@end

@interface UnitView : UIView

@property (nonatomic,assign) id <UnitViewDelegate> delegate;

/*
 @abstract 用于显示成员
 */

@property (nonatomic, strong) UIScrollView   *scrollView;

/*
 @abstract 用于管理成员
 */
@property (nonatomic, strong) NSMutableArray *unitList;



/*
    添加一个成员
    icon：成员头像
    name：成员名字
 */
-(void)addNewUnit:(EFriends *)item;

- (void)unitCellTouched:(UnitCell *)unitCell;

@end
