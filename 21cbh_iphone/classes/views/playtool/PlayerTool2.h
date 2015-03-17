//
//  PlayerTool2.h
//  21cbh_iphone
//
//  Created by qinghua on 15-1-13.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VoiceListModel;
@class PlayerTool2;
@protocol PlayerTool2Protocol <NSObject>

#pragma mark -曲目切换
-(void)PlayerTool2:(PlayerTool2 *)tool voiceChange:(VoiceListModel *)model;
-(void)PlayerTool2:(PlayerTool2 *)tool clickComment:(VoiceListModel *)model;
-(void)PlayerTool2:(PlayerTool2 *)tool clickShare:(VoiceListModel *)model;
-(void)PlayerTool2:(PlayerTool2 *)tool clickCollect:(VoiceListModel *)model;

@end

@interface PlayerTool2 : UIView
@property (nonatomic,assign) id<PlayerTool2Protocol> delegate;
-(void)closeTimer;
@end
