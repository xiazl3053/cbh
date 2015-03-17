//
//  CreateSessionCell.m
//  21cbh_iphone
//
//  Created by qinghua on 14-6-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CreateSessionCell.h"
#import "EFriends.h"
#import "UIImageView+WebCache.h"

#define KMargin 5

@interface CreateSessionCell (){

    UILabel *_name;
    UIImageView *_imgView;
    UIImageView *_icon;

}

@end

@implementation CreateSessionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initCell];
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}


-(void)initCell{
    
    //icon
    UIImageView *icon=[[UIImageView alloc]initWithFrame:CGRectMake(10, KMargin*2, 40, 40)];
    //icon.image=[UIImage imageNamed:@"createsession_icon_normal.png"];
    icon.image=[UIImage imageNamed:@"Chat_normal"];
    [self.contentView addSubview:icon];
    _icon=icon;
    
    //name
    UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(60, 10, 200, 20)];
    name.textColor=[UIColor blackColor];
    [self.contentView addSubview:name];
    _name=name;

    //status
    UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(260, KMargin*2, 25, 25)];
    imgView.image=[UIImage imageNamed:@"createsession_deselect_friends.png"];
    [self.contentView addSubview:imgView];
    _imgView=imgView;
    
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(0, self.bottom+KMargin*3, 320, 0.5)];
    line.backgroundColor=UIColorFromRGB(0xe1e1e1);
    [self.contentView addSubview:line];
    
    self.contentView.backgroundColor=[UIColor clearColor];

    
}

-(void)setCellValue:(EFriends *)friend{
    _name.text=friend.nickName;
    
    switch (friend.isSelect) {
        case EFriends_SELECT_STATUS_NO:
        {
            _imgView.image=[UIImage imageNamed:@"createsession_deselect_friends.png"];
        } break;
        case EFriends_SELECT_STATUS_YES:{
            _imgView.image=[UIImage imageNamed:@"createsession_select_friends.png"];
        }break;
        case EFriends_SELECT_STATUS_DISABLED:{
            _imgView.image=[UIImage imageNamed:@"createsession_unselect_friends.png"];
        }break;
        default:
            break;
    }
    
    [_icon setImageWithURL:[NSURL URLWithString:friend.iconUrl] placeholderImage:[UIImage imageNamed:@"Chat_normal"]];
    
    
//    if (friend.isSelect) {
//        _imgView.image=[UIImage imageNamed:@"createsession_select_friends.png"];
//    }else{
//        _imgView.image=[UIImage imageNamed:@"createsession_deselect_friends.png"];
//    }


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
