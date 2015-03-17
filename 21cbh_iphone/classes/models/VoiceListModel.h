//
//  VoiceListModel.h
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-5.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceListModel : NSObject

- (id)initWithDict:(NSDictionary *)dict ;

@property(copy,nonatomic)NSString *requestId;//请求id(原值返回)
@property(copy,nonatomic)NSString *programId;//栏目id
@property(copy,nonatomic)NSString *articleId;//某条item的id
@property(copy,nonatomic)NSString *duration;//某条item的音频播放时长
@property(copy,nonatomic)NSString *title;//某条item的标题
@property(copy,nonatomic)NSString *voiceUrl;//某条item的音频播放地址
@property(copy,nonatomic)NSString *size;//某条item的音频大小(如4.3M)
@property(copy,nonatomic)NSString *order;//某条item的排序号
@property(copy,nonatomic)NSString *addtime;//某条item的时间戳



@property(assign,nonatomic)BOOL isExistDBlist;//用此判断是否处在下载数据库列表
@property(copy,nonatomic)NSString *isDownLoad;//判断音频是否已完全下载在本地(0:没有下载完成 1:下载完成)
@property(assign,nonatomic)NSInteger downloadstus;//下载状态标识符(1:正在下载 2:等待下载 3:暂停下载)

@end
