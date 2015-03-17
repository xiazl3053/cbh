//
//  SongListViewController.h
//  Player
//
//  Created by qinghua on 14-12-23.
//  Copyright (c) 2014年 qinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^VoiceListViewBlock)(NSArray *list,NSInteger number);

@interface VoiceListViewController :BaseViewController

@property (nonatomic,copy) VoiceListViewBlock selectChapterModelblock;

@end
