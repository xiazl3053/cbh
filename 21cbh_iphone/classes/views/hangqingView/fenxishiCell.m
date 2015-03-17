//
//  fenxishiCell.m
//  21cbh_iphone
//
//  Created by 21tech on 14-3-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//
#import <objc/runtime.h>
#import "fenxishiCell.h"
#import "basehqCell.h"
#import "changeListModel.h"
#import "FMTextView.h"
#import "analystListModel.h"
#import "kFenXiShiViewController.h"
#import "kFenXiShiDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "FileOperation.h"

#define kCellBackgound UIColorFromRGB(0x000000)
#define kSmallFont [UIFont fontWithName:kFontName size:14]
#define kBigFont [UIFont fontWithName:kFontName size:18]
#define kBoldFont [UIFont fontWithName:kFontName size:18]

@interface fenxishiCell(){
    
    FileOperation *_fo;// 文件操作
}

@end
@implementation fenxishiCell

-(void)dealloc{
    self.data = nil;
    cellView = nil;
    _fo = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.font = kDefaultFont;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = ClearColor;
//        UIView *selectView = [[UIView alloc] initWithFrame:self.frame];
//        selectView.backgroundColor = UIColorFromRGB(0x333333);
//        self.selectedBackgroundView = selectView;
        cellView = [[UIView alloc] initWithFrame:self.frame];
        cellView.backgroundColor = ClearColor;
        [self addSubview:cellView];
        _fo = [[FileOperation alloc] init];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark ---------------------------------自定义方法------------------------------------

-(void)updateCell{
    if (self.data) {
        // 更新内容
        [self updateCellTitle:cellView andModle:self.data];
    }
}

-(void)show{
    // 添加自定义视图
    [self addTitleView:cellView];
}

#pragma mark 自定义Cell内容
-(void)addTitleView:(UIView*)superView{
    // 标题 0
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, self.frame.size.width-20, 60)];
    title.font = kBigFont;
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = UIColorFromRGB(0xe86e25);
    title.backgroundColor = ClearColor;
    title.text = @"";
    title.numberOfLines = 2;
    [superView addSubview:title];
    
    // pdf文档名称 1
    UILabel *pdf = [[UILabel alloc] initWithFrame:CGRectMake(13, 45, self.frame.size.width-13, 30)];
    pdf.font = kSmallFont;
    pdf.textAlignment = NSTextAlignmentLeft;
    pdf.backgroundColor = ClearColor;
    pdf.text = @"";
    pdf.textColor = UIColorFromRGB(0x808080);
    [superView addSubview:pdf];
    
    // 添加标题描述
    [self addTwoColumn:superView];
    // 添加核心观点按钮
    UIView *lView = (UIView*)[[superView subviews] lastObject]; // 最后一个视图
    UILabel *hx = [[UILabel alloc] initWithFrame:CGRectMake(10,lView.frame.origin.y+lView.frame.size.height+10, 70, 25)];
    hx.backgroundColor = ClearColor;
    hx.textColor = UIColorFromRGB(0x808080);
    hx.text = @"核心观点";
    hx.textAlignment = NSTextAlignmentCenter;
    hx.font = [UIFont fontWithName:kFontName size:16];
    [superView addSubview:hx];

