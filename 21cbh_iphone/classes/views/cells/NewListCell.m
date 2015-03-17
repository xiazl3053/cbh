//
//  NewListCell.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewListCell.h"
#import "UIImageView+WebCache.h"
#import "CommonOperation.h"
#import "SDiPhoneVersion.h"
#import "UIImage+ZX.h"


#define kInterval 10//水平间隔
#define LINENUM 18//每行字数

@interface NewListCell(){
    CGRect _titleLableFrame;
}

@property(assign,nonatomic)UIImageView *imv;//cell1单张微缩图
@property(assign,nonatomic)UILabel *titileLable;//cell1标题
@property(assign,nonatomic)UILabel *infoLable1;//cell1文字说明
@property(assign,nonatomic)UILabel *commentLable;//cell1评论数
@property(assign,nonatomic)UIImageView *identify;//cell1图片标识


@property(assign,nonatomic)UIImageView *pic1;//cell2微缩图1
@property(assign,nonatomic)UIImageView *pic2;//cell2微缩图2
@property(assign,nonatomic)UIImageView *pic3;//cell2微缩图3
@property(assign,nonatomic)UILabel *titileLable2;//cell2标题
@property(assign,nonatomic)UILabel *commentLable2;//cell2评论数

@property(assign,nonatomic)UILabel *titileLable3;//cell3标题
@property(assign,nonatomic)UIImageView *identify3;//cell3图片标识
@property(assign,nonatomic)UILabel *timeLable;//cell3时间


@property(assign,nonatomic)NSInteger iphoneType;
@property(assign,nonatomic)CGFloat fontSize;

@end


@implementation NewListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=UIColorFromRGB(0xf0f0f0);
        self.contentView.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView =[[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xe1e1e1);
        self.selectionStyle=UITableViewCellSelectionStyleDefault;
        
        self.iphoneType=[SDiPhoneVersion deviceVersion];
        
        switch (self.iphoneType) {
            case iPhone6:
                self.fontSize=12;
                break;
            case iPhone6Plus:
                self.fontSize=11;
                break;
            default:
                self.fontSize=14;
                break;
        }
        
        
        // Initialization code
        if ([reuseIdentifier isEqualToString:kNewCell1]) {
            [self initCell1];
        }else if([reuseIdentifier isEqualToString:kNewCell2]){
            [self initCell2];
        }else if([reuseIdentifier isEqualToString:kNewCell3]){
            [self initCell3];
        }
        
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

#pragma mark 初始化cell1(单微缩图)
-(void)initCell1{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, 77);
    
    //图片
    UIImage *img=[UIImage imageNamed:@"newList_defaultPic1"];
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(kInterval, (self.frame.size.height-img.size.height)*0.5f, img.size.width, img.size.height)];
    [self.contentView addSubview:imageView];
    self.imv=imageView;
    
    //标题
    UILabel *titileLable=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x+imageView.frame.size.width+kInterval+5, imageView.frame.origin.y, 220, 17)];
    _titleLableFrame=titileLable.frame;
    titileLable.text=@"工行和中诚信托谁认这笔账";
    titileLable.textAlignment = NSTextAlignmentLeft;
    titileLable.backgroundColor=[UIColor clearColor];
    titileLable.textColor=UIColorFromRGB(0x808080);
    titileLable.font = [UIFont fontWithName:kFontName size:15];
    [self.contentView addSubview:titileLable];
    self.titileLable=titileLable;
    
    //标题摘要文字
    UILabel *infoLable1=[[UILabel alloc] initWithFrame:CGRectMake(titileLable.frame.origin.x, titileLable.frame.origin.y+titileLable.frame.size.height+7, self.frame.size.width-kInterval*3-imageView.frame.size.width, 37)];
    infoLable1.textAlignment = NSTextAlignmentLeft;
    infoLable1.backgroundColor=[UIColor clearColor];
    infoLable1.textColor=UIColorFromRGB(0xa1a1a1);
    infoLable1.font = [UIFont fontWithName:kFontName size:12];
    infoLable1.lineBreakMode = UILineBreakModeWordWrap;
    infoLable1.numberOfLines = 0;
    [self.contentView addSubview:infoLable1];
    self.infoLable1=infoLable1;
    
    UIImage *image=[[UIImage imageNamed:@"articleId"] scaleToSize:CGSizeMake(24, 13)];
    //评论数
    UILabel *commentLable=[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-kInterval-image.size.width-55,imageView.frame.origin.y+imageView.frame.size.height-12, 50, 15)];
    commentLable.text=@"3000评";
    commentLable.textAlignment = NSTextAlignmentRight;
    commentLable.backgroundColor=[UIColor clearColor];
    commentLable.textColor=UIColorFromRGB(0x8d8d8d);
    commentLable.font = [UIFont fontWithName:kFontName size:12];
    commentLable.lineBreakMode = UILineBreakModeWordWrap;
    commentLable.numberOfLines = 0;
    [self.contentView addSubview:commentLable];
    self.commentLable=commentLable;
    
    //图片标识
    UIImageView *identify=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-kInterval-image.size.width, imageView.frame.origin.y+imageView.frame.size.height-8, image.size.width, image.size.height)];
    [identify setImage:image];
    [self.contentView addSubview:identify];
    self.identify=identify;
    
    //分割线
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(kInterval, self.frame.size.height-0.5f, self.frame.size.width-kInterval*2, 0.5f)];
    line.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.contentView addSubview:line];
    
    
    //适配
    CGRect frame;
    switch (self.iphoneType) {
        case iPhone6:
        {
            
        }
            break;
        case iPhone6Plus:
        {
            frame=infoLable1.frame;
            frame.origin.y=frame.origin.y-3;
            infoLable1.frame=frame;
        }
            break;
        default:
        {
            
        }
            break;
    }
    
    
}

