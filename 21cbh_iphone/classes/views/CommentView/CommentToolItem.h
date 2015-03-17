//
//  CommentToolViewItem.h
//  21cbh_iphone
//
//  Created by qinghua on 14-3-6.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZXTabbarItemDesc;

@protocol CommentToolViewProtocol <NSObject>

-(void)userSelectIndex:(UIButton *)btn;

@end


@interface CommentToolItem : UIButton

- (id)initWithFrame:(CGRect)frame itemDesc:(ZXTabbarItemDesc *)desc ;

@end
