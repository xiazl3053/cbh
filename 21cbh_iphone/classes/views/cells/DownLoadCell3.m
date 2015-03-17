//
//  DownLoadCell3.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-21.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "DownLoadCell3.h"


@interface DownLoadCell3(){
    UILabel *_titleLable;//标题
    UILabel *_sizeLable;//size
    UILabel *_durationLable;//时长
    UIView *_line;//分割线
        
    CGFloat interval1;
    CGFloat interval2;
    CGFloat interval3;
    CGFloat interval4;
}

@end

@implementation DownLoadCell3

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=UIColorFromRGB(0xf0f0f0);
        self.contentView.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView =[[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xf0f0f0);
        self.selectionStyle=UITableViewCellSelectionStyleDefault;
        
        interval1=15;
        interval2=16;
        interval3=18;
        interval4=36;
        
        [self initCell];
    }
    return self;
}


-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    _line.backgroundColor=UIColorFromRGB(0xe1e1e1);
}

#pragma mark 初始化cell
-(void)initCell{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, 75);
    
    //标题
    UILabel *titleLable=[[UILabel alloc] initWithFrame:CGRectMake(interval1, interval2, 260, 15)];
    titleLable.textAlignment = NSTextAlignmentLeft;
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.textColor=UIColorFromRGB(0x000000);
    titleLable.font = [UIFont fontWithName:kFontName size:15];
    [self.contentView addSubview:titleLable];
    _titleLable=titleLable;
    
    
    //size
    UILabel *sizeLable=[[UILabel alloc] initWithFrame:CGRectMake(interval1,  interval3+titleLable.frame.origin.y+titleLable.frame.size.height,60, 12)];
    sizeLable.textAlignment = NSTextAlignmentLeft;
    sizeLable.backgroundColor=[UIColor clearColor];
    sizeLable.textColor=UIColorFromRGB(0x8d8d8d);
    sizeLable.font = [UIFont fontWithName:kFontName size:12];
    [self.contentView addSubview:sizeLable];
    _sizeLable=sizeLable;
    
    //时长
    UILabel *durationLable=[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30-80, sizeLable.frame.origin.y,80, 12)];
    durationLable.textAlignment = NSTextAlignmentRight;
    durationLable.backgroundColor=[UIColor clearColor];
    durationLable.textColor=UIColorFromRGB(0x8d8d8d);
    durationLable.font = [UIFont fontWithName:kFontName size:12];
    [self.contentView addSubview:durationLable];
    _durationLable=durationLable;
    
    //分割线
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5f, self.frame.size.width, 0.5f)];
    line.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self addSubview:line];
     _line=line;
}


#pragma mark 设置cell
-(void)setCell:(VoiceListModel *)vlm isEditing:(BOOL)isEditing{
    _vlm=vlm;
    
    _titleLable.text=vlm.title;
    _sizeLable.text=[NSString stringWithFormat:@"%@M",vlm.size];
    _durationLable.text=[NSString stringWithFormat:@"长度: %@",vlm.duration];
    
    __block CGRect frame;
    if (isEditing) {
        [UIView animateWithDuration:0.3 animations:^{
            frame=_durationLable.frame;
            frame.origin.x=self.frame.size.width-46-80;
            _durationLable.frame=frame;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            frame=_durationLable.frame;
            frame.origin.x=self.frame.size.width-10-80;
            _durationLable.frame=frame;
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

@end
