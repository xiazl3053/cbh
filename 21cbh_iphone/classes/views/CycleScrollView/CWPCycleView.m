//
//  CWPCycleView.m
//  21cbh_iphone
//
//  Created by Franky on 14-4-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CWPCycleView.h"
#import "UIImageView+WebCache.h"
#import "CommonOperation.h"

@interface CWPCycleView()
{
    //头图的图片视图
    UIImageView *imageView;
    UILabel *titleLabel;
    UILabel* timeLabel;
    //标识
    UIImageView* iconImageview;
}

@end

@implementation CWPCycleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //头图的图片视图
        imageView=[[UIImageView alloc] initWithFrame:CGRectMake(158, 10, 142, 80)];
        imageView.clipsToBounds=YES;
        imageView.tag=2000;
        imageView.contentMode=UIViewContentModeScaleToFill;
        [self addSubview:imageView];
        
        //标题文字
        titleLabel=[[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.textColor=UIColorFromRGB(0x000000);
        titleLabel.font = [UIFont fontWithName:kFontName size:14];
        titleLabel.numberOfLines=0;
        titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
        [self addSubview:titleLabel];
        
        //时间文字
        timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 75, 120, 20)];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.backgroundColor=[UIColor clearColor];
        timeLabel.textColor=UIColorFromRGB(0x8d8d8d);
        timeLabel.font = [UIFont fontWithName:kFontName size:10];
        [self addSubview:timeLabel];
        
        //标识
        iconImageview=[[UIImageView alloc] initWithFrame:CGRectMake(130-8, 78, 24, 13)];
        [self addSubview:iconImageview];
        
        UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-0.5f, self.frame.size.width, 0.5f)];
        line.backgroundColor=UIColorFromRGB(0x808080);
        [self addSubview:line];
    }
    return self;
}

-(void)fillDataWithModel:(TopPicModel *)model
{
    titleLabel.frame=CGRectMake(20, 25, 140-5, 60);
    
    [[CommonOperation getId] setIntervalWithTextView:titleLabel text:[NSString stringWithFormat:@"%@",model.desc] font:[UIFont fontWithName:kFontName size:14] lineSpace:2 color:UIColorFromRGB(0x000000)];
    [titleLabel sizeToFit];
    
    
    NSString* time=[[CommonOperation getId]addtimeTurnToTimeString2:model.addtime];
    timeLabel.text=time;
    NSInteger type=[model.type intValue];//类型(0:普通文章; 1:原创文章; 2:专题; 3:图集 4:视频; 5:推广; 6:独家 ; 7:活动)
    switch (type) {
        case 0:
            [iconImageview setImage:nil];
            break;
        case 1:
            [iconImageview setImage:[UIImage imageNamed:@"articleId"]];
            break;
        case 2:
            [iconImageview setImage:[UIImage imageNamed:@"specialId"]];
            break;
        case 3:
            [iconImageview setImage:[UIImage imageNamed:@"picsId"]];
            break;
        case 4:
            [iconImageview setImage:[UIImage imageNamed:@"videoId"]];
            break;
        case 5:
            [iconImageview setImage:[UIImage imageNamed:@"adId"]];
            break;
        case 6:
            [iconImageview setImage:[UIImage imageNamed:@"unique"]];
            break;
        case 7:
            [iconImageview setImage:[UIImage imageNamed:@"activity"]];
            break;
        default:
            break;
    }
    
    //__unsafe_unretained  UIImageView *imageView1=imageView;
    [imageView setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:[UIImage imageNamed:@"top_default_new"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        if (image) {
//            if (cacheType!=2) {
//                imageView1.alpha=0.0;
//                [UIView animateWithDuration:kAnimateTime animations:^{
//                    imageView1.alpha=1.0;
//                } completion:^(BOOL finished) {
//                    
//                }];
//            }
//        }
    }];
}

-(void)cleanData
{
    imageView.image=nil;
    iconImageview.image=nil;
}

@end
