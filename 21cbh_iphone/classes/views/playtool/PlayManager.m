//
//  Player.m
//  Player
//
//  Created by qinghua on 14-12-19.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import "PlayManager.h"
#import "VoiceListModel.h"
#import "CyberPlayerController+External.h"
#import <AVFoundation/AVFoundation.h>
#import "CommonOperation.h"
#import "FileOperation.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayManager (){
    CyberPlayerController *_player;
    BOOL _isGetPlayer;
    BOOL _isGetPlayList;
    BOOL _isExternal;
    NSInteger _currentPlayCursor;
}

@end

@implementation PlayManager

+(PlayManager *)sharedPlayManager
{
    static dispatch_once_t pred = 0;
    
    __strong static PlayManager *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

-(CyberPlayerController *)createPlayer{
    
    if (!_isGetPlayer) {
        
        //后台播放音频设置
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        //让app支持接受远程控制事件
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputDeviceChanged:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        
        //请添加您百度开发者中心应用对应的APIKey和SecretKey。
        NSString* msAK=@"N2DyzrFLyUvnG01uXlEGWusn";
        NSString* msSK=@"yiBhI7v9PYhqAZ4v1EUa7xwBXTyq8U1h";
        
        
        //NSString *path=[[NSBundle mainBundle] pathForResource:@"我很快乐" ofType:@"mp3"];
        //NSLog(@"path:%@",path);
        
        //添加开发者信息
        [[CyberPlayerController class ]setBAEAPIKey:msAK SecretKey:msSK ];
        //当前只支持CyberPlayerController的单实例
        
        _player=[[CyberPlayerController alloc]init];
        
        //设置视频显示的位置
        //cbPlayerController.view.frame=CGRectMake(0, 100, 320, 200);
        //将视频显示view添加到当前view中
        //[self.view addSubview:cbPlayerController.view];
        
        
        //注册监听，当播放器完成视频的初始化后会发送CyberPlayerLoadDidPreparedNotification通知，
        //此时naturalSize/videoHeight/videoWidth/duration等属性有效。
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(prepareDone:)
                                                     name: CyberPlayerLoadDidPreparedNotification
                                                   object:nil];
        //注册监听，当播放器完成视频播放位置调整后会发送CyberPlayerSeekingDidFinishNotification通知，
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                 selector:@selector(seekComplete:)
                                                     name:CyberPlayerSeekingDidFinishNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishPlay:) name:CyberPlayerPlaybackDidFinishNotification object:nil];
        //开始缓冲
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startCache:) name:CyberPlayerStartCachingNotification object:nil];
        //缓冲进度
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CachePercent:) name:CyberPlayerGotCachePercentNotification object:nil];
        //CyberPlayerPlaybackErrorNotification
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                 selector:@selector(playFail:)
                                                     name:CyberPlayerPlaybackErrorNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChange:) name:CyberPlayerPlaybackStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkBitrate:) name:CyberPlayerGotNetworkBitrateNotification object:nil];
        
        
        _player.shouldAutoplay=NO;
        _isGetPlayer=YES;
    }
    return _player;

}

#pragma mark -播放失败回调
-(void)playFail: (NSNotification*)aNotification
{
    self.isPlayFail=YES;
    NSLog(@"播放失败");
}
#pragma mark -加载完成回调
-(void)prepareDone:(NSNotification *)aNotification{
    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    NSLog(@"---------准备播放--------");
    self.isPrePareDone=YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerPrePareDone object:_player];
}
#pragma mark -缓冲加载ing回调
-(void)CachePercent:(NSNotification *)aNotification{
    NSLog(@"缓冲中。。。。。。。。%@",aNotification.object);
    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerCacheing object:aNotification.object];
}

-(void)startCache:(NSNotification *)aNotification{
    NSLog(@"开始缓冲。。。。。。。。%@",aNotification.object);
    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerStartCache object:aNotification];
}
-(void)finishPlay:(NSNotification *)aNotification{
    NSLog(@"-------finishPlay--------,%@,%@",aNotification,aNotification.userInfo);
    if (_isExternal) {
        _isExternal=NO;
        return ;
    }
    //player2非正常情况不自动跳过
    if ([[PlayManager sharedPlayManager]isPlayNewsDetail]) {
        //非正常情况
        if (self.isPlayFail||!self.isPrePareDone) {
            self.isPlayFail=NO;
            self.isPrePareDone=NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerPlayFail object:self];
            return ;
        }else{
            //正常情况
            [self playerToNext];
        }
    }else{//player1 收到通知就切换
        [self playerToNext];
    }
}
-(void)playStatusChange:(NSNotification *)aNotification{
    NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    //进入前台
    if (playerState==CBPMoviePlaybackStatePlaying) {
        [_player start];
    }
     NSLog(@"-----playStatusChange------%@,%d",aNotification,_player.playbackState);
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerPlayStautsChange object:_player];
    [self changeCover];
}

#pragma mark -定位成功回调
- (void)seekComplete:(NSNotification*)notification
{   //NSLog(@"%s,[NSThread currentThread]=%@",__FUNCTION__,[NSThread currentThread]);
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerSeekToDone object:_player];
}

-(void)playerToNext{
    if (++_currentPlayCursor<self.playList.count) {
    }else{
        _currentPlayCursor=0;
    }

    VoiceListModel *model=[self.playList objectAtIndex:_currentPlayCursor];
    [self setVoiceWithFilePath:model.voiceUrl];
    [_player setNowVoice:model];
    [_player prepareToPlay];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerFinishDone object:_player];
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerVoiceChange object:_player];
    NSLog(@"%s--play->next",__FUNCTION__);
}

