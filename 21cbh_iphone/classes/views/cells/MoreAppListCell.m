//
//  MoreAppListCell.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "MoreAppListCell.h"
#import "MoreAppModel.h"
#import "UIImageView+WebCache.h"
#import "NCMConstant.h"

#define kLeftMargin 15
#define kTopMagrin 5
#define kIconWidth 50
#define kTitleWidth 200
#define kTitleHeight 30
#define kBtnWidht 20
#define kBtnHeight 20
#define kSpace 5
#define kCellHeight 70

@interface MoreAppListCell(){

    UIImageView *_icon;
    UILabel *_title;
    UILabel *_desc;
    UIButton *_btn;

}

@end

@implementation MoreAppListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCell];
        [self initStyle];
    }
    return self;
}


-(void)initCell{
    //icon
    UIImageView *icon=[[UIImageView alloc]init];
    icon.layer.masksToBounds=YES;
    icon.layer.cornerRadius=10.0;
    icon.frame=CGRectMake(kLeftMargin, (kCellHeight-kIconWidth)*.5, kIconWidth, kIconWidth);
    [self.contentView addSubview:icon];
    _icon=icon;
    
    //title
    UILabel *title=[[UILabel alloc]init];
    title.frame=CGRectMake(kLeftMargin*2+kIconWidth, 2*kTopMagrin, kTitleWidth, kTitleHeight);
    [title setFont:[UIFont fontWithName:kFontName size:KMoreAppCellTitleFontSize]];
    [title setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:title];
    _title=title;
    
    //desc
    UILabel *desc=[[UILabel alloc]init];
    desc.frame=CGRectMake(kLeftMargin*2+kIconWidth, title.bottom-kTopMagrin*2, kTitleWidth, kTitleHeight);
    [self.contentView addSubview:desc];
    [desc setFont:[UIFont fontWithName:kFontName size:KMoreAppCellDescFontSize]];
    [desc setBackgroundColor:[UIColor clearColor]];
    _desc=desc;
    
    //
    UIButton *down=[[UIButton alloc]init];
    down.frame=CGRectMake(self.frame.size.width-kLeftMargin-kBtnWidht, (kCellHeight-kBtnHeight)*.5, kBtnWidht, kBtnHeight);
    down.userInteractionEnabled=NO;
    [self.contentView addSubview:down];
    _btn=down;
    
    //sepeator
    UIView *separator=[[UIView alloc]initWithFrame:CGRectMake(0, icon.bottom+kSpace+2, 320, 1)];
    separator.backgroundColor=UIColorFromRGB(0Xcccccc);
    [self.contentView addSubview:separator];
    
    
}

-(void)initStyle{
    
    switch (KAppStyle) {
        case APPSTYLE_TYPE_WHITE:{
            [_title setTextColor:UIColorFromRGB(0X000000)];
            [_desc setTextColor:UIColorFromRGB(0X8d8d8d)];
        }break;
        case APPSTYLE_TYPE_BLACK:{
            [_title setTextColor:UIColorFromRGB(0Xffffff)];
            [_desc setTextColor:UIColorFromRGB(0X808080)];
            self.backgroundColor=[UIColor blackColor];
        }break;
            
        default:
            break;
    }

}


-(void)setCellValue:(MoreAppModel *)model{
    self.frame=CGRectMake(0, 0, 320, kCellHeight);
    [_icon setImageWithURL:[NSURL URLWithString:model.iconUrl] placeholderImage:[UIImage imageNamed:@"settings_head"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
    }];
    [_title setText:model.title];
    [_desc setText:model.desc];
    BOOL isOpen=[[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:model.scheme]];
    if (isOpen) {
        [_btn setBackgroundImage:[UIImage imageNamed:@"MoreApp_Open_Normal.png"] forState:UIControlStateNormal];
        //[_btn setBackgroundImage:[UIImage imageNamed:@"MoreApp_Open_Select.png"] forState:UIControlStateSelected];
        
    }else{
        [_btn setBackgroundImage:[UIImage imageNamed:@"MoreApp_DownLoad_Normal.png"] forState:UIControlStateNormal];
       // [_btn setBackgroundImage:[UIImage imageNamed:@"MoreApp_DownLoad_Select.png"] forState:UIControlStateSelected];
    }
//    UIView *view=[[UIView alloc]init];
//    view.backgroundColor=UIColorFromRGB(0x252525);
//    self.selectedBackgroundView=view;
}

-(void)dealloc{
    _icon=nil;
    _title=nil;
    _desc=nil;
    _btn=nil;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
