/*!
 @header    UnitCell.m
 @abstract  显示成员的原子View
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import "UnitCell.h"
#import "UIImageView+WebCache.h"

@interface UnitCell ()

// user的头像url
@property (nonatomic, strong) NSString *icon;

// user的名称
@property (nonatomic, strong) NSString *name;

@end

@implementation UnitCell

- (id)initWithFrame:(CGRect)frame andIcon:(NSString *)icon andName:(NSString *)name
{
    _icon = icon;
    _name = name;
    self = [super initWithFrame:frame];
    if (self) {
        [self setProperty];
    }
    return self;
}

/*
 *@method 设置UnitCell的属性
 */
- (void)setProperty
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4.0;
    UIImageView *icon=[[UIImageView alloc]init];
    [icon setImageWithURL:[NSURL URLWithString:_icon] placeholderImage:[UIImage imageNamed:@"Chat_normal"]];
    
    [self setBackgroundImage:icon.image forState:UIControlStateNormal];
    [self addTarget:self action:@selector(touched:) forControlEvents:UIControlEventTouchUpInside];
}

/*
 *@method UnitCell点击删除（代理告知上层）
 */
- (void)touched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(unitCellTouched:)])
        [_delegate unitCellTouched:self];
}

@end
