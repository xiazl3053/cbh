//
//  CommentView.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentView.h"
#import "CommentInfoModel.h"
#import "CommentToolView.h"
#import "NCMConstant.h"
#define kSpace 5


@interface CommentView (){
    


}
@property (nonatomic,copy) CommentInfoModel *model;
@property (nonatomic) CGRect rectFrame;
@end

@implementation CommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame andCommentInfoModel:(CommentInfoModel *)model andAllHeight:(CGFloat)height andIndex:(NSInteger)nIndex andCount:(NSInteger)nCount{
    
    _rectFrame = frame;
    
    if (self=[super initWithFrame:frame]) {
        if (nIndex!=0) {
            
           
        }
        
        self.layer.borderWidth=KCommentFloorBorderWidth;
        self.layer.borderColor=KCommentFloorBorderColor.CGColor;
        self.layer.masksToBounds=YES;
        
         self.backgroundColor=KCommentFloorBGColor;
        _model =model;
        //名称
        self.commentName=[[UILabel alloc]init];
        _commentName.frame=CGRectMake(kSpace, height-[self calculateSingleHeightFromCommentContent:model]-30, 280, KCommentFloorNameHeight);
        [_commentName setText:[NSString stringWithFormat:@"%@[%@]",model.commentUserNickName,model.commentUserLocation]];
        _commentName.textColor=KCommentFloorNameColor;
        _commentName.font=[UIFont fontWithName:kFontName size:KCommentFloorNameFontSize];
       // _commentName.backgroundColor=[UIColor redColor];
        _commentName.backgroundColor=[UIColor clearColor];
        
        [self addSubview:_commentName];
        
        //楼层
        UILabel *floor=[[UILabel alloc]init];
        floor.frame=CGRectMake(self.frame.size.width-20, 0, 20, KCommentFloorNameHeight);
        [floor setText:[NSString stringWithFormat:@"%i",nCount-model.number]];
        floor.textColor=KCommentFloorNumberColor;
        floor.font=[UIFont fontWithName:kFontName size:KCommentFloorContentFontSize];
        floor.backgroundColor=[UIColor clearColor];
        [_commentName addSubview:floor];
        
        
        //内容
        self.commentContent=[[UILabel alloc]init];
        _commentContent.text=model.commentContent;
       // _commentContent.backgroundColor=[UIColor blueColor];
        _commentContent.textColor=KCommentFloorContentColor;
        _commentContent.font=[UIFont fontWithName:kFontName size:KCommentFloorContentFontSize];
        _commentContent.frame=CGRectMake(kSpace, height-[self calculateSingleHeightFromCommentContent:model]-5, KCommentContentCalcuMaxWidth-nIndex*kSpace, [self calculateSingleHeightFromCommentContent:model]+2);
        _commentContent.numberOfLines=0;
        _commentContent.lineBreakMode=NSLineBreakByCharWrapping;
        _commentContent.backgroundColor=[UIColor clearColor];
        
        
        if (nIndex>=kMaxFloor) {
            _commentName.frame=CGRectMake(kSpace, 0, KCommentMaxWidth-kSpace*2*kMaxFloor,30);
            _commentContent.frame=CGRectMake(kSpace, 30-kSpace, 270-kSpace*2*kMaxFloor, [self calculateSingleHeightFromCommentContent:model]+2);
        }

        
        //手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userTapView:)];
        tap.numberOfTapsRequired=1;
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:tap];
        
        [self addSubview:_commentContent];
    }

    return self;

}

-(void)userTapView:(UIGestureRecognizer *)tap{
    
    CGPoint point = [tap locationInView:self];
    
//    NSLog(@"contentName.Y:%f",self.commentName.frame.origin.y);
//    NSLog(@"commentView= %f, %f",point.x, point.y);
    
//    NSLog(@"(commentView)self.Name==%f,tap.y=%f",_commentContent.frame.origin.y,point.y);
    
    CommentView *view=(CommentView *)tap.view;
    
    NSLog(@"commentView===%i,row=%i,section=%i",view.tag,view.nRow,view.nSection);

    [self.delegate userTapCommentView:tap tag:self.tag fy:_commentName.frame.origin.y height:point.y];
    

}

-(CGFloat)calculateSingleHeightFromCommentContent:(CommentInfoModel *)model{
    
    CGSize size = [model.commentContent sizeWithFont:[UIFont fontWithName:kFontName size:KCommentFloorContentFontSize] constrainedToSize:CGSizeMake(KCommentContentCalcuMaxWidth,MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    
    return size.height;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.



@end
