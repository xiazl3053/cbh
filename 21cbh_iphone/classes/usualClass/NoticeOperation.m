//
//  NoticeController.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-1-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NoticeOperation.h"

#define KNoticeWidth 138
#define KNoticeHeight 85
#define KTime 0.3
#define KRotateSpeed 0.3

@interface NoticeOperation(){
    
}

@end

static NoticeOperation *_no;

@implementation NoticeOperation

+(NoticeOperation *)getId{
    if (_no) {
        return _no;
    }
    _no=[[NoticeOperation alloc] init];
    return _no;
}

#pragma mark 显示加载loadView(含21世纪网的logo)
-(UIView *)getLoadView:(UIView *)view imageName:(NSString *)imageName{
    UIImage *img=[UIImage imageNamed:imageName];
    UIView *loadView=[[UIView alloc] initWithFrame:CGRectMake((view.frame.size.width-150)*0.5f, (view.frame.size.height-img.size.height)*0.5f, 165, img.size.height)];
    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake(loadView.frame.size.width-img.size.width, 0, img.size.width, img.size.height)];
    [iv setImage:img];
    [loadView addSubview:iv];
    
    //加载时的旋转圈圈
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGRect frame=CGRectMake(0, (loadView.frame.size.height-indicator.frame.size.height)*0.5f, indicator.frame.size.width, indicator.frame.size.height);
    indicator.frame=frame;
    indicator.color = [UIColor grayColor];
    [indicator startAnimating];
    [loadView addSubview:indicator];
    
    
    [view addSubview:loadView];
    
    return loadView;
}

#pragma mark view渐隐消失移除
-(void)viewFaceOut:(UIView *)view{
    if (view) {//移除加载view
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha=0.0;
            
        }completion:^(BOOL b){
            [view removeFromSuperview];
        }];
    }
}

#pragma mark y方向的平移动画
-(void)yMoveAnimate:(CGFloat) y view:(UIView *)view{
    //执行动画
    CGRect frame=view.frame;
    [UIView beginAnimations:@" " context:nil];
    [UIView setAnimationDuration:0.2f];
    frame.origin.y+=y;
    view.frame=frame;
    [UIView commitAnimations];
}

#pragma mark 获取点击重新加载视图
-(UIView *)getReLoadview:(UIView *)view obj:(id)obj imageName:(NSString *)imageName{
    UIImage *img=[UIImage imageNamed:imageName];
    UIView *reLoadview=[[UIView alloc] initWithFrame:CGRectMake((view.frame.size.width-200)*0.5f, (view.frame.size.height-60)*0.5f, 200, 60)];
    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake((reLoadview.frame.size.width-img.size.width)*0.5f, 0, img.size.width, img.size.height)];
    [iv setImage:img];
    [reLoadview addSubview:iv];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, iv.frame.origin.y+iv.frame.size.height+10, reLoadview.frame.size.width, 20)];
    label.backgroundColor=[UIColor clearColor];
    label.font=[UIFont fontWithName:kFontName size:15];
    label.textColor=[UIColor grayColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"点击屏幕,重新加载";
    
    [reLoadview addSubview:label];
    
    [view addSubview:reLoadview];
    
    // 创建一个手势识别器
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:obj action:@selector(clickReload)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [reLoadview addGestureRecognizer:tap];
    
    return reLoadview;
}


#pragma mark 显示提示窗口
-(UIView *)showAlertWithMsg:(NSString *)msg imageName:(NSString *)imageName toView:(UIView *)view autoDismiss:(BOOL)autoDismiss viewUserInteractionEnabled:(BOOL)viewUserInteractionEnabled{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    UIView *coverView=[[UIView alloc]initWithFrame:view.bounds];
    coverView.tag=9999;
    [view addSubview:coverView];
    view.userInteractionEnabled=viewUserInteractionEnabled;
    
    CGSize labelSize=[msg sizeWithFont:[UIFont fontWithName:kFontName size:15] constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)];;
    CGFloat width=KNoticeWidth;
    if (labelSize.width>KNoticeWidth) {
        width=labelSize.width+5;
    }
    
    UIView *alert=[[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width, view.frame.size.height/3, width, KNoticeHeight)];
    alert.backgroundColor=[UIColor clearColor];
    [view addSubview:alert];
    [alert bringSubviewToFront:view];
    UIView *maskView=[[UIView alloc] initWithFrame:alert.bounds];
    maskView.backgroundColor=UIColorFromRGB(0x464646);
    maskView.alpha=0.9;
    [alert addSubview:maskView];
    
    UIImage *image=[UIImage imageNamed:imageName];
    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake((alert.frame.size.width-image.size.width)*0.5f, 15, image.size.width, image.size.height)];
    [iv setImage:image];
    iv.tag=2001;
    [alert addSubview:iv];
    
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0,iv.frame.origin.y+iv.frame.size.height+5, alert.frame.size.width, 20)];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor=[UIColor clearColor];
    label.font=[UIFont fontWithName:kFontName size:15];
    label.text=msg;
    label.tag=2002;
    label.numberOfLines=0;
    [alert addSubview:label];
    
    
    
    [UIView animateWithDuration:KTime animations:^{
        CGRect frame=alert.frame;
        frame.origin.x=view.frame.size.width-alert.frame.size.width;
        alert.frame=frame;
    } completion:^(BOOL finished) {
        if (autoDismiss) {//是否自动隐藏
            [self hideAlertView:alert fromView:view];
        }
    }];
    
    return alert;
}


