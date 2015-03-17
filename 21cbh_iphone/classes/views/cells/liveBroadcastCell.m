//
//  liveBroadcastCell.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-5-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "liveBroadcastCell.h"
#import "NSString+Date.h"
#import "CommonOperation.h"

#define kInterval1 15
#define kInterval2 39
#define kInterval3 12

@interface liveBroadcastCell(){
    CGSize _size;
    UIImageView *_iv;//标签
    UILabel *_timeLable;//时间
    UILabel *_descLable;//描述
    UIView *_line;//分割线
}

@end

@implementation liveBroadcastCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCell];
    }
    return self;
}

#pragma mark 初始化cell
-(void)initCell{
    // Initialization code
    self.backgroundColor=[UIColor clearColor];
    self.contentView.backgroundColor=[UIColor clearColor];
    self.selectedBackgroundView =[[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xe1e1e1);
    self.selectionStyle=UITableViewCellSelectionStyleDefault;
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    _size=size;
    
    //标签
    UIImageView *iv=[[UIImageView alloc] init];
    [self.contentView addSubview:iv];
    _iv=iv;
    
    //时间
    UILabel *timeLable=[[UILabel alloc] init];
    timeLable.font=[UIFont fontWithName:kFontName size:12];
    timeLable.textColor=UIColorFromRGB(0xe86e25);
    timeLable.textAlignment=NSTextAlignmentLeft;
    [self.contentView addSubview:timeLable];
    _timeLable=timeLable;
    
    //描述
    UILabel *descLable=[[UILabel alloc] init];
    descLable.font=[UIFont fontWithName:kFontName size:12];
    descLable.textColor=UIColorFromRGB(0xe86e25);
    descLable.textAlignment=NSTextAlignmentLeft;
    descLable.lineBreakMode = NSLineBreakByCharWrapping;
    descLable.numberOfLines = 0;
    [self.contentView addSubview:descLable];
    _descLable=descLable;
    
    //分割线
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.contentView addSubview:line];
    _line=line;
}

#pragma mark 设置数据
-(void)setCell:(liveBroadcastModel *)lbm{
    CGRect frame=_iv.frame;
    UIImage *img=nil;
    NSInteger liveType=[lbm.liveType intValue];
    switch (liveType) {
        case 1:
            img=[UIImage imageNamed:@"normal_tag"];
            break;
        case 2:
            img=[UIImage imageNamed:@"index_tag"];
            break;
        case 3:
            img=[UIImage imageNamed:@"stock_tag"];
            break;
        default:
            break;
    }
    [_iv setImage:img];
    frame=CGRectMake(kInterval1, 8, 17, 17);
    _iv.frame=frame;
    
    frame=_timeLable.frame;
    frame=CGRectMake(kInterval2, 12, 200, 12);
    _timeLable.frame=frame;
    _timeLable.text=[NSString addtimeTurnToTimeString:lbm.addtime];

    CGFloat height=[liveBroadcastCell calculateContentHeightFromText:lbm.desc];
    frame=_descLable.frame;
    frame=CGRectMake(kInterval2, _iv.frame.origin.y+_iv.frame.size.height+4, _size.width-kInterval1-kInterval2, height);
    _descLable.frame=frame;
    [[CommonOperation getId] setIntervalWithTextView:_descLable text:[NSString stringWithFormat:@"%@",lbm.desc] font:[UIFont fontWithName:kFontName size:15] lineSpace:4 color:UIColorFromRGB(0x000000)];
    
    CGFloat totalHeight=10+_iv.frame.size.height+height+12;
    frame=_line.frame;
    frame=CGRectMake(kInterval1, totalHeight-0.5f, _size.width-kInterval1*2, 0.5f);
    _line.frame=frame;
    
}

#pragma mark 主内容的高度
+(CGFloat )calculateContentHeightFromText:(NSString *)str{
    CGSize size = [str sizeWithFont:[UIFont fontWithName:kFontName size:15] constrainedToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width-kInterval1-kInterval2,MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat height=size.height+(size.height/14)*4;
    
    return height;
    
}
#pragma mark 获取当前cell的高度
+(int)currentHight:(liveBroadcastModel *)lbm
{
    CGFloat textheight=[liveBroadcastCell calculateContentHeightFromText:lbm.desc];
    CGFloat totalHeight=10+17+textheight+12;
    return totalHeight;
}
@end
