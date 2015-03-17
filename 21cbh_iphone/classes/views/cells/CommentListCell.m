//
//  CommentListCell.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentListCell.h"
#import "CommentInfoModel.h"
#import "NCMConstant.h"
#import "UIImageView+WebCache.h"
#import "CommentFloorView.h"
#import "NSString+Date.h"

#define KIconHeight 30

@interface CommentListCell (){

}

@property (nonatomic,weak) UIImageView *icon;
@property (nonatomic,weak) UILabel *name;
@property (nonatomic,weak) UILabel *time;
@property (nonatomic,weak) CommentFloorView *follows;
@property (nonatomic,weak) UILabel *content;
@property (nonatomic,weak) UIView *line;
@end

@implementation CommentListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCell];
    }
    return self;
}

#pragma mark - 初始化Cell
-(void)initCell{

    //icon
    UIImageView *icon=[[UIImageView alloc]init];
    icon.frame=CGRectMake(20, 8, 17, KIconHeight-13);
//    [icon.layer setCornerRadius:2.0];
//    [icon.layer setMasksToBounds:YES];
    [self.contentView addSubview:icon];
    _icon=icon;
    
    //名称
    UILabel *name=[[UILabel alloc]init];
    name.frame=CGRectMake(45, 0, 220, KIconHeight);
    name.textColor=KCommentNameColor;
   // name.backgroundColor=[UIColor redColor];
    [name setFont:[UIFont fontWithName:kFontName size:KCommentNameFontSize]];
    [name setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:name];
    _name=name;
    
    
    //时间
    UILabel *time=[[UILabel alloc]init];
    time.frame=CGRectMake(270, 5, 300, KIconHeight);
    // [time setTextAlignment:NSTextAlignmentCenter];
    time.textColor=[UIColor grayColor];
    [time setBackgroundColor:[UIColor clearColor]];
    time.font=[UIFont fontWithName:kFontName size:KCommentNameFontSize];
    [self.contentView addSubview:time];
    _time=time;
    
    
    //follow
    CommentFloorView *follows=[[CommentFloorView alloc]init];
    follows.delegate=self;
    [self.contentView addSubview:follows];
    _follows=follows;
    
    
    
    //内容
    UILabel *content=[[UILabel alloc]init];
    content.textColor=UIColorFromRGB(0x000000);
    content.textAlignment=NSTextAlignmentLeft;
    content.font=[UIFont fontWithName:kFontName size:KCommentContentFontSize];
    content.numberOfLines=0;
    content.lineBreakMode=NSLineBreakByCharWrapping;
    [content setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:content];
    _content=content;
    
    //separateLine
//    UIView *line=[[UIView alloc]init];
//    line.backgroundColor=KCommentTableSeparatorColor;
//    [self.contentView addSubview:line];
//    _line=line;
    self.backgroundColor=KBgWitheColor;



}

#pragma mark - cell高度计算
-(CGFloat)commentListCellRowHeightWith:(CommentInfoModel *)model{

     CGFloat height=[self calculateRowInCellHeight:model];
    
    return height+KCommentNewNameHeight+10;

}

#pragma mark -设置Cell内容
-(void)setCellValue:(CommentInfoModel *)model andIndexPath:(NSIndexPath *)indexPath{
    
//    CGFloat height=[self calculateRowInCellHeight:model];
//    
//    //10额过高度
//    self.frame=CGRectMake(0, 0,300, height+KCommentNewNameHeight+10);
    
    //图像
    [self.icon setImageWithURL:[NSURL URLWithString:model.commentUserHeadUrl] placeholderImage:[UIImage imageNamed:@"NewsComment_UserIconNormal.png"]];
    
    NSLog(@"Name:%@-------icon:%@",model.commentUserNickName,model.commentUserHeadUrl);
    
    //名称
    [self.name setText:[NSString stringWithFormat:@"%@[%@]",model.commentUserNickName,model.commentUserLocation]];
    
    
    //时间
    (indexPath.section==0)?[self.time setText:[NSString stringWithFormat:@"%@ 顶",model.commentTopNum]]:[self.time setText:[NSString compareCurrentTime:model.commentTime]];
    
    //follow
    CGRect rect=CGRectMake(0, KCommentNewNameHeight, KCommentMaxWidth, [self calculateFloorViewInCellHeight:model]);
    
    [self.follows setValueWithNSArray:model.commentFollows isOpenComment:model.isOpenComment andIndexPath:indexPath];
    _follows.delegate=self;
    _follows.frame=rect;
    
    
    //model.commentFollows为空
    if (model.commentFollows.count==0) {
        _follows.frame=CGRectMake(0, KIconHeight, 0, 0);
    }
    //隐藏楼层高度
    if (model.commentFollows.count>KCommentMaxShrink&&!model.isOpenComment) {
        _follows.frame=CGRectMake(0, KCommentNewNameHeight, KCommentMaxWidth, [self calculateHideFloorHeight:model]);
    }
    
    //内容
    self.content.frame=CGRectMake(20, _follows.bottom+3, KCommentMaxWidth, [self calculateContentHeightFromText:model.commentContent]+2);
    [self.content setText:model.commentContent];
    
    //separateline
    self.line.frame=CGRectMake(10, self.frame.size.height-1, 300, 1);


}

