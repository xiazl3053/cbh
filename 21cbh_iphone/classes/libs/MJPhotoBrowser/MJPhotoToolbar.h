//
//  MJPhotoToolbar.h
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicsListModel.h"
#import "PicDetailModel.h"
#import "NoticeOperation.h"
#import "PicsListCollectDB.h"

@class MJPhotoBrowser;
@protocol MJPhotoToolbarDelegate;

@interface MJPhotoToolbar : UIView<UITextViewDelegate>
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

@property(weak,nonatomic)id<MJPhotoToolbarDelegate>delegate;

@property(weak,nonatomic)PicsListModel *plm;
@property(weak,nonatomic)NSMutableArray *pdms;//该图集的实体类
@property(weak,nonatomic)MJPhotoBrowser *mpb;
@property(weak,nonatomic) NSOperationQueue *dbQueue;//数据库操作队列
@property(weak,nonatomic) PicsListCollectDB *plcDB;


#pragma mark 监听未读消息数
-(void)listenToMessageNum:(NSNotification *)notification;

@end

@protocol MJPhotoToolbarDelegate <NSObject>

-(void)clickShareBtn;

@end