-(void)playerToPervious{
    if (--_currentPlayCursor<0) {
        _currentPlayCursor=self.playList.count-1;
    }else{
    }
    VoiceListModel *model=[self.playList objectAtIndex:_currentPlayCursor];
    [self setVoiceWithFilePath:model.voiceUrl];
    [_player setNowVoice:model];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerFinishDone object:_player];
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerVoiceChange object:_player];
    [_player prepareToPlay];
    NSLog(@"%s--play->previous",__FUNCTION__);
}

-(void)startPlay{
    [_player start];
}

-(void)stopPlay{
    [_player stop];
}
-(void)pausePlay{
    [_player pause];
}
-(void)next{
    _isExternal=YES;
    [self playerToNext];
}
-(void)previous{
    _isExternal=YES;
    [self playerToPervious];
}
-(void)seekTo:(NSTimeInterval)interval{
    [_player seekTo:interval];
}


-(void)setPlayerListWithNSArray:(NSArray *)list withNumber:(NSInteger)number isExternal:(BOOL)b{
    _player.shouldAutoplay=b;
    self.playList=list;
    if (b) {
        [self manualChangeWithChapter:number];
    }else{
        [self firstPlayWithChapterNumber:number];
    }
}

//-(void)autoChangeWithChapter:(NSInteger )number{
//    _isExternal=NO;
//    [self playerToNext];
//}

-(void)manualChangeWithChapter:(NSInteger )number{
    _isExternal=YES;
    _currentPlayCursor=number;
    VoiceListModel *model=[self.playList objectAtIndex:number];
    [self setVoiceWithFilePath:model.voiceUrl];
    [_player setNowVoice:model];
    [_player prepareToPlay];
    [_player start];
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerVoiceChange object:_player];
}

-(void)firstPlayWithChapterNumber:(NSInteger)number{
    [self createPlayer];
    VoiceListModel *model=[self.playList objectAtIndex:number];
    [_player setNowVoice:model];
    [self setVoiceWithFilePath:model.voiceUrl];
    [_player prepareToPlay];
    [_player start];
    [[NSNotificationCenter defaultCenter]postNotificationName:KNotificationPlayManagerVoiceChange object:_player];
    NSLog(@"%s--play->next",__FUNCTION__);
}

#pragma mark -切换曲目
-(void)setVoiceWithFilePath:(NSString *)path{
    NSString *path1=[[FileOperation getId]getRadioLocalUrl:path];
    if (path1) {
        _player.contentString=path1;
        //_player.contentString=@"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4";
    }else{
        _player.contentString=path;
        //_player.contentString=@"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4";
    }
}

#pragma mark -获取当前播放曲目
-(VoiceListModel *)getNowVoiceModel{
    CyberPlayerController *player= self.player;
    return player.nowVoice;
}

-(CBPMoviePlaybackState)getStatus{
    return _player.playbackState;
}

- (void)outputDeviceChanged:(NSNotification *)aNotification
{
   // NSLog(@"%s",__FUNCTION__);
    
    NSDictionary *interuptionDict = aNotification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            [_player play];
           // NSLog(@"Headphone/Line plugged in");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
//            NSLog(@"Headphone/Line was pulled. Stopping player....");
            [_player pause];
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

-(void)interruption:(NSNotification *)aNotification{
    NSDictionary *interuptionDict = aNotification.userInfo;
    NSInteger interruptionReason = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    NSInteger resume=[[interuptionDict valueForKey:AVAudioSessionInterruptionOptionKey]integerValue];
    switch (interruptionReason) {
        case AVAudioSessionInterruptionTypeEnded:{
            if (resume==AVAudioSessionInterruptionOptionShouldResume) {
                [[AVAudioSession sharedInstance]setActive:YES error:nil];
                //[_player play];
            }
        }break;
        case AVAudioSessionInterruptionTypeBegan:
        {
            [_player pause];
        }
            break;
        default:
            break;
    }
    
    NSLog(@"%s,%@",__FUNCTION__,interuptionDict);
}

#pragma mark -播放器封面
-(void)changeCover{
    VoiceListModel *model=[self getNowVoiceModel];
    NSMutableDictionary *songInfo=[NSMutableDictionary dictionary];
    [songInfo setObject: model.title forKey:MPMediaItemPropertyTitle ];
    [songInfo setObject: @"21世纪网" forKey:MPMediaItemPropertyArtist ];
    //[ songInfo setObject: @"Audio Album" forKey:MPMediaItemPropertyAlbumTitle ];
//    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]initWithImage:[UIImage imageNamed:@"icon.png"]];
//    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo ];
}

-(void)networkBitrate:(NSNotification *)aNotification{
//    NSLog(@"aNotification===%@",aNotification);
//    int networkBitrateValue = [[aNotification object] intValue];
//    NSLog(@"show network bitrate is %d\n", networkBitrateValue);
//    CyberPlayerController *player=[[PlayManager sharedPlayManager] player];
//    NSLog(@"player.currentPlaybackTime=%f,downloadSpeed=%lf,playableDuration=%lf",floor(player.currentPlaybackTime),player.downloadSpeed,player.playableDuration);
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CyberPlayerLoadDidPreparedNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CyberPlayerSeekingDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CyberPlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CyberPlayerGotCachePercentNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CyberPlayerPlaybackErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CyberPlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CyberPlayerStartCachingNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CyberPlayerGotNetworkBitrateNotification object:nil];
}


@end