//    UIImage *image = [UIImage imageNamed:@"D_hxgd.png"];
//    UIImageView *hx = [[UIImageView alloc] initWithImage:image];
//    hx.frame = CGRectMake(13,lView.frame.origin.y+lView.frame.size.height+10,image.size.width, image.size.height);
//    [superView addSubview:hx];
    // 添加内容
    FMTextView *_info = [[FMTextView alloc] initWithFrame:CGRectMake(7, hx.frame.size.height+hx.frame.origin.y, superView.frame.size.width-7*2, 133)];
    if (kDeviceVersion<7) {
        _info.frame = CGRectMake(_info.frame.origin.x, _info.frame.origin.y, _info.frame.size.width, 130);
    }
    _info.textColor = UIColorFromRGB(0xffffff);
    [superView addSubview:_info];
    
    // 添加阅读量
    UILabel *readCount = [[UILabel alloc] initWithFrame:CGRectMake(0, hx.frame.origin.y, self.frame.size.width-20, hx.frame.size.height)];
    readCount.backgroundColor = ClearColor;
    readCount.text = @"阅读";
    readCount.textColor = UIColorFromRGB(0x808080);
    readCount.font = [UIFont fontWithName:kFontName size:14];
    readCount.textAlignment = NSTextAlignmentRight;
    [superView addSubview:readCount];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:@"D_DownLoadReporter@2x" ofType:@"png"];
    UIImage *imageSize=[UIImage imageWithContentsOfFile:path];
    
    // 添加下载按钮
    UIImage *D_DownLoadReporter = [UIImage imageNamed:@"D_DownLoadReporter.png"];
    UIImage *D_DownLoadReporterHover = [UIImage imageNamed:@"D_DownLoadReporterHover.png"];
    UIButton *downButton = [[UIButton alloc] initWithFrame:CGRectMake(220,
                                                                     _info.frame.origin.y+_info.frame.size.height+5,
                                                                     imageSize.size.width, imageSize.size.height)];
    [downButton setImage:D_DownLoadReporter forState:UIControlStateNormal];
    [downButton setImage:D_DownLoadReporterHover forState:UIControlStateSelected];
    [downButton addTarget:self action:@selector(clickDownButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    downButton.tag = 100;
    [self addSubview:downButton];
    
    NSString *path1=[[NSBundle mainBundle]pathForResource:@"D_SeeDetails@2x" ofType:@"png"];
    UIImage *imageSize1=[UIImage imageWithContentsOfFile:path1];
    
    // 查看详情按钮
    UIImage *D_SeeDetails = [UIImage imageNamed:@"D_SeeDetails.png"];
    UIImage *D_SeeDetailsHover = [UIImage imageNamed:@"D_SeeDetailsHover.png"];
    UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(230+D_DownLoadReporter.size.width+20,
                                                                      _info.frame.origin.y+_info.frame.size.height+5,
                                                                      imageSize1.size.width, imageSize1.size.height)];
    [detailButton setImage:D_SeeDetails forState:UIControlStateNormal];
    [detailButton setImage:D_SeeDetailsHover forState:UIControlStateSelected];
    [detailButton addTarget:self action:@selector(clickDettailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:detailButton];
    
    // 线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(13, hx.frame.size.height+hx.frame.origin.y, self.frame.size.width-26, 0.5)];
    line.backgroundColor = UIColorFromRGB(0x808080);
    [superView addSubview:line];
    line = nil;
    hx = nil;
    
    title = nil;
    pdf = nil;
    readCount = nil;
    _info = nil;
}

#pragma mark 添加两列名称
-(void)addTwoColumn:(UIView*)superView{
    CGFloat x = 13;
    CGFloat y = superView.frame.size.height+superView.frame.origin.y + 30;
    CGFloat width = (superView.frame.size.width-40)/2;
    CGFloat height = 25;
    NSArray *titles = [[NSArray alloc] initWithObjects:@"报告来源:",@"报告作者:",@"所属领域:",@"评级调整:",@"撰写时间:",@"评级:",@"目标价:", nil];
    // 循环添加子标签
    for (int i=0; i<titles.count; i++) {
        if (i==5) {
            y +=height;
        }
        // 添加名称
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, y+4, 60, height)];
        l.text = [titles objectAtIndex:i];
        l.textAlignment = NSTextAlignmentLeft;
        l.font = [UIFont fontWithName:kFontName size:14];
        l.textColor = UIColorFromRGB(0x808080);
        l.backgroundColor = ClearColor;
        [l sizeToFit];
        [superView addSubview:l];
        // 添加对应的数值
        UILabel *v = [[UILabel alloc] initWithFrame:CGRectMake(l.frame.size.width+l.frame.origin.x+3, y, i==1?(self.frame.size.width-l.frame.size.width):width-50, height)];
        v.textAlignment = NSTextAlignmentLeft;
        v.text = @"";
        v.textColor = UIColorFromRGB(0x000000);
        v.font = [UIFont fontWithName:kFontName size:14];
        v.backgroundColor = ClearColor;
        
        [superView addSubview:v];
        y +=height; // y轴自增
        // x轴变换
        if (i==3) {
            x += width+15;
            y = superView.frame.size.height+superView.frame.origin.y + 30;
        }
        l = nil;
        v = nil;
    }
}
#pragma mark 点击下载按钮事件
-(void)clickDownButtonAction:(UIButton*)button{
    NSLog(@"---DFM---点击下载");
    analystListModel *mo = (analystListModel*)self.data;
    UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-2, button.frame.size.width, 2)];
    // 下载数据
    [self downLoad:mo.pdf andProgress:progress andButton:button];
    [button addSubview:progress];
    progress = nil;
    mo = nil;
}
#pragma mark 点击查看详情按钮
-(void)clickDettailButtonAction:(UIButton*)button{
    if (self.controller) {
        // 控制器
        kFenXiShiViewController *fenxishi = (kFenXiShiViewController*)self.controller;
        // 模型
        analystListModel *m = (analystListModel*)self.data;
        kFenXiShiDetailViewController *detail = [[kFenXiShiDetailViewController alloc] init];
        detail.title = m.title;
        NSString *pdf = [self getLocalPDFWithUrl:m.pdf];
        if (![self isExitWithPDF:pdf]) {
            pdf = m.pdf;
        }
        detail.pdf = pdf;
        m = nil;
        // 推出视图
        fenxishi.kLineView.isBack = YES; // 设置为返回状态
        [fenxishi.kLineView.navigationController pushViewController:detail animated:YES];
        detail = nil;
        fenxishi = nil;
        NSLog(@"---DFM---查看详情");
    }
}
#pragma mark 根据模型更新cell的标题内容
-(void)updateCellTitle:(UIView*)superView andModle:(id)model{
    analystListModel *mo = (analystListModel*)model;
    NSString *pdf = mo.pdf;
    if ([pdf rangeOfString:@"http://"].length>0) {
        NSArray *tmp = [pdf componentsSeparatedByString:@"/"];
        pdf = [tmp lastObject];
    }
    // 标题
    [self setLabelTitle:mo.title withIndex:0];
    // pdf
    [self setLabelTitle:pdf withIndex:1];
    // 报告来源
    [self setLabelTitle:mo.comeFrom withIndex:3];
    // 报告作者
    [self setLabelTitle:mo.author withIndex:5];
    // 所属领域
    [self setLabelTitle:mo.area withIndex:7];
    // 评级调整
    [self setLabelTitle:mo.levelChange withIndex:9];
    // 撰写时间
    [self setLabelTitle:mo.date withIndex:11];
    // 评级
    [self setLabelTitle:mo.level withIndex:13];
    // 目标价
    [self setLabelTitle:mo.targetPrice withIndex:15];
    // 阅读量
    [self setLabelTitle:[[NSString alloc] initWithFormat:@"%@阅读",mo.hits] withIndex:18];
    // 如果pdf已缓存，按钮变色
    if ([self isExitWithPDF:[self getLocalPDFWithUrl:mo.pdf]]) {
        // 下载按钮
        UIButton *button = (UIButton*)[self viewWithTag:100];
        [button setImage:[UIImage imageNamed:@"D_DownLoadReporterHover.png"] forState:UIControlStateNormal];
        button = nil;
    }
    FMTextView *_info = (FMTextView*)[cellView.subviews objectAtIndex:17];
    if ([_info.text isEqualToString:@""]) {
        // 核心观点
        _info.backgroundColor = ClearColor;
        _info.lineHeight = 5;
        _info.font = [UIFont fontWithName:kFontName size:16];
        int nums = _info.frame.size.width / 10 * 4;
        NSString *text = mo.content;
        if (text.length>nums) {
            text = [text substringWithRange:NSMakeRange(0, nums)];
            text = [[NSString alloc] initWithFormat:@"%@...",text];
        }
        NSLog(@"---DFm---cell文字：%@",text);
        _info.text = text;
        _info.textColor = UIColorFromRGB(0x000000);
        _info = nil;
    }
    
    model = nil;
}