#pragma mark 初始化cell2(3张微缩图)
-(void)initCell2{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, 135);

    //标题
    UILabel *titileLable2=[[UILabel alloc] initWithFrame:CGRectMake(kInterval, 10, 230, 17)];
    titileLable2.text=@"静观世界14处最美水景";
    titileLable2.textAlignment = NSTextAlignmentLeft;
    titileLable2.backgroundColor=[UIColor clearColor];
    titileLable2.textColor=[UIColor blackColor];
    titileLable2.font = [UIFont fontWithName:kFontName size:17];
    [self.contentView addSubview:titileLable2];
    self.titileLable2=titileLable2;
    
    UIImage *image=[[UIImage imageNamed:@"picsId"] scaleToSize:CGSizeMake(24, 13)];
    //图片标识
    UIImageView *identify2=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-kInterval-image.size.width, 10, image.size.width, image.size.height)];
    [identify2 setImage:image];
    [self.contentView addSubview:identify2];
    
    //评论数
    UILabel *commentLable2=[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-kInterval-image.size.width-45,9, 40, 15)];
    commentLable2.text=@"384评";
    commentLable2.textAlignment = NSTextAlignmentRight;
    commentLable2.backgroundColor=[UIColor clearColor];
    commentLable2.textColor=UIColorFromRGB(0xa1a1a1);
    commentLable2.font = [UIFont fontWithName:kFontName size:12];
    commentLable2.lineBreakMode = UILineBreakModeWordWrap;
    commentLable2.numberOfLines = 0;
    [self.contentView addSubview:commentLable2];
    self.commentLable2=commentLable2;
    
    //三张微缩图
    UIImage *image2=[UIImage imageNamed:@"newList_defaultPic2"];
    UIImageView *pic1=[[UIImageView alloc] initWithFrame:CGRectMake(kInterval, (self.frame.size.height-image2.size.height)*0.65f, image2.size.width, image2.size.height)];
    [self.contentView addSubview:pic1];
    self.pic1=pic1;
    
    UIImageView *pic2=[[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-image2.size.width)*0.5f, (self.frame.size.height-image2.size.height)*0.65f, image2.size.width, image2.size.height)];
    [self.contentView addSubview:pic2];
    self.pic2=pic2;
    
    UIImageView *pic3=[[UIImageView alloc] initWithFrame:CGRectMake(self.width-kInterval-image2.size.width, (self.frame.size.height-image2.size.height)*0.65f, image2.size.width, image2.size.height)];
    [self.contentView addSubview:pic3];
    self.pic3=pic3;
    
    UIView *line2=[[UIView alloc] initWithFrame:CGRectMake(kInterval, self.frame.size.height-0.3f, self.frame.size.width-kInterval*2, 0.3f)];
    line2.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.contentView addSubview:line2];
}

