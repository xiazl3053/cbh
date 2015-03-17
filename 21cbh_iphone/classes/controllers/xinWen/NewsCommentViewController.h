//
//  NewsCommentViewController.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol CommentToolViewProtocol ;
@protocol CommentInCellProtocol;
@protocol MBProgressHUDDelegate ;
@protocol commentViewContorllerDelegate;
@protocol CommentListCellDelegate;
@class CommentThemeModel;



@interface NewsCommentViewController : BaseViewController<CommentToolViewProtocol,CommentInCellProtocol,commentViewContorllerDelegate,CommentListCellDelegate, UITableViewDataSource,UITableViewDelegate>

//评论信息返回
-(void)getCommentInfo:(NSArray *)data andTheme:(CommentThemeModel *)model isSuccess:(BOOL)success;
//点赞信息返回
-(void)getCommmentDingInfo:(NSDictionary *)dic;
//评论回复返回
-(void)getCommmentFollowInfo:(NSDictionary *)dic isSuccess:(BOOL)b;

-(id)initWithProgramId:(NSString *)nProgramID andFollowID:(NSString *)nFollowID;

@end
