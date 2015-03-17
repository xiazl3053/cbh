//
//  PicsListCell.m
//  21cbh_iphone
//
//  Created by 周晓 on 14-2-25.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "PicsListCell.h"
#import "UIImageView+WebCache.h"

#define kPicsListCellinterval 20

@interface PicsListCell(){
    UIImageView *_iv1;
    UIImageView *_iv2;
    UIImageView *_iv3;
    UIImageView *_iv4;
    UIImageView *_iv5;
    UIImageView *_iv6;
    UIImageView *_iv7;
    
    UILabel *_desc;
    UILabel *_followNum;
}

@end

@implementation PicsListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        self.contentView.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView =[[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = UIColorFromRGB(0x252525);
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        if ([reuseIdentifier isEqualToString:kPicCell1]) {
            [self initCell1];
        }else if([reuseIdentifier isEqualToString:kPicCell2]){
            [self initCell2];
        }else if([reuseIdentifier isEqualToString:kPicCell3]){
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

#pragma mark 底部栏
-(void)initBottom{
    
    UIView *bottom=[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-27-kPicsListCellinterval, self.frame.size.width, 27)];
    bottom.backgroundColor=[UIColor blackColor];
    bottom.alpha=0.45f;
    [self.contentView addSubview:bottom];
    
    UILabel *desc=[[UILabel alloc] initWithFrame:CGRectMake(13, bottom.frame.origin.y, 250, bottom.frame.size.height)];
    desc.textColor=[UIColor whiteColor];
    desc.textAlignment=NSTextAlignmentLeft;
    desc.backgroundColor=[UIColor clearColor];
    desc.font=[UIFont fontWithName:kFontName size:13];
    [self.contentView addSubview:desc];
    _desc=desc;
    
    UILabel *followNum=[[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-13-50, bottom.frame.origin.y, 60, bottom.frame.size.height)];
    followNum.textColor=[UIColor whiteColor];
    followNum.textAlignment=NSTextAlignmentRight;
    followNum.font=[UIFont fontWithName:kFontName size:13];
    followNum.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:followNum];
    _followNum=followNum;
}



#pragma mark 初始化cell1(大微缩图)
-(void)initCell1{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, 159+kPicsListCellinterval);
    
    UIImageView *iv1=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-kPicsListCellinterval)];
    [self.contentView addSubview:iv1];
    _iv1=iv1;
    
    [self initBottom];
}

#pragma mark 初始化cell2(大小小微缩图)
-(void)initCell2{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, 159+kPicsListCellinterval);
    
    UIImageView *iv2=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 207, 159)];
    [self.contentView addSubview:iv2];
    _iv2=iv2;
    
    UIImageView *iv3=[[UIImageView alloc] initWithFrame:CGRectMake(iv2.frame.size.width+1, 0, 112, 78.5)];
    [self.contentView addSubview:iv3];
    _iv3=iv3;
    
    UIImageView *iv4=[[UIImageView alloc] initWithFrame:CGRectMake(iv3.frame.origin.x, iv3.frame.origin.y+iv3.frame.size.height+1, 112, 78.5)];
    [self.contentView addSubview:iv4];
    _iv4=iv4;
    
    
    [self initBottom];
}

#pragma mark 初始化cell3(小小大微缩图)
-(void)initCell3{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize size = [MainScreen bounds].size;
    self.frame=CGRectMake(0, 0, size.width, 159+kPicsListCellinterval);
    
    UIImageView *iv5=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 112, 78.5)];
    [self.contentView addSubview:iv5];
    _iv5=iv5;
    
    
    UIImageView *iv6=[[UIImageView alloc] initWithFrame:CGRectMake(0, iv5.frame.origin.y+iv5.frame.size.height+1, 112, 78.5)];
    [self.contentView addSubview:iv6];
    _iv6=iv6;
    
    UIImageView *iv7=[[UIImageView alloc] initWithFrame:CGRectMake(iv5.frame.size.width+1, 0, 207, 159)];
    [self.contentView addSubview:iv7];
    _iv7=iv7;
    
    [self initBottom];
}



