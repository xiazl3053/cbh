//
//  CommentListCell.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentInCellProtocol;
@class CommentInfoModel;

@protocol CommentListCellDelegate <NSObject>

-(void)userShowAllComment:(NSIndexPath *)indexpath;
-(void)userSeclectCellInView:(UIGestureRecognizer *)tap andHeight:(float)fHeight;

@end

@interface CommentListCell : UITableViewCell<CommentInCellProtocol>
@property (nonatomic,assign) id<CommentListCellDelegate> delegate;

//设置Cell内容
-(void)setCellValue:(CommentInfoModel *)model andIndexPath:(NSIndexPath *)indexPath;

//计算Cell高度
-(CGFloat)commentListCellRowHeightWith:(CommentInfoModel *)model;
@end
