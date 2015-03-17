//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PicsListModel.h"
#import "NewsDetailViewController.h"

@protocol MJPhotoBrowserDelegate;
@interface ZXPhotoBrowser : BaseViewController <UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<MJPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

@property(weak,nonatomic)NewsDetailViewController *ndv;

//显示照片
- (void)showPhotos;

@end

@protocol MJPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(ZXPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
@end