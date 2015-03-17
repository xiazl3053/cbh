//
//  Rmbutton.h
//  21cbh_iphone
//
//  Created by qinghua on 14-8-20.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ERoomMemberModel;
@class Rmbutton;
@protocol RmbuttonDeglegate <NSObject>

-(void)rmbuttonUserClick:(Rmbutton *)view;

@end


@interface Rmbutton : UIView
@property (nonatomic,strong) ERoomMemberModel *member;
@property (nonatomic,assign) id<RmbuttonDeglegate> delegate;
-(void)setViewContentWithRomm:(ERoomMemberModel *)model;
@end
