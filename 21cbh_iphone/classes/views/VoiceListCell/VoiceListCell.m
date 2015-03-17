//
//  SongListCell.m
//  Player
//
//  Created by qinghua on 14-12-23.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import "VoiceListCell.h"
#import "VoiceListModel.h"
#import "PlayManager.h"
#import "YLImageView.h"
#import "YLGIFImage.h"
#import "PlayManager.h"
#import "CyberPlayerController+External.h"
#import "NSString+Date.h"

#define KMainScreenSize [UIScreen mainScreen].bounds.size
#define KMarginLeft 15
#define KMarginRight 15
#define KViewWidth KMainScreenSize.width-KMarginLeft-KMarginRight

@interface VoiceListCell (){
    UILabel *_title;
    UILabel *_addtime;
    UILabel *_duration;
    YLImageView *_status;

}

@end

@implementation VoiceListCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    
    self.backgroundColor=UIColorFromRGB(0xf0f0f0);
    
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(KMarginLeft, 16, KViewWidth, 15)];
    title.font=[UIFont fontWithName:kFontName size:15];
    title.textColor=UIColorFromRGB(0x00000);
    
    UILabel *addTime=[[UILabel alloc]initWithFrame:CGRectMake(KMarginLeft, title.bottom+17, KViewWidth, 11)];
    addTime.font=[UIFont fontWithName:kFontName size:12];
    addTime.textColor=UIColorFromRGB(0x8d8d8d);
    
    
    UILabel *duration=[[UILabel alloc]initWithFrame:CGRectMake(KMainScreenSize.width-68-KMarginRight, title.bottom+17, 68, 11)];
    duration.font=[UIFont fontWithName:kFontName size:12];
    duration.textColor=UIColorFromRGB(0x8d8d8d);
    
    YLImageView *status=[[YLImageView alloc]initWithFrame:CGRectMake(KMarginLeft, 16, 17, 17)];
    status.image=[YLGIFImage imageNamed:@"playing.gif"];
    status.hidden=YES;
    
    UIView *separator=[[UIView alloc]initWithFrame:CGRectMake(0, 74, KMainScreenSize.width, 1)];
    separator.backgroundColor=UIColorFromRGB(0xe1e1e1);
    
    [self addSubview:title];
    [self addSubview:addTime];
    [self addSubview:duration];
    [self addSubview:separator];
    [self addSubview:status];
    
    _title=title;
    _addtime=addTime;
    _duration=duration;
    _status=status;
}

-(void)setValueWithVoiceModel:(VoiceListModel *)model{
    [_title setText:model.title];
    [_addtime setText:[NSString compareCurrentTime:model.addtime]];
    [_duration setText:[NSString stringWithFormat:@"长度: %@",model.duration]];
    PlayManager *play=[PlayManager sharedPlayManager];
    if ([[play getNowVoiceModel].voiceUrl isEqualToString:model.voiceUrl]) {
        [self play];
    }else{
        [self stop];
    }
}

-(void)play{
    _title.textColor=UIColorFromRGB(0xe86e25);
    _title.frame=CGRectMake(_status.right+5, 16, KMainScreenSize.width, 15);
    _status.hidden=NO;
    [_status startAnimating];
}

-(void)stop{
    _title.textColor=[UIColor blackColor];
    _title.frame=CGRectMake(KMarginLeft, 16, KMainScreenSize.width, 15);
    _status.hidden=YES;
    [_status stopAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