#pragma mark 显示提示窗口(是否带旋转动画)
-(UIView *)showAlertWithMsg:(NSString *)msg imageName:(NSString *)imageName toView:(UIView *)view autoDismiss:(BOOL)autoDismiss viewUserInteractionEnabled:(BOOL)viewUserInteractionEnabled isRotate:(BOOL)isRotate{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    UIView *coverView=[[UIView alloc]initWithFrame:view.bounds];
    coverView.tag=9999;
    [view addSubview:coverView];
    
    CGSize labelSize=[msg sizeWithFont:[UIFont fontWithName:kFontName size:15] constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)];;
    CGFloat width=KNoticeWidth;
    if (labelSize.width>KNoticeWidth) {
        width=labelSize.width+5;
    }
    
    UIView *alert=[[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width, view.frame.size.height/3, width, KNoticeHeight)];
    alert.backgroundColor=[UIColor clearColor];
    [view addSubview:alert];
    [alert bringSubviewToFront:view];
    UIView *maskView=[[UIView alloc] initWithFrame:alert.bounds];
    maskView.backgroundColor=UIColorFromRGB(0x464646);
    maskView.alpha=0.9;
    maskView.tag=2000;
    [alert addSubview:maskView];
    
    UIImage *image=[UIImage imageNamed:imageName];
    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake((alert.frame.size.width-image.size.width)*0.5f, 15, image.size.width, image.size.height)];
    [iv setImage:image];
    iv.tag=2001;
    [alert addSubview:iv];
    if (isRotate) {
        //旋转动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI/2 , 0, 0, 1.0)];
        animation.duration = KRotateSpeed;
        animation.cumulative = YES;
        animation.repeatCount = INT_MAX;
        [iv.layer addAnimation:animation forKey:@"animation"];
    }
    
    UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(0,iv.frame.origin.y+iv.frame.size.height+5, alert.frame.size.width, 20)];
    lable.backgroundColor=[UIColor clearColor];
    lable.textAlignment=NSTextAlignmentCenter;
    lable.textColor=[UIColor whiteColor];
    lable.font=[UIFont fontWithName:kFontName size:15];
    lable.text=msg;
    lable.tag=2002;
    [alert addSubview:lable];
    
    
    
    [UIView animateWithDuration:KTime animations:^{
        CGRect frame=alert.frame;
        frame.origin.x=view.frame.size.width-alert.frame.size.width;
        alert.frame=frame;
    } completion:^(BOOL finished) {
        
        if (autoDismiss) {//是否自动隐藏
            [self hideAlertView:alert fromView:view];
        }
    }];
    
    return alert;
}

#pragma mark 关闭提示窗口1
-(void)hideAlertView:(UIView *)alert fromView:(UIView *)view{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:KTime animations:^{
                CGRect frame=alert.frame;
                frame.origin.x=view.frame.size.width;
                alert.frame=frame;
                
            } completion:^(BOOL finished) {
                [[view viewWithTag:9999]removeFromSuperview];
                view.userInteractionEnabled=YES;
                [alert removeFromSuperview];
            }];
        });
    });
}

#pragma mark 关闭提示窗口3
-(void)hideAlertView:(UIView *)alert fromView:(UIView *)view completion:(void (^)(void))animations{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        sleep(6);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:KTime animations:^{
                CGRect frame=alert.frame;
                frame.origin.x=view.frame.size.width;
                alert.frame=frame;
                
            } completion:^(BOOL finished) {
                animations();
                [[view viewWithTag:9999]removeFromSuperview];
                [alert removeFromSuperview];
            }];
        });
    });
}

