//
//  PlayerTool2.m
//  21cbh_iphone
//
//  Created by qinghua on 15-1-13.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "PlayerTool2.h"
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
#import "CustomSlider.h"

#define KButtonWidth 60
#define KButtonHeight 35
#define KMainScreenWidth [UIScreen mainScreen].bounds.size.width

#define KSelfViewWidth self.frame.size.width
#define KSelfViewHeight self.frame.size.height


@interface PlayerTool2 (){
    
    UIButton *_play;
    UIButton *_previous;
    UIButton *_next;
    UISlider *_slider;
    UILabel  *_currenttime;
    UILabel  *_totaltime;
    NSInteger _currentPlayCursor;
    RotateImageView *_cacheStatus;
    CGFloat _seekTimer;
    BOOL _isSeekDone;
}
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation PlayerTool2

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self initParams];
        [self initViews];
    }
    return self;
}

-(void)initNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(prePareDone:) name:KNotificationPlayManagerPrePareDone object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(seekToDone:) name:KNotificationPlayManagerSeekToDone object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishDone:) name:KNotificationPlayManagerFinishDone object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(chapterChange:) name:KNotificationPlayManagerVoiceChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerChange:) name:KNotificationPlayManagerPlayStautsChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startCache:) name:KNotificationPlayManagerStartCache object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Cacheing:) name:KNotificationPlayManagerCacheing object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playFail:) name:KNotificationPlayManagerPlayFail object:nil];
}

#pragma mark -列表设置
-(void)setPlayerList:(NSArray *)list NowNumber:(NSInteger)number isExternal:(BOOL)b{
    PlayManager *manager=[PlayManager sharedPlayManager];
    [manager setPlayerListWithNSArray:list withNumber:number isExternal:b];
    //NSLog(@"manager.player====%@", manager.player);
}

-(void)initParams{
    [self initNotification];
    [[PlayManager sharedPlayManager] setIsPlayNewsDetail:YES];
   
}
-(void)initViews{
    [self initContentView];
    [self startTimer];
}

