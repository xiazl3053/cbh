//
//  NoticeController.h
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoticeOperation : NSObject

+(NoticeOperation *)getId;

#pragma mark 显示加载loadView(含21世纪网的logo)
-(UIView *)getLoadView:(UIView *)view imageName:(NSString *)imageName;
#pragma mark view渐隐消失移除
-(void)viewFaceOut:(UIView *)view;
#pragma mark y方向的平移动画
-(void)yMoveAnimate:(CGFloat) y view:(UIView *)view;
#pragma mark 获取点击重新加载视图
-(UIView *)getReLoadview:(UIView *)view obj:(id)obj imageName:(NSString *)imageName;
#pragma mark 显示提示窗口
-(UIView *)showAlertWithMsg:(NSString *)msg imageName:(NSString *)imageName toView:(UIView *)view autoDismiss:(BOOL)autoDismiss viewUserInteractionEnabled:(BOOL)viewUserInteractionEnabled;
#pragma mark 显示提示窗口(是否带旋转动画)
-(UIView *)showAlertWithMsg:(NSString *)msg imageName:(NSString *)imageName toView:(UIView *)view autoDismiss:(BOOL)autoDismiss viewUserInteractionEnabled:(BOOL)viewUserInteractionEnabled isRotate:(BOOL)isRotate;
#pragma mark 关闭提示窗口1
-(void)hideAlertView:(UIView *)alert fromView:(UIView *)view;
#pragma mark 关闭提示窗口2
-(void)hideAlertView:(UIView *)alert fromView:(UIView *)view msg:(NSString *)msg imageName:(NSString *)imageName;
#pragma mark 显示推荐提示view
-(void)showRecommendViewWithFrame:(CGRect)frame superView:(UIView *)superView msg:(NSString *)msg;
#pragma mark 关闭提示窗口3
-(void)hideAlertView:(UIView *)alert fromView:(UIView *)view completion:(void (^)(void))animations;
#pragma mark 聊天消息提醒View
-(UIView *)showChatNumViewWithPoint:(CGPoint)point superView:(UIView *)superView msg:(NSString *)msg;
#pragma mark 下载文件信息提醒view
-(UIView *)showDownLoadViewAlert:(NSString *)info frame:(CGRect)frame superView:(UIView *)superView backColor:(UIColor *)color;
#pragma mark 下载文件信息更新
-(void)UpdateDownLoadViewAlertInfo:(NSString *)info alertView:(UIView *)alertView;
#pragma mark 关闭下载文件信息提醒view
-(void)closeDownLoadViewAlert:(UIView *)view;
@end
