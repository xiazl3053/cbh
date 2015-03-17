//
//  MJZoomingScrollView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  MJPhotoViewDelegate;
@class MJPhotoBrowser, MJPhoto, MJPhotoView;

@interface MJPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) MJPhoto *photo;
// 代理
@property (nonatomic, weak) id<MJPhotoViewDelegate> photoViewDelegate;
@property(strong,nonatomic)UIView *loadView;
@property(strong,nonatomic)UIView *reloadView;


#pragma mark 调整frame
- (void)adjustFrame;
-(void)reloadImageView;


#pragma mark 将imageview的image设置为空
-(void)clearImage;
@end

@protocol MJPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView;
- (void)photoViewSingleTap:(MJPhotoView *)photoView;
- (void)photoViewDidEndZoom:(MJPhotoView *)photoView;
@end