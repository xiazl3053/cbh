//
//  CommentInCell.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-4.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentToolView.h"
@protocol CommentInCellProtocol <NSObject>

-(void)userShowAllComment:(NSIndexPath *)indexpath;

-(void)userSeclectCellInView:(UIGestureRecognizer *)tap andHeight:(float)fHeight;
@end

@protocol CommentViewProtocol;

@interface CommentFloorView : UIView<CommentViewProtocol>

@property (nonatomic,assign) id<CommentInCellProtocol> delegate;

-(id)initWithNSArray:(NSArray *)arr;


-(id)initWithNSArray:(NSArray *)arr isOpenComment:(BOOL)b andIndexPath:(NSIndexPath*)indexPath;


-(void)setValueWithNSArray:(NSArray *)arr isOpenComment:(BOOL)b andIndexPath:(NSIndexPath *)indexPath;

@end
