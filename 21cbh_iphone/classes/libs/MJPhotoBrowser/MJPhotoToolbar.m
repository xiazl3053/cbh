//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoToolbar.h"
#import "MJPhoto.h"
#import "MBProgressHUD+Add.h"
#import "MJPhotoBrowser.h"
#import "CommonOperation.h"
#import "ChatViewController.h"
#import "NewListModel.h"
#import "ChatLogIn.h"
#import "SessionInstance.h"
#import "UIImage+ZX.h"


@interface MJPhotoToolbar()
{
    UILabel *_titleLabel;
    UILabel *_indexLabel;
    UITextView *_text;
    UIButton *_downBtn;
    UIButton *_shareBtn;
    UIButton *_collectBtn;
    UIButton *_privateLetterBtn;
    UIView *_viewBtns;
    UIView *_chatNumView;//消息数view
}
@end

@implementation MJPhotoToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //注册通知
        //[self registerNotification];
    }
    return self;
}

-(void)dealloc{
    //移除通知
    //[self removeNotification];
}


#pragma mark - -------------------------------以下为自定义方法------------------------------

#pragma mark 设置数据
-(void)setData{
    if (self.plm) {
        _titleLabel.text=self.plm.title;
    }
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    //添加背景蒙版
    UIView *backView=[[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor=[UIColor blackColor];
    backView.alpha=0.45f;
    [self addSubview:backView];
    
    
    CGFloat width=self.frame.size.width;
    CGFloat height=self.frame.size.height;
    UIImage *img=[UIImage imageNamed:@"pb_down"];
    CGFloat vbHeight=img.size.height+12*2;
    CGFloat indexLabelWidth=100;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width-20-indexLabelWidth, 20)];
    _titleLabel.font = [UIFont fontWithName:kFontName size:16];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_titleLabel];
    
    if (_photos.count > 1) {
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-indexLabelWidth-10, 0, indexLabelWidth, _titleLabel.frame.size.height)];
        _indexLabel.font = [UIFont fontWithName:kFontName size:15];
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentRight;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    }
    
    _text=[[UITextView alloc] initWithFrame:CGRectMake(7,_titleLabel.frame.size.height+2,width-14+3, height-vbHeight-20-10)];
    _text.font = [UIFont fontWithName:kFontName size:14];
    _text.backgroundColor = [UIColor clearColor];
    _text.textColor =kffffff;
    _text.textAlignment = NSTextAlignmentLeft;
    _text.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_text setEditable:YES];
    [_text setDelegate:self];
    [self addSubview:_text];
    

    img=[[UIImage imageNamed:@"pb_down"] scaleToSize:CGSizeMake(21, 21)];
    UIView *viewBtns=[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-vbHeight, width, vbHeight)];
    [self addSubview:viewBtns];
    //下载按钮
    _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _downBtn.frame = CGRectMake(width-10-30*2-img.size.width*3-img.size.width*0.5f, (vbHeight-img.size.height*2)*0.5f, img.size.width*2, img.size.height*2);
    [_downBtn setImage:img forState:UIControlStateNormal];
    [_downBtn setImage:img forState:UIControlStateHighlighted];
    [_downBtn addTarget:self action:@selector(downBtn) forControlEvents:UIControlEventTouchUpInside];
    [viewBtns addSubview:_downBtn];
    
    //分享按钮
    img=[[UIImage imageNamed:@"newsDetail_forward"] scaleToSize:CGSizeMake(21, 21)];
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareBtn.frame = CGRectMake(_downBtn.frame.origin.x+_downBtn.frame.size.width-img.size.width*0.5f+20, _downBtn.frame.origin.y, img.size.width*2, img.size.height*2);
    [_shareBtn setImage:img forState:UIControlStateNormal];
    [_shareBtn setImage:img forState:UIControlStateHighlighted];
    [_shareBtn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    [viewBtns addSubview:_shareBtn];
    
    //收藏按钮
    img=[[UIImage imageNamed:@"pb_nocollect"] scaleToSize:CGSizeMake(21, 21)];
    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectBtn.frame = CGRectMake(_shareBtn.frame.origin.x+_shareBtn.frame.size.width-img.size.width*0.5f+15, _downBtn.frame.origin.y, img.size.width*2, img.size.height*2);
    [_collectBtn setImage:img forState:UIControlStateNormal];
    [_collectBtn setImage:img forState:UIControlStateHighlighted];
    [_collectBtn addTarget:self action:@selector(collectBtn) forControlEvents:UIControlEventTouchUpInside];
    [viewBtns addSubview:_collectBtn];
    
    //两个icon中间的分割线
    UIView *line1=[[UIView alloc] initWithFrame:CGRectMake(223, (viewBtns.frame.size.height-15)*0.5f, 1, 15)];
    line1.backgroundColor=UIColorFromRGB(0x808080);
    [viewBtns addSubview:line1];
    
    UIView *line2=[[UIView alloc] initWithFrame:CGRectMake(_shareBtn.frame.origin.x+_shareBtn.frame.size.width+5, (viewBtns.frame.size.height-15)*0.5f, 1, 15)];
    line2.backgroundColor=UIColorFromRGB(0x808080);
    [viewBtns addSubview:line2];
    
    //设置收藏按钮的状态图
    [self setCollectBtnImage];
    
    //设置数据
    [self setData];
    
//    img=[UIImage imageNamed:@"pb_down"];
//    UIView *viewBtns=[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-vbHeight, width, vbHeight)];
//    [self addSubview:viewBtns];
//    _viewBtns=viewBtns;
//    
//    //下载按钮
//    _downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _downBtn.frame = CGRectMake(width-5-30*4-img.size.width*3-img.size.width*0.5f, (vbHeight-img.size.height*2)*0.5f, img.size.width*2, img.size.height*2);
//    [_downBtn setImage:img forState:UIControlStateNormal];
//    [_downBtn setImage:img forState:UIControlStateHighlighted];
//    [_downBtn addTarget:self action:@selector(downBtn) forControlEvents:UIControlEventTouchUpInside];
//    [viewBtns addSubview:_downBtn];
//    
//    
//    //两个icon中间的分割线
//    UIView *line1=[[UIView alloc] initWithFrame:CGRectMake(_downBtn.frame.origin.x+_downBtn.frame.size.width+5, (viewBtns.frame.size.height-15)*0.5f, 1, 15)];
//    line1.backgroundColor=UIColorFromRGB(0x808080);
//    [viewBtns addSubview:line1];
//    
//    //分享按钮
//    img=[UIImage imageNamed:@"newsDetail_forward"];
//    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _shareBtn.frame = CGRectMake(line1.frame.origin.x+line1.frame.size.width+5, _downBtn.frame.origin.y, img.size.width*2, img.size.height*2);
//    [_shareBtn setImage:img forState:UIControlStateNormal];
//    [_shareBtn setImage:img forState:UIControlStateHighlighted];
//    [_shareBtn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
//    [viewBtns addSubview:_shareBtn];
//    
//    //两个icon中间的分割线
//    UIView *line2=[[UIView alloc] initWithFrame:CGRectMake(_shareBtn.frame.origin.x+_shareBtn.frame.size.width+5, (viewBtns.frame.size.height-15)*0.5f, 1, 15)];
//    line2.backgroundColor=UIColorFromRGB(0x808080);
//    [viewBtns addSubview:line2];
//    
//    //收藏按钮
//    img=[UIImage imageNamed:@"pb_nocollect"];
//    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _collectBtn.frame = CGRectMake(line2.frame.origin.x+line2.frame.size.width+5, _downBtn.frame.origin.y, img.size.width*2, img.size.height*2);
//    [_collectBtn setImage:img forState:UIControlStateNormal];
//    [_collectBtn setImage:img forState:UIControlStateHighlighted];
//    [_collectBtn addTarget:self action:@selector(collectBtn) forControlEvents:UIControlEventTouchUpInside];
//    [viewBtns addSubview:_collectBtn];
//    [self setCollectBtnImage]; //设置收藏按钮的状态图
//    
//    //两个icon中间的分割线
//    UIView *line3=[[UIView alloc] initWithFrame:CGRectMake(_collectBtn.frame.origin.x+_collectBtn.frame.size.width+5, (viewBtns.frame.size.height-15)*0.5f, 1, 15)];
//    line3.backgroundColor=UIColorFromRGB(0x808080);
//    [viewBtns addSubview:line3];
//    
//    //私信按钮
//    img=[UIImage imageNamed:@"pb_privateLetter"];
//    _privateLetterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _privateLetterBtn.frame = CGRectMake(line3.frame.origin.x+line3.frame.size.width+5, _downBtn.frame.origin.y, img.size.width*2, img.size.height*2);
//    [_privateLetterBtn setImage:img forState:UIControlStateNormal];
//    [_privateLetterBtn setImage:img forState:UIControlStateHighlighted];
//    [_privateLetterBtn addTarget:self action:@selector(privateLetterBtn) forControlEvents:UIControlEventTouchUpInside];
//    [viewBtns addSubview:_privateLetterBtn];
//    
//    //设置数据
//    [self setData];
    
}