#pragma mark -内容View
-(void)initContentView{
    self.backgroundColor=UIColorFromRGB(0xe3e3e3);
    UIView *marginLine=[[UIView alloc]initWithFrame:CGRectMake(0, 0, KSelfViewWidth, 0.5)];
    marginLine.backgroundColor=UIColorFromRGB(0x636363);
    [self addSubview:marginLine];
    
    //above
    UIView *above=[[UIView alloc]initWithFrame:CGRectMake(15, 0, KSelfViewWidth-30, 39)];
    //currenttime
    UILabel *currenttime=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 36, 39)];
    currenttime.text=@"00:00";
    currenttime.textColor=UIColorFromRGB(0xe86e25);
    currenttime.textAlignment=NSTextAlignmentCenter;
    currenttime.font=[UIFont fontWithName:kFontName size:12];
    [above addSubview:currenttime];
    //slider
    CustomSlider *slider=[[CustomSlider alloc]initWithFrame:CGRectMake(currenttime.right, 0, 218, 39)];
    [slider addTarget:self action:@selector(sliderMove:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    UIImage *image=[UIImage imageNamed:@"PlayTool_Inside_playing.png"];
    NSLog(@"image.size=%@",NSStringFromCGSize(image.size));
    [slider setThumbImage:[UIImage imageNamed:@"PlayTool_Inside_playing.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"PlayTool_Inside_playing.png"] forState:UIControlStateSelected];
    [slider setMinimumTrackTintColor:UIColorFromRGB(0xe86e25)];
    [slider setMaximumTrackTintColor:UIColorFromRGB(0xcccccc)];
    //slider.userInteractionEnabled=NO;
    slider.continuous = NO;
    [above addSubview:slider];
    //totaltime
    UILabel *totaltime=[[UILabel alloc]initWithFrame:CGRectMake(slider.right, 0, 36, 39)];
    totaltime.text=@"00:00";
    totaltime.textColor=UIColorFromRGB(0x000000);
    totaltime.textAlignment=NSTextAlignmentCenter;
    totaltime.font=[UIFont fontWithName:kFontName size:12];
    [above addSubview:totaltime];
    
    
    //left.tool
    UIView *left=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-46, 150, 46)];
    //share
    UIButton *share=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 46)];
    [share setImage:[UIImage imageNamed:@"PlayTool_Inside_share.png"] forState:UIControlStateNormal];
    [share addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [left addSubview:share];
    //collect
    UIButton *collect=[[UIButton alloc]initWithFrame:CGRectMake(share.right, 0, 50, 46)];
    [collect setImage:[UIImage imageNamed:@"PlayTool_Inside_collect.png"] forState:UIControlStateNormal];
    [collect addTarget:self action:@selector(collect:) forControlEvents:UIControlEventTouchUpInside];
    [collect setTag:88];
    [left addSubview:collect];
    //comment
    UIButton *comment=[[UIButton alloc]initWithFrame:CGRectMake(collect.right, 0, 50, 46)];
    [comment setImage:[UIImage imageNamed:@"PlayTool_Inside_comment.png"] forState:UIControlStateNormal];
    [comment addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    [left addSubview:comment];
    
    //separation
    UIView *separationLine=[[UIView alloc]initWithFrame:CGRectMake(left.right+10, self.frame.size.height-15-16, 0.5, 16)];
    separationLine.backgroundColor=UIColorFromRGB(0x838383);
    [self addSubview:separationLine];
    
    //right.tool
    UIView *right=[[UIView alloc]initWithFrame:CGRectMake(separationLine.right+10, self.frame.size.height-46, 150, 46)];
    //previous
    UIButton *previous=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 46)];
    [previous  addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchUpInside];
    [previous setImage:[UIImage imageNamed:@"PlayTool_Inside_previous.png"] forState:UIControlStateNormal];
    [right addSubview:previous];
    
    //paly
    UIButton *play=[[UIButton alloc]initWithFrame:CGRectMake(previous.right, 0, 50, 46)];
    [play  addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [play setImage:[UIImage imageNamed:@"PlayTool_Inside_play.png"] forState:UIControlStateNormal];
    [right addSubview:play];
    
    RotateImageView *cacheStatus=[[RotateImageView alloc]initWithFrame:CGRectMake(previous.right+(play.width-17)*.5,(play.height-17)*.5, 17, 17)];
    [cacheStatus setImage:[UIImage imageNamed:@"loading.png"]];
    [right addSubview:cacheStatus];
    cacheStatus.hidden=YES;
    _cacheStatus=cacheStatus;
    
    //next
    UIButton *next=[[UIButton alloc]initWithFrame:CGRectMake(play.right, 0, 50, 46)];
    [next  addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [next setImage:[UIImage imageNamed:@"PlayTool_Inside_next.png"] forState:UIControlStateNormal];
    [right addSubview:next];
    
    
    [self addSubview:above];
    [self addSubview:separationLine];
    [self addSubview:left];
    [self addSubview:right];
    
    _currenttime=currenttime;
    _totaltime=totaltime;
    _slider=slider;
    _previous=previous;
    _play=play;
    _next=next;
    _slider=slider;
    _isSeekDone=YES;
    
    [self startCacheIndication];
    [self playerChange:nil];
}



#pragma mark -播放切换
-(void)play:(UIButton *)aButton{
    NSLog(@"%s-->play",__FUNCTION__);
    NSLog(@"[[PlayManager sharedPlayManager]status]=%i",[[PlayManager sharedPlayManager]getStatus]);
    switch ([[PlayManager sharedPlayManager]getStatus]) {
        case CBPMoviePlaybackStatePrepared:{
            [[PlayManager sharedPlayManager]startPlay];
            //[_status startAnimating];
        }
            break;
        case CBPMoviePlaybackStatePaused:{
            [[PlayManager sharedPlayManager]startPlay];
            //[_status startAnimating];
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

#pragma mark -播发器状态切换
-(void)playerChange:(NSNotification *)aNotifcation{
//    NSLog(@"[[PlayManager sharedPlayManager]getStatus]=%i",[[PlayManager sharedPlayManager]getStatus]);
//    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        switch ([[PlayManager sharedPlayManager]getStatus]) {
            case CBPMoviePlaybackStatePrepared:
            {   [self stopCacheIndication];
                [_play setImage:[UIImage imageNamed:@"PlayTool_Inside_play.png"] forState:UIControlStateNormal];
            }break;
            case CBPMoviePlaybackStatePaused:{
                [self stopCacheIndication];
                [_play setImage:[UIImage imageNamed:@"PlayTool_Inside_play.png"] forState:UIControlStateNormal];
            }break;
            case CBPMoviePlaybackStatePlaying:{
                [self stopCacheIndication];
                [_play setImage:[UIImage imageNamed:@"PlayTool_Inside_stop.png"] forState:UIControlStateNormal];
            }break;
            default:
                break;
        }
    });
}

#pragma mark -播放失败
-(void)playFail:(NSNotification *)aNotification{
    [self startCacheIndication];
}

#pragma mark -开始缓冲
-(void)startCache:(NSNotification *)aNotification{
    NSLog(@"startCache====%@",aNotification);
    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startCacheIndication];
        NSLog(@"开始缓冲");
    });
}

