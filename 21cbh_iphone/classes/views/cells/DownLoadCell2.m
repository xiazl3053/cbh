//
//  DownLoadCell2.m
//  21cbh_iphone
//
//  Created by 周晓 on 15-1-14.
//  Copyright (c) 2015年 ZX. All rights reserved.
//

#import "DownLoadCell2.h"
#import "DownLoadManager.h"
#import "FileOperation.h"

@interface DownLoadCell2(){
    CGFloat interval1;
    CGFloat interval2;
    
    UILabel *_titleLable;//标题
    UIProgressView *_progressView;//进度条
    UILabel *_statusLable;//下载进度状态数据显示
    UIImageView *_iv;

}

@end

@implementation DownLoadCell2

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=UIColorFromRGB(0xf0f0f0);
        self.contentView.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView =[[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xe1e1e1);
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        
        interval1=15;
        interval2=16;
        
        [self initCell];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isEditing) {
        
        [self sendSubviewToBack:self.contentView];
        
    }
}

#pragma mark 初始化cell
-(void)initCell{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, 75);
    
    //标题
    UILabel *titleLable=[[UILabel alloc] initWithFrame:CGRectMake(interval1, interval2, 260, 15)];
    titleLable.textAlignment = NSTextAlignmentLeft;
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.textColor=UIColorFromRGB(0x000000);
    titleLable.font = [UIFont fontWithName:kFontName size:15];
    [self.contentView addSubview:titleLable];
    _titleLable=titleLable;
    
    //进度条
    UIProgressView *progressView=[[UIProgressView alloc] initWithFrame:CGRectMake(interval1, _titleLable.frame.origin.y+_titleLable.frame.size.height+10, 245, 5)];
    progressView.progressTintColor=UIColorFromRGB(0xfab78e);
    progressView.trackTintColor=UIColorFromRGB(0xe1e1e1);
    progressView.transform = CGAffineTransformMakeScale(1.0f,2.0f);//放大进度条
    progressView.alpha=0.7f;
    [progressView setProgress:0];
    [self.contentView addSubview:progressView];
    _progressView=progressView;
    
    
    //下载进度状态数据显示
    UILabel *statusLable=[[UILabel alloc] initWithFrame:CGRectMake(interval1, _progressView.frame.origin.y+_progressView.frame.size.height+10, 100, 12)];
    statusLable.textAlignment = NSTextAlignmentLeft;
    statusLable.backgroundColor=[UIColor clearColor];
    statusLable.textColor=UIColorFromRGB(0x8d8d8d);
    statusLable.font = [UIFont fontWithName:kFontName size:12];
    [self.contentView addSubview:statusLable];
    _statusLable=statusLable;
    
    //下载状态标识
    UIImage *img=[UIImage imageNamed:@"download_wait"];
    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-interval1-img.size.width, (self.frame.size.height-img.size.height)*0.5f, 29, 29)];
    [iv setImage:img];
    [self.contentView addSubview:iv];
    _iv=iv;
    UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-interval1-img.size.width, (self.frame.size.height-img.size.height)*0.5f, img.size.width*2, img.size.height*2)];
    btn.center=iv.center;
    btn.backgroundColor=[UIColor clearColor];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];
    
    //分割线
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(interval1, self.frame.size.height-0.5f, self.frame.size.width-2*interval1, 0.5f)];
    line.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.contentView addSubview:line];
    
}

#pragma mark 设置cell
-(void)setCell:(VoiceListModel *)vlm{
    _vlm=vlm;
    _titleLable.text=vlm.title;
     CGFloat size=[[FileOperation getId] getFileTemPathSize:_vlm.voiceUrl]/(1024*1024);
    float f=size/[vlm.size floatValue];
    _statusLable.text=[NSString stringWithFormat:@"%.2fM/%@M",size,_vlm.size];
    [_progressView setProgress:f];
    
    switch (_vlm.downloadstus) {
        case 1://正在下载
            [_iv setImage:[UIImage imageNamed:@"download_stop"]];
            _progressView.progressTintColor=UIColorFromRGB(0xe86e25);
            break;
        case 2://等待下载
             [_iv setImage:[UIImage imageNamed:@"download_wait"]];
             _progressView.progressTintColor=UIColorFromRGB(0xfab78e);
            break;
        case 3://暂停下载
             [_iv setImage:[UIImage imageNamed:@"download_start"]];
             _progressView.progressTintColor=UIColorFromRGB(0xfab78e);
            break;
        default:
            break;
    }
}

#pragma mark 更新下载进度
-(void)setProgress:(CGFloat)f{
    CGFloat size=[[FileOperation getId] getFileTemPathSize:_vlm.voiceUrl]/(1024*1024);
    _statusLable.text=[NSString stringWithFormat:@"%.2fM/%@M",size,_vlm.size];
    [_progressView setProgress:f];
}

#pragma mark 点击事件
-(void)clickBtn{
    
    switch (_vlm.downloadstus) {
        case 1://正在下载
            NSLog(@"DownLoadCell2正在下载");
            [_iv setImage:[UIImage imageNamed:@"download_start"]];
            [[DownLoadManager getId] cancelSingleDownload];
            break;
        case 2://等待下载
            NSLog(@"DownLoadCell2等待下载");
            break;
        case 3://暂停下载
        {
            NSLog(@"DownLoadCell2暂停下载");
            [_iv setImage:[UIImage imageNamed:@"download_stop"]];
            NSMutableArray *array=[NSMutableArray array];
            [array addObject:_vlm];
            [[DownLoadManager getId] addDownloadArray:array tag:1];
            
        }            
            break;
        default:
            break;
    }
}

@end