#pragma mark 收藏
-(void)collectBtn{
    NSLog(@"收藏");
    if ([self.plm.type isEqualToString:@"0"]&&(self.plm.picUrls.count==1)) {
        __block UIView *alert=nil;
        [self.dbQueue addOperationWithBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                BOOL b=[self.plcDB isExistPlmWithTitle:self.plm.title];
                
                if (b) {
                    NSLog(@"有数据");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        alert=[[NoticeOperation getId] showAlertWithMsg:@"已取消收藏" imageName:@"alert_collect_cancel" toView:self.mpb.view autoDismiss:NO viewUserInteractionEnabled:NO];
                    });
                    [self.plcDB deletePlm2:self.plm];
                }else{
                    NSLog(@"没有数据");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        alert=[[NoticeOperation getId] showAlertWithMsg:@"收藏成功" imageName:@"alert_collect_success" toView:self.mpb.view autoDismiss:NO viewUserInteractionEnabled:NO];
                    });
                    [self.plcDB deletePlm2:self.plm];
                    [self.plcDB insertPlm:self.plm];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NoticeOperation getId]hideAlertView:alert fromView:self.mpb.view];
                    [self setCollectBtnImage];
                });
            });
        }];
    }
}

#pragma mark 分享
-(void)shareBtn{
    NSLog(@"分享");
    if ([self.delegate respondsToSelector:@selector(clickShareBtn)]) {
        [self.delegate clickShareBtn];
    }
}


