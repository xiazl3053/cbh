//
//  NewsContentView.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-3.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "NewsContentView.h"
#import "UIImageView+WebCache.h"

@implementation NewsContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        self.backgroundColor=UIColorFromRGB(0xf0f0f0);
        self.userInteractionEnabled=NO;
        
        titleLabel_=[[UILabel alloc]initWithFrame:CGRectMake(5, 0, frame.size.width-10, 40)];
        titleLabel_.lineBreakMode=NSLineBreakByWordWrapping;
        titleLabel_.numberOfLines=2;
        titleLabel_.textAlignment = NSTextAlignmentLeft;
        titleLabel_.font=[UIFont systemFontOfSize:17];
        titleLabel_.textColor=[UIColor blackColor];
        titleLabel_.backgroundColor=[UIColor clearColor];
        [self addSubview:titleLabel_];
        
        logoImg_=[[UIImageView alloc]initWithFrame:CGRectMake(5, 45, 70, 55)];
        [self addSubview:logoImg_];
        
        descLabel_=[[UILabel alloc]initWithFrame:CGRectMake(80, 40, frame.size.width-10-65, 60)];
        descLabel_.numberOfLines=4;
        descLabel_.lineBreakMode=NSLineBreakByWordWrapping|NSLineBreakByCharWrapping;
        descLabel_.textAlignment = NSTextAlignmentLeft;
        descLabel_.font=[UIFont systemFontOfSize:14];
        descLabel_.textColor=[UIColor grayColor];
        descLabel_.backgroundColor=[UIColor clearColor];
        [self addSubview:descLabel_];
    }
    return self;
}

-(void)fillWithData:(NewListModel *)data
{
    NSString* url=nil;
    if(data.picUrls.count>0){
        url=[data.picUrls objectAtIndex:0];
    }
    [logoImg_ setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"newList_defaultPic1"]];
    titleLabel_.text=data.title;
    descLabel_.text=data.desc;
}

-(void)dealloc
{
    logoImg_.image=nil;
}

@end