#pragma mark 设置cell1的数据(大微缩图)
-(void)setCell1:(PicsListModel *)plm{
    _desc.text=plm.title;
    
    //设置评论数
    if ([plm.followNum isEqualToString:@"0"]) {
        _followNum.hidden=YES;
        
    }else{
        _followNum.hidden=NO;
        _followNum.text=[NSString stringWithFormat:@"%@评",plm.followNum];
    }
    
    
    if (plm.picUrls.count<1) {
        [_iv1 setImage:[UIImage imageNamed:@"picture_large"]];
        return;
    }
    
    @try {
        __unsafe_unretained UIImageView *iv1=_iv1;

        
        [_iv1 setImageWithURL:[plm.picUrls objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picture_large"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    iv1.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        iv1.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

    
}

#pragma mark 设置cell2的数据(大小小微缩图)
-(void)setCell2:(PicsListModel *)plm{
    _desc.text=plm.title;
    //设置评论数
    if ([plm.followNum isEqualToString:@"0"]) {
        _followNum.hidden=YES;
        
    }else{
        _followNum.hidden=NO;
        _followNum.text=[NSString stringWithFormat:@"%@评",plm.followNum];
    }
    
    if (plm.picUrls.count<2) {
        [_iv2 setImage:[UIImage imageNamed:@"picture_middle"]];
        [_iv3 setImage:[UIImage imageNamed:@"picture_small"]];
        [_iv4 setImage:[UIImage imageNamed:@"picture_small"]];
        return;
    }
    
    __unsafe_unretained UIImageView *iv2=_iv2;
        [_iv2 setImageWithURL:[plm.picUrls objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picture_middle"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    iv2.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        iv2.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }];
    
    
    
    
    __unsafe_unretained UIImageView *iv3=_iv3;
        [_iv3 setImageWithURL:[plm.picUrls objectAtIndex:1] placeholderImage:[UIImage imageNamed:@"picture_small"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    iv3.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        iv3.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }];
    
    
    __unsafe_unretained UIImageView *iv4=_iv4;
        [_iv4 setImageWithURL:[plm.picUrls objectAtIndex:2] placeholderImage:[UIImage imageNamed:@"picture_small"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    iv4.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        iv4.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }];
    
}


#pragma mark 设置cell3的数据(小小大微缩图)
-(void)setCell3:(PicsListModel *)plm{
    
    _desc.text=plm.title;
    //设置评论数
    if ([plm.followNum isEqualToString:@"0"]) {
        _followNum.hidden=YES;
        
    }else{
        _followNum.hidden=NO;
        _followNum.text=[NSString stringWithFormat:@"%@评",plm.followNum];
    }

    
    if (plm.picUrls.count<2) {
        [_iv5 setImage:[UIImage imageNamed:@"picture_small"]];
        [_iv6 setImage:[UIImage imageNamed:@"picture_small"]];
        [_iv7 setImage:[UIImage imageNamed:@"picture_middle"]];
        return;
    }
    
    __unsafe_unretained UIImageView *iv5=_iv5;
        [_iv5 setImageWithURL:[plm.picUrls objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picture_small"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    iv5.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        iv5.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }];
    
    
    
    
    __unsafe_unretained UIImageView *iv6=_iv6;
        [_iv6 setImageWithURL:[plm.picUrls objectAtIndex:1] placeholderImage:[UIImage imageNamed:@"picture_small"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    iv6.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        iv6.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }];
    
    
    
    __unsafe_unretained UIImageView *iv7=_iv7;
        [_iv7 setImageWithURL:[plm.picUrls objectAtIndex:2] placeholderImage:[UIImage imageNamed:@"picture_middle"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                if (cacheType!=2) {
                    iv7.alpha=0.0;
                    [UIView animateWithDuration:kAnimateTime animations:^{
                        iv7.alpha=1.0;
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }];
    
}

@end