#pragma mark 初始化cell3(没有微缩图)
-(void)initCell3{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, 85);
    //标题
    UILabel *titileLable3=[[UILabel alloc] initWithFrame:CGRectMake(kInterval, 10, size.width-2*kInterval, 32)];
    titileLable3.text=@"工行和中诚信托谁认这笔账";
    titileLable3.textAlignment = NSTextAlignmentLeft;
    titileLable3.backgroundColor=[UIColor clearColor];
    titileLable3.textColor=UIColorFromRGB(0x000000);
    titileLable3.font = [UIFont fontWithName:kFontName size:17];
    [self.contentView addSubview:titileLable3];
    _titileLable3=titileLable3;
    
    //标签
    UIImage *image=[[UIImage imageNamed:@"articleId"] scaleToSize:CGSizeMake(24, 13)];
    //图片标识
    UIImageView *identify3=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-kInterval-image.size.width, titileLable3.frame.origin.y+titileLable3.frame.size.height+10, image.size.width, image.size.height)];
    [identify3 setImage:image];
    [self.contentView addSubview:identify3];
    _identify3=identify3;
    
    //时间
    UILabel *timeLable=[[UILabel alloc] initWithFrame:CGRectMake(identify3.frame.origin.x-200-5, identify3.frame.origin.y, 200, 12)];
    timeLable.text=@"2014-02-21 00:58";
    timeLable.textAlignment = NSTextAlignmentRight;
    timeLable.backgroundColor=[UIColor clearColor];
    timeLable.textColor=UIColorFromRGB(0x8d8d8d);
    timeLable.font = [UIFont fontWithName:kFontName size:12];
    [self.contentView addSubview:timeLable];
    _timeLable=timeLable;
    
    
    //分割线
    UIView *line3=[[UIView alloc] initWithFrame:CGRectMake(kInterval, self.frame.size.height-0.5f, self.frame.size.width-kInterval*2, 0.5f)];
    line3.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.contentView addSubview:line3];
    
}




#pragma mark 设置cell1的数据
-(void)setCell1:(NewListModel *)nlm{
    if (!nlm) {
        return;
    }
    //设置标签
    NSInteger type=[[NSString stringWithFormat:@"%@",nlm.type] intValue];//类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广; 6:独家 ; 7:活动)
    self.commentLable.frame=CGRectMake(self.frame.size.width-kInterval-self.identify.frame.size.width-55,self.identify.frame.origin.y+self.identify.frame.size.height-15+1, 50, 15);
    
    self.commentLable.hidden=NO;
    switch (type) {
        case 0:
            [self.identify setImage:nil];
            self.commentLable.frame=CGRectMake(self.frame.size.width-kInterval-50,self.identify.frame.origin.y+self.identify.frame.size.height-15+1, 50, 15);
            
            break;
        case 1:
            [self.identify setImage:[UIImage imageNamed:@"articleId"]];
            break;
        case 2:
             [self.identify setImage:[UIImage imageNamed:@"specialId"]];
            break;
        case 3:
            
            break;
        case 4:
            [self.identify setImage:[UIImage imageNamed:@"videoId"]];
            break;
        case 5:
            [self.identify setImage:[UIImage imageNamed:@"adId"]];
            self.commentLable.hidden=YES;
            break;
        case 6:
            [self.identify setImage:[UIImage imageNamed:@"unique"]];
            break;
        case 7:
            [self.identify setImage:[UIImage imageNamed:@"activity"]];
            self.commentLable.hidden=YES;
            break;
        default:
            break;
    }
    
    //设置新闻列表描述
    NSString *desc=[NSString stringWithFormat:@"%@",nlm.desc];
    
    NSInteger num=0;
    switch (self.iphoneType) {
        case iPhone6:
        {
            num=27;
        }
            break;
        case iPhone6Plus:
        {
            num=30;
        }
            break;
        default:
        {
            num=23;
        }
            break;
    }
    
    if (desc.length>num) {
        desc=[[desc substringToIndex:num] stringByAppendingString:@"..."];
    }
    CGRect frame=self.infoLable1.frame;
    frame.size.height=[self calculateContentHeightFromText:desc];
    self.infoLable1.frame=frame;
    [[CommonOperation getId] setIntervalWithTextView:self.infoLable1 text:[NSString stringWithFormat:@"%@",desc] font:[UIFont fontWithName:kFontName size:_fontSize] lineSpace:2 color:UIColorFromRGB(0x000000)];
    
    //设置标题
    self.titileLable.text=[NSString stringWithFormat:@"%@",nlm.title];
    [self.dbQueue addOperationWithBlock:^{
        BOOL b=[self.nlrDB isExistNlm:nlm];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (b) {
                self.titileLable.textColor=UIColorFromRGB(0x8d8d8d);
                self.infoLable1.textColor=UIColorFromRGB(0x8d8d8d);
            }else{
                self.titileLable.textColor=UIColorFromRGB(0x000000);
                self.infoLable1.textColor=UIColorFromRGB(0x000000);
            }
        });
    }];
    
    
    
    //设置评论数
    if ([nlm.followNum isEqualToString:@"0"]) {
        self.commentLable.hidden=YES;
       
    }else{
        self.commentLable.hidden=NO;
        self.commentLable.text=[[NSString stringWithFormat:@"%@",nlm.followNum] stringByAppendingString:@"评"];
    }
    
    //异步加载图片
    __unsafe_unretained  UIImageView *imv1=self.imv;
    [self.imv setImageWithURL:[NSURL URLWithString:[nlm.picUrls objectAtIndex:0]] placeholderImage:[UIImage imageNamed:@"newList_defaultPic1"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            if (cacheType!=2) {
                imv1.alpha=0.0;
                [UIView animateWithDuration:kAnimateTime animations:^{
                    imv1.alpha=1.0;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
        
    }];
}

#pragma mark 设置cell2的数据
-(void)setCell2:(NewListModel *)nlm{
    if (!nlm) {
        return;
    }
    //设置标题
    self.titileLable2.text=nlm.title;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.dbQueue addOperationWithBlock:^{
            BOOL b=[self.nlrDB isExistNlm:nlm];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (b) {
                    self.titileLable2.textColor=UIColorFromRGB(0x8d8d8d);
                }else{
                   self.titileLable2.textColor=UIColorFromRGB(0x000000);
                }
            });       
        }];
    });
    
    //设置评论数
    if ([nlm.followNum isEqualToString:@"0"]) {
        self.commentLable2.hidden=YES;
        
    }else{
        self.commentLable2.hidden=NO;
        self.commentLable2.text=[[NSString stringWithFormat:@"%@",nlm.followNum] stringByAppendingString:@"评"];
    }
    self.commentLable2.text=[nlm.followNum stringByAppendingString:@"评"];
    if (nlm.picUrls.count<2) {
        [self.pic1 setImage:[UIImage imageNamed:@"newList_defaultPic2"]];
        [self.pic2 setImage:[UIImage imageNamed:@"newList_defaultPic2"]];
        [self.pic3 setImage:[UIImage imageNamed:@"newList_defaultPic2"]];
        return;
    }
    //异步加载图片
    __unsafe_unretained  UIImageView *imv1=self.pic1;
    [self.pic1 setImage:[UIImage imageNamed:@"newList_defaultPic2"]];
        [self.pic1 setImageWithURL:[NSURL URLWithString:[nlm.picUrls objectAtIndex:0] ] placeholderImage:[UIImage imageNamed:@"newList_defaultPic2"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    imv1.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        imv1.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
            
        }];
    
    
    __unsafe_unretained  UIImageView *imv2=self.pic2;
        [self.pic2 setImageWithURL:[NSURL URLWithString:[nlm.picUrls objectAtIndex:1] ] placeholderImage:[UIImage imageNamed:@"newList_defaultPic2"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    imv2.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        imv2.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
            
        }];
    
     __unsafe_unretained  UIImageView *imv3=self.pic3;
        [self.pic3 setImageWithURL:[NSURL URLWithString:[nlm.picUrls objectAtIndex:2] ] placeholderImage:[UIImage imageNamed:@"newList_defaultPic2"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    imv3.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        imv3.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
            
        }];
    
}

