//
//  PlayerTool.m
//  Player
//
//  Created by qinghua on 14-12-19.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

//
//  PlayerTool.m
//  Player
//
//  Created by qinghua on 14-12-19.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import "PlayerTool1.h"
#import "LampLabel.h"
#import "PlayManager.h"
#import "CyberPlayerController+External.h"
#import "CyberPlayerController.h"
#import "YLGIFImage.h"
#import "YLImageView.h"
#import "UIView+Common.h"
#import "VoiceListModel.h"
#import "RotateImageView.h"
#import "CommonOperation.h"

#define KButtonWidth 60
#define KButtonHeight 35
#define KMainScreenWidth [UIScreen mainScreen].bounds.size.width

#define KSelfViewWidth self.frame.size.width
#define KSelfViewHeight self.frame.size.height

@interface PlayerTool1 (){
    UIButton *_play;
    UIButton *_next;
    NSInteger _currentPlayCursor;
    LampLabel *_title;
    RotateImageView *_cacheStatus;
    
}

@end

@implementation PlayerTool1

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self initParams];
        [self initViews];
    }
    return self;
}

-(void)initParams{
    [self registerNotification];
}

-(void)initViews{
    [self initPlayerTool];
}


-(void)registerNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prePareDone:) name:KNotificationPlayManagerPrePareDone object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(seekToDone:) name:KNotificationPlayManagerSeekToDone object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishDone:) name:KNotificationPlayManagerFinishDone object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(chapterChange:) name:KNotificationPlayManagerVoiceChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerChange:) name:KNotificationPlayManagerPlayStautsChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startCache:) name:KNotificationPlayManagerStartCache object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cacheing:) name:KNotificationPlayManagerCacheing object:nil];
}

#pragma mark -setPlayerList 
-(void)setPlayerList:(NSArray *)list NowNumber:(NSInteger)number isExternal:(BOOL)b{
    PlayManager *manager=[PlayManager sharedPlayManager];
    [manager setPlayerListWithNSArray:list withNumber:number isExternal:b];
    //NSLog(@"manager.player====%@", manager.player);
}

-(void)initPlayerTool{
    [self initPlayerStyleNormal];
}

