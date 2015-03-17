//
//  loadingView.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "loadingView.h"

#define kD_FinishedImg [UIImage imageNamed:@"alert_savephoto_success.png"]
#define kD_ErrorImg [UIImage imageNamed:@"alert_tanhao.png"]

@interface loadingView(){
    UIActivityIndicatorView *_loadImg;
    UIImageView *_finishImgView;
    CGFloat _alpha;
    UIView *mengban;// 蒙版
    BOOL _isFullScreen;
}

@end

@implementation loadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _alpha = 0.8;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 100, 80);
        [self create];
    }
    return self;
}

-(id)initWithTitle:(NSString*)title Frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 100, 80);
        _alpha = 0.8;
        [self create];
    }
    return self;
}

-(id)initWithTitle:(NSString*)title  Frame:(CGRect)frame IsFullScreen:(BOOL)fullScreen{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        _alpha = 0.5;
        _isFullScreen = fullScreen;
        if (fullScreen) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 150, 100);
//            // 创建蒙版视图
//            CGRect frame = [UIScreen mainScreen].bounds;
//            mengban = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//            mengban.backgroundColor = UIColorFromRGB(0x000000);
//            mengban.alpha = 0.5;
//            mengban.userInteractionEnabled = NO;
//            [self.superview addSubview:mengban];
//            [self.superview bringSubviewToFront:mengban];
            _alpha = 1;
        }
        [self create];
    }
    return self;
}

-(void)create{
    if (!self.title) {
       self.title = @"数据加载中...";
    }
    self.alpha = _alpha;
    self.backgroundColor = UIColorFromRGB(0x262626);
    self.layer.cornerRadius = 5;
    
    // 关闭自身按钮
    UIImage *close = nil;//[UIImage imageNamed:@"ad_delete_btn.png"];
    UIImageView *closeView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-close.size.width) - 5, (self.frame.size.height - close.size.height)/2, close.size.width, close.size.height)];
    closeView.image = close;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [closeButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    [closeButton addSubview:closeView];
    closeView = nil;
    closeButton = nil;
    
    
    
    // 添加加载控件
    _loadImg = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    if (_isFullScreen) {
        _loadImg.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    _loadImg.frame = CGRectMake((self.frame.size.width-_loadImg.frame.size.width)/2, (self.frame.size.height-_loadImg.frame.size.height)/2-20, _loadImg.frame.size.width, _loadImg.frame.size.height);
    [_loadImg startAnimating];
    if (mengban) {
        [mengban addSubview:_loadImg];
    }else{
        [self addSubview:_loadImg];
    }
    
    _finishImgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-kD_FinishedImg.size.width)/2, (self.frame.size.height-kD_FinishedImg.size.height)/2-20, kD_FinishedImg.size.width, kD_FinishedImg.size.height)];
    _finishImgView.image = kD_FinishedImg;
    [self addSubview:_finishImgView];
    _finishImgView.hidden = YES;
    
    // 添加加载文字
    UILabel *_lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _lb.text = self.title;
    _lb.font = [UIFont fontWithName:kFontName size:12];
    if (_isFullScreen) {
        _lb.font = [UIFont fontWithName:kFontName size:14];
    }
    _lb.textColor = UIColorFromRGB(0xFFFFFF);
    _lb.backgroundColor = ClearColor;
    _lb.textAlignment = NSTextAlignmentCenter;
    [_lb sizeToFit];
    _lb.frame = CGRectMake((self.frame.size.width-_lb.frame.size.width)/2, _loadImg.frame.origin.y+_loadImg.frame.size.height+15, _lb.frame.size.width, _lb.frame.size.height);
    [self addSubview:_lb];
    _lb = nil;
    
}

-(void)start{
    UILabel *lb = (UILabel*)[self.subviews lastObject];
    lb.text = self.title;
    lb = nil;
    _finishImgView.hidden = YES;
    [_loadImg startAnimating];
}
-(void)stop{
    _finishImgView.hidden = YES;
    [_loadImg stopAnimating];

}

-(void)setSelfTitle:(NSString*)title isSuccess:(BOOL)success andSecond:(int)second{
    UILabel *lb = (UILabel*)[self.subviews lastObject];
    lb.text = title;
    lb = nil;
    if (success) {
        _finishImgView.image = kD_FinishedImg;
    }else{
        _finishImgView.image = kD_ErrorImg;
    }
    _loadImg.hidden = YES;
    _finishImgView.hidden = NO;
    // 显示1秒
    [self performSelector:@selector(defaultBackground) withObject:nil afterDelay:second];
}

-(void)closeSelf{
    NSLog(@"---DFM---关闭加载");
    self.backgroundColor = UIColorFromRGB(0x000000);
    [self performSelector:@selector(defaultBackground) withObject:nil afterDelay:0.3];
}

-(void)defaultBackground{
    [self stop];
    self.hidden = YES;
    self.backgroundColor = UIColorFromRGB(0x262626);
}
@end
