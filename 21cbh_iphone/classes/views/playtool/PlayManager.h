//
//  Player.h
//  Player
//
//  Created by qinghua on 14-12-19.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CyberPlayerController.h"
#import "VoiceListModel.h"
#define KNotificationPlayManagerPrePareDone @"PlayManagerPrePareDone"
#define KNotificationPlayManagerSeekToDone @"PlayManagerSeekToDone"
#define KNotificationPlayManagerFinishDone @"PlayManagerFinishDone"
#define KNotificationPlayManagerVoiceChange @"PlayManagerVoiceChange"
#define KNotificationPlayManagerPlayStautsChange @"KNotificationPlayManagerPlayStautsChange"
#define KNotificationPlayManagerStartCache @"PlayManagerStartCache"
#define KNotificationPlayManagerCacheing @"PlayManagerCacheing"
#define KNotificationPlayManagerPlayFail @"PlayManagerPlayFail"



typedef enum : NSUInteger {
    PlayerToolStyleNomal,
    PlayerToolStyleBig,
} PlayerToolStyle;

@interface PlayManager : NSObject

+(id )sharedPlayManager;

@property (nonatomic,strong) CyberPlayerController *player;
@property (nonatomic,strong) NSArray *playList;
@property (nonatomic,assign) BOOL isAutoPlay;
@property (nonatomic,assign) BOOL isPlayNewsDetail;
@property (nonatomic,assign) BOOL isPrePareDone;
@property (nonatomic,assign) BOOL isPlayFail;
-(void)next;
-(void)previous;
-(void)stopPlay;
-(void)pausePlay;
-(void)startPlay;
-(CBPMoviePlaybackState)getStatus;
-(void)seekTo:(NSTimeInterval)interval;
-(void)setPlayerListWithNSArray:(NSArray *)list withNumber:(NSInteger)number isExternal:(BOOL)b;
-(VoiceListModel *)getNowVoiceModel;

@end