-(void)setLabelTitle:(NSString*)title withIndex:(int)index{
    if (index<cellView.subviews.count) {
        UILabel *l = (UILabel*)[cellView.subviews objectAtIndex:index];
        l.text = title;
        //l.lineBreakMode = NSLineBreakByClipping;
        l = nil;
    }
    
}
#pragma mark 下载文件
-(void)downLoad:(NSString*)urlstr andProgress:(UIProgressView*)progress andButton:(UIButton*)button{
    
    // 网络下载地址
    NSURL *url = [NSURL URLWithString:urlstr];
    // 请求
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    // 本地缓存地址
    NSString *path = [self getLocalPDFWithUrl:urlstr];
    // 下载目的路径
    [request setDownloadDestinationPath :path];
    // 下载进度条
    [request setDownloadProgressDelegate:progress];
    __block UIProgressView *ProgressView = progress;
    //请求成功
    [request setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"---DFM---下载成功==%@",path);
            [button setImage:[UIImage imageNamed:@"D_DownLoadReporterHover.png"] forState:UIControlStateNormal];
            [ProgressView removeFromSuperview];
            ProgressView = nil;
        });
    }];
    //请求失败
    [request setFailedBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"---DFM---下载失败");
            [ProgressView removeFromSuperview];
            ProgressView = nil;
        });
    }];
    
    
    // 开始异步下载
    [request startAsynchronous];
}
#pragma mark 获取本地PDF缓存地址
-(NSString*)getLocalPDFWithUrl:(NSString*)urlstr{
    NSString *pdf = urlstr;
    if ([pdf rangeOfString:@"http://"].length>0) {
        NSArray *tmp = [pdf componentsSeparatedByString:@"/"];
        pdf = [tmp lastObject];
    }
    // 放到用户沙盒 Library 缓存
    NSString * path= [_fo getFileDirWithFileDirName:@"PDF"];
    // 取最后的文件名
    path = [path stringByAppendingString:[[NSString alloc] initWithFormat:@"/%@",pdf]];
    return path;
}
#pragma mark 本地PDF是否存在
-(BOOL)isExitWithPDF:(NSString*)pdf{
    NSFileManager *fileManage = [[NSFileManager alloc] init];
    if ([fileManage fileExistsAtPath:pdf]) {
        fileManage = nil;
        return YES;
    }else{
        fileManage = nil;
        return NO;
    }

}

@end
