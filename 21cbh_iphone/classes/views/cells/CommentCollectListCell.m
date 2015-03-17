//
//  ReplyListCell.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentCollectListCell.h"
#import "CommentInfoModel.h"
#import "NCMConstant.h"
#import "NSString+LineHeight.h"

#define KCommentCollectNameFontSize 10
#define KCommentCollectContentFontSize 15
#define KCommentCollectTitleFontSize 14
#define KCommentCollectNameHeight 20
#define KCommentCollectContentMaxWidth 280
#define KSpace 8

@interface CommentCollectListCell (){


}

@property (nonatomic,assign)  UIView *bgView;
@property (nonatomic,assign)  UILabel *content;
@property (nonatomic,assign)  UILabel *name;
@property (nonatomic,assign)  UILabel *title;

@end

@implementation CommentCollectListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCell];
    }
    self.selectedBackgroundView =[[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xe1e1e1);
    return self;
}


-(void)initCell{
    
    //背景
    UIView *bgView=[[UIView alloc]init];
    bgView.backgroundColor=UIColorFromRGB(0xe1e1e1);
//    bgView.layer.borderColor=KCommentContentBorderColor.CGColor;
//    bgView.layer.borderWidth=1.0;
    self.bgView=bgView;
    //内容
    UILabel *content=[[UILabel alloc]init];
    [content setFont:[UIFont fontWithName:kFontName size:KCommentCollectContentFontSize]];
    [content setNumberOfLines:0];
    [content setTextColor:UIColorFromRGB(0X000000)];
    content.backgroundColor=[UIColor clearColor];
    self.content=content;
    
    //名称
    UILabel *name=[[UILabel alloc]init];
    [name setFont:[UIFont fontWithName:kFontName size:KCommentCollectNameFontSize]];
    [name setTextColor:UIColorFromRGB(0x8d8d8d)];
    name.backgroundColor=[UIColor clearColor];
    self.name=name;
    
    //标题
    UILabel *title=[[UILabel alloc]init];
    [title setFont:[UIFont fontWithName:kFontName size:KCommentCollectTitleFontSize]];
    [title setTextColor:UIColorFromRGB(0X8d8d8d)];
    title.backgroundColor=[UIColor clearColor];
    self.title=title;
    
    [bgView addSubview:content];
    [bgView addSubview:name];
    
    [self.contentView addSubview:bgView];
    [self.contentView addSubview:title];
    
    self.backgroundColor=KBgWitheColor;
}

-(void)setCell:(CommentInfoModel *)nlm{
    
    NSMutableParagraphStyle * myStyle = [[NSMutableParagraphStyle alloc] init];
    [myStyle setLineSpacing:5.0];
    NSDictionary *dict=@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:myStyle};
    NSAttributedString *att=[[NSAttributedString alloc]initWithString:nlm.commentContent attributes:dict];
    
    CGSize size=[nlm.commentContent boundingRectWithSize:CGSizeMake(280, 1000) withTextFont:[UIFont systemFontOfSize:15] withLineSpacing:5];
    
//    self.frame=CGRectMake(0, 0, 320, [self calculateHeightFromText:nlm.commentContent] + 2* KCommentNameHeight+4*KSpace);
    
    
    NSLog(@"size.height=%f",size.height);
    self.frame=CGRectMake(0, 0, 320, size.height+2* KCommentCollectNameHeight+4*KSpace);
    
   
    //标题
    [self.title setText:nlm.commentTitle];
    [self.title setFrame:CGRectMake(KSpace+5, 2*KSpace, KCommentCollectContentMaxWidth, KCommentCollectNameHeight)];
    [self.title setTextAlignment:NSTextAlignmentLeft];
    
    //内容
    [self.content setText:nlm.commentContent];
    [self.content setFrame:CGRectMake(KSpace, KSpace, KCommentCollectContentMaxWidth, size.height)];
    self.content.attributedText=att;
    
    //名称
    [self.name setText:[NSString stringWithFormat:@"%@[%@]",nlm.commentUserNickName,nlm.commentUserLocation]];
    [self.name setFrame:CGRectMake(0-KSpace, self.content.bottom, KCommentCollectContentMaxWidth, KCommentCollectNameHeight)];
    [self.name setTextAlignment:NSTextAlignmentRight];
    

    
    //背景
    [self.bgView setFrame:CGRectMake(KSpace+5, self.title.bottom+5, KCommentCollectContentMaxWidth+10, self.content.frame.size.height+KCommentCollectNameHeight+KSpace)];
    
    
 
}

//-(CGFloat )calculateHeightFromText:(NSString *)str{
//    CGSize size = [str sizeWithFont:KCommentContentFontSize constrainedToSize:CGSizeMake(KCommentContentMaxWidth,MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
//    return size.height;
//    
//}


#pragma mark -前delete推到前面
- (void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *subview in self.subviews) {
        for (UIView *subview2 in subview.subviews) {
            if ([NSStringFromClass([subview2 class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]) { 
                [subview bringSubviewToFront:subview2];
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
