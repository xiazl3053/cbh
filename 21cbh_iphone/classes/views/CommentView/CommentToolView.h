//
//  CommentToolView.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-5.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentInfoModel;

@protocol CommentToolViewProtocol <NSObject>

-(void)userSelectToolBarIndex:(UIButton *)btn;

@end

@interface CommentToolView : UIView

@property (nonatomic,assign) id<CommentToolViewProtocol> delegate;

- (id)initWithFrame:(CGRect)frame andCommentInfo:(CommentInfoModel*)info;
-(void)setItemWithIndex:(int)nIdex Title:(NSString *)title andImage:(NSString *)iMage;

@end
