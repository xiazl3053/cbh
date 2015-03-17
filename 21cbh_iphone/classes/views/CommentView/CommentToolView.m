//
//  CommentToolView.m
//  21cbh_iphone
//
//  Created by qinghua on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "CommentToolView.h"
#import "ZXTabbarItem.h"
#import "NCMConstant.h"
#import "CommentToolItem.h"
#import "CommentInfoModel.h"
#import "CommentInfoCollectDB.h"

@implementation CommentToolView


- (id)initWithFrame:(CGRect)frame andCommentInfo:(CommentInfoModel*)info{
    
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *items=[self initializeItem];
        for (int nIndex=0; nIndex<items.count; nIndex++) {
           
                ZXTabbarItem *item=[items objectAtIndex:nIndex];
                item.tag=nIndex+100;
                [item addTarget:self action:@selector(userClickIndex:) forControlEvents:UIControlEventTouchUpInside];
            if (nIndex==0) {
                if (info.isTop) {
                   [item setTitle:@"已顶" forState:UIControlStateNormal];
                    item.userInteractionEnabled=NO;
                }else{
                    [item setTitle:[NSString stringWithFormat:@"%@顶",info.commentTopNum] forState:UIControlStateNormal];
                }
            }
            if (nIndex==3) {
                if ([self queryCommentInfo:info]) {
                    [item setTitle:@"已收藏" forState:UIControlStateNormal];
                    [item  setImage:[UIImage imageNamed:@"NewsComment_AchieveCollect.png"] forState:UIControlStateNormal];
                }
            }
            [self addSubview: item];
            
        }
        self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"NewsComment_ToolBG.png"]];
    }
    return self;
}

-(void)userClickIndex:(UIButton *)btn{
    [self.delegate userSelectToolBarIndex:btn];
    [self removeFromSuperview];
}


-(void)setItemWithIndex:(int)nIdex Title:(NSString *)title andImage:(NSString *)iMage{

    ZXTabbarItem *item=(ZXTabbarItem *)[self viewWithTag:nIdex];
    
    NSLog(@"item====%@",item);
    
    [item setTitle:title forState:UIControlStateNormal];
    
    [item setImage:[UIImage imageNamed:iMage] forState:UIControlStateNormal];


}


-(NSArray *)initializeItem{
    
    ZXTabbarItemDesc *desc=[ZXTabbarItemDesc itemWithTitle:@"顶" normal:@"NewsComment_Top.png" highlighted:nil];
    ZXTabbarItemDesc *desc1=[ZXTabbarItemDesc itemWithTitle:@"回复" normal:@"NewsComment_Reply.png" highlighted:nil];
    ZXTabbarItemDesc *desc2=[ZXTabbarItemDesc itemWithTitle:@"分享" normal:@"NewsComment_rotate.png" highlighted:nil];
    ZXTabbarItemDesc *desc3=[ZXTabbarItemDesc itemWithTitle:@"收藏" normal:@"NewsComment_Collect.png" highlighted:nil];
    ZXTabbarItemDesc *desc4=[ZXTabbarItemDesc itemWithTitle:@"复制" normal:@"NewsComment_Copy.png" highlighted:nil];
    
    NSArray *arr=[NSArray arrayWithObjects:desc,desc1,desc2,desc3,desc4,nil];
    NSMutableArray *items=[NSMutableArray array];
    for (int nIndex=0; nIndex<arr.count; nIndex++) {
        CGRect rect=CGRectMake(300/arr.count*nIndex+5, 10, 300/arr.count-10, 300/arr.count-10);
        CommentToolItem *item=[[CommentToolItem alloc]initWithFrame:rect itemDesc:[arr objectAtIndex:nIndex]];
        [items addObject:item];
    }
    
    return items;
}

-(BOOL)queryCommentInfo:(CommentInfoModel *)info{
    CommentInfoCollectDB *db=[[CommentInfoCollectDB alloc]init];
    BOOL back=[db isExistCim:info];
    NSLog(@"是否收藏＝＝＝%i",back);
    return back;
}

-(void)dealloc{

    NSLog(@"——————————————toolView------dealloc-----");

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