#pragma mark -缓冲中
-(void)Cacheing:(NSNotification *)aNotification{
    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
}

#pragma mark -视频准备完成
-(void)prePareDone:(NSNotification *)aNotification{
    [self resetStatus];
}

#pragma mark -Voice改变,改变title
-(void)chapterChange:(NSNotification *)aNotification{
   [self chapterChange];
}

#pragma mark -playTool2.delagate.method
-(void)previous:(UIButton *)aBtn{
    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    [[PlayManager sharedPlayManager]previous];
    [self chapterChange];
    
    [[Frontia getStatistics]logEvent:@"voice_controller" eventLabel:@"change"];
}
-(void)next:(UIButton *)aBtn{
    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    [[PlayManager sharedPlayManager]next];
    [self chapterChange];
    [[Frontia getStatistics]logEvent:@"voice_controller" eventLabel:@"change"];
}

-(void)chapterChange{
    CyberPlayerController *play=[[PlayManager sharedPlayManager] player];
    if ([self.delegate respondsToSelector:@selector(PlayerTool2:voiceChange:)]) {
        [self.delegate PlayerTool2:self voiceChange:play.nowVoice];
    }
    [self resetStatus];
    [self startCacheIndication];
}

#pragma mark -seek完成
-(void)seekToDone:(NSNotification *)aNotification{
//    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
//    CyberPlayerController *player=[[PlayManager sharedPlayManager] player];
//    NSLog(@"seekToDone===%f",player.currentPlaybackTime);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playerChange:nil];
        [self stopCacheIndication];
    });
}

#pragma mark -播放完成
-(void)finishDone:(NSNotification *)aNotification{
    //NSLog(@"%s",__FUNCTION__);
}

#pragma mark -播放器位置定位
-(void)sliderMove:(UISlider *)aSlider{
    //实现视频播放位置切换
    NSLog(@"sliderMove===seek to %f", aSlider.value);
    [[PlayManager sharedPlayManager]seekTo:aSlider.value];
    _seekTimer=aSlider.value;
    _isSeekDone=NO;
    [self startCacheIndication];
    [self startTimer];
}
#pragma mark -进度条位置定位
-(void)sliderChangeValue:(UISlider *)aSlider{
//    NSLog(@"%@",[NSThread currentThread]);
//    NSLog(@"sliderChangeValue===%f",aSlider.value);
//    CyberPlayerController *player=[[PlayManager sharedPlayManager] player];
//    [self refreshProgress:aSlider.value totalDuration:player.duration];
}
#pragma mark -slider-touchDown响应
-(void)sliderTouchDown:(UISlider *)aSlider{
    [self stopTimer];
    NSLog(@"========stopTimer==========%@,%@",self.timer,[NSThread currentThread]);
}

#pragma mark -停止定时器
- (void)stopTimer{
    if ([self.timer isValid])
    {
        [self.timer invalidate];
    }
    self.timer = nil;
}

#pragma mark -刷新UI
- (void)startTimer{
    //为了保证UI刷新在主线程中完成。
    [self performSelectorOnMainThread:@selector(startTimeroOnMainThread) withObject:nil waitUntilDone:NO];
}
- (void)startTimeroOnMainThread{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
}
-(void)timerHandler:(NSTimer *)aTimer{
    CyberPlayerController *player=[[PlayManager sharedPlayManager] player];
    //NSLog(@"_seekTimer=%f,player.currentPlaybackTime=%f,downloadSpeed=%f,playableDuration=%f",floor(_seekTimer),floor(player.currentPlaybackTime),floor(player.downloadSpeed),floor(player.playableDuration));
    if (floor(_seekTimer)==floor(player.currentPlaybackTime)) {
        _isSeekDone=YES;
    }
    if (_isSeekDone) {
        [self refreshProgress:player.currentPlaybackTime totalDuration:player.duration];
    }
}