#pragma mark 保存图片
- (void)downBtn
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhoto *photo = _photos[_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

#pragma mark 设置收藏按钮的状态图像
-(void)setCollectBtnImage{
    [self.dbQueue addOperationWithBlock:^{
        BOOL b=[self.plcDB isExistPlmWithTitle:self.plm.title];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (b) {
                [_collectBtn setImage:[[UIImage imageNamed:@"pb_collect"] scaleToSize:CGSizeMake(21, 21)] forState:UIControlStateNormal];
                [_collectBtn setImage:[[UIImage imageNamed:@"pb_collect"] scaleToSize:CGSizeMake(21, 21)] forState:UIControlStateHighlighted];
            }else{
                [_collectBtn setImage:[[UIImage imageNamed:@"pb_nocollect"] scaleToSize:CGSizeMake(21, 21)] forState:UIControlStateNormal];
                [_collectBtn setImage:[[UIImage imageNamed:@"pb_nocollect"] scaleToSize:CGSizeMake(21, 21)] forState:UIControlStateHighlighted];
            }
        });
        
    }];
}

#pragma mark 聊天
-(void)privateLetterBtn{
    if (!self.mpb.isReturn) {//打开聊天界面
        if (_chatNumView) {//如果有红点就移除
            [_chatNumView removeFromSuperview];
        }
        //封装一个NewListModel对象传给聊天界面
        NewListModel *nlm=[self getNewListModel];
        //手动登陆
        [[ChatLogIn getId] manualLoginWithModel:nlm];
        
    }else{//返回聊天界面
        [self.mpb.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark 封装一个NewListModel对象传给聊天界面
-(NewListModel *)getNewListModel{
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:@"3" forKey:@"type"];
    [dic setValue:self.plm.programId forKey:@"programId"];
    [dic setValue:self.plm.picsId forKey:@"picsId"];
    [dic setValue:self.plm.title forKey:@"title"];
    [dic setValue:self.plm.followNum forKey:@"followNum"];
    [dic setValue:self.plm.picUrls forKey:@"picUrls"];
    
    NewListModel *nlm=[[NewListModel alloc] initWithDict:dic];
    return nlm;
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
    
    MJPhoto *photo = _photos[_currentPhotoIndex];
    _downBtn.enabled =!photo.save;
    
    if (self.pdms) {
        PicDetailModel *pdm=self.pdms[_currentPhotoIndex];
        NSString *s=pdm.desc;
        //去掉换行符
        s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [[CommonOperation getId] setIntervalWithTextView:_text text:[NSString stringWithFormat:@"%@",s] font:[UIFont fontWithName:kFontName size:14] lineSpace:5 color:kffffff];
        [_text setContentOffset:CGPointMake(0, 5)];
    }
}


#pragma mark 通知响应
-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(listenToMessageNum:) name:kXMPPSessionChangeNotifaction object:nil];
}

#pragma mark 移除通知
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPSessionChangeNotifaction object:nil];
}

#pragma mark 监听未读消息数
-(void)listenToMessageNum:(NSNotification *)notification{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        dispatch_async(dispatch_get_main_queue(), ^{
            if (_chatNumView) {
                [_chatNumView removeFromSuperview];
            }
            //显示未读消息数
            if ([INSTANCE totalUnReadCount]>0) {
                 _chatNumView=[[NoticeOperation getId] showChatNumViewWithPoint:CGPointMake(_viewBtns.frame.size.width-5, 10) superView:_viewBtns msg:@" "];
            }
           
        });
    });
}

#pragma mark - --------------UITextView的代理方法---------------
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}
@end

