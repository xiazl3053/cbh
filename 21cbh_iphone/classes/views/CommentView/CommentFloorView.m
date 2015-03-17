//
//  CommentInCell.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentFloorView.h"
#import "CommentView.h"
#import "CommentInfoModel.h"
#import "CommentToolView.h"
#import "NCMConstant.h"
#define kSpece 5
#define kMaxFloor 4

@interface CommentFloorView (){
    
    BOOL _isOpenComment;
    NSIndexPath *_indexPath;

}

@property (nonatomic,strong) CommentToolView *tool;
@property (nonatomic) float nAllCurLength;
@property (nonatomic,copy) NSArray *array;
@end

@implementation CommentFloorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor=[UIColor blueColor];
    }
    return self;
}

-(CGFloat)calculateRowHeightFromCommentContent:(NSArray *)data{
    
    CGFloat height=0;
    
    for (int nIndex=0; nIndex<data.count; nIndex++) {
        
        CommentInfoModel *model=[data objectAtIndex:nIndex];
        
        CGSize size = [model.commentContent sizeWithFont:[UIFont fontWithName:kFontName size:KCommentContentFontSize] constrainedToSize:CGSizeMake(KCommentContentCalcuMaxWidth,MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        
        height=height+size.height;

    }
    return height;
}

-(CGFloat)calculateSingleHeightFromCommentContent:(CommentInfoModel *)model{

    CGSize size = [model.commentContent sizeWithFont:[UIFont fontWithName:kFontName size:KCommentContentFontSize] constrainedToSize:CGSizeMake(KCommentContentCalcuMaxWidth,MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];

    return size.height;
}
//
//-(void)userTapCommentView:(UIGestureRecognizer *)tap model:(CommentInfoModel*)infoModel
//{
//    
//    CGRect rect=[tap.view convertRect:tap.view.frame toView:self];
//    NSLog(@"nAll:%f-height:%f",_nAllCurLength,_nAllCurLength-[self calculateSingleHeightFromCommentContent:infoModel]);
//    CGPoint point = [tap locationInView:self];
//    NSLog(@"点击两下画面坐标位置 %f, %f",point.x, point.y);
//    
//    
//}
-(void)userTapCommentView:(UIGestureRecognizer *)tap tag:(NSInteger)nTag fy:(float)fY height:(float)fHeight
{
    
   // CommentView *view= (CommentView *)tap.view;
    
    //fy label在CellView Y坐标   // 点击在CellView点击Y坐标
    
    float fCurHeight = 0;
    
    CGPoint point = [tap locationInView:self];
    
  //  NSLog(@"commentIncell==点击两下画面坐标位置 %f, %f",point.x, point.y);
    
    
   //  NSLog(@"在Cell的Y==%f,在Cell里面的点击位置=%f",fY,fHeight);
    
    
    
//    if(_array.count <= nTag + 1)
//    {
//        [self.delegate userSeclectCellInView:tap andHeight:point.y-10];
//        return ;
//    }
//    
//    
//    CommentInfoModel *model=[_array objectAtIndex:nTag];
//    fCurHeight = [self calculateSingleHeightFromCommentContent:model];
//    
//    
//    if (_array.count<kMaxFloor)
//    {
//        if(nTag == 0)
//        {
//            fCurHeight -= 30;
//        }
//    }
//    else if(_array.count>=kMaxFloor)
//    {
//        if(nTag<=1)
//        {
//            fCurHeight = fY+kSpece*nTag+2;//这里自己微调一下
//        }
//        else
//        {
//            fCurHeight = fHeight;
//            [self.delegate userSeclectCellInView:tap andHeight:fHeight];
//            return  ;
//        }
//    }
    [self.delegate userSeclectCellInView:tap andHeight:point.y-fCurHeight];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setValueWithNSArray:(NSArray *)arr isOpenComment:(BOOL)b andIndexPath:(NSIndexPath *)indexPath{
    
        _indexPath=indexPath;
        _array = arr;
        CGFloat nAllHeight=0;
        
        _nAllCurLength = nAllHeight;
        
        //hide floor
        if (arr.count>KCommentMaxShrink&&!b) {
            
            NSArray *temp=[NSArray arrayWithObjects:[arr objectAtIndex:0],[arr objectAtIndex:1],[arr objectAtIndex:2],[arr lastObject], nil];
            
            nAllHeight=3*KCommentNewNameHeight+[self calculateRowHeightFromCommentContent:temp]-[self calculateSingleHeightFromCommentContent:[temp objectAtIndex:2]]+44;
            
            //   NSLog(@"nAllHeight=====%f",nAllHeight);
            
            for (int nIndex=0; nIndex<4; nIndex++) {
                
                
                CommentInfoModel *model=[temp objectAtIndex:temp.count-nIndex-1];
                
                CGRect rect=CGRectMake(4*kSpece+kSpece*nIndex, kSpece*nIndex, KCommentMaxWidth-kSpece*nIndex*2, nAllHeight);
                
                //     NSLog(@"rect=====%@",NSStringFromCGRect(rect));
                
                CommentView *view=[[CommentView alloc]initWithFrame:rect andCommentInfoModel:model andAllHeight:nAllHeight andIndex:nIndex andCount:arr.count];
                view.delegate=self;
                view.nRow=indexPath.row;
                view.nSection=indexPath.section;
                view.tag=nIndex;
                if (nIndex==1) {
                    
                    view.commentContent.hidden=YES;
                    view.commentName.hidden=YES;
                    //添加展开按钮
                    UIButton *btn=[[UIButton alloc]init];
                    [btn setTitle:@"展开隐藏楼层" forState:UIControlStateNormal];
                    [btn setTitleColor:KCommentFloorExpandBtnTextColor forState:UIControlStateNormal];
                    [btn setBackgroundColor:[UIColor clearColor]];
                    [btn addTarget:self action:@selector(showAllComment:) forControlEvents:UIControlEventTouchUpInside];
                    btn.frame=CGRectMake(35, view.height-44, 200, 44);
                    [view addSubview:btn];
                    
                    //剩余高度
                    nAllHeight=nAllHeight-44;
                    
                }else{
                    
                    //剩余高度
                    nAllHeight=nAllHeight-[self calculateSingleHeightFromCommentContent:model]-KCommentNewNameHeight;
                    
                }
                [self addSubview:view];
                
            }
        }else{
            
            int count=arr.count-kMaxFloor;
            
            // show all floor
            if (count>0) {
                nAllHeight=arr.count*KCommentNewNameHeight+[self calculateRowHeightFromCommentContent:arr]+count*kSpece;
                
            }else{
                
                nAllHeight=arr.count*KCommentNewNameHeight+[self calculateRowHeightFromCommentContent:arr];
            }
            for (int nIndex=0; nIndex<arr.count; nIndex++) {
                
                CommentInfoModel *model=[arr objectAtIndex:arr.count-nIndex-1];
                
                CGRect rect;
                
                
                if (nIndex<kMaxFloor) {
                    
                    rect=CGRectMake(4*kSpece+kSpece*nIndex,kSpece*nIndex, KCommentMaxWidth-kSpece*nIndex*2, nAllHeight);
                    
                }else{
                    
                    // NSLog(@"magin=%i",nIndex-kMaxFloor);
                    
                    rect=CGRectMake(4*kSpece+kSpece*kMaxFloor, nAllHeight-[self calculateSingleHeightFromCommentContent:model]-kSpece*(nIndex-kMaxFloor)-15, KCommentMaxWidth-kSpece*2*kMaxFloor, [self calculateSingleHeightFromCommentContent:model]+KCommentNewNameHeight);
                }
                    CommentView *view=[[CommentView alloc]initWithFrame:rect andCommentInfoModel:model andAllHeight:nAllHeight andIndex:nIndex andCount:arr.count];
                    view.nRow=indexPath.row;
                    view.nSection=indexPath.section;
                    view.delegate=self;
                    view.tag=nIndex;
                    [self addSubview:view];
                 
                //剩余高度
                nAllHeight=nAllHeight-[self calculateSingleHeightFromCommentContent:model]-KCommentNewNameHeight;
            }
    }
}


-(void)showAllComment:(UIButton *)btn{
  
    [self.delegate userShowAllComment:_indexPath];


}

@end
