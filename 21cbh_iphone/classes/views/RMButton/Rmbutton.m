//
//  Rmbutton.m
//  21cbh_iphone
//
//  Created by qinghua on 14-8-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "Rmbutton.h"
#import "ERoomMemberModel.h"
#import "UIImageView+WebCache.h"
#import "ERoomMemberModel.h"
#import "EFriends.h"
#import "EFriendsAndRoomsOpration.h"

#define Kinterval 3

@interface Rmbutton (){

    UIImageView *_icon;
    UILabel *_name;
    
}

@end

@implementation Rmbutton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initContent];
        [self addTapGesture];
    }
    return self;
}

-(void)initContent{
    CGSize size=self.frame.size;
    
    UIImageView *icon=[[UIImageView alloc]init];
    icon.frame=CGRectMake(12.5, 5, 50, 50);
    
    UILabel *name=[[UILabel alloc]init];
    name.frame=CGRectMake(0, 56, size.width, 20);
    name.textAlignment=NSTextAlignmentCenter;
    [name setFont:[UIFont systemFontOfSize:10]];
    
    [self addSubview:icon];
    [self addSubview:name];
    
    _icon=icon;
    _name=name;

}

-(void)addTapGesture{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userClick:)];
    tap.numberOfTapsRequired=1;
    [self addGestureRecognizer:tap];

}

-(void)setViewContentWithRomm:(ERoomMemberModel *)model{
    if ([model.roomJid isEqual:@"addFriendButton"]) {
        _icon.image=[UIImage imageNamed:@"setting_add.png"];
    }else{
        [_icon setImageWithURL:[NSURL URLWithString:model.member.iconUrl] placeholderImage:[UIImage imageNamed:@"Chat_normal"]];
    }
    if ([[EFriendsAndRoomsOpration instance]isFriend:model.member.jid]) {
        _name.text=[[EFriendsAndRoomsOpration instance]getFriendWithJid:model.member.jid].nickName;
    }else{
        _name.text=model.member.nickName;
    }
}


-(void)userClick:(UITapGestureRecognizer *)tap{
    [self.delegate rmbuttonUserClick:(Rmbutton *)tap.view];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