-(void)initPlayerStyleNormal{
    
    CGFloat Y=(KSelfViewHeight-KButtonHeight)*.5;
    UIView *below=[[UIView alloc]initWithFrame:CGRectMake(0, 0, KSelfViewWidth, KSelfViewHeight)];
    below.backgroundColor=UIColorFromRGB(0xe1e1e1);
    
    
    LampLabel *title = [[LampLabel alloc]init];
    [title setFrame:CGRectMake(KButtonWidth*2+4, Y, 0, KButtonHeight)];
    title.lineBreakMode = NSLineBreakByClipping;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:kFontName size:11];
    title.textColor = UIColorFromRGB(0x000000);
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(10, Y, 117, 40)];
    [scroll addSubview:title];
    [below addSubview: scroll];
    
    
    UIView *vertical1=[[UIView alloc]initWithFrame:CGRectMake(scroll.right+10, Y, 1, KButtonHeight)];
    vertical1.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [below addSubview:vertical1];
    
    //paly
    UIButton *play=[[UIButton alloc]initWithFrame:CGRectMake(scroll.right+11, Y, KButtonWidth, KButtonHeight)];
    [play  addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [play setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    play.hidden=NO;
    //play.backgroundColor=[UIColor greenColor];
    [below addSubview:play];
    
    RotateImageView *cacheStatus=[[RotateImageView alloc]initWithFrame:CGRectMake(scroll.right+10+(play.width-17)*.5, (play.height-17)*.5, 17, 17)];
    [cacheStatus setImage:[UIImage imageNamed:@"loading.png"]];
    [below addSubview:cacheStatus];
    cacheStatus.hidden=YES;
    _cacheStatus=cacheStatus;
    
    UIView *vertical2=[[UIView alloc]initWithFrame:CGRectMake(play.right, Y, 1, KButtonHeight)];
    vertical2.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [below addSubview:vertical2];
    
    //next
    UIButton *next=[[UIButton alloc]initWithFrame:CGRectMake(play.right+1, Y, KButtonWidth, KButtonHeight)];
    [next  addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    //next.backgroundColor=[UIColor greenColor];
    [next setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [below addSubview:next];
    
    UIView *vertical3=[[UIView alloc]initWithFrame:CGRectMake(next.right, Y, 1, KButtonHeight)];
    vertical3.backgroundColor=UIColorFromRGB(0x8d8d8d);
    [below addSubview:vertical3];
    
    //list
    UIButton *list=[[UIButton alloc]initWithFrame:CGRectMake(next.right+1, Y, KButtonWidth, KButtonHeight)];
    [list  addTarget:self action:@selector(playList:) forControlEvents:UIControlEventTouchUpInside];
    [list setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    //list.backgroundColor=[UIColor greenColor];
    [below addSubview:list];
    
    [self addSubview:below];
    _title=title;
    _play=play;
    _next=next;
}

-(void)playList:(UIButton *)playList{
    NSLog(@"%s",__FUNCTION__);
    [self.delegate PlayerTool1:self userClick:playList];
    [[Frontia getStatistics]logEvent:@"voiceList_click" eventLabel:@"mainView"];
}

-(void)previous:(UIButton *)aBtn{
    NSLog(@"%s--play->previous",__FUNCTION__);
    [[PlayManager sharedPlayManager]previous];
    CyberPlayerController *play=[[PlayManager sharedPlayManager] player];
    if ([self.delegate respondsToSelector:@selector(PlayerTool1:voiceChange:)]) {
        [self.delegate PlayerTool1:self voiceChange:play.nowVoice];
    }
}
-(void)next:(UIButton *)aBtn{
    NSLog(@"%s--play->next",__FUNCTION__);
    [[PlayManager sharedPlayManager]next];
    CyberPlayerController *play=[[PlayManager sharedPlayManager] player];
    play.shouldAutoplay=YES;
    if ([self.delegate respondsToSelector:@selector(PlayerTool1:voiceChange:)]) {
        [self.delegate PlayerTool1:self voiceChange:play.nowVoice];
    }
    [self startCacheIndication];
    [[Frontia getStatistics]logEvent:@"voice_controller" eventLabel:@"change"];
}
-(void)play:(UIButton *)aButton{
    NSLog(@"%s-->play",__FUNCTION__);
    NSLog(@"[[PlayManager sharedPlayManager]status]=%i",[[PlayManager sharedPlayManager]getStatus]);
    CyberPlayerController *play=[[PlayManager sharedPlayManager] player];
    play.shouldAutoplay=YES;
    switch ([[PlayManager sharedPlayManager]getStatus]) {
        case CBPMoviePlaybackStatePrepared:{
            [[PlayManager sharedPlayManager]startPlay];
        }
            break;
        case CBPMoviePlaybackStatePaused:{
            [[PlayManager sharedPlayManager]startPlay];
            }
            break;
        case CBPMoviePlaybackStatePlaying:{
            playerState=CBPMoviePlaybackStatePaused;
            [[PlayManager sharedPlayManager]pausePlay];
            }
            break;
        case CBPMoviePlaybackStateStopped:{
            [[PlayManager sharedPlayManager]startPlay];
        }break;
        default:
            break;
    }
}

-(void)playerChange:(NSNotification *)aNotifcation{
    //NSLog(@"%s",__FUNCTION__);
    dispatch_sync(dispatch_get_main_queue(), ^{
        switch ([[PlayManager sharedPlayManager]getStatus]) {
            case CBPMoviePlaybackStatePrepared:
            {
                [self stopCacheIndication];
                [_title stopAnimation];
                [_play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            }break;
            case CBPMoviePlaybackStatePaused:{
                [_play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                [self stopCacheIndication];
                [_title stopAnimation];
            }break;
            case CBPMoviePlaybackStatePlaying:{
                [_play setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
                [self stopCacheIndication];
                [_title startAnimation];
            }break;
            default:
                break;
        }
    });
}

-(void)startCache:(NSNotification *)aNotification{
    [self refreshTextStatusWithPlayerStatus:CBPMoviePlaybackStateInterrupted];
}

#pragma mark -缓冲中
-(void)cacheing:(NSNotification *)aNotification{
    CGFloat precent= [aNotification.object floatValue];
    if (precent==100) {
        [self refreshTextStatusWithPlayerStatus:CBPMoviePlaybackStatePlaying];
    }
}

#pragma mark -视频准备完成
-(void)prePareDone:(NSNotification *)aNotification{
    [self refreshTextStatusWithPlayerStatus:[[PlayManager sharedPlayManager]getStatus]];
    //NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
}

#pragma mark -Voice改变,改变title
-(void)chapterChange:(NSNotification *)aNotification{
    //NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    CyberPlayerController *player=(CyberPlayerController *)aNotification.object;
    [self resetTitleText:player];
    [self refreshTextStatusWithPlayerStatus:[[PlayManager sharedPlayManager]getStatus]];
}


-(void)resetTitleText:(CyberPlayerController *)player{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:kFontName size:11]};
        CGRect rect = [player.nowVoice.title boundingRectWithSize:CGSizeMake(0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        [_title setFrame:CGRectMake(0, 0, rect.size.width, KButtonHeight)];
        [_title layoutSubviews];
        VoiceListModel *model=player.nowVoice;
        _title.text=model.title;
    });
}

-(void)startTextAnimation{
    [self refreshTextStatusWithPlayerStatus:[[PlayManager sharedPlayManager]getStatus]];
    NSLog(@"%i",[[PlayManager sharedPlayManager]getStatus]);
}

-(void)refreshTextStatusWithPlayerStatus:(CBPMoviePlaybackState)state{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case CBPMoviePlaybackStatePlaying:{
                [self stopCacheIndication];
                [_title startAnimation];
            }break;
            case CBPMoviePlaybackStatePaused:{
                [self stopCacheIndication];
                [_title stopAnimation];
            }break;
            case CBPMoviePlaybackStateStopped:{
                [self stopCacheIndication];
                [_title stopAnimation];
            }break;
            case CBPMoviePlaybackStatePrepared:{
                [self stopCacheIndication];
                [_title stopAnimation];
            }break;
            default:{
                [self startCacheIndication];
                [_title stopAnimation];
            }break;
        }
    });
}

-(void)stopCacheIndication{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_cacheStatus stopAnimating];
        _cacheStatus.hidden=YES;
        _play.hidden=NO;
    });
}

-(void)startCacheIndication{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_title stopAnimation];
        _cacheStatus.hidden=NO;
        [_cacheStatus startAnimating];
        _play.hidden=YES;
    });
}

#pragma mark -seek完成
-(void)seekToDone:(NSNotification *)aNotification{
   // NSLog(@"%s",__FUNCTION__);
    //[self startTimer];
    [self stopCacheIndication];
}

#pragma mark -播放完成
-(void)finishDone:(NSNotification *)aNotification{
    //NSLog(@"%s",__FUNCTION__);
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerPrePareDone object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerSeekToDone object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerFinishDone object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerVoiceChange object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerPlayStautsChange object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerStartCache object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerCacheing object:nil];
    
    _play=nil;
    _next=nil;
    _title=nil;
    _cacheStatus=nil;

}


@end
