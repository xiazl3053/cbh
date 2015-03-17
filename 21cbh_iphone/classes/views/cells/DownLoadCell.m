//
//  DownLoadCell.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-5.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "DownLoadCell.h"
#import "NSString+Date.h"
#import "YLImageView.h"
#import "YLGIFImage.h"
#import "CommonOperation.h"
#import "PlayManager.h"

@interface DownLoadCell(){
    UILabel *_titleLable;//标题
    UILabel *_timeLable;//时间
    UILabel *_sizeLable;//size
    UILabel *_durationLable;//时长
    UIView *_line;//分割线
    YLImageView *_playView;//当前播放的音频标识
    
    
    CGFloat interval1;
    CGFloat interval2;
    CGFloat interval3;
    CGFloat interval4;
}

@end

@implementation DownLoadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=UIColorFromRGB(0xf0f0f0);
        self.contentView.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView =[[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        self.selectionStyle=UITableViewCellSelectionStyleDefault;
        
        interval1=10;
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
    
    //时间
    UILabel *timeLable=[[UILabel alloc] initWithFrame:CGRectMake(interval1, interval3+titleLable.frame.origin.y+titleLable.frame.size.height,100, 12)];
    timeLable.textAlignment = NSTextAlignmentLeft;
    timeLable.backgroundColor=[UIColor clearColor];
    timeLable.textColor=UIColorFromRGB(0x8d8d8d);
    timeLable.font = [UIFont fontWithName:kFontName size:12];
    [self.contentView addSubview:timeLable];
    _timeLable=timeLable;
    
    //size
    UILabel *sizeLable=[[UILabel alloc] initWithFrame:CGRectMake(timeLable.frame.size.width+timeLable.frame.origin.x, timeLable.frame.origin.y,60, 12)];
    sizeLable.textAlignment = NSTextAlignmentLeft;
    sizeLable.backgroundColor=[UIColor clearColor];
    sizeLable.textColor=UIColorFromRGB(0x8d8d8d);
    sizeLable.font = [UIFont fontWithName:kFontName size:12];
    [self.contentView addSubview:sizeLable];
    _sizeLable=sizeLable;
    
    //时长
    UILabel *durationLable=[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30-100, timeLable.frame.origin.y,100, 12)];
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
-(void)setCell:(VoiceListModel *)vlm{
    CGRect frame;
    
    if (vlm.isExistDBlist) {
        
        self.userInteractionEnabled=NO;
        
        frame=_titleLable.frame;
        frame.origin.x=interval1+interval4;
        _titleLable.frame=frame;
        
        frame=_timeLable.frame;
        frame.origin.x=interval1+interval4;
        _timeLable.frame=frame;
        
        frame=_sizeLable.frame;
        frame.origin.x=_timeLable.frame.size.width+interval1+interval4;
        _sizeLable.frame=frame;
        
        frame=_durationLable.frame;
        frame.origin.x=self.frame.size.width-52-100+interval4;
        _durationLable.frame=frame;
        
    }else{
        self.userInteractionEnabled=YES;
        frame=_titleLable.frame;
        frame.origin.x=interval1;
        _titleLable.frame=frame;
        
        frame=_timeLable.frame;
        frame.origin.x=interval1;
        _timeLable.frame=frame;
        
        frame=_sizeLable.frame;
        frame.origin.x=_timeLable.frame.size.width+interval1;
        _sizeLable.frame=frame;
        
        frame=_durationLable.frame;
        frame.origin.x=self.frame.size.width-52-100;
        _durationLable.frame=frame;
    }
    
    
    if (_playView) {
        [_playView removeFromSuperview];
        _playView=nil;
    }
    //设置当前播放的音频
    if ([vlm.articleId isEqual:[[PlayManager sharedPlayManager] getNowVoiceModel].articleId]){
        _playView=[[YLImageView alloc]initWithFrame:CGRectMake(_titleLable.frame.origin.x, interval2, 17, 17)];
        _playView.image=[YLGIFImage imageNamed:@"playing.gif"];
        [self.contentView addSubview:_playView];
        
        frame=_titleLable.frame;
        frame.origin.x=frame.origin.x+17+5;
        _titleLable.frame=frame;
        
        _titleLable.textColor=UIColorFromRGB(0xe86e25);
    }else{
        _titleLable.textColor=UIColorFromRGB(0x000000);
    }
    
    _titleLable.text=vlm.title;
    _timeLable.text=[NSString compareCurrentTime2:vlm.addtime];
    _sizeLable.text=[NSString stringWithFormat:@"%@M",vlm.size];
    _durationLable.text=[NSString stringWithFormat:@"长度 :%@",vlm.duration];
    
    
    
}

@end
