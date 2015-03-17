//
//  PlayerTool.h
//  Player
//
//  Created by qinghua on 14-12-19.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayManager.h"

@class PlayerTool1;
@class VoiceListModel;

@protocol PlayerToolProtocol <NSObject>

#pragma mark -点击清单列表
-(void)PlayerTool1:(PlayerTool1 *)tool userClick:(UIButton *)aButton;
#pragma mark -曲目切换
-(void)PlayerTool1:(PlayerTool1 *)tool voiceChange:(VoiceListModel *)model;
@end

@interface PlayerTool1 : UIView

#pragma mark -设置播放列表
-(void)setPlayerList:(NSArray *)list NowNumber:(NSInteger )number isExternal:(BOOL)b;
@property (nonatomic,assign) id<PlayerToolProtocol> delegate;
-(void)startTextAnimation;
@end