#pragma mark 设置cell3的数据
-(void)setCell3:(NewListModel *)nlm{
    if (!nlm) {
        return;
    }
    //设置标签
    NSInteger type=[nlm.type intValue];//类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广; 6:独家 ; 7:活动)
    self.timeLable.frame=CGRectMake(_identify3.frame.origin.x-200-5, _identify3.frame.origin.y, 200, 12);
    switch (type) {
        case 0:
            [self.identify3 setImage:nil];
           self.timeLable.frame=CGRectMake(self.frame.size.width-kInterval-200, _identify3.frame.origin.y, 200, 12);
            
            break;
        case 1:
            [self.identify3 setImage:[UIImage imageNamed:@"articleId"]];
            break;
        case 2:
            [self.identify3 setImage:[UIImage imageNamed:@"specialId"]];
            break;
        case 3:
            
            break;
        case 4:
            [self.identify3 setImage:[UIImage imageNamed:@"videoId"]];
            break;
        case 5:
            [self.identify3 setImage:[UIImage imageNamed:@"adId"]];
            break;
        case 6:
            [self.identify3 setImage:[UIImage imageNamed:@"unique"]];
            break;
        case 7:
            [self.identify3 setImage:[UIImage imageNamed:@"activity"]];
            break;
        default:
            break;
    }
    _titileLable3.text=nlm.title;
    _timeLable.text=[[CommonOperation getId] addtimeTurnToTimeString:nlm.addtime];
}




#pragma mark 主内容的高度
-(CGFloat )calculateContentHeightFromText:(NSString *)str{
    CGSize size = [str sizeWithFont:[UIFont fontWithName:kFontName size:14] constrainedToSize:CGSizeMake(self.frame.size.width-kInterval*3-self.imv.frame.size.width,MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat height=size.height+(size.height/14)*2;
    
    return height;
    
}

@end
