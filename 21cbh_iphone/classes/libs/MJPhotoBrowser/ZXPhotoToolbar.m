//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "ZXPhotoToolbar.h"
#import "MJPhoto.h"
#import "MBProgressHUD+Add.h"
#import "NoticeOperation.h"
#import "CommonOperation.h"
#import "UIImage+ZX.h"


@interface ZXPhotoToolbar()
{
    
    UILabel *_indexLabel;
    UIButton *_downBtn;
    UITextView *_text;//描述
    UIView *_backView;//蒙版
}
@end

@implementation ZXPhotoToolbar

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    
    //添加背景蒙版
    UIView *backView=[[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor=[UIColor blackColor];
    backView.alpha=0.45f;
    [self addSubview:backView];
    _backView=backView;
    
    CGFloat width=self.frame.size.width;
    CGFloat height=self.frame.size.height;
    UIImage *img=[[UIImage imageNamed:@"pb_down"] scaleToSize:CGSizeMake(21, 21)];
    
    _text=[[UITextView alloc] initWithFrame:CGRectMake(7,0,width-14+3,60)];
    _text.font = [UIFont fontWithName:kFontName size:14];
    _text.backgroundColor = [UIColor clearColor];
    _text.textColor =kffffff;
    _text.textAlignment = NSTextAlignmentLeft;
    _text.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_text setEditable:YES];
    [_text setDelegate:self];
    [self addSubview:_text];
    
    if (_photos.count > 1) {
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (height-40+_text.frame.size.height)*0.5f, 50, 40)];
        _indexLabel.font = [UIFont systemFontOfSize:15];
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_indexLabel];
    }
    
    
    
    img=[[UIImage imageNamed:@"pb_down"] scaleToSize:CGSizeMake(21, 21)];
    //下载按钮
    _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _downBtn.frame = CGRectMake(width-img.size.width*2, (height-img.size.height*2+_text.frame.size.height)*0.5f, img.size.width*2, img.size.height*2);
    [_downBtn setImage:img forState:UIControlStateNormal];
    [_downBtn setImage:img forState:UIControlStateHighlighted];
    [_downBtn addTarget:self action:@selector(downBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_downBtn];
    
}


#pragma mark 保存图片
- (void)downBtn
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhoto *photo = _photos[_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [[NoticeOperation getId] showAlertWithMsg:@"保存失败" imageName:@"error" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    } else {
        MJPhoto *photo = _photos[_currentPhotoIndex];
        photo.save = YES;
        _downBtn.enabled = NO;
        [[NoticeOperation getId] showAlertWithMsg:@"成功保存到相册" imageName:@"alert_savephoto_success" toView:nil autoDismiss:YES viewUserInteractionEnabled:NO];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%d / %d", _currentPhotoIndex + 1, _photos.count];
    
    //对应图片的描述
    if (_descs&&_descs.count>currentPhotoIndex) {
        NSString *s=[_descs objectAtIndex:currentPhotoIndex];
        //去掉换行符
        s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [[CommonOperation getId] setIntervalWithTextView:_text text:[NSString stringWithFormat:@"%@",s] font:[UIFont fontWithName:kFontName size:14] lineSpace:5 color:kffffff];
        [_text setContentOffset:CGPointMake(0, 0)];
        
        if (s.length>1) {
            _backView.hidden=NO;
        }else{
            _backView.hidden=YES;
        }
        
    }
    
    MJPhoto *photo = _photos[_currentPhotoIndex];
    _downBtn.enabled =!photo.save;
    
}

#pragma mark - --------------UITextView的代理方法---------------
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}
@end

