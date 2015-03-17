//
//  CommentView.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommentInfoModel;
@protocol CommentViewProtocol <NSObject>
//-(void)userTapCommentView:(UIGestureRecognizer *)tap model:(CommentInfoModel*)infoModel;
-(void)userTapCommentView:(UIGestureRecognizer *)tap tag:(NSInteger)nTag fy:(float)fY height:(float)fHeight;

@end

@class CommentInfoModel;

@interface CommentView : UIView

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *commentName;
@property (nonatomic,strong) UILabel *commentTime;
@property (nonatomic,strong) UILabel *commentContent;
@property (nonatomic,assign) id<CommentViewProtocol> delegate;
@property (nonatomic,assign) int nSection;
@property (nonatomic,assign) int nRow;

-(id)initWithFrame:(CGRect)frame andCommentInfoModel:(CommentInfoModel *)model andAllHeight:(CGFloat)height andIndex:(NSInteger)nIndex andCount:(NSInteger )nCount;

@end