#pragma mark 关闭提示窗口2
-(void)hideAlertView:(UIView *)alert fromView:(UIView *)view msg:(NSString *)msg imageName:(NSString *)imageName{
   // view.userInteractionEnabled=NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageName) {
                UIImage *image=[UIImage imageNamed:imageName];
                UIImageView *iv=(UIImageView *)[view viewWithTag:2001];
                [iv setImage:image];
                [iv.layer removeAllAnimations];
            }
            
            if (msg) {
                CGSize labelSize=[msg sizeWithFont:[UIFont fontWithName:kFontName size:15] constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)];
                CGFloat width=KNoticeWidth;
                if (labelSize.width>KNoticeWidth) {
                    width=labelSize.width+5;
                }
                
                CGRect frame;
                frame=alert.frame;
                frame.size.width=width;
                frame.origin.x-=width-KNoticeWidth;
                alert.frame=frame;
                
                UIView *maskView=[alert viewWithTag:2000];
                maskView.frame=alert.bounds;
                
                UIImageView *iv=(UIImageView *)[view viewWithTag:2001];
                frame=iv.frame;
                frame.origin.x=(alert.frame.size.width-iv.frame.size.width)*0.5f;
                iv.frame=frame;
                
                UILabel *label=(UILabel *)[view viewWithTag:2002];
                frame=label.frame;
                frame.size.width=width;
                frame.origin.x=0;
                label.frame=frame;
                label.text=msg;

            }
            
        });
        
        
        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:KTime animations:^{
                CGRect frame=alert.frame;
                frame.origin.x=view.frame.size.width;
                alert.frame=frame;
                
            } completion:^(BOOL finished) {
                [[view viewWithTag:9999]removeFromSuperview];
                [alert removeFromSuperview];
            }];
        });
    });
}

#pragma mark 显示推荐提示view
-(void)showRecommendViewWithFrame:(CGRect)frame superView:(UIView *)superView msg:(NSString *)msg{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.font=[UIFont fontWithName:kFontName size:13];
    label.textColor=UIColorFromRGB(0xffffff);
    label.textAlignment=NSTextAlignmentCenter;
    label.text=msg;
    label.backgroundColor=UIColorFromRGB(0xe86e25);
    label.layer.masksToBounds=YES;
    label.layer.cornerRadius=2;
    [superView addSubview:label];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
             [self viewFaceOut:label];
        });
    });
   
}

#pragma mark 聊天消息提醒View
-(UIView *)showChatNumViewWithPoint:(CGPoint)point superView:(UIView *)superView msg:(NSString *)msg{
//    NSInteger num=[msg intValue];
//    if (num==0) {
//        return nil;
//    }
//    
//    if (num>99) {
//        msg=@"99+";
//    }
    
    CGSize labelSize=[msg sizeWithFont:[UIFont fontWithName:kFontName size:10] constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)];
    CGFloat width=labelSize.width;
    CGFloat height=labelSize.height;
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, width+5, width+5)];
    label.center=point;
    label.backgroundColor=[UIColor redColor];
    label.text=msg;
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor whiteColor];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius=5;//设置圆角
    label.layer.borderWidth=1;
    label.layer.borderColor=[UIColor whiteColor].CGColor;
    [superView addSubview:label];
    [superView bringSubviewToFront:label];
    return label;
}



#pragma mark 下载文件信息提醒view
-(UIView *)showDownLoadViewAlert:(NSString *)info frame:(CGRect)frame superView:(UIView *)superView backColor:(UIColor *)color{
    UIView *view=[[UIView alloc] initWithFrame:frame];
    view.backgroundColor=color;
    view.alpha=0.7;
    UILabel *label=[[UILabel alloc] initWithFrame:view.bounds];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=UIColorFromRGB(0xffffff);
    label.backgroundColor=[UIColor clearColor];
    label.font=[UIFont fontWithName:kFontName size:14];
    label.text=info;
    label.tag=2014;
    [view addSubview:label];
    [superView addSubview:view];
    return  view;
}

#pragma mark 下载文件信息更新
-(void)UpdateDownLoadViewAlertInfo:(NSString *)info alertView:(UIView *)alertView{
    UILabel *label=(UILabel *)[alertView viewWithTag:2014];
    label.text=info;
}


#pragma mark 关闭下载文件信息提醒view
-(void)closeDownLoadViewAlert:(UIView *) view{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha=0;
            
        } completion:^(BOOL finished) {
         
            [view removeFromSuperview];
        }];
    });
}


@end
