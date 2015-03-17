//
//  DownLoadCell2.h
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-14.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoiceListModel.h"

@interface DownLoadCell2 : UITableViewCell

@property(weak,nonatomic)VoiceListModel *vlm;

#pragma mark 设置cell的数据
-(void)setCell:(VoiceListModel *)vlm;

#pragma mark 更新下载进度
-(void)setProgress:(CGFloat)f;

@end
