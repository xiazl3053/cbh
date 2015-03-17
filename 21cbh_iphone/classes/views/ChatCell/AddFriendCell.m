//
//  AddFriendCell.m
//  21cbh_iphone
//
//  Created by qinghua on 14-7-2.
//  Copyright (c) 2014年 ZX. All rights reserved.
//




#import "AddFriendCell.h"

#define KMargin 10


@interface AddFriendCell (){

    UIImageView *_img;
    UILabel *_title;

}



@end

@implementation AddFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initCell];
    }
    return self;
}


-(void)initCell{
    
    UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(KMargin, KMargin, 20, 20)];
    [self.contentView addSubview:img];
    _img=img;
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(img.right+KMargin, KMargin, 200, 20)];
    title.font=[UIFont fontWithName:kFontName size:15.0];
    title.textColor=UIColorFromRGB(0x000000);
    [self.contentView addSubview:title];
    _title=title;
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, self.contentView.bottom-1.5, 320, 0.5)];
    line.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.contentView addSubview:line];
    
    self.backgroundColor=UIColorFromRGB(0xffffff);

}

-(void)setCellValue:(NSString *)imgName andtitle:(NSString *)title{
    _img.image=[UIImage imageNamed:imgName];
    _title.text=title;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
