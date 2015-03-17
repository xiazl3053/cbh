//
//  SongListCell.h
//  Player
//
//  Created by qinghua on 14-12-23.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VoiceListModel;
@interface VoiceListCell : UITableViewCell
-(void)setValueWithVoiceModel:(VoiceListModel *)model;
-(void)play;
-(void)stop;
@end
