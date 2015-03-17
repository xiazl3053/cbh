//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PicsListModel.h"
#import "MJPhotoToolbar.h"

@protocol MJPhotoBrowserDelegate;
@interface MJPhotoBrowser : BaseViewController <UIScrollViewDelegate,MJPhotoToolbarDelegate>

-(id)initWithProgramId:(NSString *)programId picsId:(NSString *)picsId followNum:(NSString *)followNum main:(UIViewController *)main;
-(id)initWithProgramId:(NSString *)programId picsId:(NSString *)picsId followNum:(NSString *)followNum main:(UIViewController *)main  isReturn:(BOOL)isReturn;

@property (nonatomic, weak) id<MJPhotoBrowserDelegate> delegate;// 代理
@property (nonatomic, strong) NSArray *photos;// 所有的图片对象
@property (nonatomic, assign) NSUInteger currentPhotoIndex;// 当前展示的图片索引
@property(strong,nonatomic)PicsListModel *plm;
@property(assign,nonatomic)BOOL isReturn;//根据它来判断打开聊天界面还是返回聊天界面


//显示照片
- (void)showPhotos;

#pragma mark 获取图集详情信息后的处理
-(void)getPicsDetailHandle:(NSMutableArray *)pdms plms:(NSMutableArray *)plms dic:(NSMutableDictionary *)dic;
@end

@protocol MJPhotoBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
@end