-(void)share:(UIButton *)aButton{
    NSLog(@"%s",__FUNCTION__);
    CyberPlayerController *play=[[PlayManager sharedPlayManager] player];
    if ([self.delegate respondsToSelector:@selector(PlayerTool2:clickShare:)]) {
        [self.delegate PlayerTool2:self clickShare:play.nowVoice];
    }
}
-(void)comment:(UIButton *)aButton{
    NSLog(@"%s",__FUNCTION__);
    CyberPlayerController *play=[[PlayManager sharedPlayManager] player];
    if ([self.delegate respondsToSelector:@selector(PlayerTool2:clickComment:)]) {
        [self.delegate PlayerTool2:self clickComment:play.nowVoice];
    }
}
-(void)collect:(UIButton *)aButton{
    NSLog(@"%s",__FUNCTION__);
    CyberPlayerController *play=[[PlayManager sharedPlayManager] player];
    if ([self.delegate respondsToSelector:@selector(PlayerTool2:clickCollect:)]) {
        [self.delegate PlayerTool2:self clickCollect:play.nowVoice];
    }
}

#pragma mark -时间转换
- (void)refreshProgress:(int) currentTime totalDuration:(int)allSecond{
    NSDictionary* dict = [[self class] convertSecond2HourMinuteSecond:currentTime];
    NSString* strPlayedTime = [self getTimeString:dict prefix:@""];
    _currenttime.text = strPlayedTime;
    NSDictionary* dictLeft = [[self class] convertSecond2HourMinuteSecond:allSecond - currentTime];
    NSString* strLeft = [self getTimeString:dictLeft prefix:@"0"];
    _totaltime.text = strLeft;
    _slider.value = currentTime;
    _slider.maximumValue = allSecond;
   // NSLog(@"====refreshProgress====%@",[NSThread currentThread]);
}
+ (NSDictionary*)convertSecond2HourMinuteSecond:(int)second
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    int hour = 0, minute = 0;
    
    hour = second / 3600;
    minute = (second - hour * 3600) / 60;
    second = second - hour * 3600 - minute *  60;
    
    [dict setObject:[NSNumber numberWithInt:hour] forKey:@"hour"];
    [dict setObject:[NSNumber numberWithInt:minute] forKey:@"minute"];
    [dict setObject:[NSNumber numberWithInt:second] forKey:@"second"];
    
    return dict;
}
- (NSString*)getTimeString:(NSDictionary*)dict prefix:(NSString*)prefix
{
    int hour = [[dict objectForKey:@"hour"] intValue];
    int minute = [[dict objectForKey:@"minute"] intValue];
    int second = [[dict objectForKey:@"second"] intValue];
    
    NSString* formatter = hour < 10 ? @"0%d" : @"%d";
   // NSString* strHour = [NSString stringWithFormat:formatter, hour];
    
    formatter = minute < 10 ? @"0%d" : @"%d";
    formatter = minute <  0 ? @"00"  : formatter;
    NSString* strMinute = [NSString stringWithFormat:formatter, minute];
    
    formatter = second < 10 ? @"0%d" : @"%d";
    formatter = second <  0 ? @"00"  : formatter;
    NSString* strSecond = [NSString stringWithFormat:formatter, second];
    
    return [NSString stringWithFormat:@"%@:%@", strMinute, strSecond];
    //return [NSString stringWithFormat:@"%@%@:%@:%@", prefix, strHour, strMinute, strSecond];
}

#pragma mark -重置
-(void)resetStatus{
    _currenttime.text=@"00:00";
    _totaltime.text=@"00:00";
    _slider.value=0;
    _seekTimer=0;
}

#pragma mark -结束时钟
-(void)closeTimer{
    [self stopTimer];
    [[PlayManager sharedPlayManager] setIsPlayNewsDetail:NO];
}
#pragma mark -开始缓冲
-(void)startCacheIndication{
    [_cacheStatus startAnimating];
    _cacheStatus.hidden=NO;
    _play.hidden=YES;
}
#pragma mark -结束缓冲
-(void)stopCacheIndication{
    [_cacheStatus stopAnimating];
    _cacheStatus.hidden=YES;
    _play.hidden=NO;
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNotificationPlayManagerPlayFail object:nil];
    
    _play=nil;
    _previous=nil;
    _next=nil;
    _slider=nil;
    _currenttime=nil;
    _totaltime=nil;
    _cacheStatus=nil;
    self.timer=nil;
    
}
@end