#pragma mark - 计算Cell高度
-(CGFloat)calculateRowInCellHeight:(CommentInfoModel *)model{
    CGFloat fHeight=0;
    //无盖楼高度
    if (model.commentFollows.count==0) {
        return fHeight=[self calculateContentHeightFromText:model.commentContent];
    }
    
    //隐藏盖楼高度
    if (model.commentFollows.count>KCommentMaxShrink&&!model.isOpenComment) {
        for (int nIndex=0; nIndex<2; nIndex++) {
            CommentInfoModel *info=[model.commentFollows objectAtIndex:nIndex];
            fHeight=(fHeight+[self calculateFloorContentHeightFromText:info.commentContent]+KCommentNewNameHeight);
            NSLog(@"隐藏盖楼高度内容-------%@",info.commentContent);
            
        }
        //最后一条高度
        CommentInfoModel *info =[model.commentFollows lastObject];
        NSLog(@"隐藏盖楼高度内容最后一条-------%@",info.commentContent);
        CGFloat lastHeight=[self calculateFloorContentHeightFromText:info.commentContent]+KCommentNewNameHeight;
        //主content的高度
        NSLog(@"隐藏盖楼高度内容主信息内容-------%@",model.commentContent);
        CGFloat mainHeight=[self calculateContentHeightFromText:model.commentContent];
        //总高度+按钮高度
        return fHeight=fHeight+lastHeight+mainHeight+44;
    }
    
    
    //盖楼高度
    CGFloat floorHeight =[self calculateFloorViewInCellHeight:model];
    //主content的高度
    CGFloat fContent=[self calculateContentHeightFromText:model.commentContent];
    //总高度
    return fHeight=floorHeight+fContent;
    
}

#pragma mark -隐藏楼层的高度
-(CGFloat)calculateHideFloorHeight:(CommentInfoModel *)model{
    CGFloat fHeight=0;
    for (int nIndex=0; nIndex<2; nIndex++) {
        CommentInfoModel *info=[model.commentFollows objectAtIndex:nIndex];
        //  NSLog(@"info.commentContent===%@",info.commentContent);
        fHeight+=[self calculateFloorContentHeightFromText:info.commentContent]+KCommentNewNameHeight;
    }
    CommentInfoModel *info =[model.commentFollows lastObject];
    //  NSLog(@"info.commentContent===%@",info.commentContent);
    //KCommentNewNameHeight+按钮的高度
    return fHeight+=[self calculateFloorContentHeightFromText:info.commentContent]+74;
    
}

#pragma mark -盖楼高度
-(CGFloat)calculateFloorViewInCellHeight:(CommentInfoModel *)model{
    CGFloat fHeight=0;
    //盖楼高度
    for (CommentInfoModel *obj in model.commentFollows) {
        fHeight=fHeight +[self calculateFloorContentHeightFromText:obj.commentContent]+KCommentNewNameHeight;
    }
    //超过KCommentMaxShrink的floor间距
    int exceedHeight=model.commentFollows.count-KCommentMaxShrink;
    
    //flow间的间隔
    if (exceedHeight >0) {
        exceedHeight=exceedHeight*5;
    }else{
        exceedHeight=0;
    }
    return fHeight+exceedHeight;
}

#pragma mark -每楼层的高度
-(CGFloat )calculateFloorContentHeightFromText:(NSString *)str{
    CGSize size = [str sizeWithFont:[UIFont fontWithName:kFontName size:KCommentContentFontSize] constrainedToSize:CGSizeMake(KCommentContentCalcuMaxWidth,MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    return size.height;
    
}

#pragma mark -主内容的高度
-(CGFloat )calculateContentHeightFromText:(NSString *)str{
    CGSize size = [str sizeWithFont:[UIFont fontWithName:kFontName size:KCommentContentFontSize] constrainedToSize:CGSizeMake(KCommentContentCalcuMaxWidth+20,MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    return size.height;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -显示所有楼层
-(void)userShowAllComment:(NSIndexPath *)indexpath{
    
    [self.delegate userShowAllComment:indexpath];

}

#pragma mark -点击Cell方法
-(void)userSeclectCellInView:(UIGestureRecognizer *)tap andHeight:(float)fHeight{
    [self.delegate userSeclectCellInView:tap andHeight:fHeight];
}
@end
